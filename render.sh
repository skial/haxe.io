INPUT="$@"
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
OPT_BASE="${OPT_BASE/.md/}"
OPT_CRIT=$OPT_DIR$OPT_BASE.crt.html
OPT_TWIN=$OPT_DIR$OPT_BASE.opt.html

mkdir -p $BIN_DIR$BIN_BASE
mkdir -p $MIN_DIR$MIN_BASE
mkdir -p $OPT_DIR$OPT_BASE

electron --enable-logging ./render/index.js \
-md markdown-it-abbr markdown-it-attrs markdown-it-emoji \
markdown-it-footnote markdown-it-headinganchor \
-s ./render/build.js -r src -i $INPUT -o $BIN_DIR$BIN_BASE/index.max.html -b src \
-j ./src/data/ld36.json ./src/data/ld36.manual.json \
--scripts ../site/subresourceintegrity.js ../site/font.characters.js ../site/screengrab.js \
-rs opt -w 1920 -h 1080

html-minifier \
--collapse-boolean-attributes --remove-comments --remove-empty-attributes --remove-redundant-attributes \
--collapse-whitespace --decode-entities --remove-style-link-type-attributes \
--remove-script-type-attributes -o $OPT_DIR$OPT_BASE/index.html $BIN_DIR$BIN_BASE/index.max.html
