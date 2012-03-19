#!/bin/bash

for ((fold=1;fold<=5;fold++))
do
    for ((shrink=1;shrink<=4;shrink++))
    do
        for ((k=1;k<=10;k++)) 
        do 
            octave3.2 -q main.m $k $fold $shrink    
            rm imageDb.data
        done
    done
done
