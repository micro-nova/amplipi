#!/bin/bash
# Set up directory and pipe
src_config_dir="$1"

# Execute from the stream scripts directory
cd "$(dirname "$0")"

mkdir -p ${src_config_dir}
mkfifo ${src_config_dir}/metafifo
chmod +x ${src_config_dir}/metafifo

# Send relevant logfile data to the translation script
cat ${src_config_dir}/metafifo | grep --line-buffered -w 'CurrentTrackMetaData\|TransportState' | python3 dlna_meta.py "${src_config_dir}"
