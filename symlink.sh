INPUT="$@"
#echo "$#"
#echo $INPUT
STR="${INPUT:3}"
BIN="./bin$STR"
BIN_DIR="${BIN%/*}"
#echo $BIN
#echo $BIN_DIR
MIN="./min$STR"
MIN_DIR="${MIN%/*}"
#echo $MIN
#echo $MIN_DIR
OPT="./opt$STR"
OPT_DIR="${OPT%/*}"
#echo $OPT
#echo $OPT_DIR
mkdir -p $BIN_DIR
mkdir -p $MIN_DIR
mkdir -p $OPT_DIR

cp -s "$(pwd)/$INPUT" "$BIN"
cp -s "$(pwd)/$INPUT" "$MIN"
cp -s "$(pwd)/$INPUT" "$OPT"
#echo $(pwd)/$INPUT
