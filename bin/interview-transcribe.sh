#!/usr/bin/env bash
#
#  early experiments show that "tiny" is really good, as-good-or-better than "small" and "base" and
#  way faster
#
WHISPER_PATH=$HOME/code/oss/whisper.cpp

function usage {
  echo "Usage: $0 input-file model-name"
  echo "  e.g., $0 interview.wav tiny.en"
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

file=$1
model=$2

set -x

time ${WHISPER_PATH}/main \
  --model ${WHISPER_PATH}/models/ggml-${model}.bin \
  --diarize \
  --file ${file} \
  --output-txt --output-file ${file}.${model} \
  --threads 6
