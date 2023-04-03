#!/bin/bash
path="/home/deq"
path1="/home/deq/Bash"
path2="/home/deq/Terraform"

if [ -e $path/$1 ]
then 
    echo " File present in $path"
elif [ -e $path1/$1 ]
then
    echo " File present in $path1"
elif [ -e $path2/$1 ]
then
    echo " File present in $path2"
else
    echo " File not present!"
fi