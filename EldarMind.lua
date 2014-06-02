-----------------------------------------------------------------------------------------------
-- Client Lua Script for EldarMind
-- Copyright (c) DoctorVanGogh on Wildstar forums - All Rights reserved
-- Referenced libraries (c) their respective owners - see LICENSE file in each library directory
-----------------------------------------------------------------------------------------------
 
require "Window"
require "PlayerPathLib"

-----------------------------------------------------------------------------------------------
-- Constants
-----------------------------------------------------------------------------------------------
local NAME = "EldarMind"

local MAJOR, MINOR = NAME.."-1.0", 1
local glog
local inspect

local kstrDefaultSprite = "IconSprites:Icon_ItemMisc_AcceleratedOmniplasm";
local kstrPatternTooltipStringFormula = "<P Font=\"CRB_InterfaceLarge_B\" TextColor=\"ff9d9d9d\">%s</P><P Font=\"CRB_InterfaceSmall\" TextColor=\"ff9d9d9d\">%s</P>"

local kstrAttemptExperimentationFunction = "AttemptScientistExperimentation"

local kstrWindowNameBlockerMismatch = "BlockerMismatch"
local kstrWindowNameBlockerWaiting = "BlockerNoExperiment"

local kstrInitNoScientistWarning = "Player not a scientist - consider disabling Addon %s for this character!"
local kstrConfigNoScientistWarning = "Not a scientist - configuration disabled!"
local kstrUINoScientistWarning = "Not a scientist - interface disabled!"

local knCreatureIdCaretakerMad = 23583
local knCreatureIdCaretakerBenevolent = 23797

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

local EldarMind = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon(
																	NAME, 
																	false, 
																	{ 
																		"Gemini:Logging-1.2",
																		"Drafto:Lib:inspect-1.2",
																		"Gemini:Locale-1.0",
																		"DoctorVanGogh:Lib:Tuple-1.0",
																		"DoctorVanGogh:Lib:Mastermind:P4C4R:Knuth-1.0"
																	},
																	"Gemini:Hook-1.0")
																	
local GeminiLocale
local tuple
																	
EldarMind.States = {
	Waiting = 1,
	Running = 2,
	Mismatch = 3
}																	
																
function EldarMind:OnInitialize()
	-- import inspect
	inspect = Apollo.GetPackage("Drafto:Lib:inspect-1.2").tPackage	

	-- setup logger
	local GeminiLogging = Apollo.GetPackage("Gemini:Logging-1.2").tPackage
	glog = GeminiLogging:GetLogger({
		level = GeminiLogging.INFO,
		pattern = "%d [%c:%n] %l - %m",
		appender = "GeminiConsole"
	})	
	self.log = glog
		
	-- setup localization
	GeminiLocale = Apollo.GetPackage("Gemini:Locale-1.0").tPackage	
	self.localization = GeminiLocale:GetLocale(NAME)
		
	Apollo.RegisterSlashCommand("em", "OnSlashCommand", self)			
	
	--if PlayerPathLib.GetPlayerPathType() ~= PathMission.PlayerPathType_Scientist then
	--	glog:warn(self.localization[kstrInitNoScientistWarning], NAME)
	--	self.bDisabled = true
	--	return
	--end				
	
	-- import tuple
	tuple = Apollo.GetPackage("DoctorVanGogh:Lib:Tuple-1.0").tPackage
	
	--	import lookup table
	self.lookup = Apollo.GetPackage("DoctorVanGogh:Lib:Mastermind:P4C4R:Knuth-1.0").tPackage;	
		
	self:SetState(EldarMind.States.Waiting)
	
	self.xmlDoc = XmlDoc.CreateFromFile("EldarMind.xml")
	self.xmlDoc:RegisterCallback("OnDocumentReady", self) 	
	
end


-- Called when player has loaded and entered the world
function EldarMind:OnEnable()
	glog:debug("OnEnable")
	
	self.ready = true

end

