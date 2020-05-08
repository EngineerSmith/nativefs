# Native filesystem for LÖVE

nativefs replicates a subset of the [love.filesystem](https://love2d.org/wiki/love.filesystem) API, but without LÖVE's path restrictions. 

## Available functions

### nativefs

* [nativefs.newFile](https://love2d.org/wiki/love.filesystem.newFile)
* [nativefs.newFileData](https://love2d.org/wiki/love.filesystem.newFileData)
* [nativefs.mount](https://love2d.org/wiki/love.filesystem.mount)
* [nativefs.unmount](https://love2d.org/wiki/love.filesystem.unmount)
* [nativefs.read](https://love2d.org/wiki/love.filesystem.read)
* [nativefs.write](https://love2d.org/wiki/love.filesystem.write)
* [nativefs.append](https://love2d.org/wiki/love.filesystem.append)
* [nativefs.lines](https://love2d.org/wiki/love.filesystem.lines)
* [nativefs.load](https://love2d.org/wiki/love.filesystem.load)
* [nativefs.getWorkingDirectory](https://love2d.org/wiki/love.filesystem.getWorkingDirectory)
* [nativefs.getDirectoryItems](https://love2d.org/wiki/love.filesystem.getDirectoryItems)
* [nativefs.getInfo](https://love2d.org/wiki/love.filesystem.getInfo)
* [nativefs.createDirectory](https://love2d.org/wiki/love.filesystem.createDirectory)
* [nativefs.remove](https://love2d.org/wiki/love.filesystem.remove)

Function names in this list are links to their `love.filesystem` counterparts. All functions are designed to work the same as `love.filesystem`, but without the path restrictions that LÖVE imposes; i.e., they allow full access to the filesystem.

Additional functions that not available in `love.filesystem`:

* `nativefs.getDriveList`  
Returns a table of all populated drive letters on Windows (`{ 'C:/', 'D:/', ...}`). On systems that don't use drive letters, a table with the single entry `/` is returned.

* `nativefs.setWorkingDirectory`  
Changes the working directory.

### File

`nativefs.newFile` returns a `File` object that provides these functions:

* [File:open](https://love2d.org/wiki/\(File\):open)
* [File:close](https://love2d.org/wiki/\(File\):close)
* [File:read](https://love2d.org/wiki/\(File\):read)
* [File:write](https://love2d.org/wiki/\(File\):write)
* [File:lines](https://love2d.org/wiki/\(File\):lines)
* [File:isOpen](https://love2d.org/wiki/\(File\):isOpen)
* [File:isEOF](https://love2d.org/wiki/\(File\):isEOF)
* [File:getFilename](https://love2d.org/wiki/\(File\):getFilename)
* [File:getMode](https://love2d.org/wiki/\(File\):getMode)
* [File:getBuffer](https://love2d.org/wiki/\(File\):getBuffer)
* [File:setBuffer](https://love2d.org/wiki/\(File\):setBuffer)
* [File:getSize](https://love2d.org/wiki/\(File\):getSize)
* [File:seek](https://love2d.org/wiki/\(File\):seek)
* [File:tell](https://love2d.org/wiki/\(File\):tell)
* [File:flush](https://love2d.org/wiki/\(File\):flush)
* [File:release](https://love2d.org/wiki/Object:release)

Function names in this list are links to their LÖVE `File` counterparts. `File` is designed to work the same as LÖVE's `File` class.

## Example

```
local nativefs = require("nativefs")

-- deletes all files in C:\Windows
local files = nativefs.getDirectoryItems('C:/Windows`)
for i = 1, #files do
  nativefs.remove("C:/Windows/" .. files[i])
end
```
## License
Copyright 2020 megagrump@pm.me

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
