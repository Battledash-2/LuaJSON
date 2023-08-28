local Lexer = require('src.lexer')

local parser = {}
parser.__index = parser

function parser.new(lexer)
	if type(lexer) == "string" then lexer = Lexer.new(lexer) end
	return setmetatable({
		lexer = lexer,
		peek = lexer:next(),
	}, parser)
end

function parser:consume(t)
	t = t or ""
	local peek = self.peek or "";
	if t ~= "" and (self.lexer:eof() or self.peek == nil) then self:error("Input abruptly ended while expecting " .. t) end
	if t ~= "" and peek.type ~= t then self:error("Received token " .. peek.type .. " while expecting " .. t) end

	self.peek = self.lexer:next()
	return peek
end

function parser:parse()
	return self:literal()
end

function parser:string()
	return self:consume('str').value:sub(2, -2)
end

function parser:boolean()
	return self:consume('bool') == 'true' and true or false
end

function parser:primary(item)
	if item.type == 'str' then return self:string() end
	if item.type == 'null' then self:consume('null') return nil end
	if item.type == 'int' then return tonumber(self:consume('int').value) end
	if item.type == 'bool' then return self:boolean() end
	self:error("Unknown item " .. item.value)
end

function parser:literal()
	local peek = self.peek;
	if peek.type == 'lbrack' then return self:array() end -- array
	if peek.type == 'lbrace' then return self:object() end -- object
	return self:primary(peek)
end

-- function parser:id()
-- 	return self:consume('id').value
-- end

function parser:object()
	self:consume('lbrace')
	local obj = {}

	while self.peek and self.peek.type ~= 'rbrace' do
		local name = self:string()
		self:consume('colon')
		local val = self:literal()
		obj[name] = val

		if self.peek and self.peek.type ~= 'rbrace' then self:consume('sep') end
	end

	self:consume('rbrace')
	return obj
end

function parser:array()
	self:consume('lbrack')
	local obj = {}

	while self.peek and self.peek.type ~= 'rbrack' do
		local val = self:literal()
		table.insert(obj, val)

		if self.peek and self.peek.type ~= 'sep' then break
		else self:consume('sep') end
	end

	self:consume('rbrack')
	return obj
end

function parser:error(msg)
	error('JSON Syntax Error: ' .. msg)
end

return parser