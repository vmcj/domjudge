#!/usr/bin/env python3
# Invoke as:
# .github/jobs/compare_problem_package.py "$PROBLEM" "$STATE"

import sys
import os
import hashlib

problem = sys.argv[1]
state = sys.argv[2]

all_files_left = []
all_files_right = []

dirL = ''
dirR = ''

error = 0

def get_full_file(root: str, dirs: list, files: list) -> str:
    res = []
    croot = root[:]
    for p in [dirL, dirR]:
        croot = croot.replace(f"{p}/", '')
        croot = croot.replace(f"{p}", '')
    for f in files:
        # Ignore some languages we never submit
        skip = False
        for extension in ['pas','js','json','sh','hs','p','ml','lua','plg','R','mjs','kt','cs','pp','adb','rb','swift','awk','f95','pl','bash','rs']:
            extension = '.'+extension
            if extension in f[(len(extension)*-1):]:
                skip = True
                break
        if skip:
            continue
        if len(croot) == 0:
            res.append(f)
        else:
            res.append(f"{croot}/{f}")
    for d in dirs:
        if d in ['check_manually', 'multiple', 'bogus-filename', 'output_validators']:
            continue
        nroot, ndirs, nfiles = next(os.walk(f"{root}/{d}"))
        res += get_full_file(nroot, ndirs, nfiles)
    return res

def compare_problem_zip(dirL: str, dirR: str) -> None:
    global error
    (root, dirs, files) = next(os.walk(dirL))
    for f in get_full_file(root, dirs, files):
        all_files_left.append(f)
    (root, dirs, files) = next(os.walk(dirR))
    for f in get_full_file(root, dirs, files):
        all_files_right.append(f)
    differenceL = set(all_files_left)-set(all_files_right)
    differenceR = set(all_files_right)-set(all_files_left)

    # Ignore those files for now, they are not really in the spec (yet)
    ignore_files = ['.timelimit', 'domjudge-problem.ini']
    differenceL = differenceL-set(ignore_files)
    differenceR = differenceR-set(ignore_files)

    # If things get renamed assume the same number of files.
    if len(differenceL)-len(differenceR) != 0:
        print("Different number of files in zips.")
    for difference in differenceL.union(differenceR):
        # We know submission names get lost during import
        if 'submissions' in difference:
            continue
        elif 'output_validators' in difference:
            continue
        print(f"Found lost file: {difference}.")
    output_validatorsL = {}
    output_validatorsR = {}
    for validator in differenceL:
        if 'output_validators' not in validator:
            continue
        tmp = validator.split('/')
        file = '/'.join(tmp[2:])
        new_hash = None
        with open(f"{dirL}/{validator}", 'rb', buffering=0) as f:
            new_hash = hashlib.file_digest(f, 'sha512').hexdigest()
        try:
            output_validatorsL[tmp[1]].append({'n': file, 'h': new_hash})
        except KeyError:
            output_validatorsL[tmp[1]] = [{'n': file, 'h': new_hash}]
    for validator in differenceR:
        if 'output_validators' not in validator:
            continue
        tmp = validator.split('/')
        file = '/'.join(tmp[2:])
        new_hash = None
        with open(f"{dirR}/{validator}", 'rb', buffering=0) as f:
            new_hash = hashlib.file_digest(f, 'sha512').hexdigest()
        try:
            output_validatorsR[tmp[1]].append({'n': file, 'h': new_hash})
        except KeyError:
            output_validatorsR[tmp[1]] = [{'n': file, 'h': new_hash}]
    # Now compare that the same files are in the same solution folder
    for oval in output_validatorsL:
        missing = True
        try:
            for oval2 in output_validatorsR:
                if oval['h'] == oval2['h']:
                    missing = False
                    break
        except KeyError:
            continue
        if missing:
            print(f"Lost {oval['n']}.")
            error += 1
    submissionsL = {}
    submissionsR = {}
    for submission in differenceL:
        if 'submissions' not in submission:
            continue
        tmp = submission.split('/')
        file = '/'.join(tmp[2:])
        new_hash = None
        with open(f"{dirL}/{submission}", 'rb', buffering=0) as f:
            new_hash = hashlib.file_digest(f, 'sha512').hexdigest()
        try:
            submissionsL[tmp[1]].append({'n': file, 'h': new_hash})
        except KeyError:
            submissionsL[tmp[1]] = [{'n': file, 'h': new_hash}]
    for submission in differenceR:
        if 'submissions' not in submission:
            continue
        tmp = submission.split('/')
        file = '/'.join(tmp[2:])
        new_hash = None
        with open(f"{dirR}/{submission}", 'rb', buffering=0) as f:
            new_hash = hashlib.file_digest(f, 'sha512').hexdigest()
        try:
            submissionsR[tmp[1]].append({'n': file, 'h': new_hash})
        except KeyError:
            submissionsR[tmp[1]] = [{'n': file, 'h': new_hash}]
    # Now compare that the same files are in the same solution folder
    for verdict in submissionsL:
        for sol in submissionsL[verdict]:
            missing = True
            try_verdicts = [verdict]
            if verdict in ['check_manually', 'multiple']:
                try_verdicts = submissionsR.keys()
            for verdict2 in try_verdicts:
                try:
                    for sol2 in submissionsR[verdict2]:
                        if sol['h'] == sol2['h']:
                            missing = False
                            break
                except KeyError:
                    continue
            if missing:
                print(f"Lost {sol['n']}.")
                error += 1
    exit(error)

if state == "original":
    dirL = f"./example_problems/{problem}"
    dirR = f"./{state}zips"
elif state == "reimport":
    dirL = "./initialzips"
    dirR = "./reimportzips"
else:
    print(f"Unknown option: {state}.")
    exit(1)
compare_problem_zip(dirL, dirR)

