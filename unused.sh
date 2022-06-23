#!/bin/bash
# 获取单个文件的大小，单位Byte
function getFileSize(){
    file_name=$1
    file_size=0
    # 文件存在，则获取文件大小
    if [ -f ${file_name} ]; then
        file_size=`wc -c ${file_name} | awk '{print $1}'`
    fi
    echo ${file_size}
    return 0
}

# 获取文件大小的显示文本，如8.8MB
function getSizeText(){
    size_Bytes=$1
    size_text="0KB"
    if [ $size_Bytes -lt 1024 ]
    then
        size_text="${size_Bytes}B"
    elif [ $size_Bytes -lt `expr 1024 \* 1024` ]
    then
        # 保留3位小数
        size_text="`echo "scale=3; ${size_Bytes} / 1024" | bc`KB"
    elif [ ${size_Bytes} -lt `expr 1024 \* 1024 \* 1024` ]
    then
        unit_MB=`expr 1024 \* 1024`
        size_text="`echo "scale=3; ${size_Bytes} / ${unit_MB}" | bc`MB"
    else
        unit_GB=`expr 1024 \* 1024 \* 1024`
        size_text="`echo "scale=3; ${size_Bytes} / ${unit_GB}" | bc`GB"
    fi

    echo ${size_text}
    return 0
}

echo "Searching unused files. This may take a while..."

target_path="`pwd`/assets"
# echo "target_path:${target_path}";
unused_files=()
unused_files_size=0
for file in `find ${target_path} \( -iname "*.webp" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \) -type f `;
do
    fileName="$(basename ${file})"
    # echo $fileName
    # -q: --quiet
    grep -rn -F -q "${fileName}" lib/
    # $? 显示最后命令的退出状态。0表示没有错误。
    if [ $? -ne 0 ]
    then
        file_size=$(getFileSize ${file})
        unused_files_size=`expr ${unused_files_size} + ${file_size}`
        unused_files+=(${file})
        echo "Unused file: ${file}"
        rm -rf ${file}
    fi
done
# echo "======unused_files_size:${unused_files_size}"
unused_count=${#unused_files[@]}
unused_size_text=$(getSizeText ${unused_files_size})
echo "${unused_count} unused files are found. Total size: ${unused_size_text}."
