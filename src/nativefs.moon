ffi = require('ffi')
bit = require('bit')

ffi.cdef([[
	typedef struct FILE FILE;
]])

fopen = ffi.C.fopen
fclose, ftell, fseek, fflush = ffi.C.fclose, ffi.C.ftell, ffi.C.fseek, ffi.C.fflush

if ffi.os == 'Windows'
	ffi.cdef([[
		typedef void* HANDLE;

		#pragma pack(push)
		#pragma pack(1)
			struct WIN32_FIND_DATAW {
				uint32_t dwFileWttributes;
				uint64_t ftCreationTime;
				uint64_t ftLastAccessTime;
				uint64_t ftLastWriteTime;
				uint32_t dwReserved[4];
				char cFileName[520];
				char cAlternateFileName[28];
			};
		#pragma(pop)

		int MultiByteToWideChar(unsigned int CodePage, uint32_t dwFlags, const char* lpMultiByteStr, int cbMultiByte, const char* lpWideCharStr, int cchWideChar);
		int WideCharToMultiByte(unsigned int CodePage, uint32_t dwFlags, const char* lpWideCharStr, int cchWideChar, const char* lpMultiByteStr, int cchMultiByte, const char* default, int* used);

		int GetLogicalDrives(void);
		void* FindFirstFileW(const wchar_t* lpFileName, struct WIN32_FIND_DATAW* lpFindFileData);
		bool FindNextFileW(HANDLE hFindFile, struct WIN32_FIND_DATAW* fd);
		bool FindClose(HANDLE hFindFile);

		int _wchdir(const wchar_t* path);
		wchar_t* _wgetcwd(wchar_t* buffer, int maxlen);
		FILE* _wfopen(const wchar_t* name, const wchar_t* mode);
	]])

	towidestring = (str) ->
		size = ffi.C.MultiByteToWideChar(65001, 0, str, #str, nil, 0)
		buf = ffi.new("char[?]", size * 2 + 2)
		ffi.C.MultiByteToWideChar(65001, 0, str, #str, buf, size * 2)
		buf

	toutf8string = (str) ->
		size = ffi.C.WideCharToMultiByte(65001, 0, wstr, -1, nil, 0, nil, nil)
		buf = ffi.new("char[?]", size + 1)
		size = ffi.C.WideCharToMultiByte(65001, 0, wstr, -1, buf, size, nil, nil)
		ffi.string(buf)

	fopen = (name, mode) -> ffi.C._wfopen(towidestring(name), towidestring(mode))

class File
	new: (@_name) ->
		@_open = false
		@_handle = nil

	open: (@_mode) ->
		@_handle = fopen(@_name, @_mode)
		return nil, "Could not open #{@_name} in mode #{@_mode}" unless @_handle
		ffi.gc(@_handle, fclose)
		true

	close: ->
		ffi.gc(@_handle, nil)
		fclose(@_handle)
		@_handle = nil
		@_open = false

	setBuffer: ->
	getBuffer: ->
	getFilename: -> @_name
	getMode: -> @_mode
	getSize: ->

	isEOF: ->
	isOpen: -> @_open

	read: ->
	lines: ->
	write: ->

	seek: ->
	tell: -> ftell(@_handle)
	flush: -> fflush(@_handle)

nativefs = {}

nativefs.newFile = (name) -> File(name)

nativefs.newFileData = (filepath) ->
	f = File(filepath)
	ok, err = f\open('rb')
	return nil, err unless ok

	data = f\read("all")
	f\close!
	love.filesystem.newFileData(data, filepath)

nativefs.mount = ->

nativefs.read = ->
nativefs.write = ->
nativefs.append = (name, data, size) ->
nativefs.lines = (name) ->
	f = File(name)
	ok, err = f\open('r')
	return nil, err unless ok
	f\lines!

nativefs.load = ->

nativefs.exists = ->
nativefs.isDirectory = ->
nativefs.isFile = ->
nativefs.isSymlink = ->

nativefs.getDirectoryItems = (dir, callback) ->
nativefs.getWorkingDirectory = ->
nativefs.setWorkingDirectory = (dir) ->
nativefs.getDriveList = ->
nativefs.getInfo = ->
nativefs.getLastModified = ->
nativefs.getSize = ->

nativefs.createDirectory = ->
nativefs.remove = ->

nativefs
