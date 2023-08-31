#!/usr/bin/env bash

shfmt --language-dialect bash --write -i 4 -bn -ci -sr \
    ./**/*
