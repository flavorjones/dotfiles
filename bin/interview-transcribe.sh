#!/usr/bin/env bash

WHISPER_PATH=$HOME/code/oss/whisper.cpp

function usage {
  echo "Usage: $0 input-file model-name"
  echo "  e.g., $0 interview.wav base.en"
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
