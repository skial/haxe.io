INPUT="$@"
echo $INPUT
INPUT_DIR=${INPUT%/*}
if [ "$INPUT_DIR" == "$INPUT" ]; then
	#echo "correcting path"
	INPUT="${INPUT//\\//}"
	INPUT_DIR=${INPUT%/*}
fi
INPUT_FILE="${INPUT##*/}"
INPUT_BASE="${INPUT_FILE%%.*}"

STR="${INPUT:3}"
BIN=./bin$STR
BIN_DIR=${BIN%/*}
BIN_FILE="${BIN##*/}"
BIN_BASE="${BIN_FILE%%.*}"

MIN=./min$STR
MIN_DIR=${MIN%/*}
MIN_FILE="${MIN##*/}"
MIN_BASE="${MIN_FILE%%.*}"

OPT=./opt$STR
OPT_DIR=${OPT%/*}
OPT_FILE="${OPT##*/}"
OPT_BASE="${OPT_FILE%%.*}"
OPT_CRIT="$OPT_DIR/$OPT_BASE.crt.css"
OPT_TWIN="$OPT_DIR/$OPT_BASE.opt.css"

echo "creating directories"
mkdir -p $BIN_DIR
mkdir -p $MIN_DIR
mkdir -p $OPT_DIR

echo "running postcss"
postcss -u autoprefixer --autoprefixer.browsers "> 5% in my stats" --autoprefixer.stats "./browserstats/latest.json" -o $BIN $INPUT
echo "copying post processed css to min"
cp -u $BIN $MIN
echo "running cssnano"
cssnano $BIN $MIN
echo "copying from min to opt"
cp -u $MIN $OPT
