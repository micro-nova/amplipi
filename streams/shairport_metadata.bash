#!/bin/bash
# Clear out any previous album cover images, then navigate to the proper directory #
scripts_dir="$0"
src_config_dir="$1"

# Execute from the generated directory for shairport album art
cd "$(dirname "$2")"

# Start the metadata service with argument $1 being the source number #
cat ${src_config_dir}/shairport-sync-metadata | shairport-sync-metadata-reader | python3 ${scripts_dir}/sp_meta.py "${src_config_dir}"
