-- Modified for Wildstar by DoctorVanGogh on Wildstar forums

local MAJOR,MINOR = "DoctorVanGogh:Lib:Loop:Base-1.0", 1

-- Get a reference to the package information if any
local APkg = Apollo.GetPackage(MAJOR)
-- If there was an older version loaded we need to see if this is newer
if APkg and (APkg.nVersion or 0) >= MINOR then
	return -- no upgrade needed
end


--------------------------------------------------------------------------------
---------------------- ##       #####    #####   ######  -----------------------
---------------------- ##      ##   ##  ##   ##  ##   ## -----------------------
---------------------- ##      ##   ##  ##   ##  ######  -----------------------
---------------------- ##      ##   ##  ##   ##  ##      -----------------------
---------------------- ######   #####    #####   ##      -----------------------
----------------------                                   -----------------------
----------------------- Lua Object-Oriented Programming ------------------------
--------------------------------------------------------------------------------
-- Project: LOOP - Lua Object-Oriented Programming                            --
-- Release: 2.3 beta                                                          --
-- Title  : Base Class Model                                                  --
-- Author : Renato Maia <maia@inf.puc-rio.br>                                 --
-- License: MIT - See accompanying LICENSE file								  --
--------------------------------------------------------------------------------
-- Exported API:                                                              --
--   class(class)                                                             --
--   new(class, ...)                                                          --
--   classof(object)                                                          --
--   isclass(class)                                                           --
--   instanceof(object, class)                                                --
--   memberof(class, name)                                                    --
--   members(class)                                                           --
--------------------------------------------------------------------------------

local pairs        = pairs
local unpack       = unpack
local rawget       = rawget
local setmetatable = setmetatable
local getmetatable = getmetatable

--------------------------------------------------------------------------------
local function rawnew(class, object)
	return setmetatable(object or {}, class)
end
--------------------------------------------------------------------------------
local function new(class, ...)
	if class.__init
		then return class:__init(...)
		else return rawnew(class, ...)
	end
end
--------------------------------------------------------------------------------
local function initclass(class)
	if class == nil then class = {} end
	if class.__index == nil then class.__index = class end
	return class
end
--------------------------------------------------------------------------------
local MetaClass = { __call = new }
local function class(class)
	return setmetatable(initclass(class), MetaClass)
end
--------------------------------------------------------------------------------
local classof = getmetatable
--------------------------------------------------------------------------------
local function isclass(class)
	return classof(class) == MetaClass
end
--------------------------------------------------------------------------------
local function instanceof(object, class)
	return classof(object) == class
end
--------------------------------------------------------------------------------
local memberof = rawget
--------------------------------------------------------------------------------
local members = pairs

--------------------------------------------------------------------------------


local Loop = APkg and APkg.tPackage or {
	rawnew = rawnew,
	new = new,
	initclass = initclass,
	class = class,
	classof = classof,
	isclass = isclass,
	instanceof = instanceof,
	memberof = memberof,
	members = members
}

Apollo.RegisterPackage(Loop, MAJOR, MINOR, {})

