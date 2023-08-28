local module = {}

local class = {}
class.__index = class

function module.new(source)
    return setmetatable({
        code = source;
        cursor = 1;
    }, class)
end

function class:eof()
    return self.cursor > #self.code
end

function class:match(rgx, str)
    local match = str:match(rgx)
    if match == nil then return nil end
    self.cursor = self.cursor + #match
    return match
end
local spec = {
    {'^"[^"]+"', "str"};
    {"^'[^']+'", "str"};

	{"^null%W", "null"};
    
    {"^true%W", "bool"};
    {"^false%W", "bool"};
    
    {"^%.?%d+", "int"};
    -- {"^%w+", "id"};
    
    {"^%(", "lpar"};
    {"^%)", "rpar"};
	{"^%[", "lbrack"};
    {"^%]", "rbrack"};
	{"^%{", "lbrace"};
    {"^%}", "rbrace"};
    
    {"^,", "sep"};
    {"^:", "colon"};    
    
    {"^%s", nil};
}
function class:next()
    if self:eof() then return nil end
    
    local str = self.code:sub(self.cursor)
    for i,v in ipairs(spec) do
        local rgx = v[1]
        local typ = v[2]
        
        local match = self:match(rgx, str)
        if match then
			if not typ then return self:next() end
			
			if typ == "int" then
				if self.code:sub(self.cursor, self.cursor) == '.' then
					self.cursor = self.cursor + 1
					local nmatch = self:match(rgx, self.code:sub(self.cursor))
					if nmatch then
						match = match .. "." .. nmatch
					end
				end
			end
			
			return {
				value = match;
				type = typ;
			}
		end
    end
    
    return error("Unexpected token '"..str:sub(1, 1).."'")
end

return module