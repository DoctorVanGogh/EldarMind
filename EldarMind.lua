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

local kstrDefaultSprite = "IconSprites:Icon_ItemArmorChest_shirt_0001";
local kstrPatternTooltipStringFormula = "<P Font=\"CRB_InterfaceLarge_B\" TextColor=\"ff9d9d9d\">%s</P><P Font=\"CRB_InterfaceSmall\" TextColor=\"ff9d9d9d\">%s</P>"


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
	self.log = glog
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
	self.xmlDoc = nil;
	
	Apollo.RegisterSlashCommand("em", "OnSlashCommand", self)		
	self.wndMain:Show(false);
	
	end
	Apollo.RegisterEventHandler("InvokeScientistExperimentation", "OnInvokeScientistExperimentation", self)
	Apollo.RegisterEventHandler("ScientistExperimentationResult", "OnScientistExperimentationResult", self)	
end

function EldarMind:InitializeForm()
	self.wndMain:FindChild("HeaderLabel"):SetText(MAJOR)	

	if self.locSavedWindowLoc then
		self.wndMain:MoveToLocation(self.locSavedWindowLoc)
	end		
end

function EldarMind:UpdateSuggestion(pmExperiment, arResults)

	if pmExperiment ~= nil then
		self.guesses = {}
		self.pmExperiment = pmExperiment
		
		-- local tInfo = pmExperiment:GetScientistExperimentationInfo()
		-- tInfo.nAttempts
		
		-- local tPatterns = pmExperiment:GetScientistExperimentationCurrentPatterns()
		-- for idx, tPattern in pairs(tPatterns) do
		--    tPattern.strIcon -- SPRITE
		--    tPattern.strName, tPattern.strDescription
		
	end


	if arResults ~= nil then
		
	
	end
	
	
	local tSuggestBtns = {self.wndMain:FindChild("Suggestion1"), self.wndMain:FindChild("Suggestion2"), self.wndMain:FindChild("Suggestion3"), self.wndMain:FindChild("Suggestion4")}

	--local tPatterns = pmExperiment:GetScientistExperimentationCurrentPatterns()
	--if tPatterns == nil then
	--	for key, wndSuggestBtn in pairs(tSuggestBtns ) do
	--		local icon = wndSuggestBtn:FindChild("SuggestionIcon")
	--		icon:SetTooltip("")		
	--		icon:SetSprite(kstrDefaultSprite)
	--	end
	--else
	--	
	--end
	
end

-----------------------------------------------------------------------------------------------
-- EldarMind logic
-----------------------------------------------------------------------------------------------
function EldarMind:OnInvokeScientistExperimentation(pmExperiment)
	self:InitializeForm()
			
	self:UpdateSuggestion(pmExperiment, nil)	
	
	if not self.wndMain:IsVisible() then
		self:ToggleWindow()	
	end
end


function EldarMind:OnScientistExperimentationResult(arResults)		
	self:UpdateSuggestion(nil, arResults)
		
	if not self.wndMain:IsVisible() then
		self:ToggleWindow()	
	end
end



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
	glog:debug("OnSaveSettings")	
	
    if eLevel == GameLib.CodeEnumAddonSaveLevel.Account then				
		local locWindowLocation = self.wndMain and self.wndMain:GetLocation() or self.locSavedWindowLoc				
	
		local tSave = { 
			version = {
				MAJOR = MAJOR,
				MINOR = MINOR
			}, 		
			tWindowLocation = locWindowLocation and locWindowLocation:ToTable() or nil
		}	
	end	
end


function EldarMind:OnRestoreSettings(eLevel, tSavedData)
	glog:debug("OnRestoreSettings")

	if not tSavedData or tSavedData.version.MAJOR ~= MAJOR then
		return
	end	
	
    if eLevel == GameLib.CodeEnumAddonSaveLevel.Account then						
		if tSavedData.tWindowLocation then
			self.locSavedWindowLoc = WindowLocation.new(tSavedData.tWindowLocation)
		end	
	
	end		
end

-----------------------------------------------------------------------------------------------
-- EldarMindForm Functions
-----------------------------------------------------------------------------------------------
function EldarMind:ToggleWindow()
	if self.wndMain:IsVisible() then
		self.wndMain:Close()
	else
		self.wndMain:Show(true)
		self.wndMain:ToFront()
	end
end

function EldarMind:WindowMove()
	self.locSavedWindowLoc = self.wndMain:GetLocation()
end