local parser = require "parser"

local function append(ret, name, location, end_location)
    ret[#ret+1] = {
        name = name,
        range = {location.line, end_location.line},
    }
end

local function dump_local_function(root, ret)
    local left = root[1]
    local right = root[2]
    if right then
        for i,v in ipairs(right) do
            if v.tag == "Function" then
                local name = left[i] and left[i][1]
                if name then
                    append(ret, name, v.location, v.end_location)
                end
            end
        end
    end
end

local function dump_localrec_function (root, ret)
    local location = root.location
    local end_location = root[2].end_location
    local name = root[1][1]
    append(ret, name, location, end_location)
end

local function dump_index(root)
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
    local name = dump_index(root[1][1])
    local location = root[2][1].location
    local end_location = root[2][1].end_location
    append(ret, name, location, end_location)
end


-- 只遍历最外层的function
local function dump_block(root, ret)
    ret = ret or {}
    local root_tag = root.tag
    for i,v in ipairs(root) do
        if root_tag == "Block" then
            local tag = v.tag
            if tag == "Set" and v.first_token == "function" then
                dump_set_function(v, ret)
            elseif tag == "Localrec" then
                dump_localrec_function(v, ret)
            elseif tag == "Local" then
                dump_local_function(v, ret)
            end
        end
        dump_block(v, ret)
    end
    return ret
end


local function do_parser(source)
    local ast = parser(source)
    local info = dump_block(ast, {})
    return info
end


return do_parser
