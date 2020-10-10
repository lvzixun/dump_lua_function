local lfs = require "lfs"
local M = {}

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
 
function M.list_all_lua(lua_dir)
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

M.join = join

return M