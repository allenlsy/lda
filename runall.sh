#!/bin/bash

for ((fold=1;fold<=5;fold++))
do
    for ((shrink=2;shrink<=4;shrink++))
    do
        for ((k=1;k<=10;k++)) 
        do 
            octave3.2 -q main.m $k $fold $shrink    
        done
        rm imageDb.data faceDb.data PCAMtx.data
    done
done
