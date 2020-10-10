local ci = require "check_indent"
local lfs = require "lfs"
local utils = require "utils"

local lua_dir = ...

local function main()
    local ret = utils.list_all_lua(lua_dir)
    local count = 1
    for path, v in pairs(ret) do
        local full_path = utils.join(lua_dir, path)
        local result, char = ci.check_indent(full_path)
        for _, location in ipairs(result) do
           print(string.format("[%s] %s:%s inconsistent indent (%s).",
            count, path, location.line, char))
           count = count + 1
        end
    end
end

main()