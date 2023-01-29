#!/bin/bash
export PATH=$PATH:/opt/conda/bin
pip install projector-installer --user
jupyter lab --no-browser --port 8888 --ip=* --allow-root --NotebookApp.token='' --NotebookApp.password=''