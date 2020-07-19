#!/bin/bash
PROJECT_DIR="${PWD}"
cd ${PROJECT_DIR}/examples/node
yarn install && yarn start:prod
