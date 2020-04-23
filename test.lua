local parser = require "genlfunc"
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
    local function pp()
        local function _gg ()
            local hh = function ()
            end
        end
    end
    return 4
end

local gg = function ()
    return 5
end
]]


local ret = parser(source)
print_r(ret)
