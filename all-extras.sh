INPUT="$@"
find $INPUT \( -name "*.jpg*" -o -name "*.jpeg*" -o -name "*.gif" -o -name "*.png" -o -name "*.mp4" -o -name "*.PNG" -o -name "*.webm" -o -name "*.swf" -o -name "*.pdf" -o -name "*.js" \) \
| xargs -I{} -n 1 symlink.sh "{}"
