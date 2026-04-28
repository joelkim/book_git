#!/bin/bash
set -e

REGISTRY="docker.io/joelkim/book_git"
DATE_TAG=$(date +%Y%m%d)

echo "=== Building image ==="
podman build \
    --tag "${REGISTRY}:${DATE_TAG}" \
    --tag "${REGISTRY}:latest" \
    --file Dockerfile \
    .

echo "=== Pushing to Docker Hub ==="
podman push "${REGISTRY}:${DATE_TAG}"
podman push "${REGISTRY}:latest"

echo "=== Packaging Helm chart ==="
helm package helm/book-git --destination .

echo ""
echo "Done:"
echo "  Docker : ${REGISTRY}:${DATE_TAG}, ${REGISTRY}:latest"
echo "  Helm   : $(ls book-git-*.tgz | tail -1)"
