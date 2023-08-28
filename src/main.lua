local JSON = {}
JSON.Parser = require('./src/parser')

function JSON.isArray(t) -- https://stackoverflow.com/questions/7526223/how-do-i-know-if-a-table-is-an-array
  local i = 0
  for _ in pairs(t) do
      i = i + 1
      if t[i] == nil then return false end
  end
  return true
end

function JSON.debug(table, tabs)
	local tbs = ('\t'):rep(tabs or 0)
	local str = tbs
	for k,v in pairs(table) do
		local a = type(v) == "table" and JSON.debug(v, (tabs or 0) + 1) or tostring(v)
		str = str .. tostring(k) .. ' = ' .. a .. '\n' .. tbs
	end
	return str
end

function JSON.print(tbl)
	print(JSON.debug(tbl))
end

-- Stringify
function JSON.valueToDisplay(val)
	if type(val) == "table" then return JSON.stringify(val) end
	if type(val) == "string" then return '"' .. val:gsub('"', '\\"') .. '"' end
	if val == nil then return 'null' end
	return tostring(val)
end

function JSON.stringifyArray(arr)
	local s = " "
	for _,v in ipairs(arr) do
		s = s .. JSON.valueToDisplay(v) .. ", "
	end
	if s:sub(-2, -1) == ', ' then s = s:sub(0, -3) .. ' ' end
	return s
end
function JSON.stringifyObject(tbl)
	local s = " "
	for k,v in pairs(tbl) do
		s = s .. '"' .. k:gsub('"', '\\"') .. '": ' .. JSON.valueToDisplay(v) .. ", "
	end
	if s:sub(-2, -1) == ', ' then s = s:sub(0, -3) .. ' ' end
	return s
end

function JSON.stringify(tbl)
	local arr = JSON.isArray(tbl)
	local s = arr and '[' or '{'

	if arr then s = s .. JSON.stringifyArray(tbl)
	else s = s .. JSON.stringifyObject(tbl) end

	s = s .. (arr and ']' or '}')
	return s
end

function JSON.parse(str)
	return JSON.Parser.new(str):parse()
end

return JSON;