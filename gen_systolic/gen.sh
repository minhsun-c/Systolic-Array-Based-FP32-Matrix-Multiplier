SIZE=2
WIDTH=32
mkdir obj build
gcc -o build/main main.c
./build/main $SIZE $WIDTH >systolic$SIZEx$SIZE.v
rm -rf obj
rm -rf build
echo "END"
