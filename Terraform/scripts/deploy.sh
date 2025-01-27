#!/bin/bash
environment=$1
region=$2

if [ -z "$environment" ] || [ -z "$region" ]; then
    echo "Usage: ./deploy.sh <environment> <region>"
    exit 1
fi