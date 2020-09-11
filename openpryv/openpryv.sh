#!/bin/bash
# Update Open-Pryv.io
git -C /var/pryv/open-pryv.io/ commit -a -m "save config files";
git -C /var/pryv/open-pryv.io/ fetch && git -C /home/ubuntu/open-pryv.io/ merge --strategy-option ours --quiet --commit --no-edit;

# Start Open-Pryv.io
yes | yarn --cwd /var/pryv/open-pryv.io setup
yes | yarn --cwd /var/pryv/open-pryv.io release
yarn --cwd /var/pryv/open-pryv.io pryv