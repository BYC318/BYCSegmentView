#!/bin/bash
set -e

CommitInfo=$1
if [ "$CommitInfo" = "" ]
then
    echo "请输入修改的信息"
    read CommitInfo
    while([[ "$CommitInfo" = "" ]])
    do
    echo "请输入修改的信息"
    read CommitInfo
done
fi

#得到版本号自增后的版本号：例如0.1.0--->0.1.1
increment_version ()
{
  declare -a part=( ${1//\./ } )
  declare    new
  declare -i carry=1

  for (( CNTR=${#part[@]}-1; CNTR>=0; CNTR-=1 )); do
    len=${#part[CNTR]}
    new=$((part[CNTR]+carry))
    [ ${#new} -gt $len ] && carry=1 || carry=0
    [ $CNTR -gt 0 ] && part[CNTR]=${new: -len} || part[CNTR]=${new}
  done
  new="${part[*]}"
  
  NewVersionNumber=${new// /.}
} 

pod lib lint BYCSegmentView.podspec --allow-warnings
# pod spec lint BYCSegmentView.podspec --allow-warnings
set +e

# 如果是新建的仓库（ repositories ）的话在pull代码的时候，出现这个提示，可以忽略不计，直接提交就可以。所以出错推出命令不能包含这个指令
git stash
git pull origin master --tags
git stash pop

set -e
#从文件BYCSegmentView.podspec中得到版本所在行的信息也就是  s.version          = '0.1.0' 信息
VersionString=`grep -E 's.version.*=' BYCSegmentView.podspec`
#从VersionString 中把行号提取出来 此时VersionNumber=010
VersionNumber=`tr -cd 0-9 <<<"$VersionString"`
#新版本号
NewVersionNumber=""
#新版本号NewVersionNumber进过for循环之后
for ((i=0;$i<${#VersionNumber};i=$i+1));
do 
	NewVersionNumber=$NewVersionNumber${VersionNumber:$i:1}"."
    echo $NewVersionNumber;
done
#得到OldVersionNumber旧版本号0.1.0
OldVersionNumber=${NewVersionNumber: 0:${#NewVersionNumber}-1}
#把OldVersionNumber做为参数传给increment_version函数
#increment_version函数内部最后是直接给NewVersionNumber赋值的，此时NewVersionNumber是OldVersionNumber自增后的值也就是：0.1.1
increment_version $OldVersionNumber
# 获取s.version对应的行号
#（目前好像没有用到了，废弃了，因为直接根据行号替换对应行的文本信息的命令，
# 老报错command c expects \ followed by text）虽然升级了用gsed，但是不想改回来
LineNumber=`grep -nE 's.version.*=' BYCSegmentView.podspec | cut -d : -f1`
# 在BYCSegmentView.podspec文本中找到OldVersionNumber信息替换成NewVersionNumber信息
sed -i "" "s/$OldVersionNumber/$NewVersionNumber/g" BYCSegmentView.podspec

echo "旧标签${OldVersionNumber}, 新标签：${NewVersionNumber}"

git add .
git commit -am "${CommitInfo}"
git tag ${NewVersionNumber}
git push origin master --tags
pod trunk push BYCSegmentView.podspec --verbose --allow-warnings --use-libraries

set +e
