
#!/bin/bash



set -euo pipefail



REGISTRY="172.29.186.208:31141"

IMAGE_NAME="testing-nodejs"

PLATFORM="linux/amd64" 

CONTEXT="."

PROGRESS="plain"







VERSION="$1"

shift || true



PUSH=false

NO_CACHE=false



while [[ $# -gt 0 ]]; do

  case "$1" in

    --push) PUSH=true ;;

    --no-cache) NO_CACHE=true ;;

    *)

      echo "Invalid arguments: $1"

      usage

      exit 1

      ;;

  esac

  shift

done





TAG="${REGISTRY}/${IMAGE_NAME}:${VERSION}"



CMD=( docker buildx build

  --platform "${PLATFORM}"

  -t "${TAG}"

  "${CONTEXT}"

  --progress="${PROGRESS}"

)





if [[ "$PUSH" == true ]]; then

  CMD+=( --push )

fi





if [[ "$NO_CACHE" == true ]]; then

  CMD+=( --no-cache )

fi





echo "🚀 Running:"

printf '  %q' "${CMD[@]}"; echo

"${CMD[@]}"

