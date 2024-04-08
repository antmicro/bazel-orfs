#!/bin/bash

set -e

echo "Build L1MetadataArray"
for stage in "synth_sdc" "synth" "floorplan" "place" "cts" "grt" "generate_abstract"
do
  echo "query make script target"
  bazel query L1MetadataArray_test_${stage}_make
  bazel query L1MetadataArray_test_${stage}_make --output=build
  echo "build make script"
  bazel build --subcommands --verbose_failures --sandbox_debug L1MetadataArray_test_${stage}_make
  echo "run make script"
  ./bazel-bin/L1MetadataArray_test_${stage}_make bazel-${stage}
done
