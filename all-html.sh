INPUT="$@"
find $INPUT -name "*.html" | xargs -P 7 -n 1 htmlmin.sh
