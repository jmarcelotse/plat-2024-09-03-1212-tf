#!/bin/bash

RESULT_DIR=${PWD##*/}

eval "cat <<< \"$(cat)\"" 2> /dev/null