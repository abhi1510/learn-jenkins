#!/bin/bash

FNAME=$1
LNAME=$2
SHOW=$3

if $SHOW; then
    echo "Hello $FNAME $LNAME"
else
    echo "Mark SHOW flag as try if you want to see the name"
fi
