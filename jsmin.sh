CLOSURE=./node_modules/google-closure-compiler/compiler.jar
INPUT="$@"
#echo $INPUT
STR="${INPUT:3}"
BIN=./bin$STR
BIN_DIR=${BIN%/*}
BIN_BASE="${BIN/$BIN_DIR/}"
BIN_BASE="${BIN_BASE/.js/}"

MIN=./min$STR
MIN_DIR=${MIN%/*}
MIN_BASE="${MIN/$MIN_DIR/}"
MIN_BASE="${MIN_BASE/.js/}"

OPT=./opt$STR
OPT_DIR=${OPT%/*}
OPT_BASE="${OPT/$OPT_DIR/}"
#echo $BASE
OPT_BASE="${OPT_BASE/.js/}"
OPT_CRIT=$OPT_DIR$OPT_BASE.crt.js
OPT_TWIN=$OPT_DIR$OPT_BASE.opt.js

mkdir -p $BIN_DIR
mkdir -p $MIN_DIR
mkdir -p $OPT_DIR

cp $INPUT $BIN
cp $BIN $MIN
cp $MIN $OPT

java -jar $CLOSURE --js $INPUT --compilation_level SIMPLE_OPTIMIZATIONS --js_output_file $BIN
java -jar $CLOSURE --js $INPUT --compilation_level ADVANCED_OPTIMIZATIONS --js_output_file $OPT
