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

local kstrDefaultSprite = "IconSprites:Icon_ItemMisc_AcceleratedOmniplasm";
local kstrPatternTooltipStringFormula = "<P Font=\"CRB_InterfaceLarge_B\" TextColor=\"ff9d9d9d\">%s</P><P Font=\"CRB_InterfaceSmall\" TextColor=\"ff9d9d9d\">%s</P>"

local kstrAttemptExperimentationFunction = "AttemptScientistExperimentation"

-----------------------------------------------------------------------------------------------
-- Initialization
-----------------------------------------------------------------------------------------------

local EldarMind = Apollo.GetPackage("Gemini:Addon-1.0").tPackage:NewAddon(
																	"EldarMind", 
																	false, 
																	{ 
																		"Gemini:Logging-1.2",
																		"DoctorVanGogh:Lib:Mastermind:P4C4R:Knuth-1.0"
																	},
																	"Gemini:Hook-1.0")

EldarMind.States = {
	Waiting = 1,
	Running = 2,
	Mismatch = 3
}																	
																
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
		
	self:SetState(EldarMind.States.Waiting)
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
	if not self.wndMain then
		return
	end

	self.wndMain:FindChild("HeaderLabel"):SetText(MAJOR)	

	if self.locSavedWindowLoc then
		self.wndMain:MoveToLocation(self.locSavedWindowLoc)
	end	
	
	self:UpdateForm()	
end

function EldarMind:UpdateForm(pmExperiment, arResults)

	if not self.wndMain then
		return
	end	
	
	self.wndMain:FindChild("BlockerMismatch"):SetVisible(self:GetState() == EldarMind.States.Mismatch)
	self.wndMain:FindChild("BlockerWaiting"):SetVisible(self:GetState() == EldarMind.States.Waiting)	

	if pmExperiment ~= nil then
		self.guesses = {}
		self.pmExperiment = pmExperiment
		self.tPatterns = pmExperiment:GetScientistExperimentationCurrentPatterns()		
		
		if not self:IsHooked(pmExperiment, kstrAttemptExperimentationFunction) then
			self:Hook(pmExperiment, kstrAttemptExperimentationFunction, "PreAttemptExperimentation")
		end						
	end

	if arResults ~= nil then	
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
	end	
	
	self:UpdateSuggestions()	
end

function EldarMind:UpdateSuggestions()
	
	local suggestion = self:EldarMind:GetCurrentSuggestion()
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
		local icon = wndSuggestBtn:FindChild("SuggestionIcon")
		if p then
			local pattern = self.tPatterns[p]
			icon:SetTooltip(string.format(kstrPatternTooltipStringFormula, pattern.strName, pattern.strDescription))		
			icon:SetSprite(pattern.strIcon)					
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

function EldarMind:PreAttemptExperimentation(numPatterns, tCode)
	local suggestion = self:EldarMind:GetCurrentSuggestion()
	local p1, p2, p3, p4 = suggestion()
	
	if tCode.Choice1 ~= p1 or tCode.Choice2 ~= p2 or  tCode.Choice3 ~= p3 or tCode.Choice4 ~= p4 then
		self:SetState(EldarMind.States.Mismatch)
		return		
	end
	
	table.insert(self.guesses, {guess = suggestion})	
end


function EldarMind:OnSlashCommand()
	if not self.wndMain then
		return
	end
	
	self:ToggleWindow()
end

function EldarMind:GetState()
	return self.state
end

function EldarMind:SetState(state)
	if state == self.state then
		return
	end

	if not EldarMind.States[state]  then
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