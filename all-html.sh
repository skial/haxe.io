INPUT="$@"
electron --enable-logging . -w 1920 -h 1080 --input "//$INPUT/index.html" --script ./script.js --outputDir "//bin" --show \
--scripts linkqueue.js font.characters.js sitemap.js checkmissing.js screengrab.js version.js scriptstripper.js
find $INPUT -name "*.html" | xargs -P 6 -n 1 htmlmin.sh
