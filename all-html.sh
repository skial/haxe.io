INPUT="$@"
electron --enable-logging . -w 1920 -h 1080 --input "//$INPUT/index.html" --script ./script.js --outputDir "//bin" --show \
--scripts linkqueue.js checkmissing.js font.characters.js sitemap.js screengrab.js version.js
find $INPUT -name "*.html" | xargs -P 6 -n 1 htmlmin.sh
