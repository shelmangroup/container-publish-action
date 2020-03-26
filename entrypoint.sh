#!/bin/bash
set -e

function main(){

  REGISTRY_NO_PROTOCOL=$(echo "${INPUT_REGISTRY}" | sed -e 's/^https:\/\///g')
  if uses "${INPUT_REGISTRY}" && ! isPartOfTheName "${REGISTRY_NO_PROTOCOL}"; then
    INPUT_NAME="${REGISTRY_NO_PROTOCOL}/${INPUT_NAME}"
  fi

  if uses "${INPUT_WORKDIR}"; then
    cd "${INPUT_WORKDIR}"
  fi

  CONTEXT="."
  BUILDPARAMS=""
  TAGS=""

  if uses "${INPUT_TAGS}"; then
    TAGS=$(echo "${INPUT_TAGS}" | sed "s/,/ /g")
  fi

  if uses "${INPUT_TAG_LATEST}"; then
    TAGS="${TAGS} latest"
  fi

  if uses "${INPUT_DOCKERFILE}"; then
    BUILDPARAMS="${BUILDPARAMS} -f ${INPUT_DOCKERFILE}"
  fi

  if uses "${INPUT_CONTEXT}"; then
    CONTEXT="${INPUT_CONTEXT}"
  fi

  # Authenticate
  echo ${INPUT_PASSWORD} | buildah login -u ${INPUT_USERNAME} --password-stdin ${INPUT_REGISTRY}

  build_and_push
}

function uses() {
  [ ! -z "${1}" ]
}

function isPartOfTheName() {
  [ $(echo "${INPUT_NAME}" | sed -e "s/${1}//g") != "${INPUT_NAME}" ]
}

function build_and_push() {
  local BUILD_TAGS=""
  for TAG in ${TAGS}
  do
    BUILD_TAGS="${BUILD_TAGS}-t ${INPUT_NAME}:${TAG} "
  done
  buildah build ${INPUT_BUILDARGS} ${BUILDPARAMS} ${BUILD_TAGS} ${CONTEXT}

  for TAG in ${TAGS}
  do
    echo buildah push "${INPUT_NAME}:${TAG}"
  done
}

main
