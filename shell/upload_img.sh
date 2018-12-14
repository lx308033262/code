#!/bin/bash
pic_dir=
cd $pic_dir
for file in *
do
    echo $file
    curl --data-binary  @./$file http://img.moscoper.com/v1/tfs
done
