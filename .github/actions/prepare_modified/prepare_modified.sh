#!/usr/bin/env bash
set -Eeuo pipefail

function modified() {
    count=0
    IFS=',' read -r -a paths <<< "$1"

    for path in ${paths[@]}; do
        num=$(git diff --name-only HEAD^ HEAD -- "$path" | wc -l)
        count=$(($count + $((num))))
    done

    echo $count
}

IS_COMMON_CHANGED_VAR=$(modified "$COMMON_PATHS")
IS_TERRAFORM_CHANGED_VAR=$(modified "$TERRAFORM_PATH")
IS_DB_MIGRATION_CHANGED_VAR=$(modified "$DB_MIGRATION_PATH")

if [ $IS_COMMON_CHANGED_VAR -gt 0 ]; then
    echo "Common changed"