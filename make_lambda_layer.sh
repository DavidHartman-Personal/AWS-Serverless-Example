#!/usr/bin/env bash
usage() {
  echo "AWS Lambda Layer Builder"
  echo "------------------------"
  echo "make-layer NAME PACKAGE_1 [PACKAGE_2] ..."
  echo "make-layer NAME MANIFEST"
  echo ""
}

function main() {
  set -e

  if [[ $# -lt 2 ]]; then
    usage
    exit 1
  fi

  name="${1}"
  manifest="${3}"

  if test -f "$manifest"; then
    packages="${@:4}"
  else
    manifest=""
    packages="${@:3}"
  fi

  output_folder="$(mktemp -d)"
  docker_image="amazon/aws-sam-cli-build-image-$runtime:latest"
  package_folder="python/lib/$runtime/site-packages/"

	if [[ -n $manifest ]]; then
		cp "$manifest" "$output_folder/requirements.txt"
	else
		touch "$output_folder/requirements.txt"
	fi
	install_command="pip install -r requirements.txt -t $package_folder $packages"

  echo "Building layer"

  zip_command="zip -r layer.zip *"

  docker run --rm -v "$output_folder:/layer" -w "/layer" "$docker_image" /bin/bash -c "$install_command && $zip_command"

  pushd "$output_folder"

  echo "Uploading layer $name to AWS"

  aws lambda publish-layer-version --layer-name "$name" --compatible-runtimes "$runtime" --zip-file "fileb://layer.zip"

  echo "Upload complete"

  popd

  echo "Cleaning up"

  rm -rf "$output_folder"

  echo "All done. Enjoy your shiny new Lambda layer!"
}

main "$@"