function EldarMind:OnDocumentReady()
	if self.xmlDoc == nil then
		return
	end
	
	self.wndMain = Apollo.LoadForm(self.xmlDoc, "EldarMindForm", nil, self)
	self.xmlDoc = nil;

	self.wndMain:Show(false);
	
	-- localization
	local L = self.localization	
	GeminiLocale:TranslateWindow(L, self.wndMain)	
	
	-- some composite values auto localization won't capture
	self.wndMain:FindChild("HeaderLabel"):SetText(string.gsub(MAJOR, NAME, L[NAME]))
		
	
	Apollo.RegisterEventHandler("InvokeScientistExperimentation", "OnInvokeScientistExperimentation", self)
	Apollo.RegisterEventHandler("ScientistExperimentationResult", "OnScientistExperimentationResult", self)	
	
	Apollo.RegisterEventHandler("WindowManagementReady", "OnWindowManagementReady", self)
		
	if not self:IsHooked(_G, "Event_CancelExperimentation") then
		self:PostHook(_G, "Event_CancelExperimentation", "CancelExperimentation")
	end
end

function EldarMind:OnWindowManagementReady()
    Event_FireGenericEvent("WindowManagementAdd", {wnd = self.wndMain, strName = NAME})
end

function EldarMind:InitializeForm()
	if not self.wndMain then
		return
	end
		
	self.wndMain:FindChild("BlockerPortrait"):SetCostumeToCreatureId(knCreatureIdCaretakerMad)
	self.wndMain:FindChild("ContentPortrait"):SetCostumeToCreatureId(knCreatureIdCaretakerBenevolent)
		
	self:UpdateForm()	
end

