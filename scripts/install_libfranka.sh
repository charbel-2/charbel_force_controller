#!/usr/bin/env bash
set -euo pipefail

LIBFRANKA_VERSION="${LIBFRANKA_VERSION:-0.13.3}"
LIBFRANKA_SRC="/tmp/libfranka"

echo "[libfranka] Installing system dependencies..."
apt-get update
apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libpoco-dev \
    libeigen3-dev \
    libboost-all-dev \
    libssl-dev \
    libusb-1.0-0-dev \
    liblapack-dev \
    libv4l-dev \
    libglfw3-dev \
    libncurses5-dev \
    libncursesw5-dev \
    libgtk-3-dev \
    libglib2.0-dev

echo "[libfranka] Cloning version ${LIBFRANKA_VERSION}..."
rm -rf "${LIBFRANKA_SRC}"
git clone --branch "${LIBFRANKA_VERSION}" --recursive --depth 1 \
    https://github.com/frankarobotics/libfranka.git "${LIBFRANKA_SRC}"

echo "[libfranka] Building..."
cd "${LIBFRANKA_SRC}"
git submodule update --init --recursive

cmake -S . -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_TESTS=OFF
cmake --build build -j"$(nproc)"

echo "[libfranka] Installing..."
cmake --install build
ldconfig

rm -rf "${LIBFRANKA_SRC}"

echo "[libfranka] Done."
