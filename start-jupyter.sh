#!/bin/bash

echo "Starting Jupyter..."

/ve/bin/jupyter notebook "$@" --allow-root --no-browser
