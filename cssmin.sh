INPUT="$@"
#echo $INPUT
STR="${INPUT:3}"
BIN=./bin$STR
BIN_DIR=${BIN%/*}
BIN_BASE="${BIN/$BIN_DIR/}"
BIN_BASE="${BIN_BASE/.css/}"

MIN=./min$STR
MIN_DIR=${MIN%/*}
MIN_BASE="${MIN/$MIN_DIR/}"
MIN_BASE="${MIN_BASE/.css/}"

OPT=./opt$STR
OPT_DIR=${OPT%/*}
OPT_BASE="${OPT/$OPT_DIR/}"
#echo $BASE
OPT_BASE="${OPT_BASE/.css/}"
OPT_CRIT=$OPT_DIR$OPT_BASE.crt.css
OPT_TWIN=$OPT_DIR$OPT_BASE.opt.css

mkdir -p $BIN_DIR
mkdir -p $MIN_DIR
mkdir -p $OPT_DIR
#cp -u $INPUT $BIN
#cp -u $BIN $MIN
#cp $MIN $OPT

postcss -u autoprefixer --autoprefixer.browsers "> 5% in my stats" --autoprefixer.stats "./browserstats/latest.json" -o $BIN $INPUT
cssnano $BIN $MIN
cp $MIN $OPT
