#!/bin/bash
###
 # @Author: elenno elenno.chen@gmail.com
 # @Date: 2024-08-14 23:06:11
 # @LastEditors: elenno elenno.chen@gmail.com
 # @LastEditTime: 2024-08-15 00:14:01
 # @FilePath: \MySkynetServer\sprotodump.sh
 # @Description: 这是默认设置,请设置`customMade`, 打开koroFileHeader查看配置 进行设置: https://github.com/OBKoro1/koro1FileHeader/wiki/%E9%85%8D%E7%BD%AE
### 

# 将相对路径转换为绝对路径
sprotodump_dir=$(realpath "./3rd/sprotodump/")
sproto_dir=$(realpath "./proto/sproto/")
spb_dir=$(realpath "./proto/spb/")
spb_file="$spb_dir/proto.spb"

sproto_files=$(find "$sproto_dir" -type f -name "*.sproto")

cur_dur=$(realpath "./")
cd $sprotodump_dir
lua sprotodump.lua -spb $sproto_files -o $spb_file
cd $cur_dur