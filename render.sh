INPUT="$@"
#echo $INPUT
STR="${INPUT:3}"
BIN=./bin$STR
BIN_DIR=${BIN%/*}
BIN_BASE="${BIN/$BIN_DIR/}"
BIN_BASE="${BIN_BASE/.md/}"

MIN=./min$STR
MIN_DIR=${MIN%/*}
MIN_BASE="${MIN/$MIN_DIR/}"
MIN_BASE="${MIN_BASE/.md/}"

OPT=./opt$STR
OPT_DIR=${OPT%/*}
OPT_BASE="${OPT/$OPT_DIR/}"
OPT_BASE="${OPT_BASE/.html/}"
OPT_CRIT=$OPT_DIR$OPT_BASE.crt.html
OPT_TWIN=$OPT_DIR$OPT_BASE.opt.html

mkdir -p $BIN_DIR
mkdir -p $MIN_DIR
mkdir -p $OPT_DIR

electron --enable-logging ./render/index.js \
-md markdown-it-abbr markdown-it-attrs markdown-it-emoji markdown-it-footnote \
markdown-it-headinganchor \
-s ./render/build.js -r src -i $INPUT -o $BIN_DIR$BIN_BASE/index.html --show
