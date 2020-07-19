#!/bin/bash
PROJECT_DIR="${PWD}"
PYTHON_MAJOR=3
PYTHON_MINOR=6
PYTHON_REF=$(source ${PROJECT_DIR}/scripts/check_python.sh ${PYTHON_MAJOR} ${PYTHON_MINOR})
if [[ ${PYTHON_REF} == "NoPython" ]]; then
    echo ">> [ERROR] Requires Python v${PYTHON_MAJOR}.${PYTHON_MINOR}+"
    exit
fi

# Check if boto3 is installed
${PYTHON_REF} -c "import boto3"
if [[ ! $? -eq 0 ]]; then
    echo ">> [FIX] '${PYTHON_REF} -m pip install boto3'"
    exit
fi

${PYTHON_REF} ${PROJECT_DIR}/examples/python/index.py
