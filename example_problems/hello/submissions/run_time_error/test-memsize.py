<<<<<<< HEAD
'''
@EXPECTED_RESULTS@: RUN-ERROR
'''
storage = []

while True:
    some_str = ' ' * bytearray(512000000)
    storage.append(some_str)
=======
'''
@EXPECTED_RESULTS@: RUN-ERROR
'''
storage = []

while True:
    some_str = ' ' * bytearray(512000000)
    storage.append(some_str)
>>>>>>> 0c6114514 (Add some extra test files)
