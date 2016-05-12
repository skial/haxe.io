INPUT="$@"
find $INPUT -name "*.css" | xargs -P 5 -n 1 cssmin.sh
