/*
 * The main function has a very specific function signature for the 
 * JVM to pick it up.
 *
 * This submission mimics: compiler_error/wrong-string.java together
 * with accepted/correct-string.java.
 *
 * @EXPECTED_RESULTS@: CORRECT
 */

import java.io.*;

class CorrectString {
}

class Main {
    public static void main(String[] arguments) {
	System.out.print("Hello world!\n");
    }
}
