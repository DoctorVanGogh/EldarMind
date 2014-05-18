-----------------------------------------------------------------------------------------------
-- Client Lua Script for Newton
-- Copyright (c) DocVanGogh on Wildstar forums
-----------------------------------------------------------------------------------------------
 
--require "GameLib"
--require "PlayerPathLib"
--require "ScientistScanBotProfile"

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------


local MAJOR, MINOR = "EldarMind-1.0", 1
local glog

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

local EldarMind = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon(
																	"EldarMind", 
																	false, 
																	{ 
																		"Gemini:Logging-1.2",
																		"DocVanGogh:Lib:Mastermind:P4C4R:Knuth-1.0"
																	} 
																	--,"Gemini:Hook-1.0"																	
																	)

function EldarMind:OnInitialize()
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
	glog = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d [%c:%n] %l - %m",
		appender = "GeminiConsole"
	})	
		
end


-- Called when player has loaded and entered the world
function EldarMind:OnEnable()
	glog:debug(string.format("OnEnable"))
	
	self.ready = true
	self.lookup = Apollo.GetPackage("DocVanGogh:Lib:Mastermind:P4C4R:Knuth-1.0").tPackage;
end
-----------------------------------------------------------------------------------------------
-- Newton logic
-----------------------------------------------------------------------------------------------


-----------------------------------------------------------------------------------------------
-- Persistence
-----------------------------------------------------------------------------------------------
function EldarMind:OnSaveSettings(eLevel)
	-- We save at character level,
	if (eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character) then
		return
	end

	glog:debug("OnSaveSettings")	
		
	local tSave = { 
		version = {
			MAJOR = MAJOR,
			MINOR = MINOR
		}, 
	}
	
	return tSave
end


function EldarMind:OnRestoreSettings(eLevel, tSavedData)
	-- We restore at character level,
	if (eLevel ~= GameLib.CodeEnumAddonSaveLevel.Character) then
		return
	end
	
	glog:debug("OnRestoreSettings")
	
	if not tSavedData or tSavedData.version.MAJOR ~= MAJOR then
		return
	end	
	
	
end

-----------------------------------------------------------------------------------------------
-- NewtonForm Functions
-----------------------------------------------------------------------------------------------

