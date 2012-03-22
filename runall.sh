#!/bin/bash

for ((fold=1;fold<=5;fold++))
do
    for ((shrink=6;shrink>=2;shrink--))
    do
        for ((k=1;k<=10;k++)) 
        do
            for sh in 0.9 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 1
            do
                for ((time=1;time<=10;time++))
                do
                    echo 'time ' $time
                    echo
                    octave3.2 -q main.m $k $fold $shrink $sh
                done
            done
        done
        rm *.data
    done
done
