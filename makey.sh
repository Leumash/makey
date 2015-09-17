#!/usr/bin/bash

function usage()
{
    echo "Running the script $(basename $0) will look in the current directory for a valid filename with a proper extension. It will then compile and execute the script."
}

function ParseArguments
{
    while getopts ":h" arg; do
        case "${arg}" in
            h)
                usage
                exit 0
                ;;
            *)
                usage
                exit 1
                ;;
        esac
    done
}

function GetFileNames()
{
    fileNames=($(ls))
    if [ ${#fileNames[@]} -eq 0 ]; then
        return 1
    else
        return 0
    fi

}

function GetFileExtension()
{
    local __result=$1
    eval $__result="${2##*.}"
}

function IsValidFileExtension()
{
    case "$1" in
        "cc" | "cpp" | "c")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

function GetFileName()
{
    local __result=$1
    eval $__result="${2%.*}"
}

function FindValidFileName()
{
    local __result=$1
    local myResult=""

    for fileName in "${fileNames[@]}"
    do
        :
            GetFileExtension extension $fileName
            IsValidFileExtension $extension
            if [ $? -eq 0 ]; then
                GetFileName file $fileName
                myResult=$file
                break
            fi
    done

    eval $__result=$myResult
}

function MakeFile()
{
    make $1
    if [ $? -ne 0 ]; then
        return 1
    fi
}

function ExecuteFile()
{
    "./$1"
}

function main()
{
    ParseArguments $@

    GetFileNames
    if [ $? -ne 0 ]; then
        echo "Failed to find any file names in the directory $(pwd)"
        echo "Usage: $(basename $0) -h"
        exit 1
    fi

    FindValidFileName result
    if [[ -z "$result" ]]; then
        echo "Failed to find a valid file name in: "$(ls)
        echo "Usage: $(basename $0) -h"
        exit 1
    fi

    MakeFile $result
    if [ $? -ne 0 ]; then
        exit 1
    fi

    ExecuteFile $result
}

main $@
