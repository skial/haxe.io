INPUT="$@"
electron --enable-logging . --input "//$INPUT/index.html" --script ./script.js --outputDir "//bin" --show --scripts linkqueue.js font.characters.js sitemap.js checkmissing.js
find $INPUT -name "*.html" | xargs -P 6 -n 1 htmlmin.sh
