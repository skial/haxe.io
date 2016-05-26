INPUT="$@"
find $INPUT \( -name "*.svg" -o -name "*.json" -o -name "*.txt" -o -name "*.xml" -o -name "*.jpg*" -o -name "*.jpeg*" -o -name "*.JPEG*" -o -name "*.JPG*" -o -name "*.gif" -o -name "*.png" -o -name "*.mp4" -o -name "*.PNG" -o -name "*.webm" -o -name "*.swf" -o -name "*.pdf" -o -name "*.js" \) \
| xargs -I{} -P 7 -n 1 symlink.sh "{}"
