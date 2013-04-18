#!/bin/bash

if [ $# == 0 ]
then
  echo "$0: Illegal params. Please specify the input file."
  exit 1
fi

pwdir="$(pwd)"
srcfile="${!#}"
outfile="${srcfile%.*}"
upcfile="$outfile.upc"

while getopts "n:" arg #选项后面的冒号表示该选项需要参数
do
  case $arg in
    n)
      threads=$OPTARG #参数存在$OPTARG中
      ;;
    ?)  #当有不认识的选项的时候arg为?
      echo "unkonw argument"
      exit 1
      ;;
  esac
done

echo "pwd = $pwdir"
echo "srcfile= $srcfile"
echo "upcfile= $upcfile"
echo "outfile= $outfile"
echo "threads= $threads"

cmdCreate="cp $srcfile $upcfile"
cmdCompile="upc -o $outfile -fupc-threads-$threads $upcfile"

echo "Createing UPCfile... \`$upcfile\`"
$($cmdCreate)
echo "Executing compiling... \`$cmdCompile\`"
$($cmdCompile)
