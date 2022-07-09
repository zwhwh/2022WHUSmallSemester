#!/bin/bash
if [ "$1" == "" -o "$2" == "" ]; then
    echo "usage: $0 stu_id stu_name"
    exit
fi

repo_addr="https://se.jisuanke.com/whu-summer-course-2022/303.git"

class_id="303"

if [ ! -d $class_id ]; then
    git clone $repo_addr &>/dev/null
    cd ./$class_id
else
    cd ./$class_id
    git pull &>/dev/null
fi

stu_id="$1"
name="$2"

git checkout -f $stu_id$name &>/dev/null
if [ $? != 0 ]; then
    echo "签到失败:缺少分支"$stu_id$name
    exit
fi

if [ ! -f "../check_code.txt" ]; then
    echo "缺少密码文件 check_code.txt"
    exit
fi
mydate="2022-07-06"
for line in `cat ../check_code.txt`
do
    if [ `date -d$mydate +%w` -eq 0 ]; then
        mydate=`date -d"$mydate 1 days" "+%Y-%m-%d"`
    fi
    if [ ! -f $mydate ]; then
        echo $mydate"签到失败，无签到文件"
        mydate=`date -d"$mydate 1 days" "+%Y-%m-%d"`
        continue
    fi
    combined=$stu_id$line$class_id 
    md5val=`echo $combined | md5sum | tr -cd "^[0-9a-z]"`
    md5val1=`echo -n $combined | md5sum | tr -cd "^[0-9a-z]"`
    md5read=$(cat $mydate | xargs)
    if [ "$md5val" == "$md5read" -o "$md5val1" == "$md5read" ]; then
        echo $mydate"签到成功"
    else
        echo $mydate"签到失败，md5不匹配 " 
        echo "md5read:"$md5read
        echo "md5val:"$md5val
        echo "md5val1:"$md5val1
    fi
    mydate=`date -d"$mydate 1 days" "+%Y-%m-%d"`
done
