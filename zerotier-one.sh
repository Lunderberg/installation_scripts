#!/bin/bash

set -euo pipefail

cat gpg_keys/zerotier_one.pub | gpg --import

if z=$(curl -s 'https://install.zerotier.com/' | gpg); then
    echo "$z" | sudo bash
fi
