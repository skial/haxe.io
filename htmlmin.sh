INPUT="$@"
INPUT_DIR=${INPUT%/*}
echo $INPUT
#echo $INPUT_DIR
if [ "$INPUT_DIR" == "$INPUT" ]; then
	#echo "correcting path"
	INPUT="${INPUT//\\//}"
	INPUT_DIR=${INPUT%/*}
fi
#INPUT_BASE="${INPUT/$INPUT_DIR/}"
#INPUT_BASE="${INPUT_BASE/.html/}"
INPUT_FILE="${INPUT##*/}"
INPUT_BASE="${INPUT_FILE%%.*}"
#echo $INPUT
#echo $INPUT_DIR
#echo $INPUT_FILE
#echo $INPUT_BASE
STR="${INPUT:3}"
BIN=./bin$STR
BIN_DIR=${BIN%/*}
#BIN_BASE="${BIN/$BIN_DIR/}"
#BIN_BASE="${BIN_BASE/.html/}"
BIN_FILE="${BIN##*/}"
BIN_BASE="${BIN_FILE%%.*}"
#echo $BIN
#echo $BIN_DIR
#echo $BIN_FILE
#echo $BIN_BASE
MIN=./min$STR
MIN_DIR=${MIN%/*}
#MIN_BASE="${MIN/$MIN_DIR/}"
#MIN_BASE="${MIN_BASE/.html/}"
MIN_FILE="${MIN##*/}"
MIN_BASE="${MIN_FILE%%.*}"

OPT=./opt$STR
OPT_DIR=${OPT%/*}
#OPT_BASE="${OPT/$OPT_DIR/}"
#echo $BASE
#OPT_BASE="${OPT_BASE/.html/}"
OPT_FILE="${OPT##*/}"
OPT_BASE="${OPT_FILE%%.*}"
OPT_CRIT="$OPT_DIR/$OPT_BASE.crt.html"
OPT_TWIN="$OPT_DIR/$OPT_BASE.opt.html"
#echo $OPT
#echo $OPT_DIR
#echo $OPT_FILE
#echo $OPT_BASE
#echo $OPT_CRIT
#echo $OPT_TWIN
#echo "str" $STR
#echo "bin" $BIN
#echo "min" $MIN
#echo "opt" $OPT
#echo "dir" $DIR
#echo "base" $BASE
mkdir -p $BIN_DIR
mkdir -p $MIN_DIR
mkdir -p $OPT_DIR
cp -u $INPUT $BIN
cp -u $BIN $MIN
#electron --enable-logging . --input "//$INPUT" --script ./script.js --outputDir "//$BIN_DIR" --show --scripts linkqueue.js font.characters.js sitemap.js checkmissing.js
html-minifier \
--collapse-boolean-attributes --remove-comments --remove-empty-attributes --remove-redundant-attributes \
--preserve-line-breaks --decode-entities --minify-js --remove-style-link-type-attributes \
--remove-script-type-attributes --prevent-attributes-escaping -o "$MIN" "$BIN"
cp $MIN $OPT
# saving from $OPT to $DIR/$BASE.opt.html and back to $OPT prevents `invalid filename $OPT` error.
#critical "$MIN" --minify true --base ./min/ --ignore "@font-face" --ignore "fonts.google" --inline > $OPT_CRIT 
#inline-critical "$MIN" --base ./min/ --ignore "@font-face" --ignore "/fonts.google/" > $OPT_CRIT 
#if [ ! -f $OPT_CRIT ]; then
	cp $OPT $OPT_CRIT
#fi
html-minifier \
--collapse-boolean-attributes --remove-comments --remove-empty-attributes --remove-redundant-attributes \
--decode-entities --minify-js --remove-style-link-type-attributes \
--remove-script-type-attributes --minify-css --prevent-attributes-escaping -o "$OPT" "$OPT_CRIT"
#zopfli --i1000 $OPT
