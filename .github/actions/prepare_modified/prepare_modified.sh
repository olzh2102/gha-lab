#!/usr/bin/env bash
set -Eeuo pipefail

function modified() {
    count=0
    IFS=', ' read -r -a paths <<< "$1"

    for path in ${paths[@]}; do
        num=$(git diff --name-only HEAD^ HEAD -- "$path" | wc -l)
        count=$(($count + $((num))))
    done

    echo $count
}

IS_COMMON_CHANGED_VAR=$(modified "$COMMON_PATHS")
IS_TERRAFORM_CHANGED_VAR=$(modified "$TERRAFORM_PATH")
IS_DB_MIGRATION_CHANGED_VAR=$(modified "$DB_MIGRATION_PATH")

if [ $IS_COMMON_CHANGED_VAR -gt 0 ]; 
then
    echo "Common files were modified"
    echo $CONFIG
    echo "modified_modules=$CONFIG" >> $GITHUB_OUTPUT
else
    modified_modules="[]"
    jq -c .[] <<< $CONFIG | while read module; do
        path=$(jq -c '.path' <<< $module)
        num=$(git diff --name-only HEAD^ HEAD -- "$path" | wc -l)
        if [ $num -gt 0 ];
        then
            newValue=$(jq -c --argjson c "$module" '. += [$c]' <<< $modified_modules)
            modified_modules=$newValue
            echo $newValue
            echo "modified_modules=$newValue" >> $GITHUB_OUTPUT
        else
            echo "modified_modules=[]" >> $GITHUB_OUTPUT
        fi
done
fi

if [ $IS_TERRAFORM_CHANGED_VAR -gt 0 ]; 
then
    echo "Terraform files were modified"
    echo "terraform=true" >> $GITHUB_OUTPUT
fi

if [ $IS_DB_MIGRATION_CHANGED_VAR -gt 0 ]; 
then
    echo "Database Migration files were modified"
    echo "db_migration=true" >> $GITHUB_OUTPUT
fi