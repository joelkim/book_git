#!/bin/bash
quarto render
ghp-import -c git.bykim.dev -f -n -o -p _site
