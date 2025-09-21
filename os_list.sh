#!/bin/sh

TARGET=$1
OUPTUT_FILE=dist/${TARGET}
BASE_URL=https://github.com/beagleboard/micropython-builder/releases/download/continuous-release

# Build os_list.json
SHA=$(sha256sum ${OUPTUT_FILE} | cut -d " " -f 1)
EXTRACT_SIZE=$(xz --robot --list ${OUPTUT_FILE} | awk 'END {print $5}')
URL="${BASE_URL}/${TARGET}"
jq --argjson extract_size $EXTRACT_SIZE --arg sha "${SHA}" --arg url ${URL} '.os_list += [{ "name": env.OS_LIST_NAME, "description": env.OS_LIST_DESC, "icon": env.OS_LIST_ICON, "devices": [ env.DEVICE ], "tags": [ "zephyr" ], "image_download_sha256": $sha, "url": $url, "release_date": env.RELEASE_DATE, "extract_size": $extract_size } ]' os_list.json > os_list.json.tmp
mv os_list.json.tmp os_list.json
