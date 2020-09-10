#!/bin/bash
# Update Open-Pryv.io
git -C /home/ubuntu/open-pryv.io/ commit -a -m "save config files";
git -C /home/ubuntu/open-pryv.io/ fetch && git -C /home/ubuntu/open-pryv.io/ merge --strategy-option ours --quiet --commit --no-edit;

# Start Open-Pryv.io
yes | yarn --cwd /home/ubuntu/open-pryv.io setup
yes | yarn --cwd /home/ubuntu/open-pryv.io release
yarn --cwd /home/ubuntu/open-pryv.io pryv