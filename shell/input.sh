#!/bin/bash
while read line 
do
      echo "line: $line"
        cat
done <<EOF
foo
bar
zot
EOF
