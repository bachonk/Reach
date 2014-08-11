#!/bin/sh

ITUNES_ARTWORK="$1"
FOLDER=$(dirname "$ITUNES_ARTWORK")

sips -z 57 57 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon.png"
sips -z 114 114 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon@2x.png"
sips -z 120 120 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-60@2x.png"
sips -z 29 29 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-Small.png"
sips -z 58 58 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-Small@2x.png"
sips -z 40 40 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-Small-40.png"
sips -z 80 80 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-Small-40@2x.png"
sips -z 50 50 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-Small-50.png"
sips -z 100 100 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-Small-50@2x.png"
sips -z 72 72 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-72.png"
sips -z 144 144 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-72@2x.png"
sips -z 76 76 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-76.png"
sips -z 152 152 "$ITUNES_ARTWORK" --out "${FOLDER}/Icon-76@2x.png"