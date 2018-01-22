#!/usr/bin/env bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
HOOKS_DIR="$DIR/../.git/hooks"


mkdir -p "$HOOKS_DIR"
cp "$DIR/pre-commit" "$HOOKS_DIR"

