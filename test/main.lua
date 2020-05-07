io.stdout:setvbuf('no')
package.path = package.path .. ';../?.lua'

local ffi = require('ffi')
local lu = require('luaunit')
local lfs = love.filesystem
local fs

local equals, notEquals = lu.assertEquals, lu.assertNotEquals
local isError, containsError = lu.assertErrorMsgEquals, lu.assertErrorMsgContains
local contains = lu.assertStrContains

local function notFailed(ok, err)
	equals(ok, true)
	equals(err, nil)
end

local function hasFailed(expected, ok, err)
	equals(ok, false)
	if expected then
		equals(err, expected)
	end
end

-----------------------------------------------------------------------------

function test_fs_newFile()
	local file = fs.newFile('test.file')
	notEquals(file, nil)
	equals(file:getFilename(), 'test.file')
end

function test_fs_newFileData()
	local fd = fs.newFileData('data/ümläüt.txt')
	local filesize = love.filesystem.newFile('data/ümläüt.txt'):getSize()
	equals(fd:getSize(), filesize)

	local d = love.filesystem.read('data/ümläüt.txt')
	equals(fd:getString(), d)
end

function test_fs_mount()
	equals(fs.mount('data', 'test_data'), true)
	local data, size = love.filesystem.read('test_data/ümläüt.txt')
	notEquals(data, nil)
	notEquals(size, nil)
	equals(fs.unmount('data'), true)
end

function test_fs_read()
	local text, textSize = love.filesystem.read('data/ümläüt.txt')
	local data, size = fs.read('data/ümläüt.txt')
	equals(size, textSize)
	equals(data, text)

	local data, size = fs.read('data/ümläüt.txt', 'all')
	equals(size, textSize)
	equals(data, text)

	local data, size = fs.read('string', 'data/ümläüt.txt')
	equals(size, textSize)
	equals(data, text)

	local data, size = fs.read('data', 'data/ümläüt.txt', 'all')
	equals(size, textSize)
	equals(data:type(), 'FileData')
	equals(data:getSize(), size)
	equals(data:getString(), text)

	local foo, bar = fs.read('does_not_exist')
	equals(foo, nil)
	contains(bar, "Could not open")
end

function test_fs_write()
	local data, size = fs.read('data/ümläüt.txt')
	notFailed(fs.write('data/write.test', data))

	local data2, size2 = love.filesystem.read('data', 'data/write.test')
	notFailed(fs.write('data/write.test', data2, 100))
	local file = fs.newFile('data/write.test')
	equals(file:getSize(), 100)

	fs.remove('data/write.test')
end

function test_fs_append()
	local text, textSize = love.filesystem.read('data/ümläüt.txt')
	fs.write('data/append.test', text)
	fs.append('data/append.test', text)

	local text2, textSize2 = love.filesystem.read('data/append.test')
	equals(textSize2, textSize * 2)
	equals(text2, text .. text)

	fs.remove('data/append.test')
end

function test_fs_lines()
end

function test_fs_load()
	local chunk, err = fs.load('data/test.lua')
	notEquals(chunk, nil)
	local result = chunk()
	equals(result, 'hello')
end

function test_fs_getDirectoryItems()
	local items = fs.getDirectoryItems('data')

	local map = {}
	for i = 1, #items do map[items[i]] = true end
	equals(map['ümläüt.txt'], true)
	equals(map['test.lua'], true)
end

function test_fs_setWorkingDirectory()
	local wd = fs.getWorkingDirectory()

	notFailed(fs.setWorkingDirectory('data'))

	local cwd = fs.getWorkingDirectory()
	notEquals(cwd, nil)
	equals(cwd:sub(#cwd - 3, #cwd), 'data')

	hasFailed('Could not set working directory', fs.setWorkingDirectory('does_not_exist'))

	notFailed(fs.setWorkingDirectory('..'))
	equals(fs.getWorkingDirectory(), wd)
end

function test_fs_getDriveList()
	local dl = fs.getDriveList()
	notEquals(dl, nil)
	notEquals(#dl, 0)
	if ffi.os ~= 'Windows' then
		equals(dl[1], '/')
	end
end

function test_fs_getInfo()
end

function test_fs_createDirectory()
end

function test_fs_remove()
	local text = love.filesystem.read('data/ümläüt.txt')
	fs.write('data/remove.test', text)
	notFailed(fs.remove('data/remove.test'))
	equals(love.filesystem.getInfo('data/remove.test'), nil)
end

-----------------------------------------------------------------------------

function test_File_open()
	local f = fs.newFile('data/ümläüt.txt')
	notEquals(f, nil)
	equals(f:isOpen(), false)
	equals(f:getMode(), 'c')

	notFailed(f:open('r'))
	equals(f:isOpen(), true)
	equals(f:getMode(), 'r')

	hasFailed('File is already open', f:open())
	equals(f:getMode(), 'r')

	notFailed(f:close())
	equals(f:isOpen(), false)
	equals(f:getMode(), 'c')

	hasFailed('File is not open', f:close())
	equals(f:getMode(), 'c')

	f:release()
end

function test_File_setBuffer()
end

function test_File_isEOF()
	local f = love.filesystem.newFile('data/ümläüt.txt')
	f:open('r')
	f:read(f:getSize() - 1)
	equals(f:isEOF(), false)

	f:read(1)
	equals(f:isEOF(), true)
end

function test_File_read()
end

function test_File_lines()
end

function test_File_write()
end

function test_File_seek()
end

function test_File_tell()
end

function test_File_flush()
end

function test_xxx_globalsCheck()
	for k, v in pairs(_G) do
		equals(v, _globals[k])
	end
end

_globals = {}
for k, v in pairs(_G) do _globals[k] = v end

fs = require('nativefs')

lu.LuaUnit.new():runSuite('--verbose')
love.event.quit()
