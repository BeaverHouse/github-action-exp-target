#!/bin/bash

# UTF-8 Encoding
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# Default Value
VALUES_FILES=${VALUES_FILES:-"values.yaml"}
IMAGES=${IMAGES:-"[]"}

# Print Usage Function
print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -i, --images    JSON 형식의 이미지 목록 '[{\"name\": \"이미지1\", \"tag\": \"태그1\"}]'"
    echo "  -f, --files     업데이트할 values 파일들 (쉼표로 구분)"
    echo "  -h, --help      도움말 출력"
}

# Parse Command Line Arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -i|--images)
            IMAGES="$2"
            shift 2
            ;;
        -f|--files)
            VALUES_FILES="$2"
            shift 2
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            echo "알 수 없는 옵션: $1"
            print_usage
            exit 1
            ;;
    esac
done

# Convert values file list to array
IFS=',' read -ra VALUES_FILES_ARRAY <<< "$VALUES_FILES"

# Process each values file
for values_file in "${VALUES_FILES_ARRAY[@]}"; do
    # Delete leading slash if exists
    values_file="${values_file#/}"
    
    if [ ! -f "$values_file" ]; then
        echo "경고: $values_file 파일이 존재하지 않습니다."
        continue
    fi
    
    # Process each image for this file
    echo "$IMAGES" | jq -c '.[]' | while read -r image; do
        name=$(echo "$image" | jq -r '.name')
        tag=$(echo "$image" | jq -r '.tag')
        
        if [ -z "$name" ]; then
            echo "이미지 이름이 없는 항목이 있습니다. 해당 항목을 건너뜁니다."
            continue
        fi
        
        # Check if the component exists
        if yq -e ".$name" "$values_file" > /dev/null 2>&1; then
            printf "파일 %s에서 이미지 %s의 태그를 %s로 업데이트합니다.\n" "$values_file" "$name" "$tag"
            # Update the tag
            yq --inplace --prettyPrint ".$name.image.tag = \"$tag\"" "$PWD/$values_file"
        else
            printf "경고: %s 파일에서 %s 컴포넌트를 찾을 수 없습니다.\n" "$values_file" "$name"
        fi
    done
    
    # Add blank lines between sections
    awk '
        /^[a-zA-Z]/ { if (NR!=1) print ""; print; next }
        { print }
    ' "$values_file" > "${values_file}.tmp" && mv "${values_file}.tmp" "$values_file"
done 