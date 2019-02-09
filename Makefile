HPATCH_OBJ := \
    libHDiffPatch/HPatch/patch.o \
    file_for_patch.o \
    dirDiffPatch/dir_patch/dir_patch.o \
    dirDiffPatch/dir_patch/res_handle_limit.o \
    dirDiffPatch/dir_patch/ref_stream.o \
    dirDiffPatch/dir_patch/new_stream.o \
    libHDiffPatch/HDiff/private_diff/limit_mem_diff/adler_roll.o

HDIFF_OBJ := \
    libHDiffPatch/HDiff/diff.o \
    libHDiffPatch/HDiff/private_diff/bytes_rle.o \
    libHDiffPatch/HDiff/private_diff/suffix_string.o \
    libHDiffPatch/HDiff/private_diff/compress_detect.o \
    libHDiffPatch/HDiff/private_diff/limit_mem_diff/digest_matcher.o \
    libHDiffPatch/HDiff/private_diff/limit_mem_diff/stream_serialize.o \
    libHDiffPatch/HDiff/private_diff/libdivsufsort/divsufsort64.o \
    libHDiffPatch/HDiff/private_diff/libdivsufsort/divsufsort.o \
    dirDiffPatch/dir_diff/dir_diff.o \
    $(HPATCH_OBJ)

DEF_FLAGS := \
    -O3 -DNDEBUG \
    -D_7ZIP_ST \
    -D_IS_USED_MULTITHREAD=0 \
    -D_IS_NEED_ORIGINAL=1 \
    -D_IS_NEED_DIR_DIFF_PATCH=1 \
    \
    -D_IS_NEED_ALL_CompressPlugin=0 \
    -D_IS_NEED_DEFAULT_CompressPlugin=0 \
    -D_CompressPlugin_zlib  \
    -D_CompressPlugin_bz2  \
    -D_CompressPlugin_lzma -I'../lzma/C' \
    -D_CompressPlugin_lzma2 -I'../lzma/C' \
    \
    -D_IS_NEED_ALL_ChecksumPlugin=0 \
    -D_IS_NEED_DEFAULT_ChecksumPlugin=0 \
    -D_ChecksumPlugin_crc32 \
    -D_ChecksumPlugin_fadler64

PATCH_LINK := -lz -lbz2
DIFF_LINK  := $(PATCH_LINK)

CFLAGS     += $(DEF_FLAGS) 
CXXFLAGS   += $(DEF_FLAGS)

.PHONY: all install clean

all: lzmaLib libhdiffpatch.a hdiffz hpatchz

LZMA_DEC_OBJ := 'LzmaDec.o' 'Lzma2Dec.o' 
LZMA_OBJ     := 'LzFind.o' 'LzmaEnc.o' 'Lzma2Enc.o' $(LZMA_DEC_OBJ)
lzmaLib: # https://www.7-zip.org/sdk.html  https://github.com/sisong/lzma
	$(CC) -c $(CFLAGS) \
		'../lzma/C/LzFind.c' '../lzma/C/LzmaDec.c' '../lzma/C/LzmaEnc.c' \
		'../lzma/C/Lzma2Dec.c' '../lzma/C/Lzma2Enc.c'

libhdiffpatch.a: $(HDIFF_OBJ)
	$(AR) rcs $@ $^

hdiffz: 
	$(CXX) hdiffz.cpp libhdiffpatch.a $(LZMA_OBJ) $(CXXFLAGS) $(DIFF_LINK) -o hdiffz
hpatchz: 
	$(CC) hpatchz.c $(HPATCH_OBJ) $(LZMA_DEC_OBJ) $(CFLAGS) $(PATCH_LINK) -o hpatchz

RM := rm -f
INSTALL_X := install -m 0755
INSTALL_BIN := $(DESTDIR)/usr/local/bin

clean:
	$(RM) libhdiffpatch.a hdiffz hpatchz $(HDIFF_OBJ) $(LZMA_OBJ)

install: all
	$(INSTALL_X) hdiffz $(INSTALL_BIN)/hdiffz
	$(INSTALL_X) hpatchz $(INSTALL_BIN)/hpatchz

uninstall:
	$(RM)  $(INSTALL_BIN)/hdiffz  $(INSTALL_BIN)/hpatchz
