/*
 * This should give CORRECT on the default problem 'hello'.
 * This only uses another way of printing.
 *
 * @EXPECTED_RESULTS@: CORRECT
 */

import java.io.*;

class Main {
    public static void main(String[] args) throws IOException {
        OutputStreamWriter streamWriter = new OutputStreamWriter(System.out);
        streamWriter.write("Hello world!\n");
        streamWriter.flush();
    }
}
