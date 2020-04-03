#!/bin/bash

set -e

# Deploy the timezone settings
[ "x${TZ}" != "x" ] && \
    [ -f "/usr/share/zoneinfo/${TZ}" ] && \
    ln -snf "/usr/share/zoneinfo/${TZ}" /etc/localtime && \
    echo "${TZ}" > /etc/timezone

# Deploy the pip mirror settings
[ "x${PIP_MIRROR}" != "x" ] && \
    python -m pip config set global.index-url "${PIP_MIRROR}"

# Execute the program
exec "$@"
