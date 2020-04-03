#!/bin/bash

# ---- build arguments ----
IMAGE_NAME="ml-runtime2"
REPO_NAME="haowenxu"

UBUNTU_VERSION=18.04
CUDA_VERSION=10.0-cudnn7
TORCH_VERSION=1.3.1
TORCH_VISION_VERSION=0.4.2
TENSORFLOW_VERSION=2.1.0

PIP_DEFAULT_TIMEOUT="${PIP_DEFAULT_TIMEOUT:-120}"
PIP_MIRROR="${PIP_MIRROR:-}"

GPU_BASE_IMAGE="nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}"
CPU_BASE_IMAGE="ubuntu:${UBUNTU_VERSION}"

# ---- recognize the variant ----
VARIANT="$1"

if [[ "${VARIANT}" != "cpu" && "${VARIANT}" != "gpu" ]]; then
    echo build.sh cpu|gpu
    exit 1
fi

# ---- config according to the variant ----
if [ "${VARIANT}" == "gpu" ]; then
    GPU_LIB_PATH="/usr/local/nvidia/lib64:/usr/local/nvidia/lib:/usr/local/cuda/lib64:/usr/local/cuda/lib"
    BASE_IMAGE="${GPU_BASE_IMAGE}"
else
    GPU_LIB_PATH=""
    BASE_IMAGE="${CPU_BASE_IMAGE}"
fi

# ---- determine the docker tags ----
SHORT_TAG="${VARIANT}"
FULL_TAG="${VARIANT}-ubuntu${UBUNTU_VERSION}-cuda${CUDA_VERSION}-torch${TORCH_VERSION}"

# ---- build the docker image ----
WORK_DIR=./"${VARIANT}"
mkdir -p "${WORK_DIR}" && cd "${WORK_DIR}" && \
    echo "FROM ${BASE_IMAGE}" > Dockerfile && \
    cat ../template/Dockerfile >> Dockerfile && \
    cp ../entry.sh entry.sh && \
    docker build -t "${IMAGE_NAME}:${FULL_TAG}" \
            --build-arg VARIANT="${VARIANT}" \
            --build-arg GPU_LIB_PATH="${GPU_LIB_PATH}" \
            --build-arg TORCH_VERSION="${TORCH_VERSION}" \
            --build-arg TORCH_VISION_VERSION="${TORCH_VISION_VERSION}" \
            --build-arg TENSORFLOW_VERSION="${TENSORFLOW_VERSION}" \
            --build-arg PIP_DEFAULT_TIMEOUT="${PIP_DEFAULT_TIMEOUT}" \
            --build-arg PIP_MIRROR="${PIP_MIRROR}" \
            . \
        && \
        docker tag "${IMAGE_NAME}:${FULL_TAG}" "haowenxu/${IMAGE_NAME}:${FULL_TAG}" && \
        docker tag "${IMAGE_NAME}:${FULL_TAG}" "haowenxu/${IMAGE_NAME}:${SHORT_TAG}" && \
        docker push "haowenxu/${IMAGE_NAME}:${FULL_TAG}" && \
        docker push "haowenxu/${IMAGE_NAME}:${SHORT_TAG}"
