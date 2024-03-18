#!/bin/bash

# Program to run my other four programs

echo -e "Give me a number for the countdown program"
read NUMBER

./questionnaire.sh
./countdown.sh $NUMBER
./bingo.sh
./fortune.sh