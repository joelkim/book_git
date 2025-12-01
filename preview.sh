#!/bin/bash
code --openExternal "http://127.0.0.1:8080/"
quarto preview "index.ipynb" --no-browser --host 0.0.0.0 --port 8080
