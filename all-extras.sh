INPUT="$@"
find $INPUT \( -name "*.svg" -name "*.json" -name "*.txt" -name "*.xml" -name "*.jpg*" -o -name "*.jpeg*" -o -name "*.gif" -o -name "*.png" -o -name "*.mp4" -o -name "*.PNG" -o -name "*.webm" -o -name "*.swf" -o -name "*.pdf" -o -name "*.js" \) \
| xargs -I{} -P 7 -n 1 symlink.sh "{}"
