all: lzma.dll

lzma.dll: LzFind.o LzAlloc.o LzmaDec.o LzmaEnc.o LzmaLib.o llzma.o 
	gcc -O -shared -fPIC -o lzma.dll llzma.o LzmaLib.o LzmaEnc.o LzmaDec.o LzFind.o LzAlloc.o -L"C:\Users\columna1\projects\lua-power-cherrypicked\bin\mingw64" -llua51
	#rm C:\Users\columna1\projects\replay\lzma.dll
	#cp C:\Users\columna1\projects\lua-power-cherrypicked\csrc\lua-lzma\lzma.dll C:\Users\columna1\projects\replay\lzma.dll
LzFind.o: LzFind.c
	gcc -O2 -c LzFind.c 
LzAlloc.o: LzAlloc.c
	gcc -O2 -c LzAlloc.c 
LzmaDec.o: LzmaDec.c
	gcc -O2 -c LzmaDec.c 
LzmaEnc.o: LzmaEnc.c
	gcc -O2 -c LzmaEnc.c 
LzmaLib.o: LzmaLib.c
	gcc -O2 -c LzmaLib.c 
llzma.o:   llzma.c
	gcc -IC:\Users\columna1\projects\lua-power-cherrypicked\csrc\luajit\src\src -O2 -c -o llzma.o llzma.c
clean:
	rm lzma.dll
	rm llzma.o
	rm LzmaLib.o
	rm LzmaEnc.o
	rm LzmaDec.o
	rm LzFind.o
	rm LzAlloc.o