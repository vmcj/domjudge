<<<<<<< HEAD
'''
This should fail with TIMELIMIT as the program is left running.
This tests that a currently correct output does not lead to a CORRECT.

@EXPECTED_RESULTS@: TIMELIMIT
'''

import time

print("Hello world!")
while True:
    time.sleep(60*60*24)
=======
'''
This should fail with TIMELIMIT as the program is left running.
This tests that a currently correct output does not lead to a CORRECT.

@EXPECTED_RESULTS@: TIMELIMIT
'''

import time

print("Hello world!")
while True:
    time.sleep(60*60*24)
>>>>>>> 0c6114514 (Add some extra test files)
