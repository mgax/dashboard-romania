#!/bin/bash

BASE_URL="http://epp.eurostat.ec.europa.eu/NavTree_prod/everybody/BulkDownloadListing?file=data"
DST_DIR="src/eurostat"

declare -A DATA_FILES
DATA_FILES=(
	[gdp]=tec00001.tsv.gz
	[population]=tps00001.tsv.gz
)

CURL=$(which curl)
[ -n "$CURL" -a -x "$CURL" ] || exit


SCRIPT_DIR=$(dirname $0)
ROOT_DIR=$(readlink -f "$SCRIPT_DIR/..")

TMP_DIR=$(mktemp -d)
cd "$TMP_DIR" &> /dev/null

for file in ${!DATA_FILES[@]}; do
	data=${DATA_FILES[$file]}

	curl -s -O "$BASE_URL/$data"

	[ -e "$data" ] || continue
	gunzip "$data"
	raw_data="${data%.*}"
	mv "$raw_data" "$ROOT_DIR/$DST_DIR/${file}_data.tsv"
done


cd - &> /dev/null
rm -rf "$TMP_DIR"
