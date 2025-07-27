#!/bin/bash
quarto render
ghp-import -c git.datascienceschool.net -f -n -o -p _site
