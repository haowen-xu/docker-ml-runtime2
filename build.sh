#!/bin/bash

# ---- build arguments ----
IMAGE_NAME="ml-runtime2"
REPO_NAME="haowenxu"

PYTHON_VERSION="${PYTHON_VERSION:-3.8}"
CUDA_VERSION="${CUDA_VERSION:-11.3-cudnn8}"
TENSORFLOW_VERSION="${TENSORFLOW_VERSION:-2.6.0}"
TORCH_VERSION="${TORCH_VERSION:-1.10.0}"
TORCH_VISION_VERSION="${TORCH_VISION_VERSION:-0.10.1}"
TORCH_CUDA_CHANNEL="${TORCH_CHANNEL:-+cu113}"

PIP_DEFAULT_TIMEOUT="${PIP_DEFAULT_TIMEOUT:-120}"
PIP_MIRROR="${PIP_MIRROR:-}"

# ---- recognize the variant ----
VARIANT="${VARIANT:-cpu}"

if [[ "${VARIANT}" != "cpu" && "${VARIANT}" != "gpu" ]]; then
    echo "Variant ${VARIANT} is not supported."
    exit 1
fi

if [[ "${PYTHON_VERSION}" == "3.6" ]]; then
    UBUNTU_VERSION=18.04
elif [[ "${PYTHON_VERSION}" == "3.8" ]]; then
    UBUNTU_VERSION=20.04
else
    echo "Python ${PYTHON_VERSION} is not supported."
    exit 1
fi

if [[ "${VARIANT}" == "gpu" && "${UBUNTU_VERSION}" != "18.04" ]]; then
    echo "The combination of ubuntu ${UBUNTU_VERSION} and variant ${VARIANT} is not supported."
    exit 1
fi

GPU_BASE_IMAGE="nvidia/cuda:${CUDA_VERSION}-devel-ubuntu${UBUNTU_VERSION}"
CPU_BASE_IMAGE="ubuntu:${UBUNTU_VERSION}"

# ---- config according to the variant ----
if [ "${VARIANT}" == "gpu" ]; then
    GPU_LIB_PATH="/usr/local/nvidia/lib64:/usr/local/nvidia/lib:/usr/local/cuda/lib64:/usr/local/cuda/lib"
    BASE_IMAGE="${GPU_BASE_IMAGE}"
    TORCH_CHANNEL="${TORCH_CUDA_CHANNEL}"
else
    GPU_LIB_PATH=""
    BASE_IMAGE="${CPU_BASE_IMAGE}"
    TORCH_CHANNEL=""
fi

# ---- determine the docker tags ----
SHORT_TAG="${VARIANT}-py${PYTHON_VERSION}"
if [[ "${VARIANT}" == "gpu" ]]; then
    GPU_TAG="-cuda${CUDA_VERSION}"
else
    GPU_TAG=""
fi
FULL_TAG="${VARIANT}${GPU_TAG}-py${PYTHON_VERSION}-torch${TORCH_VERSION}"

# ---- build the docker image ----
echo "Build ${FULL_TAG}"

DOCKER="${DOCKER:-docker}"
WORK_DIR=./"${VARIANT}-py${PYTHON_VERSION}"
mkdir -p "${WORK_DIR}" && cd "${WORK_DIR}" && \
    echo "FROM ${BASE_IMAGE}" > Dockerfile && \
    cat ../template/Dockerfile >> Dockerfile && \
    cp ../template/entry.sh entry.sh && \
    ${DOCKER} build -t "${IMAGE_NAME}:${FULL_TAG}" \
            --build-arg VARIANT="${VARIANT}" \
            --build-arg GPU_LIB_PATH="${GPU_LIB_PATH}" \
            --build-arg TORCH_VERSION="${TORCH_VERSION}${TORCH_CHANNEL}" \
            --build-arg TORCH_VISION_VERSION="${TORCH_VISION_VERSION}${TORCH_CHANNEL}" \
            --build-arg TENSORFLOW_VERSION="${TENSORFLOW_VERSION}" \
            --build-arg PIP_DEFAULT_TIMEOUT="${PIP_DEFAULT_TIMEOUT}" \
            --build-arg PIP_MIRROR="${PIP_MIRROR}" \
            . \
        && \
        ${DOCKER} tag "${IMAGE_NAME}:${FULL_TAG}" "haowenxu/${IMAGE_NAME}:${FULL_TAG}" && \
        ${DOCKER} tag "${IMAGE_NAME}:${FULL_TAG}" "haowenxu/${IMAGE_NAME}:${SHORT_TAG}" && \
        ${DOCKER} push "haowenxu/${IMAGE_NAME}:${FULL_TAG}" && \
        ${DOCKER} push "haowenxu/${IMAGE_NAME}:${SHORT_TAG}"
