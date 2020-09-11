#!/bin/bash

# Start Open-Pryv.io
yes | yarn --cwd /var/pryv/open-pryv.io setup
yes | yarn --cwd /var/pryv/open-pryv.io release
yarn --cwd /var/pryv/open-pryv.io pryv