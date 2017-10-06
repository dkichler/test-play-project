#!/bin/sh

BUILT_AT=$(date)
BUILT_ON=$(uname -a)
BUILT_BY=$(whoami)
COMMIT=$(git rev-parse HEAD)

echo "{
  \"builtAt\": \"$BUILT_AT\",
  \"builtOn\": \"$BUILT_ON\",
  \"builtBy\": \"$BUILT_BY\",
  \"commit\": \"$COMMIT\"
}"
