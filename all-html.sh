INPUT="$@"
electron --enable-logging ./site/ -w 1920 -h 1080 --input "//$INPUT/index.html" --script ./site/script.js --outputDir "//bin" --show \
--scripts linkqueue.js checkmissing.js font.characters.js sitemap.js screengrab.js subresourceintegrity.js
find $INPUT -name "*.html" | xargs -P 6 -n 1 htmlmin.sh
