#!/bin/bash

#项目配置
project=
jenkinsi_project=
produce_git_branch=

for i in $@
do
  tempP=`echo $i | awk -F '-p=' '{print $2}'`
  tempJ=`echo $i | awk -F '-j=' '{print $2}'`
  tempB=`echo $i | awk -F '-b=' '{print $2}'`
  if [[ ${tempP} != "" ]]; then
     project=${tempP}
  fi
  if [[ ${tempJ} != "" ]]; then
     jenkins_project=${tempJ}
  fi
  if [[ ${tempB} != "" ]]; then
     produce_git_branch=${tempB}
  fi
done

if [[ ${project} == "" ]]; then
  echo "-p[项目]参数必须, like -p=project"
  exit
fi

if [[ ${jenkins_project} == "" ]]; then
  echo "-j[jenkins项目]参数必须, like -j=jenkins_project"
  exit
fi

if [[ ${produce_git_branch} == "" ]]; then
  echo "-b[项目分支]参数必须, like -b=branch"
  exit
fi

jenkins_url="http://jenkins.imcoming.cn/job/"${jenkins_project}"/"

#获取最后一次构建版本
last_build_version=`curl ${jenkins_url} -H 'Authorization: Basic eWFuZ2Z1eWk6QUxZMTIzYWx5' 2>/dev/null | grep -o -E 'Last build \(#[0-9]*' | awk -F# '{print $2}'` 

echo "最后一次构建版本："${last_build_version}

#获取最后一次构建git代码库版本
git_versions=`curl ${jenkins_url}${last_build_version}/ -H 'Authorization: Basic eWFuZ2Z1eWk6QUxZMTIzYWx5' 2>/dev/null | grep -o -E 'Revision</b>: [0-9a-zA-Z]*' | awk -F ' ' '{print $2}'`
last_build_git_version=`echo ${git_versions} | awk -F ' ' '{print $2}'`

echo "最后一次构建git代码库版本："${last_build_git_version}

#获取项目最新git代码库版本
cd ${project}
git checkout ${produce_git_branch} 2>/dev/null
git pull 2>/dev/null
latest_git_version=`git rev-parse Head`

echo ${produce_git_branch}"分支最新版本："${latest_git_version}

#比较两版本代码差异
echo "版本代码差异如下："
if 
 [ ${last_build_git_version} == ${latest_git_version} ]; then
  echo "版本一致！！！"
else
  git diff ${last_build_git_version} ${latest_git_version}
fi
