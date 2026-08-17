#!/bin/bash

# Variables
REMOTE_USER="hkhe451"
REMOTE_HOST="sc-cer0042.its.auckland.ac.nz"
REMOTE_PATH="/data/DPRC/derivatives/dwi/F0"
LOCAL_PATH="/media/hkhe451/Nicoles2019/Hayat_DPRC"

# Run SCP (recursive, verbose, preserve timestamps)
scp -r -p -v "$REMOTE_USER@$REMOTE_HOST:$REMOTE_PATH" "$LOCAL_PATH"