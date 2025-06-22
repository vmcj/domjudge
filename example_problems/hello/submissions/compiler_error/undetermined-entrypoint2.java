/*
 * This should give CORRECT on the default problem 'hello'.
 * It becomes COMPILER-ERROR as we can't determine what is the
 * correct class (although either would be fine)
 *
 * If we shadow and use the provided entrypoint it would be CORRECT.
 *
 * @EXPECTED_RESULTS@: COMPILER-ERROR
 */

import java.io.*;

class Main {
    public static void main(String[] arguments) {
	System.out.print("Hello world!\n");
    }
}

class MainAlternative {
    public static void main(String[] arguments) {
	Main.main(arguments);
    }
}

