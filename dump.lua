local parser = require "parser"
local print_r = require "print_r"

local source = [[

function aa()
    return 33
end

function ee.cc:ff()
    return 3
end

local function foo()
    return 4
end

function foo.cc.ee ()
    return 4
end
]]

local function append(ret, name, location, end_location)
    ret[#ret+1] = {
        name = name,
        range = {location.line, end_location.line},
    }
end


local function dump_local_function (root, ret)
    assert(root.tag == "Localrec")
    local location = root.location
    local end_location = root[2].end_location
    local name = root[1][1]
    append(ret, name, location, end_location)
end

local function dump_index(root)
    -- print("------------")
    -- print_r(root)
    if root.tag == "Id" then
        return root[1]
    end
    assert(root.tag == "Index")
    local ret = {}
    for i,v in ipairs(root) do
        local tag = v.tag
        if tag == "Id" or tag == "String" then
            ret[#ret+1] = v[1]
        elseif tag == "Index" then
            ret[#ret+1] = dump_index(v)
        end
    end
    return table.concat(ret, ".")
end


local function dump_set_function(root, ret)
    assert(root.tag == "Set")
    assert(root.first_token == "function")
    -- print("$$$$$$$$$")
    -- print_r(root)
    local name = dump_index(root[1][1])
    local location = root[2][1].location
    local end_location = root[2][1].end_location
    append(ret, name, location, end_location)
end


-- 只遍历最外层的function
local function dump_block(root, ret)
    ret = ret or {}
    assert(root.tag == "Block")
    for i,v in ipairs(root) do
        local tag = v.tag
        if tag == "Set" and v.first_token == "function" then
            dump_set_function(v, ret)
        elseif tag == "Localrec" then
            dump_local_function(v, ret)
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

local path = ...
local source = read_file(path)

local ast = parser(source)
local info = dump_block(ast, {})


print("#############")
print_r(info)
