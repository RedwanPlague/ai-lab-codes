#!/usr/bin/env bash

# abort on errors
set -e

# build
npm run build

site="../ghost-busters/"

cp -R dist/. ${site}

cd ${site}

git add -A
git commit -m 'deploy'
git push -u origin main

cd -