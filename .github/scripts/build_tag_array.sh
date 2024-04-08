#!/bin/bash

set -e

if [[ -z "$STAGES" ]]; then
  STAGES=("synth_sdc" "synth" "memory" "floorplan" "generate_abstract")
else
  eval "STAGES=($STAGES)"
fi

echo "Build tag_array_64x184 macro"
for stage in ${STAGES[@]}
do
  if [[ -z $SKIP_BUILD ]] ; then
    echo "query make script target"
    bazel query tag_array_64x184_${stage}_make
    bazel query tag_array_64x184_${stage}_make --output=build
    echo "build make script"
    bazel build --subcommands --verbose_failures --sandbox_debug tag_array_64x184_${stage}_make
  fi
  if [[ -z $SKIP_RUN ]] ; then
    echo "run make script"
    ./bazel-bin/tag_array_64x184_${stage}_make $(if [[ "$stage" != "memory" ]] ; then echo "bazel-" ; fi)${stage}
  fi
done
