Object = {}

-- new函数，不应该重载

function Object.new(class, ...)
	local ret = {}
	local comps = {}
	local mt = {__components=comps, __class=class, __initCalled={}}
	--local call = rawget(class,'__call')
	--if call~=nil then
	--	mt.__call = call
	--end
	mt.__index = function(table, key)
		for i=#comps,1,-1 do
			local got =  comps[i][key]
			if got~=nil then return got end
		end
		return class[key]
	end
	setmetatable(ret, mt)
	-- 调用init
	Object.callInit(class, ret, ...)
	return ret
end

function Object.customInit(class)
	local mt = getmetatable(class)
	mt.__customInit = true
end

function Object.doCallInit(class, obj, ...)
	-- 同一个类的init不能重复调用
	local className = rawget(getmetatable(class),'__className')
	local called = rawget(getmetatable(obj), '__initCalled')
	for _,name in ipairs(called) do
		if name==className then return end
	end
	local init = rawget(class, 'init')
	if init~=nil and type(init)=='function' then
		init(obj, ...)
	end
	called[#called+1] = className
end

function Object.callInit(class, obj, ...)
	local mt = getmetatable(class)
	if mt.__customInit then
		Object.doCallInit(class, obj, ...)
	else
		local parents = mt.__components
		for _,comp in ipairs(parents) do
			Object.callInit(comp, obj, ...)
		end
		Object.doCallInit(class, obj, ...)
	end
end

function Object.getClassName(obj)
	local class = getmetatable(obj).__class
	return getmetatable(class).__className
end

local copyMembers=function(from , to)
	for key,value in pairs(from) do
		if key~='init'  then
			to[key] = value
		end
	end
end

-- 一个类添加父类，调用这个函数之后，会影响这个类的所有对象
function Object.inherit(cls, ...)
	for _, comp in ipairs(arg) do
		local comps = getmetatable(cls).__components
		comps[#comps+ 1] = comp
	end
end

-- 给一个对象添加一个组件，只影响到这一个对象
-- 后面的参数是初始化组件时的参数
-- 请注意，这里会调用init
function Object.addClass(obj, cls, ...)
	local comps = getmetatable(obj).__components
	comps[#comps + 1] = cls 
	Object.callInit(cls, obj,  ...)
end


function class(name)
	local cls = {}
	local comps = {}
	local mt = {__className=name, __components=comps}
	setmetatable(cls, mt)
	mt.__index = function(table, key)
		for i=#comps, 1, -1 do
			local parentFunc = comps[i][key]
			if parentFunc~=nil then
				return parentFunc
			end
		end
		return Object[key]
	end
	_G[name] = cls
	return cls
end


