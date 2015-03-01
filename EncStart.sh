#!bin/bash

#Authors: Giorgos  Papoutsis
#         Katerina Spiropoulou


######### Comments ######
# ./src/    		: source codes
# ./testsets 	: test data
# …………………………….

#main arguments for  read and write txt files location
arg1=./vga.lcd.trans.tmax_enc.txt
arg2=./vga.lcd.trans.tmax_pat.txt

## Generate Executables ###
#gcc ./src/[filename].c -o [filename].exe
gcc ./src/ATE_Pattern_Repeat.c -o  ATErunnable

#……………

## Running programs ###
./src/ATErunnable.out $arg1 $arg2   > ./program1.log

#……………….

## Hardware Measurements ###
#dc_shell -xg-t -f run.tcl | tee synth.log





