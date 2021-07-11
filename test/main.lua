io.stdout:setvbuf('no')
package.path = package.path .. ';../?.lua'

local ffi = require('ffi')
local lu = require('luaunit')
local fs

local equals, notEquals = lu.assertEquals, lu.assertNotEquals
local contains = lu.assertStrContains
local errorContains = lu.assertErrorMsgContains

local function notFailed(ok, err)
	equals(ok, true)
	if err then print("ERROR: " .. err) end
	equals(err, nil)
end

local function hasFailed(expected, ok, err)
	equals(ok or false, false)
	if expected then
		equals(err, expected)
	end
end

-----------------------------------------------------------------------------

local testFile1, testSize1 = 'data/ümläüt.txt', 446
local testFile2, testSize2 = 'data/𠆢ßЩ.txt', 450

function test_fs_newFile()
	errorContains('bad argument', fs.newFile)
	for _, v in ipairs({ 1, true, false, function() end, {} }) do
		errorContains(type(v), fs.newFile, v)
	end

	local file = fs.newFile('test.file')
	notEquals(file, nil)
	equals(file:type(), 'File')
	equals(file:typeOf('File'), true)
	equals(file:getMode(), 'c')
	equals(file:isEOF(), true)
	equals(file:getFilename(), 'test.file')
end

function test_fs_newFileData()
	local fd = fs.newFileData(testFile1)
	local filesize = love.filesystem.newFile(testFile1):getSize()
	equals(fd:getSize(), filesize)

	local d = love.filesystem.read(testFile1)
	equals(fd:getString(), d)
end

function test_fs_mount()
	equals(fs.mount('data', 'test_data'), true)
	local data, size = love.filesystem.read('test_data/' .. love.path.leaf(testFile1))
	notEquals(data, nil)
	notEquals(size, nil)
	equals(fs.unmount('data'), true)
end

function test_fs_read()
	local text, textSize = love.filesystem.read(testFile1)
	local data, size = fs.read(testFile1)
	equals(size, textSize)
	equals(data, text)

	local data, size = fs.read(testFile1, 'all')
	equals(size, textSize)
	equals(data, text)

	local data, size = fs.read('string', testFile1)
	equals(size, textSize)
	equals(data, text)

	local data, size = fs.read('data', testFile1, 'all')
	equals(size, textSize)
	equals(data:type(), 'FileData')
	equals(data:getSize(), size)
	equals(data:getString(), text)

	local foo, bar = fs.read('does_not_exist')
	equals(foo, nil)
	contains(bar, "Could not open")
end

function test_fs_write()
	local data, size = fs.read(testFile1)
	notFailed(fs.write('data/write.test', data))

	local data2, size2 = love.filesystem.read('data', 'data/write.test')
	notFailed(fs.write('data/write.test', data2, 100))
	local file = fs.newFile('data/write.test')
	equals(file:getSize(), 100)

	fs.remove('data/write.test')
end

function test_fs_append()
	local text, textSize = love.filesystem.read(testFile1)
	fs.write('data/append.test', text)
	fs.append('data/append.test', text)

	local text2, textSize2 = love.filesystem.read('data/append.test')
	equals(textSize2, textSize * 2)
	equals(text2, text .. text)

	fs.remove('data/append.test')
end

function test_fs_lines()
	local count, bytes = 0, 0
	for line in fs.lines(testFile1) do
		count = count + 1
		bytes = bytes + #line
	end
	equals(count, 4)
	equals(bytes, testSize1 - count)

	local code = ""
	for line in fs.lines('main.lua') do
		code = code .. line .. '\n'
	end
	local r = fs.read('main.lua')
	equals(code, r)
end

function test_fs_load()
	local chunk, err = fs.load('data/test.lua')
	notEquals(chunk, nil)
	local result = chunk()
	equals(result, 'hello')
end

