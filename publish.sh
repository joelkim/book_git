#!/bin/bash
quarto render
ghp-import -c gitbook.madebykim.kr -f -n -o -p _site
