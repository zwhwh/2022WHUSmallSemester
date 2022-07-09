#!/bin/bash

#config:
repo_addr="https://se.jisuanke.com/whu-summer-course-2022/303"
repo_name="303"
class_id="303"
id_file="../303.txt"
pass_file="../pass.txt"



function check(){
    stu_id="$1"
    stu_name="$2"
    if [ "$stu_name" != "" ]; then
        branch_name=$stu_id$stu_name
        git checkout $branch_name &> /dev/null
        if [ $? != 0 ]; then
            echo "$stu_id: 缺少分支"
            return
        fi
    else
        branch_name=`git branch | grep $stu_id`
        if [ "$branch_name" == "" ]; then
            echo "$stu_id: 缺少分支"
            return
        fi
        git checkout $branch_name &> /dev/null
        if [ $? != 0 ]; then
	 # echo "$branch_name"
            echo "$stu_id: 分支过多，需手动检查"
            return
        fi
    fi
    # echo "----$stu_id----" #debug info

   mydate="2022-07-09"
   for line in `cat ../pass.txt`
    do
    if [ `date -d$mydate +%w` -eq 0 ]; then
        mydate=`date -d"$mydate 1 days" "+%Y-%m-%d"`
    fi
    if [ ! -f $mydate ]; then
        echo "$stu_id:"$mydate"签到失败，无签到文件"
        mydate=`date -d"$mydate 1 days" "+%Y-%m-%d"`
        continue
    fi
    combined=$stu_id$line$class_id 
    md5val=`echo $combined | md5sum | tr -cd "^[0-9a-z]"`
    md5val1=`echo -n $combined | md5sum | tr -cd "^[0-9a-z]"`
    md5read=$(cat $mydate | xargs)
    if [ "$md5val" == "$md5read" -o "$md5val1" == "$md5read" ]; then
        echo "$stu_id:"$mydate"签到成功"
    else
        echo "$stu_id:"$mydate"签到失败，md5不匹配 " 
        echo "提交的md5:"$md5read
        echo "答案1 md5:"$md5val
        echo "答案2 md5:"$md5val1
    fi
    mydate=`date -d"$mydate 1 days" "+%Y-%m-%d"`
done
}

# pull or clone from remote repo:
if [ ! -d $repo_name ]; then
    git clone $repo_addr &>/dev/null
    cd ./$repo_name
    if [ "$1" == "all" ]; then
        git branch -r | grep -v '\->' | 
        while read remote
        do
            git branch --track "${remote#origin/}" "$remote"
        done
        git fetch --all &>/dev/null
        git pull --all &>/dev/null
    fi
else
    cd ./$repo_name
    if [ "$1" == "all" ]; then
        git branch -r | grep -v '\->' | 
        while read remote
        do
            git branch --track "${remote#origin/}" "$remote"
        done
        git fetch --all &>/dev/null
    fi
    git pull --all &>/dev/null
fi

if [ ! -f $pass_file ]; then
    echo "缺少密码文件"
    exit
fi


#judge:
if [ "$1" == "all" ]; then
    if [ ! -f $id_file ]; then
        echo "缺少学号文件"
        exit
    fi
    for line in `cat $id_file`
    do
        check $line
    done
elif [[ "$1" =~ [0-9] ]]; then
    if [ "$2" != "" ]; then
        check $1 $2
    else
        check $1
    fi
else
    echo "usage: ./check.sh [student_id student_name | all]"
fi