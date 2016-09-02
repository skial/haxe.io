NUM="$@"
electron --enable-logging ./ld/index.js -s ./ld/scraper.js -o ./src/data/ld$NUM.json -n $NUM -f haxe haxeflixel openfl luxeengine snowkit haxepunk
