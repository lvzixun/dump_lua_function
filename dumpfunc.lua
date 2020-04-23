local parser = require "genlfunc"
local seri = require "serialize"
local lfs = require "lfs"
local print_r = require "print_r"

local function join(...)
    local t = {...}
    local sep = string.match (package.config, "[^\n]+")
    return table.concat(t, sep)
end
 
 
local function _f(lua_dir, out)
    out = out or {}
    for file in lfs.dir(lua_dir) do
        if file ~= "." and file ~= ".." then
            local f = join(lua_dir, file)
            local attr = lfs.attributes(f)
            if attr.mode == "directory" then
                _f(f, out)
            elseif string.match(file, ".+%.lua$") then
                out[#out+1] = {
                    path = f,
                    name = file,
                }
            end
        end
    end
    return out
end
 
local function list_all_lua(lua_dir)
    local out = _f(lua_dir)
    local ret = {}
    local map = {}
    for i,v in ipairs(out) do
        local abs_path = v.path
        v.path = string.gsub(abs_path, lua_dir, "")
        ret[v.path] = v
        map[v.path] = {
            name = v.name,
            path = abs_path,
        }
    end
    return ret, map
end


local function reshape_func(info)
    local ret = {}
    for i,v in ipairs(info) do
        local def = v.range[1]
        if not ret[def] then
            ret[def] = v.name
        end
    end
    return ret
end

local function read_file(path)
    local fd =io.open(path, "r")
    assert(fd, path)
    local s = fd:read("a")
    fd:close()
    return s
end

local function write_file(source, path)
    local fd = io.open(path, "w")
    fd:write(source)
    fd:close()
end

local lua_dir, out_lua = ...
local function main()
    local ret = list_all_lua(lua_dir)
    local func_ret = {}
    for path, v in pairs(ret) do
        local full_path = join(lua_dir, path)
        local source = read_file(full_path)
        local info = parser(source)
        func_ret[path] = reshape_func(info)
    end
    local s = seri(func_ret)
    write_file(s, out_lua)
    print("dump function success to " .. out_lua)
end


main()