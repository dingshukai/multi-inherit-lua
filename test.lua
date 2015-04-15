---以下为测试代码
class('AA')

function AA:init(name)
	self.name=name
	print('AA init')
end

function AA:hoho()
	print(self.name)
end

function AA:haha()
	print('haha')
end

class('BB')
function BB:init(name)
	self.bName = 'b-'..name
	print('BB init')
end

function BB:hb()
	print(self.bName)
end

function BB:hoho()
	print('oo', self.bName)
end

class('CC'):inherit(BB,AA)
--CC:customInit()

class('DD'):inherit(CC)

function CC:init()
	self:hoho()
	--BB:callInit(self, 'wewe')
	print('CC init')
end

