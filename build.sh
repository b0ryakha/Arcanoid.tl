tl check ./sources/*.tl &&
tl gen ./sources/*.tl &&

rm -rf build &&
mkdir build &&
mv ./sources/*.lua ./build/