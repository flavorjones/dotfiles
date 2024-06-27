#!/usr/bin/env bash
#
#  script to record an interview in such a way that I can get a good transcription from whisper.cpp
#
#  - record two separate audio sources,
#  - put each on on a separate channel so I can use the `--diarize` option,
#  - make sure the audio is 16kHz as whisper.cpp expects
#
if [ $# -ne 1 ]; then
  echo "USAGE: $0 <output-file>"
  exit 1
fi

output_file=$1

function choose_source {
  channel=$1
  filter=$2
  pw-link -o | egrep "${channel}$" | fgrep "$filter" | sort | fzf +m --border --prompt="choose ${channel} channel > "
}

set -eu

# choose audio sources
source_left=$(choose_source FL input)
source_right=$(choose_source FR output)

# set up a sink to combine sources into left/right channels for diarizing in a transcript
INTERVIEW_SINK_NAME="interview-sink-$(uuid)"

set -x

pw-cli create-node adapter "{
  factory.name=support.null-audio-sink
  node.name=$INTERVIEW_SINK_NAME
  media.class=Audio/Sink
  object.linger=true
  audio.position=[FL FR]
  monitor.channel-volumes=true
  monitor.passthrough=true
}"

function cleanup {
  pw-cli info "${INTERVIEW_SINK_NAME}" > /dev/null 2>&1 && pw-cli destroy "${INTERVIEW_SINK_NAME}"
  trap - SIGINT EXIT
}
trap cleanup SIGINT EXIT

pw-link "${source_left}" "${INTERVIEW_SINK_NAME}:playback_FL"
pw-link "${source_right}" "${INTERVIEW_SINK_NAME}:playback_FR"

pw-record --target "${INTERVIEW_SINK_NAME}" -P '{ stream.capture.sink=true }' --rate 16000 "${output_file}"
