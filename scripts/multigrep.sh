#!/usr/bin/env bash

if [ -z $1 ]; then                                                      # check user has passed in search terms
    echo "pass in search terms"
    return 0
else
    data="ps -ef | grep $USER"                                          # search processed for current user
    for term in $@; do
        data="$data | grep $term"                                       # grep for each term separately
    done

    eval $data                                                          # evaluate grep statement
fi
