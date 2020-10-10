local parser = require "parser"
local M = {}

local function do_check_indent(indent_str, location, ret)
    assert(#indent_str>0)
    local has_tab = string.find(indent_str, "\t")
    local has_space =  string.find(indent_str, " ")
    if has_tab then
        table.insert(ret.tab, location)
    end
    if has_space then
        table.insert(ret.space, location)
    end
end

local function reolve_node(source, node, last_line, ret)
    local location = node.location
    local line = location and location.line
    if line and line ~= last_line then
        local offset = location.offset
        local indent_len = location.column-1
        local indent_str = string.sub(source, offset-indent_len, offset-1)
        if #indent_str > 0 and string.match(indent_str, "^%s+$") then
            do_check_indent(indent_str, location, ret)
        end
        last_line = location.line
    end

    for i,v in ipairs(node) do
        if type(v) == "table" then
            reolve_node(source, v, last_line, ret)
        end
    end
end

local function readfile(file_path)
    local fd = io.open(file_path, "rb")
    local s = fd:read("a")
    fd:close()
    return s
end

function M.check_indent(file_path)
    local source = readfile(file_path)
    local ret = {
        tab = {},
        space = {},
    }
    local ast = parser(source)
    indent_char_byte = nil
    reolve_node(source, ast, nil, ret)
    if #ret.tab<=#ret.space then
        return ret.tab, "tab"
    else
        return ret.space, "space"
    end
end

return M

