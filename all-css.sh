INPUT="$@"
find $INPUT -name "*.css" | xargs -n 1 cssmin.sh
