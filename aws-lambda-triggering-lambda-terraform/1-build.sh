#!/bin/bash
pushd lambda/caller
npm install
popd
pushd lambda/callee
npm install
popd