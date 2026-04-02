#!/usr/bin/env bash
set -euo pipefail

MUJOCO_VERSION="3.2.0"
MUJOCO_ROOT="${HOME}/mujoco"
MUJOCO_DIR="${MUJOCO_ROOT}/mujoco-${MUJOCO_VERSION}"

mkdir -p "${MUJOCO_ROOT}"
cd /tmp

# MuJoCo official Linux release archive for x86_64
wget -q "https://github.com/google-deepmind/mujoco/releases/download/${MUJOCO_VERSION}/mujoco-${MUJOCO_VERSION}-linux-x86_64.tar.gz" -O "mujoco-${MUJOCO_VERSION}-linux-x86_64.tar.gz"

tar -xzf "mujoco-${MUJOCO_VERSION}-linux-x86_64.tar.gz" -C "${MUJOCO_ROOT}"

# Make the path explicit and stable
if [ ! -d "${MUJOCO_DIR}" ]; then
  mv "${MUJOCO_ROOT}/mujoco-${MUJOCO_VERSION}" "${MUJOCO_DIR}"
fi

rm -f "/tmp/mujoco-${MUJOCO_VERSION}-linux-x86_64.tar.gz"

echo "MuJoCo installed at: ${MUJOCO_DIR}"
