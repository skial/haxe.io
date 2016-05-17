INPUT="$@"
find $INPUT -name "*.html" | xargs -P 6 -n 1 htmlmin.sh
