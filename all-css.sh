INPUT="$@"
find $INPUT -name "*.css" | xargs -P 7 -n 1 cssmin.sh
