
#include "LzmaLib.h"
#include "LzmaEnc.h"
#include "LzmaDec.h"
#include "LzAlloc.h"
#include "lua.h"
#include "lauxlib.h"
#include <assert.h>


#ifdef EJOY2D_OS
#include "array.h"
#else
#if defined(_MSC_VER)
#	include <malloc.h>
#	define ARRAY(type, name, size) type* name = (type*)_alloca((size) * sizeof(type))
#else
#	define ARRAY(type, name, size) type name[size]
#endif
#endif


#define LZMA_PROPS_SIZE 5
#define LENGTH_SIZE 8

static void *SzAlloc(void *p, size_t size) { p = p; return MyAlloc(size); }
static void SzFree(void *p, void *address) { p = p; MyFree(address); }
static ISzAlloc g_Alloc = { SzAlloc, SzFree };

static int
compress(const unsigned char* src, size_t src_len, unsigned char* dst, size_t* dst_len) {
	size_t props_len=LZMA_PROPS_SIZE;
	int res = LzmaCompress(&dst[LENGTH_SIZE+LZMA_PROPS_SIZE], dst_len, src, src_len, &dst[0], &props_len, 
		5, 1<<16, 3, 0, 2, 32, 2);
	assert(props_len == LZMA_PROPS_SIZE);
	if (res==SZ_OK) {
		dst[5] = src_len ;
		dst[6] = src_len >> 8;
		dst[7] = src_len >> 16;
		dst[8] = src_len >> 24;
		dst[9] = src_len >> 32;
		dst[10] = src_len >> 40;
		dst[11] = src_len >> 48;
		dst[12] = src_len >> 56;
	}
	return res;
}

static int
lcompress(lua_State* L) {
	const unsigned char* code = (unsigned char*)luaL_checkstring(L, 1);
	size_t len = lua_objlen(L, 1);
	if (len <= LZMA_PROPS_SIZE)
		return luaL_error(L, "too short to compress");

	size_t dst_len = len + len/3 + 128;
	ARRAY(unsigned char, dst, LENGTH_SIZE+LZMA_PROPS_SIZE+dst_len);

	int ret = compress(code, len, dst, &dst_len);
	if (ret != SZ_OK) 
		return luaL_error(L, "Lzma compress failed:%d", ret);
	lua_pushlstring(L,(char*)dst, LENGTH_SIZE+LZMA_PROPS_SIZE + dst_len);
	return 1;
}

//static unsigned char* swapBytes(unsigned char)

static int
lzmaDecompress(lua_State* L) {
	//(const uint8_t *input, uint32_t inputSize, uint32_t *outputSize)
	size_t inputSize;
	unsigned char* input = (unsigned char*)luaL_checklstring(L, 1, &inputSize);
	if (inputSize < 13)
		return luaL_error(L, "invalid lzma header"); // invalid header!

	// extract the size from the header
	UInt64 size = 0;
	for (int i = 0; i < 8; i++)
		size |= (input[5 + i] << (i * 8));

	if (size <= (256 * 1024 * 1024)) {
		//auto blob = std::make_unique<uint8_t[]>(size);
		ARRAY(unsigned char, dst, size);

		ELzmaStatus lzmaStatus;
		SizeT procOutSize = size, procInSize = inputSize - 13;
		int status = LzmaDecode(dst, &procOutSize, &input[13], &procInSize, input, 5, LZMA_FINISH_END, &lzmaStatus, &g_Alloc);
		//return luaL_error(L, "Lzma size is :%d", size);

		if (status == SZ_OK && procOutSize == size) {
			//*outputSize = size;
			//return blob;
			lua_pushlstring(L, (char*)dst, size);
			return 1;
		}
	}

	return 1;
}

static const luaL_Reg R[] = {
    {"compress", lcompress},
	{"uncompress", lzmaDecompress},
    {NULL, NULL},
  };

//__declspec(dllexport) 
LUALIB_API int 
luaopen_lzma(lua_State* L) {

  luaL_register(L, "lzma", R);

  return 1;
}

