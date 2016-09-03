NUM="$@"
electron --enable-logging ./ld/index.js -s ./ld/scraper.js -o ./src/data/ld$NUM.json -n $NUM -d 100 -f haxe openfl haxeflixel haxepunk luxeengine snowkit