function EldarMind:UpdateForm(pmExperiment, arResults)
	glog:debug("UpdateForm(%s, %s)", tostring(pmExperiment), tostring(arResults))

	if not self.wndMain then
		return
	end	
	
	self.wndMain:FindChild(kstrWindowNameBlockerMismatch):Show(self:GetState() == EldarMind.States.Mismatch)
	self.wndMain:FindChild(kstrWindowNameBlockerWaiting):Show(self:GetState() == EldarMind.States.Waiting)	

	if pmExperiment ~= nil then
		self.guesses = {}
		self.pmExperiment = pmExperiment
		self.tPatterns = pmExperiment:GetScientistExperimentationCurrentPatterns()		
		
		-- HACK: pmExperiment is a userdata - can't hook that directly. So let's hook it's metatable...
		local mtExperiment = getmetatable(pmExperiment)
		if not self:IsHooked(mtExperiment, kstrAttemptExperimentationFunction) then
			self:Hook(mtExperiment, kstrAttemptExperimentationFunction, "PreAttemptExperimentation")
		end		
		
		self:SetState(EldarMind.States.Running)

	end

	if arResults ~= nil and self:GetState() == EldarMind.States.Running then	
		local nExact = 0
		local nPartial = 0
		for idx, eCurrResult in ipairs(arResults) do
			if eCurrResult == PathMission.ScientistExperimentationResult_Correct then
				nExact = nExact + 1
			elseif eCurrResult == PathMission.ScientistExperimentationResult_CorrectPattern then
				nPartial = nPartial + 1
			end
		end	
				
		self.guesses[#self.guesses].result = tuple(nExact, nPartial)		
		
		if nExact == 4 then
			self:SetState(EldarMind.States.Waiting)
			return
		end
	end	
	
	self:UpdateSuggestions()	
end

function EldarMind:UpdateSuggestions()

	glog:debug("UpdateSuggestions()")
	
	local suggestion = self:GetCurrentSuggestion()
	local p1, p2, p3, p4
	
	if suggestion then
		p1, p2, p3, p4 = suggestion()
	else
		p1, p2, p3, p4 = false, false, false, false
	end
		
	local tSuggestBtns = {
		[self.wndMain:FindChild("Suggestion1")] = p1, 
		[self.wndMain:FindChild("Suggestion2")] = p2, 
		[self.wndMain:FindChild("Suggestion3")] = p3, 
		[self.wndMain:FindChild("Suggestion4")] = p4
	}
	
	for wndSuggestion, p in pairs(tSuggestBtns) do
		local icon = wndSuggestion:FindChild("SuggestionIcon")
		if p then
			local pattern = self.tPatterns[p]
			icon:SetSprite(pattern.strIcon)
			icon:SetTooltip(string.format(kstrPatternTooltipStringFormula, pattern.strName, pattern.strDescription))		
		else
			icon:SetTooltip("")		
			icon:SetSprite(kstrDefaultSprite)			
		end
	end

end

-----------------------------------------------------------------------------------------------
-- EldarMind logic
-----------------------------------------------------------------------------------------------
function EldarMind:OnInvokeScientistExperimentation(pmExperiment)
	self:InitializeForm()
			
	self:UpdateForm(pmExperiment, nil)	
	
	if not self.wndMain:IsVisible() then
		self:ToggleWindow()	
	end
end


function EldarMind:OnScientistExperimentationResult(arResults)		
	self:UpdateForm(nil, arResults)
		
	if not self.wndMain:IsVisible() then
		self:ToggleWindow()	
	end
end

function EldarMind:GetCurrentSuggestion()
	if not self.tPatterns or not self.guesses then
		return
	end
	
	local suggestion = self.lookup
	for idx, guess in ipairs(self.guesses) do
		if guess.result then
			suggestion = suggestion[guess.result]
		end
	end
	
	if not suggestion then
		return
	end
	
	return suggestion.guess	
end

function EldarMind:PreAttemptExperimentation(luaCaller, numPatterns, tCode)
	glog:debug("PreAttemptExperimentation: Code=%s", inspect(tCode))
	
	local suggestion = self:GetCurrentSuggestion()
	
	if suggestion then
		local s1, s2, s3, s4 = suggestion()
		
		if 	tCode.Choice1 == self.tPatterns[s1].idPattern and 
			tCode.Choice2 == self.tPatterns[s2].idPattern and 
			tCode.Choice3 == self.tPatterns[s3].idPattern and 
			tCode.Choice4 == self.tPatterns[s4].idPattern then
			table.insert(self.guesses, {guess = suggestion})			
			return
		end	
	end
	
	self:SetState(EldarMind.States.Mismatch)
	
end

function EldarMind:CancelExperimentation()
	glog:debug("CancelExperimentation")
	
	self:SetState(EldarMind.States.Waiting)
end


function EldarMind:OnSlashCommand()
	if self.wndMain then
		self:ToggleWindow()
	else
		if self.bDisabled then
			glog:warn(self.localization[kstrUINoScientistWarning])
		end
	end
end

function EldarMind:GetState()
	return self.state or EldarMind.States.Waiting
end

function EldarMind:SetState(state)
	glog:debug("SetState(%s)", tostring(state))


	if state == self.state then
		return
	end

	if EldarMind.States.Waiting ~= state and EldarMind.States.Running ~= state and EldarMind.States.Mismatch ~= state then
		return
	end
	
	self.state = state
	self:UpdateForm()
end

-----------------------------------------------------------------------------------------------
-- Persistence
-----------------------------------------------------------------------------------------------
function EldarMind:OnSaveSettings(eLevel)
	glog:debug("OnSaveSettings")	
	
    if eLevel == GameLib.CodeEnumAddonSaveLevel.Account then				
		local tSave = { 
			version = {
				MAJOR = MAJOR,
				MINOR = MINOR
			}, 		
			logLevel = self.log.level
		}	
	end	
end


function EldarMind:OnRestoreSettings(eLevel, tSavedData)
	glog:debug("OnRestoreSettings")

	if not tSavedData or tSavedData.version.MAJOR ~= MAJOR then
		return
	end	
	
    if eLevel == GameLib.CodeEnumAddonSaveLevel.Account then						
		if tSavedData.logLevel then
			self.log.level = tSavedData.logLevel	
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
		self:InitializeForm()
		
		self.wndMain:Show(true)
		self.wndMain:ToFront()
	end
end
