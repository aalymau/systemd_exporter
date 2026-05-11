#!/bin/bash
set -e

go_builder_docker_image=$(grep "quay.io/prometheus/golang-builder:" .github/workflows/ci.yml | awk '{print $2}')
if [[ ${go_builder_docker_image} == "" ]]; then
    echo "Failed to setup docker image"
    exit 1
fi

if [[ $1 == "tidy" ]]; then
    echo "Go mod tidy"
    docker run -t -v $(pwd):/app -w /app --entrypoint go ${go_builder_docker_image} mod tidy
    exit 0
fi

if [[ $1 == "lint" ]]; then
    echo "Linting"
    docker run -t -v $(pwd):/app -w /app --entrypoint make ${go_builder_docker_image} GO_ONLY=1
fi

docker run -t -v $(pwd):/app -w /app --entrypoint make ${go_builder_docker_image} common-build common-tarball

ARCHIVE_NAME=systemd_exporter-$(cat VERSION).linux-amd64
tar xzf ${ARCHIVE_NAME}.tar.gz --strip-components=1 ${ARCHIVE_NAME}/systemd_exporter
