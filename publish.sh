#!/bin/bash
set -e

quarto render

# Helm chart tgz만 _site/helm/ 에 포함
mkdir -p _site/helm
helm package helm/book-git --destination _site/helm

ghp-import -c gitbook.madebykim.kr -f -n -o -p _site
