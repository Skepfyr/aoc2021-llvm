llc day1.ll # Dump assembly for debugging
llc -filetype=obj day1.ll -o day1.o --relocation-model=pic
clang day1.o -o app
