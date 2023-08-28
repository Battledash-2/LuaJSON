local JSON = require('src.main')
local parsed = JSON.Parser.new([[
	[{
		"hi": 6.2,
		"poop": 'lol'
	}]
]]):parse()

JSON.print(parsed)
print(JSON.stringify(parsed))