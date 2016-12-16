#!/bin/bash
# this shell script automates the restarting process 
truncate -s 0 log.txt

line1="$(grep -n "Iteration" pw7.restart_dn.s1 | cut -d: -f1)"
line2="$(grep -n "E VAL" pw7.restart_dn.s1 | cut -d: -f1)"
read -a array1 <<< $line1; read -a array2 <<< $line2; 

echo "Please Specify Which Iteration You Would Like to Use"
read ITER  
echo "OK. We Will Do Iteration Number $ITER"
# -1 for restarting from iteration 2, another -1 from index counting from 0
let  ITER-=2

let line1=${array1[$ITER]}+1
let line2=${array2[$ITER]}-1
let lined=($line2-$line1+1)*2

echo "Total $lined Lines To Be Copied"

sed "$line1,$line2"'!d' pw7.restart_dn.s1 >> log.txt
sed "$line1,$line2"'!d' pw7.restart_up.s1 >> log.txt
NUMOFLINES=$(wc -l < "log.txt")

if [ $lined -eq $NUMOFLINES ]
then
 echo "Copied Correctly"
else
 echo "Copied Wrong"
fi

# caution: difference betwen > (overwrite) and >> (append)
cat log.txt >> pw7s.input
line="$(grep -n "FRAC=3" pw7s.input | cut -d: -f1)" 

if [ $line -gt 0 ] 
then
sed -i "$line"'d' pw7s.input
sed -i "$line"'a &ITR NITER=30,FRAC=2,29*0.16d0 &END' pw7s.input
fi

