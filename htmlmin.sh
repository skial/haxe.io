INPUT="$@"
#echo $INPUT
STR="${INPUT:3}"
BIN=./bin$STR
BIN_DIR=${BIN%/*}
BIN_BASE="${BIN/$BIN_DIR/}"
BIN_BASE="${BIN_BASE/.html/}"

MIN=./min$STR
MIN_DIR=${MIN%/*}
MIN_BASE="${MIN/$MIN_DIR/}"
MIN_BASE="${MIN_BASE/.html/}"

OPT=./opt$STR
OPT_DIR=${OPT%/*}
OPT_BASE="${OPT/$OPT_DIR/}"
#echo $BASE
OPT_BASE="${OPT_BASE/.html/}"
OPT_CRIT=$OPT_DIR$OPT_BASE.crt.html
OPT_TWIN=$OPT_DIR$OPT_BASE.opt.html
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
cp $MIN $OPT
html-minifier \
--collapse-boolean-attributes --remove-comments --remove-empty-attributes --remove-redundant-attributes \
--collapse-whitespace --preserve-line-breaks --decode-entities --minify-js  --remove-style-link-type-attributes \
--remove-script-type-attributes -o $MIN $BIN
#cp -u $OPT $OPT_TWIN
# saving from $OPT to $DIR/$BASE.opt.html and back to $OPT prevents `invalid filename $OPT` error.
critical $OPT --src $OPT --minify true --base ./opt/ --inline --dest $OPT_CRIT 
if [ ! -f $OPT_CRIT ]; then
	cp $OPT $OPT_CRIT
fi
html-minifier \
--collapse-boolean-attributes --remove-comments --remove-empty-attributes --remove-redundant-attributes \
--collapse-whitespace --decode-entities --minify-js  --remove-style-link-type-attributes \
--remove-script-type-attributes --minify-css -o ./$OPT $OPT_CRIT
#zopfli --i1000 $OPT
