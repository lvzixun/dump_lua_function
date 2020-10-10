local parser = require "genlfunc"
local seri = require "serialize"
local lfs = require "lfs"
local utils = require "utils"
local list_all_lua = utils.list_all_lua
local join = utils.join


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
    -- print(path)
    assert(fd, path)
    local s = fd:read("a")
    fd:close()
    return s
end

local function write_file(source, path)
    local fd = io.open(path, "w")
    fd:write("return ")
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