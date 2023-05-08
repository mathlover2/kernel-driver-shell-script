#!/usr/bin/zsh

# Run this program in the directory containing the disassembled files
# to be analyzed. This assumes benign samples are located in a
# subdirectory `Benign` and malicious samples are located in a
# subdirectory titled `Malicious`. GNU coreutils should also be
# installed.

# This program should be run after installing the C5 classifier, which
# can be downloaded at https://rulequest.com/download.html.

# This value should be set to the actual location of the feature
# extractor. 

REPORT=report.py

# This should be set to the location of the C5 installation. If C5 is
# findable via the path, this need not be changed.

C5=c5.0

# Create benign and malicious report files

cd Benign
for i in *.asm
do echo "Working on: $i"
   python3 $REPORT $i > ${i:r}_report
done

cd ../Malicious
for i in *.asm
do echo "Working on: $i"
   python3 $REPORT $i > ${i:r}_report
done

# Create data files. These contain the report file contents, but in
# random order.

{ for i in Malicious/*_report
  do paste $i =(echo -n ", malware.")
  done } | shuf  >> malware.txt

{ for i in Benign/*_report
  do paste $i =(echo -n ", benign.")
  done } | shuf  >> benign.txt

# Create data file
{head -n 200 benign.txt ; head -n 200 malware.txt } > data.data

# Create names file
echo "malware, benign." > data.names
for i in {1..41}
do echo "A$i: continuous" >> data.names
done

# Create test file
{tail -n +200 benign.txt
 tail -n +200 malware.txt } > data.test

$C5 -f data > results
