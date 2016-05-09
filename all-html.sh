INPUT="$@"
find $INPUT -name "*.html" | xargs -P 3 -n 1 htmlmin.sh
