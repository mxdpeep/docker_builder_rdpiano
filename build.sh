#!/bin/bash

function yes_or_no () {
  while true
  do
    read -p "$* [y/N]: " yn
    case $yn in
      [Yy]*) return 0 ;;
      [Nn]*) return 1 ;;
      *)
      return 1 ;;
    esac
  done
}

docker build -t rpiano-builder . || exit 1

TMP_NAME="plugin-builder-$RANDOM"
docker create --name "$TMP_NAME" rpiano-builder

rm -rf ./Release
mkdir -p ./Release

if docker cp "$TMP_NAME":/app/rdpiano_juce/Builds/LinuxMakefile/build/. ./Release/; then
    echo "Build artifacts copied successfully."
    ls -R ./Release
else
    echo "Zkouším alternativní cestu..."
    docker cp "$TMP_NAME":/app/rdpiano_juce/Builds/LinuxMakefile/build/Release/. ./Release/
fi

docker rm -f "$TMP_NAME"
yes_or_no "Remove the builder image?" && docker rmi rpiano-builder
