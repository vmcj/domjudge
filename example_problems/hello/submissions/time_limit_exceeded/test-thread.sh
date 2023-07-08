#!/bin/bash

# See: https://codegolf.stackexchange.com/a/24488
# Eat up kernel memory

open_stdinput(){
    open_stdinput <(open_stdinput)
}
open_stdinput
