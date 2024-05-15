#!/bin/sh
read -p "PRD環境ですが実行しますか？ (prd/N): " input
case $input in "prd"*) ;; *) echo "aborted" && exit 1 ;; esac