function test_fs_getDirectoryItems()
	local items, map = fs.getDirectoryItems('data'), {}
	for i = 1, #items do map[items[i]] = true end

	local items2, map2 = love.filesystem.getDirectoryItems('data'), {}
	for i = 1, #items2 do map2[items2[i]] = true end

	equals(#items, #items2)

	for i = 1, #items2 do
		equals(map[items2[i]], map2[items2[i]])
		equals(fs.getInfo('data/' .. items2[i]), love.filesystem.getInfo('data/' .. items2[i]))
	end

	equals(#fs.getDirectoryItems('does_not_exist'), 0)
end

function test_fs_getDirectoryItemsInfo()
	local files = fs.getDirectoryItems('data')
	local items, map = {}, {}
	for i = 1, #files do
		local info = fs.getInfo('data/' .. files[i])
		if info then
			info.name = files[i]
			table.insert(items, info)
		end
	end

	for i = 1, #items do map[items[i].name] = true end
	local itemsEx, mapEx = fs.getDirectoryItemsInfo('data'), {}
	for i = 1, #itemsEx do mapEx[itemsEx[i].name] = itemsEx[i] end

	equals(#items, #itemsEx)
	for i = 1, #itemsEx do
		local item = itemsEx[i]
		equals(map[item.name], true)
		local info = love.filesystem.getInfo('data/' .. item.name)
		equals(info.type, item.type)
		equals(info.size, item.size)
		equals(info.modtime, item.modtime)
	end
	equals(#fs.getDirectoryItemsInfo('does_not_exist'), 0)
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
	local info = fs.getInfo('data')
	notEquals(info, nil)
	equals(info.type, 'directory')

	local info = fs.getInfo('data', 'file')
	equals(info, nil)

	local info = fs.getInfo('main.lua')
	notEquals(info, nil)
	equals(info.type, 'file')

	equals(fs.getInfo('does_not_exist', nil))

	local info = fs.getInfo(testFile1)
	notEquals(info, nil)
	equals(info.type, 'file')
	equals(info.size, testSize1)
	notEquals(info.modtime, nil)

	local info = fs.getInfo(testFile2)
	notEquals(info, nil)
	equals(info.type, 'file')
	equals(info.size, testSize2)
	notEquals(info.modtime, nil)
end

function test_fs_createDirectory()
	notFailed(fs.createDirectory('data/a/b/c/defg/h'))
	notEquals(fs.getInfo('data/a/b/c/defg/h'), nil)
	fs.remove('data/a/b/c/defg/h')
	fs.remove('data/a/b/c/defg')
	fs.remove('data/a/b/c')
	fs.remove('data/a/b')
	fs.remove('data/a')

	local d = fs.getWorkingDirectory() .. '/data/a'
	notFailed(fs.createDirectory(d))
	notEquals(fs.getInfo(d), nil)
	fs.remove(d)
end

function test_fs_remove()
	local text = love.filesystem.read(testFile1)
	fs.write('data/remove.test', text)
	notFailed(fs.remove('data/remove.test'))
	equals(love.filesystem.getInfo('data/remove.test'), nil)

	fs.createDirectory('data/test1')
	fs.createDirectory('data/test1/test2')
	notFailed(fs.remove('data/test1/test2'))
	equals(love.filesystem.getInfo('data/test1/test2'), nil)
	notFailed(fs.remove('data/test1'))
	equals(love.filesystem.getInfo('data/test1'), nil)

	hasFailed("Could not remove does_not_exist", fs.remove('does_not_exist'))
end

-----------------------------------------------------------------------------

function test_File_open()
	local f = fs.newFile(testFile1)
	notEquals(f, nil)
	equals(f:isOpen(), false)
	equals(f:getMode(), 'c')

	notFailed(f:open('r'))
	equals(f:isOpen(), true)
	equals(f:getMode(), 'r')

	hasFailed('File ' .. testFile1 .. ' is already open', f:open())
	equals(f:getMode(), 'r')

	notFailed(f:close())
	equals(f:isOpen(), false)
	equals(f:getMode(), 'c')

	hasFailed('File is not open', f:close())
	equals(f:getMode(), 'c')
	f:close()

	local f = fs.newFile(testFile2)
	notFailed(f:open('r'))
	f:close()
end

function test_File_setBuffer()
	local f = fs.newFile('data/test.test')
	f:open('w')
	notFailed(f:setBuffer('none', 0))
	notFailed(f:setBuffer('line', 0))
	notFailed(f:setBuffer('full', 0))
	f:close()
	fs.remove('data/test.test')
end

function test_File_isEOF()
	local f = fs.newFile(testFile1)
	f:open('r')
	f:read(f:getSize() - 1)
	equals(f:isEOF(), false)

	f:read(1)
	equals(f:isEOF(), true)
end

function test_File_read()
	local f = fs.newFile(testFile1)
	f:open('r')
	local data, size = f:read(5)
	equals(data, 'Lorem')

	local data, size = f:read(6)
	equals(data, ' ipsum')
	f:close()
end

function test_File_lines()
	local text = fs.read(testFile2)
	local f = fs.newFile(testFile2)
	local lines = ""
	f:open('r')
	for line in f:lines() do lines = lines .. line .. '\r\n' end
	f:close()
	equals(lines, text)

	local text = fs.read(testFile1)
	local f = fs.newFile(testFile1)
	local lines = ""
	f:open('r')
	for line in f:lines() do lines = lines .. line .. '\n' end
	f:close()
	equals(lines, text)
end

function test_File_write()
	local f = fs.newFile('data/write.test')
	notFailed(f:open('w'))
	notFailed(f:write('hello'))
	equals(f:getSize(), 5)
	f:close()
	f:open('a')
	notFailed(f:write('world'))
	equals(f:getSize(), 10)
	f:close()

	notFailed(f:open('r'))
	local hello, size = f:read()
	equals(hello, 'helloworld')
	equals(size, #'helloworld')
	f:close()

	fs.remove('data/write.test')
end

function test_File_seek()
	local f = fs.newFile(testFile1)
	f:open('r')
	f:seek(72)
	local data, size = f:read(6)
	equals(data, 'tempor')
	f:close()
end

function test_File_tell()
	local f = fs.newFile(testFile1)

	hasFailed("Invalid position", f:tell())

	f:open('r')
	f:read(172)
	equals(f:tell(), 172)
	f:close()
end

function test_File_flush()
	local f = fs.newFile('data/write.test')

	hasFailed("File is not opened for writing", f:flush())

	f:open('w')
	f:write('hello')
	notFailed(f:flush())

	f:close()
end

local _globals = {}

function test_xxx_globalsCheck()
	for k, v in pairs(_G) do
		if v ~= _globals[k] then
			print("LEAKED GLOBAL: " .. k)
		end
		equals(v, _globals[k])
	end
end

for k, v in pairs(_G) do _globals[k] = v end

fs = require('nativefs')

lu.LuaUnit.new():runSuite('--verbose')
love.event.quit()
