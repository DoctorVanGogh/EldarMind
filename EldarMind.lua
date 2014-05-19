-----------------------------------------------------------------------------------------------
-- Client Lua Script for EldarMind
-- Copyright (c) DoctorVanGogh on Wildstar forums
-- Referenced libraries (c) their respective owners - see LICENSE file in each library directory
-----------------------------------------------------------------------------------------------
 
require "Window"

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
																		"DoctorVanGogh:Lib:Mastermind:P4C4R:Knuth-1.0"
																	})

function EldarMind:OnInitialize()
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
	glog = GeminiLogging:GetLogger({
		level = GeminiLogging.DEBUG,
		pattern = "%d [%c:%n] %l - %m",
		appender = "GeminiConsole"
	})	
	self.xmlDoc = XmlDoc.CreateFromFile("EldarMind.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self) 	
	
	self.lookup = Apollo.GetPackage("DoctorVanGogh:Lib:Mastermind:P4C4R:Knuth-1.0").tPackage;	
end


-- Called when player has loaded and entered the world
function EldarMind:OnEnable()
	glog:debug(string.format("OnEnable"))
	
	self.ready = true

end

function EldarMind:OnDocumentReady()
	if self.xmlDoc == nil then
		return
	end
	
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "EldarMindForm", nil, self)
	self.wndMain:FindChild("HeaderLabel"):SetText(MAJOR)
	self.xmlDoc = nil;
	
	Apollo.RegisterSlashCommand("em", "OnSlashCommand", self)		
	self.wndMain:Show(false);
end
-----------------------------------------------------------------------------------------------
-- EldarMind logic
-----------------------------------------------------------------------------------------------
function EldarMind:OnSlashCommand()
	if not self.wndMain then
		return
	end
	
	self:ToggleWindow()
end

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
-- EldarMind Functions
-----------------------------------------------------------------------------------------------
function EldarMind:ToggleWindow()
	if self.wndMain:IsVisible() then
		self.wndMain:Close()
	else
		self.wndMain:Show(true)
		self.wndMain:ToFront()
	end
end