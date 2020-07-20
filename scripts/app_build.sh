#!/bin/bash
PROJECT_DIR="${PWD}"

rm -r ${PROJECT_DIR}/dist
mkdir ${PROJECT_DIR}/dist

echo "🔎  Identifying services folders ..."
servicesFolders=$(find services -maxdepth 1 -type d -name "*-api" -print | sort)
[[ -z "${servicesFolders}" ]] && "Failed - missing folders named: {service}-api " && exit
printf "📁  Services folders\n===================\n${servicesFolders}\n"
echo "🌍  Installing dependencies, building services and layers"
for serviceFolder in $servicesFolders; do
    echo "🛠️  Building ${serviceFolder}"
    cd "${PROJECT_DIR}/${serviceFolder}"
    yarn build:dev
    sleep 1
    if [[ -d "./layer" ]]; then
        echo "⛏️  Building ${serviceFolder}/layer"
        cd "${PROJECT_DIR}/${serviceFolder}/layer"
        yarn build
        sleep 1
    fi
    find "${PROJECT_DIR}/${serviceFolder}" -iname '*.zip' -exec cp {} ${PROJECT_DIR}/dist \;
done

find "${PROJECT_DIR}" -maxdepth 1 -iname 'cfn-template-*.yml' -exec cp {} ${PROJECT_DIR}/dist/ \;

[[ -z $GITHUB_SHA ]] && export GITHUB_SHA=$(git rev-parse HEAD)
SHORT_COMMIT=${GITHUB_SHA:0:8}
mkdir -p ${PROJECT_DIR}/dist/${SHORT_COMMIT}

for f in ${PROJECT_DIR}/dist/*; do
    if [ -f "$f" ]; then
        filename=$(basename ${f})
        cp $f ${PROJECT_DIR}/dist/${SHORT_COMMIT}/${filename}
    fi
done

echo "✅  Finished"