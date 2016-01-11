--[[
path: /KillLog/
filename: KillLogFrame.lua
author: Daniel Risse <dan@risse.com>
update: Detritis <Slynx - Quel'Thalas>	
created: Mon, 17 Jan 2005 17:33:00 -0800
updated: Thurs, 23 Feb 2007

Kill Log: A record of your exploits fighting creeps in Azeroth
]]

---------------
-- constants --
---------------

KILLLOG_VERSION = GetAddOnMetadata('KillLog', 'Version');
KILLLOG_DATA_VERSION = 10;
KILLLOG_MAX_LEVEL = 60;

local titleGreen 		= "|CFF00FF00";
local titleYellow 		= "|CFFFFFF00";
local myAddonsGreen		= "|CFF00FF00";
local myAddonsYellow 	= "|CFFFFFF00";
local myAddonsBlue	 	= "|CFF99CCFF";
local myAddonsWhite		= "|CFFFFFFFF";
local myAddonsClose		= "|r";
local loadingTitle = titleGreen.. "KillLog [" ..titleYellow..KILLLOG_VERSION..titleGreen.. "] successfully loaded.";

UIPanelWindows["KillLogFrame"] = { area = "left", pushable = 0 };
local KILLLOG_TAB_SUBFRAMES = { "KillLog_GeneralFrame", "KillLog_ListFrame", "KillLog_DeathFrame", "KillLog_OptionsFrame" };

local KILLLOG_DIFFICULTY_COLOR = {
	{ r = 0.50, g = 0.50, b = 0.50 },
	{ r = 0.25, g = 0.75, b = 0.25 },
	{ r = 1.00, g = 1.00, b = 0.00 },
	{ r = 1.00, g = 0.50, b = 0.25 },
	{ r = 1.00, g = 0.10, b = 0.10 },
}; 

KillLog_SessionData     = { };
KillLog_CreepPortrait   = { };
KillLog_Map             = { };
KillLog_CreepPortraitID = 1;

----------------------------------------------------------------------------------------------------------
-- Help for KillLog myAddons.																	--
----------------------------------------------------------------------------------------------------------
KillLog_Help = {};
--#Region Help File
KillLog_Help[1] = 		myAddonsGreen.."Shortcuts for Kill Log.\n"..
						myAddonsBlue.."/kl "..myAddonsWhite.."- will display the Kill Log information window.\n"..
						myAddonsBlue.."/kl debug"..myAddonsYellow.." <number> "..myAddonsWhite.."- sets the debug level between 0 and 5.\n"..
						myAddonsBlue.."/kl update"..myAddonsYellow.." <family> <name> "..myAddonsWhite.."- creates a new 'family' type in the database to categories mobs.\n eg. "..
						myAddonsBlue.."/kl update"..myAddonsYellow.." Zombie Rotting Dead "..myAddonsWhite.."- will create a new <family> "..myAddonsYellow.."Zombie"..
							myAddonsWhite.." and place the mob "..myAddonsYellow.."Rotting Dead"..myAddonsWhite.." under that heading.\n"..
						myAddonsBlue.."/kl delete"..myAddonsYellow.." <family> "..myAddonsWhite.."- will remove "..myAddonsYellow.."<family>"..myAddonsWhite.." from the database."..myAddonsClose
--#Endregion

local table_maxn = function(tab)
  local count = 0
  for k,v in pairs(tab) do
    count = count + 1
  end
  return count
end

---------------------------
-- XML handler functions --
---------------------------

function DebugMessage(x,y,z)
	if ( KillLog_Options.debugLevel == 1 ) then
		if ( z == "function" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cff87ade4[%s]: %s|r", x, y)) 
		elseif ( z == "helper" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cff00ff00[%s]: %s|r", x, y))
		elseif ( z == "info" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffffff00[%s]: %s|r", x, y))
		elseif ( z == "warning" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffffc000[%s]: %s|r", x, y))
		elseif ( z == "error" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffff0000[%s]: %s|r", x, y)) 
		end
	elseif ( KillLog_Options.debugLevel == 2 ) then
		if ( z == "helper" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cff00ff00[%s]: %s|r", x, y))
		elseif ( z == "info" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffffff00[%s]: %s|r", x, y))
		elseif ( z == "warning" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffffc000[%s]: %s|r", x, y))
		elseif ( z == "error" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffff0000[%s]: %s|r", x, y)) 
		end
	elseif ( KillLog_Options.debugLevel == 3 ) then
		if ( z == "info" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffffff00[%s]: %s|r", x, y))
		elseif ( z == "warning" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffffc000[%s]: %s|r", x, y))
		elseif ( z == "error" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffff0000[%s]: %s|r", x, y)) 
		end
	elseif ( KillLog_Options.debugLevel == 4 ) then
		if ( z == "warning" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffffc000[%s]: %s|r", x, y))
		elseif ( z == "error" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffff0000[%s]: %s|r", x, y)) 
		end
	elseif ( KillLog_Options.debugLevel == 5 ) then
		if ( z == "error" ) then
			DEFAULT_CHAT_FRAME:AddMessage(format("|cffff0000[%s]: %s|r", x, y)) 
		end
	end
end

function KillLogLoadingFrame_OnLoad()
	if ( Cosmos_RegisterButton ) then
		Cosmos_RegisterButton(KILLLOG_BUTTON_TEXT, KILLLOG_BUTTON_SUBTEXT, KILLLOG_BUTTON_TIP, "Interface\\Icons\\Ability_Warrior_Sunder", ToggleKillLog);
	end

	-- Check if myAddOns is loaded
	if(myAddOnsFrame_Register) then
		DEFAULT_CHAT_FRAME:AddMessage(loadingTitle);
	end
	
	KillLogLoadingFrame:RegisterEvent("VARIABLES_LOADED");
	KillLogLoadingFrame:RegisterEvent("UNIT_NAME_UPDATE");
	KillLogLoadingFrame:RegisterEvent("PLAYER_ENTER_COMBAT");
	KillLogLoadingFrame:RegisterEvent("PLAYER_LEAVE_COMBAT");
	KillLogLoadingFrame:RegisterEvent("PLAYER_REGEN_DISABLED");
	KillLogLoadingFrame:RegisterEvent("PLAYER_REGEN_ENABLED");
	KillLogLoadingFrame:RegisterEvent("PLAYER_ENTERING_WORLD");
	KillLogLoadingFrame.init = 0;
	KillLogLoadingFrame.checkLoaded = GetTime() + 10;
end

function KillLogLoadingFrame_OnEvent(event)
	if ( event == "PLAYER_ENTER_COMBAT" or event == "PLAYER_REGEN_DISABLED" ) then
		KillLogLoadingFrame.combatEnded = nil;
		DebugMessage("KL", event.." >>> combat", "helper");
	elseif ( event == "PLAYER_LEAVE_COMBAT" or event == "PLAYER_REGEN_ENABLED" ) then
		KillLogLoadingFrame.combatEnded = GetTime() + 5;
		KillLogLoadingFrame:Show();
		DebugMessage("KL", event.." <<< combat", "helper");
	elseif ( event == "VARIABLES_LOADED" or event == "UNIT_NAME_UPDATE" ) then
		--DebugMessage("KL", "DebugLevel "..KillLog_Options.debugLevel, "helper");
		KillLogLoadingFrame.init = KillLogLoadingFrame.init + 1;
		if ( KillLogLoadingFrame.init >= 1 ) then
			KillLogFrame_LoadData();
		end
	end
end


function KillLogLoadingFrame_OnEvent(event)
	if ( event == "PLAYER_ENTER_COMBAT" or event == "PLAYER_REGEN_DISABLED" ) then
		KillLogLoadingFrame.combatEnded = nil;
		DebugMessage("KL", event.." >>> combat", "helper");
	elseif ( event == "PLAYER_LEAVE_COMBAT" or event == "PLAYER_REGEN_ENABLED" ) then
		KillLogLoadingFrame.combatEnded = GetTime() + 5;
		KillLogLoadingFrame:Show();
		DebugMessage("KL", event.." <<< combat", "helper");
	elseif ( event == "VARIABLES_LOADED" or event == "UNIT_NAME_UPDATE" ) then
		--DebugMessage("KL", "DebugLevel "..KillLog_Options.debugLevel, "helper");
		KillLogLoadingFrame.init = KillLogLoadingFrame.init + 1;
		if ( KillLogLoadingFrame.init >= 1 ) then
			KillLogFrame_LoadData();
		end
	elseif ( event == "PLAYER_ENTERING_WORLD" ) then
		local characterLevel = UnitLevel("player");
		if ( KillLog_Options.maxLevel ) then
			if ( characterLevel == KillLog_Options.maxLevel ) then
				KillLogFrame.NoXpGain = true;
				DebugMessage("KL", "Set NoXpGain OnEvent", "helper");
			end
		end
	end
end


function KillLogLoadingFrame_OnUpdate()
	if ( KillLogLoadingFrame.combatEnded ) then
		if ( KillLogLoadingFrame.combatEnded < GetTime() ) then
			KillLogFrame.lastHitSelfToOther = nil;
			KillLogFrame.lastHitOtherToSelf = nil;
			KillLogLoadingFrame.combatEnded = nil;
		end
	elseif ( KillLogLoadingFrame.checkLoaded ) then
		if ( KillLogFrame.loaded ) then
			KillLogLoadingFrame:UnregisterEvent("VARIABLES_LOADED");
			KillLogLoadingFrame:UnregisterEvent("UNIT_NAME_UPDATE");
		end

		--sanity check; ensure that we are loaded and have the actual character name
		if ( KillLogLoadingFrame.checkLoaded <= GetTime() ) then
			if ( KillLogFrame.loaded == UnitName("player") ) then
				KillLogLoadingFrame.init = nil;
				KillLogLoadingFrame.checkLoaded = nil;
				KillLogLoadingFrame:Hide();
			else
				if ( KillLogFrame.loaded ) then
					DebugMessage("KL", "Data initialized for "..KillLogFrame.loaded.." instead of the actual character!  This has been corrected, but Frenn should be notified to prevent this from happening again.", "error");
				end
				KillLogFrame_LoadData();
				KillLogLoadingFrame.checkLoaded = GetTime() + 10;
			end
		end
	else
		KillLogLoadingFrame:Hide();
	end
end


function ToggleKillLog(tab)
	if ( not KillLogFrame.loaded ) then
		-- UIErrorsFrame:AddMessage("Frenn's "..KILLLOG_TITLE.." AddOn NOT initialized fully yet...", 1.0, 0.0, 0.0, 1.0, UIERRORS_HOLD_TIME);
		KillLogFrame_LoadData();
	end
	if ( not tab ) then
		if ( KillLogFrame:IsVisible() ) then
			HideUIPanel(KillLogFrame);
		else
			ShowUIPanel(KillLogFrame);
			local selectedFrame = getglobal(KILLLOG_TAB_SUBFRAMES[KillLogFrame.selectedTab]);
			if ( not selectedFrame:IsVisible() ) then
				selectedFrame:Show()
			end
		end
	else
		local subFrame = getglobal(tab);
		if ( subFrame ) then
			PanelTemplates_SetTab(KillLogFrame, subFrame:GetID());
			if ( KillLogFrame:IsVisible() ) then
				if ( subFrame:IsVisible() ) then
					HideUIPanel(KillLogFrame);
				else
					PlaySound("igCharacterInfoTab");
					KillLogFrame_ShowSubFrame(tab);
				end
			else
				ShowUIPanel(KillLogFrame);
				KillLogFrame_ShowSubFrame(tab);
			end
		end
	end
end

function KillLogFrame_ShowSubFrame(frameName)
	for index, value in pairs(KILLLOG_TAB_SUBFRAMES) do
		if ( value == frameName ) then
			getglobal(value):Show();
		else
			getglobal(value):Hide();
		end
	end
end

function KillLogTab_OnClick()
	if ( this:GetName() == "KillLogFrameTab1" ) then
		ToggleKillLog("KillLog_GeneralFrame");
	elseif ( this:GetName() == "KillLogFrameTab2" ) then
		ToggleKillLog("KillLog_ListFrame");
	elseif ( this:GetName() == "KillLogFrameTab3" ) then
		ToggleKillLog("KillLog_DeathFrame");
	elseif ( this:GetName() == "KillLogFrameTab4" ) then
		ToggleKillLog("KillLog_OptionsFrame");
	end
	PlaySound("igCharacterInfoTab");
end

function KillLogFrame_OnLoad()
	SlashCmdList["KILL_LOG_TOGGLE"] = KillLogFrame_Slash;
	SLASH_KILL_LOG_TOGGLE1 = "/killlog";
	SLASH_KILL_LOG_TOGGLE2 = "/kl";

	if ( not ChatParse_RegisterEvent ) then
		DebugMessage("KL", "function ChatParse_RegisterEvent not defined!", "error");
	end

	-- Tab Handling code
	PanelTemplates_SetNumTabs(this, 4);
	PanelTemplates_SetTab(this, 2);
	-- PanelTemplates_DisableTab(this, 4);
	
	this.loaded = nil;
	this.init   = 0;
	-- this will only be filled with creeps that we do not expect experience for
	-- that way, when we see a creep die we can count it as a kill if it's name is filled
	this.lastHitSelfToOther = nil;
	this.lastHitOtherToSelf = nil;
end

function KillLogFrame_Slash(msg)
	if msg == nil or msg == "" then
		msg = "log";
	end
	local args = { n = 0 }
	local function helper(word) table.insert(args, word) end
	string.gsub(msg, "[_%w]+", helper);
	argSize = table_maxn(args)
	DebugMessage("KL", msg, "helper");
	DebugMessage("KL", "args size "..argSize, "helper");
	
	if args[1] == 'log'  then
		ToggleKillLog(nil);
	elseif args[1] == 'debug' then
		if args[2] == nil then
			DEFAULT_CHAT_FRAME:AddMessage("|cffffff00".."Debug Level currently set at "..KillLog_Options.debugLevel.."|r");
		else
			argNumber = tonumber(args[2])
			if ( argNumber < 0 or argNumber > 5 ) then
				DEFAULT_CHAT_FRAME:AddMessage("Please use a value between 0 & 5 ",1,0,0);
			else
				DEFAULT_CHAT_FRAME:AddMessage("Debug Level set to "..argNumber,0,1,0);
				KillLog_Options.debugLevel = argNumber
			end
		end
	elseif args[1] == 'update' then
		if args[2] == nil or args[3] == nil then
			DebugMessage("KL", "Error updating family!", "warning");
			DebugMessage("KL", "use /kl update <family> <creepName>", "warning");
		else
			local creepFamily = args[2];
			local creepName = "";
			for i = 3, argSize, 1 do
				if ( i < argSize ) then	
					creepName = creepName..args[i].." "
				else
					creepName = creepName..args[i]
				end
			end
			DebugMessage("KL", "Format recognised!", "warning");
			DebugMessage("KL", "Family <"..creepFamily.."> creepName <"..creepName..">", "warning");
			
			if ( not KillLog_CreepFamily[1][creepFamily] ) then
				local creepInfo = KillLog_CreepFamily[1][creepFamily]
				if ( not creepInfo ) then
					DebugMessage("KL", "New family added, "..creepFamily, "warning");
					KillLog_CreepFamily[1][creepFamily] = { [1] = creepName }
				end
			else
				DebugMessage("KL", "New creep "..creepName, "warning");
				table.insert(KillLog_CreepFamily[1][creepFamily], creepName)
			end
		end
	elseif args[1] == 'delete' then
		if args[2] == 'family' then
			if args[3] == nil then
				DebugMessage("KL", "Error removing family! Please supply family name.", "error");
			else
				local creepFamily = args[3];
			
				KillLog_CreepFamily[1][creepFamily] = nil;
				DebugMessage("KL", "Family successfully removed, "..creepFamily, "warning");
			end
		else
			DebugMessage("KL", "Please use /kl delete family <creepFamily>", "error");
		end
	elseif args[1] == 'dataversion' then
		if args[2] == nil then
			DebugMessage("KL", "Please enter a number.", "error");
		else
			argNumber = tonumber(args[2])
			KillLog_Options.dataVersion = argNumber
			DebugMessage("KL", "Data Version reset to "..argNumber, "info");
		end
	elseif args[1] == 'datacheck' then
		if args[2] == 'family' then
			DebugMessage("KL", "Checking data integrity of 'family'", "helper");
			local family = {};
			--local i = 0
		
			for index, value in pairs(KillLog_CreepFamily[1]) do 
				table.insert(family, { family = "family", name = index } )
			--	i = i + 1
			--	DebugMessage("KL", "["..i.."] Family <"..index..">", "warning");
			end
			
			local numEntries = table.getn(family)
			QuickSort(family, function(a,b) if (a.name ~= b.name) then return a.name < b.name; end return a.name > b.name; end);
			for i = 1, numEntries, 1 do
				DebugMessage("KL", "Family: ["..i.."] <"..family[i].name..">", "warning");
			end
			
		elseif args[2] == 'overall' then
			DebugMessage("KL", "Checking data integrity of 'overall'", "helper");
			local i = 1
			for creepName, data in pairs(KillLog_AllCharacterData["overall"]) do
				if ( not data.kill and not data.death ) then
					DebugMessage("KL", i..": Missing data for "..creepName, "info");
					KillLog_AllCharacterData["overall"][creepName].kill = 1
					i = i + 1
				end
			end
		elseif args[2] == 'level' then
			if args[3] ~= nil then	
				DebugMessage("KL", "Checking data integrity of 'levels'", "helper");
				local lvl = tonumber(args[2]);
				KillLog_AllCharacterData["level"][lvl] = nil;
			else
				for level, data in pairs(KillLog_AllCharacterData["level"]) do
					if ( level == 0 ) then
						KillLog_AllCharacterData["level"][level] = nil;
						DebugMessage("KL", "Removing level, "..level, "info");
					end
				end
			end
		else
			DebugMessage("KL", "Please use /kl datacheck <family> or <overall> or <level>", "warning");
		end
	end
end	

function KillLogFrame_OnEvent(event)
	if ( event == "MEMORY_EXHAUSTED" ) then
		KillLog_FreeMemory();
	elseif ( event == "PLAYER_TARGET_CHANGED" ) then
		KillLogFrame_RecordCreepInfo("target");
       	local characterLevel = UnitLevel("player");
        if ( characterLevel == KillLog_Options.maxLevel ) then
			KillLogFrame.NoXpGain = true;
            if ( KillLogFrame.NoXpGain ) then
				DebugMessage("KL", "NoXpGain set to True", "info");
			end
		end
	elseif ( event == "UPDATE_MOUSEOVER_UNIT" ) then
		KillLogFrame_RecordCreepInfo("mouseover");
		local characterLevel = UnitLevel("player");
		if ( UnitExists("mouseover") and not UnitPlayerControlled("mouseover") and KillLog_Options.tooltip ) then
			KillLog_Tooltip();
		end
        if ( characterLevel == KillLog_Options.maxLevel ) then
			KillLogFrame.NoXpGain = true;
            if ( KillLogFrame.NoXpGain ) then
				DebugMessage("KL", "NoXpGain set to True", "info");
			end
		end
	elseif ( event == "PLAYER_XP_UPDATE" ) then
		DebugMessage("KL", "event: "..event, "function");
		local characterLevel = UnitLevel("player");
		if ( characterLevel >= 60 ) then
			KillLog_Options.maxLevel = 70;
			DebugMessage("KL", "maxLevel: "..KillLog_Options.maxLevel, "function");
		end
	elseif ( event == "UNIT_LEVEL" ) then
		local characterLevel = UnitLevel("player");
		if ( characterLevel == 70 ) then
			KillLog_Options.maxLevel = 70
		end
		if ( characterLevel == KillLog_Options.maxLevel ) then
			KillLogFrame.NoXpGain = true;
            if ( KillLogFrame.NoXpGain ) then
				DebugMessage("KL", "NoXpGain set to True", "info");
			end
		end
		if ( not KillLog_ListFrame:IsVisible() ) then
			KillLog_ListFrame.displayLevel = characterLevel;
		end
		if ( KillLog_Options.storeLevel and KillLog_AllCharacterData["level"] and not KillLog_AllCharacterData["level"][characterLevel] ) then
			KillLog_AllCharacterData["level"][characterLevel] = { };

			if ( KillLog_Options.storeLevel < KillLog_Options.maxLevel ) then
				local level, levelCount;
				levelCount = 0;
				for level = characterLevel, 1, -1 do
					if ( KillLog_AllCharacterData["level"][level] ) then
						if ( levelCount == KillLog_Options.storeLevel ) then
							KillLog_AllCharacterData["level"][level] = nil;
						else
							levelCount = levelCount + 1;
						end
					end
				end
			end
		end
	end
end

function KillLogFrame_OnShow()
	PlaySound("igCharacterInfoOpen");
end

function KillLogFrame_OnHide()
	PlaySound("igCharacterInfoClose");
end

----------------------
-- Helper functions --
----------------------
function KillLog_FreeMemory()
	if ( KillLog_CreepPortrait ) then
		DebugMessage("KL", "Out of Memory! discarding portraits!", "error");
		KillLog_CreepPortrait = nil;
		KillLog_CreepPortraitID = KILL_LOG_MAX_PORTRAITS;
		local index;
		for index=1, KILL_LOG_MAX_PORTRAITS, 1 do
			local portrait = getglobal("KillLog_ListFrame_CreepPortrait"..index);
			portrait = nil;
		end
	elseif ( KillLog_SessionData ) then
		DebugMessage("KL", "Out of Memory! discarding data for current session!", "error");
		KillLog_SessionData = nil;
	elseif ( KillLogFrame ) then
		DebugMessage("KL", "Out of Memory! discarding XML frames!!  The display will now be broken for the remainder of this session, but all of your data is still intact!", "error");
		KillLogFrame = nil;
	elseif ( KillLog_CreepData ) then
		DebugMessage("KL", "Out of Memory! discarding creep data!", "error");
		KillLog_CreepData = nil;
	end
end

function KillLogFrame_LoadData()
	local server         = GetCVar("realmName");
	local characterName  = UnitName("player");
	local characterLevel = UnitLevel("player");
    
	if ( KillLogFrame.loaded or not characterName or characterName == UNKNOWNOBJECT ) then
		return;
	end

	-- initialize options
	if ( not KillLog_Options ) then
		KillLogFrame_SetDefaults();
		if ( KillLog_CharacterData ) then
			KillLog_UpdateData();
		end
	end
	
	if ( KillLog_Options.maxLevel ) then
		if ( characterLevel == KillLog_Options.maxLevel ) then
			KillLogFrame.NoXpGain = true;
		end
	else
		KillLog_Options.maxLevel = KILLLOG_MAX_LEVEL;
		DebugMessage("KL", "characterLevel: "..KillLog_Options.maxLevel, "info");
	end
	
	if ( not KillLog_Options.version or not KillLog_Options.debugLevel or KillLog_Options.version ~= KILLLOG_VERSION ) then
		KillLog_Options.version = KILLLOG_VERSION;
		KillLog_Options.debugLevel = nil;
		--DEFAULT_CHAT_FRAME:AddMessage("Version compare: "..KillLog_Options.version.. " - "..KILLLOG_VERSION);
		--DEFAULT_CHAT_FRAME:AddMessage("Debug reset: "..KillLog_Options.debugLevel);
	end
	
	if ( not KillLog_CreepFamily ) then
		KillLog_CreepFamily = {  
			KILLLOG_CREEP_FAMILIES
		};
	end

	while ( KillLog_Options.dataVersion ~= KILLLOG_DATA_VERSION ) do
		KillLog_UpdateData();
	end

	if ( not KillLog_CreepInfo ) then
		KillLog_CreepInfo = { };
	end

	if ( KillLog_Options.storeOverall or KillLog_Options.storeLevel or KillLog_Options.storeMax or KillLog_Options.storeDeath ) then
		if ( not KillLog_CharacterData ) then
			KillLog_CharacterData = { };
		end
		if ( not KillLog_CharacterData[server] ) then
			KillLog_CharacterData[server] = { };
		end
		if ( not KillLog_CharacterData[server][characterName] ) then
			KillLog_CharacterData[server][characterName] = { };
		end
		
		-- we'll only be dealing with one character; so privide local name for data
		KillLog_AllCharacterData = KillLog_CharacterData[server][characterName];
		
		if ( KillLog_Options.storeOverall ) then
			if ( not KillLog_AllCharacterData["overall"] ) then
				KillLog_AllCharacterData["overall"] = { };
			end
		end
		
		if ( KillLog_Options.storeLevel ) then
			if ( not KillLog_AllCharacterData["level"] ) then
				KillLog_AllCharacterData["level"] = { };
				DebugMessage("KL", "Character data missing!", "info");
			end
			DebugMessage("KL", "character level: "..characterLevel, "function");
		end

		if ( KillLog_Options.storeMax ) then
			if ( not KillLog_AllCharacterData["max"] ) then
				KillLog_AllCharacterData["max"] = { };
			end
			KillLog_AllCharacterData["heals"] = nil;
			--[[if ( not KillLog_AllCharacterData["heals"] ) then
				KillLog_AllCharacterData["heals"] = { };
			end--]]
		end

		if ( KillLog_Options.storeDeath ) then
			if ( not KillLog_AllCharacterData["death"] ) then
				KillLog_AllCharacterData["death"] = { };
			end
		end
	end

	-- for switching to new / level table entry
	if ( KillLog_Options.storeLevel ) then
		KillLogFrame:RegisterEvent("UNIT_LEVEL");
	end
	-- for gathering creep info
	if ( KillLog_Options.storeCreep ) then
		KillLogFrame:RegisterEvent("PLAYER_TARGET_CHANGED");
		KillLogFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
		KillLogFrame:RegisterEvent("PLAYER_XP_UPDATE");

		local continents = { GetMapContinents() };
		local continent, junk, zones, zone, name;
		for continent, junk in pairs({ GetMapContinents() }) do
			for zone, name in pairs({ GetMapZones(continent) }) do
				KillLog_Map[name] = { continent = continent, zone = zone };
			end
		end
	end

	if ( KillLog_Options.tooltip ) then
		KillLogFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT");
	end
	
	local chatParseInfo 	= { AddOn = "KillLog" };
--#Region XP Gain
	chatParseInfo.event		= "CHAT_MSG_COMBAT_XP_GAIN";
	chatParseInfo.func		= function(t) KillLogFrame_RecordData(t, "kill", 1); end;

	chatParseInfo.template = COMBATLOG_XPGAIN_EXHAUSTION1_GROUP; --"%s dies, you gain %d experience. (%s exp %s bonus, +%d group bonus)"
	chatParseInfo.fields   = { "creepName", "xp", "bonusXp", "bonusType", "groupXp" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.template = COMBATLOG_XPGAIN_EXHAUSTION1_RAID; --"%s dies, you gain %d experience. (%s exp %s bonus, -%d raid penalty)"
	chatParseInfo.fields   = { "creepName", "xp", "bonusXp", "bonusType", "raidXp" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.template = COMBATLOG_XPGAIN_EXHAUSTION1; --"%s dies, you gain %d experience. (%s exp %s bonus)"
	chatParseInfo.fields   = { "creepName", "xp", "bonusXp", "bonusType" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.template = COMBATLOG_XPGAIN_FIRSTPERSON_GROUP; --"%s dies, you gain %d experience. (+%d group bonus)"
	chatParseInfo.fields   = { "creepName", "xp", "groupXp" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.template = COMBATLOG_XPGAIN_FIRSTPERSON_RAID; --"%s dies, you gain %d experience. (-%d raid penalty)"
	chatParseInfo.fields   = { "creepName", "xp", "raidXp" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.template = COMBATLOG_XPGAIN_FIRSTPERSON; --"%s dies, you gain %d experience."
	chatParseInfo.fields   = { "creepName", "xp" };
	ChatParse_RegisterEvent(chatParseInfo);


	chatParseInfo.event    = "CHAT_MSG_SYSTEM";
	chatParseInfo.func     = function(t) KillLogFrame_RecordMiscXp("exploration", t.xp); end;
	chatParseInfo.template = ERR_ZONE_EXPLORED_XP; --"Discovered %s: %d experience gained"
	chatParseInfo.fields   = { nil, "xp" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     = function(t) KillLogFrame_RecordMiscXp("quest", t.xp); end;
	chatParseInfo.template = ERR_QUEST_REWARD_EXP_I; --"Experience gained: %d."
	chatParseInfo.fields   = { "xp" };
	ChatParse_RegisterEvent(chatParseInfo);
--#Endregion
--#Region Melee Combat Messages
	chatParseInfo.event    = "CHAT_MSG_COMBAT_SELF_HITS";
	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(KILLLOG_LABEL_DEFAULT, KILLLOG_LABEL_HIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = COMBATHITSELFOTHER; --"You hit %s for %d."
	chatParseInfo.fields   = { "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(KILLLOG_LABEL_DEFAULT, KILLLOG_LABEL_CRIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = COMBATHITCRITSELFOTHER; --"You crit %s for %d."
	chatParseInfo.fields   = { "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(t.spell, KILLLOG_LABEL_HIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = SPELLLOGSELFOTHER; --"Your %s hits %s for %d."
	chatParseInfo.fields   = { "spell", "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(t.spell, KILLLOG_LABEL_CRIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = SPELLLOGCRITSELFOTHER; -- "Your %s crits %s for %d %s."
	chatParseInfo.fields   = { "spell", "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);
--#Endregion
--#Region Spell Combat Messages
	chatParseInfo.event    = "CHAT_MSG_SPELL_SELF_DAMAGE";
	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(t.spell, KILLLOG_LABEL_HIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = SPELLLOGSELFOTHER; -- "Your %s hits %s for %d."
	chatParseInfo.fields   = { "spell", "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);
	
	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(t.spell, KILLLOG_LABEL_CRIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = SPELLLOGCRITSELFOTHER; -- "Your %s crits %s for %d %s."
	chatParseInfo.fields   = { "spell", "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(t.spell, KILLLOG_LABEL_HIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = SPELLLOGSCHOOLSELFOTHER; --"Your %s hits %s for %d %s."
	chatParseInfo.fields   = { "spell", "creepName", "damage", "spelltype" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(t.spell, KILLLOG_LABEL_CRIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = SPELLLOGCRITSCHOOLSELFOTHER;
	chatParseInfo.fields   = { "spell", "creepName", "damage", "spelltype" };
	ChatParse_RegisterEvent(chatParseInfo);
--#Endregion
--#Region Healing Messages	
	--[[ Healing Spells
	chatParseInfo.event =	"CHAT_MSG_SPELL_SELF_BUFF";
	chatParseInfo.func     = function(t) KillLogFrame_CheckMaxDamage(t.spell, KILLLOG_LABEL_HIT, t.damage, KILLLOG_LABEL_HEAL); end;
	chatParseInfo.template = HEALEDSELFSELF; -- "Your %s heals you for %d."
	chatParseInfo.fields   = { "spell", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);
	
	chatParseInfo.func     = function(t) KillLogFrame_CheckMaxDamage(t.spell, KILLLOG_LABEL_CRIT, t.damage, KILLLOG_LABEL_HEAL); 
							 			 DebugMessage("KL", "Spell name: "..t.spell, "warning");	 
							 end;
	chatParseInfo.template = HEALEDCRITSELFSELF; -- "Your %s critically heals you for %d"
	chatParseInfo.fields   = { "spell", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);
	
	chatParseInfo.func     = function(t) KillLogFrame_CheckMaxDamage(t.spell, KILLLOG_LABEL_HIT, t.damage, KILLLOG_LABEL_HEAL); end;
	chatParseInfo.template = HEALEDSELFOTHER; -- "Your %s heals %s for %d."
	chatParseInfo.fields   = { "spell", "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     = function(t) KillLogFrame_CheckMaxDamage(t.spell, KILLLOG_LABEL_CRIT, t.damage, KILLLOG_LABEL_HEAL); end;
	chatParseInfo.template = HEALEDCRITSELFOTHER; -- "Your %s critically heals %s for %d."
	chatParseInfo.fields   = { "spell", "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);]]
--#Endregion
--#Region Pet Melee Combat Messages	
	chatParseInfo.event    = "CHAT_MSG_COMBAT_PET_HITS";
	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(KILLLOG_LABEL_DEFAULT.." "..KILLLOG_LABEL_PET, KILLLOG_LABEL_HIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = COMBATHITOTHEROTHER; --"%s hits %s for %d."
	chatParseInfo.fields   = { nil, "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(KILLLOG_LABEL_DEFAULT.." "..KILLLOG_LABEL_PET, KILLLOG_LABEL_CRIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = COMBATHITCRITOTHEROTHER; --"%s crits %s for %d."
	chatParseInfo.fields   = { nil, "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);
--#Endregion
--#Region Pet Spell Combat Messages
	chatParseInfo.event    = "CHAT_MSG_SPELL_PET_DAMAGE";
	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(t.spell.." "..KILLLOG_LABEL_PET, KILLLOG_LABEL_HIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = SPELLLOGSCHOOLOTHEROTHER; --"%s's %s hits %s for %d %s damage."
	chatParseInfo.fields   = { nil, "spell", "creepName", "damage", "spelltype"};
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     = function(t) KillLogFrame_StoreTrivialCreepName(t.creepName); KillLogFrame_CheckMaxDamage(t.spell.." "..KILLLOG_LABEL_PET, KILLLOG_LABEL_CRIT, t.damage, KILLLOG_LABEL_DAMAGE); end;
	chatParseInfo.template = SPELLLOGCRITSCHOOLOTHEROTHER; --"%s's %s crits %s for %d %s damage."
	chatParseInfo.fields   = { nil, "spell", "creepName", "damage", "spelltype"};
	ChatParse_RegisterEvent(chatParseInfo);
--#Endregion
--#Region Creature Melee Combat Messages
	chatParseInfo.event    = "CHAT_MSG_COMBAT_CREATURE_VS_SELF_HITS";
	chatParseInfo.func     = function(t) KillLogFrame.lastHitOtherToSelf = t.creepName; end;
	chatParseInfo.template = COMBATHITOTHERSELF; --"%s hits you for %d."
	chatParseInfo.fields   = { "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     = function(t) KillLogFrame.lastHitOtherToSelf = t.creepName; end;
	chatParseInfo.template = COMBATHITCRITOTHERSELF; --"%s crits you for %d."
	chatParseInfo.fields   = { "creepName", "damage" };
	ChatParse_RegisterEvent(chatParseInfo);
--#Endregion
--#Region Creature Spell Combat Messages
	chatParseInfo.event    	= "CHAT_MSG_SPELL_CREATURE_VS_SELF_DAMAGE";
	chatParseInfo.func     	= 	function(t) KillLogFrame.lastHitOtherToSelf = t.creepName; 	end;
	chatParseInfo.template 	= SPELLLOGSCHOOLOTHERSELF; --"%s's %s hits you for %d %s damage."
	chatParseInfo.fields   	= { "creepName", "spell", "damage", "spelltype"};
	ChatParse_RegisterEvent(chatParseInfo);

	chatParseInfo.func     	= 	function(t) KillLogFrame.lastHitOtherToSelf = t.creepName; end;
	chatParseInfo.template 	= SPELLLOGCRITSCHOOLOTHERSELF; --"%s's %s crits you for %d %s damage."
	chatParseInfo.fields   	= { "creepName", "spell", "damage", "spelltype"};
	ChatParse_RegisterEvent(chatParseInfo);
--#Endregion
--#Region Creature Kill Messages
	chatParseInfo.event    	= "CHAT_MSG_COMBAT_HOSTILE_DEATH";
	chatParseInfo.func     	= 	function(t)
									if ( KillLogFrame.lastHitSelfToOther and KillLogFrame.lastHitSelfToOther == t.creepName ) then
										KillLogFrame_RecordData({ creepName = KillLogFrame.lastHitSelfToOther }, "kill", 1);
										KillLogFrame.lastHitSelfToOther = nil;
									end
								end;
	chatParseInfo.template = UNITDIESOTHER; --"%s dies."
	chatParseInfo.fields   = { "creepName" };
	ChatParse_RegisterEvent(chatParseInfo);
	
	--[[chatParseInfo.template = SELFKILLOTHER; --"You have slain %s!"
	chatParseInfo.fields   = { "creepName" };
	ChatParse_RegisterEvent(chatParseInfo);]]
--#Endregion
--#Region Death Messages
	-- You Die
	chatParseInfo.event    	= "CHAT_MSG_COMBAT_FRIENDLY_DEATH";
	chatParseInfo.func		=	function()
									local killedBy = KILLLOG_LIST_UNKNOWNTYPE;
									if ( KillLogFrame.lastHitOtherToSelf ) then
										KillLogFrame_RecordData({ creepName = KillLogFrame.lastHitOtherToSelf }, "death", 1);
										killedBy = KillLogFrame.lastHitOtherToSelf;
										KillLogFrame_RecordDeath(killedBy);
										KillLogFrame.lastHitOtherToSelf = nil;
									end
									
								end;
	chatParseInfo.template = UNITDIESSELF; -- "You die."
	chatParseInfo.fields   = { };
	ChatParse_RegisterEvent(chatParseInfo);
--#Endregion
	-- error handling
	KillLogFrame:RegisterEvent("MEMORY_EXHAUSTED");

	KillLogFrame.loaded = characterName
	DebugMessage("KL", "data loaded for "..characterName, "helper");
	DebugMessage("KL", "sanity check: "..characterLevel, "helper");
end

function KillLogFrame_SetDefaults()
	KillLog_Options = {
		tooltip       = true,
		trivial       = true,
		storeMax      = true,
		notifyMax     = true,
		storeCreep    = true,
		storeLocation = true,
		storeOverall  = true,
		storeDeath    = true,
		session       = true,
		debugLevel	  = nil,
		storeLevel    = 31,
		portrait      = KILLLOG_LIST_MAX_PORTRAITS,
		dataVersion   = KILLLOG_DATA_VERSION,
		version		  = KILLLOG_VERSION,
		sctSupport	  = true,
		color		  = { r = 1.0, g = 1.0, b = 1.0 }
	};
end

function KillLogFrame_RecordCreepInfo(unit)
	if ( not UnitExists(unit) or UnitPlayerControlled(unit) or UnitIsFriend("player", unit) ) then
		if ( not UnitExists(unit) ) then
			DebugMessage("KL", "Unit does not exist: "..unit, "helper");
		elseif ( UnitPlayerControlled(unit) ) then
			DebugMessage("KL", "Unit is player controlled: "..unit, "helper");
		elseif ( UnitIsFriend("player", unit) ) then
			DebugMessage("KL", "Unit is friend: "..unit, "helper");
		end
		return;
	end
			
	local creepName = UnitName(unit);
	local creepLevel = UnitLevel(unit);

	if ( creepLevel == -1 ) then
		creepLevel = nil;
	end
	-- check if we should store data
	if ( KillLog_Options.storeCreep ) then
		local creepClass    = UnitClassification(unit);
		local creepFaction  = UnitFactionGroup(unit);
		local creepType     = UnitCreatureType(unit);
		local creepFamily   = UnitCreatureFamily(unit);

		-- creep family only true for beasts... use our function to fill for humanoids
		if ( not creepFamily ) then
			creepFamily = KillLog_GetCreepFamily(creepName);
			if ( creepFamily ) then
				DebugMessage("KL", "Family not found: "..creepName..", using "..creepFamily.." from localisation!", "helper");
			else
				creepFamily = creepType;
				if ( unit == "target" and creepType ) then
					DebugMessage("KL", "Family not found: "..creepName..", using type "..creepType.." please update!", "warning");
				end
			end
		end

		if ( creepClass == "normal" ) then
			creepClass = nil;
		end
		if ( not UnitIsPVP(unit) ) then
			creepFaction = nil;
		end

		local creepInfo = KillLog_CreepInfo[creepName];
		if ( not creepInfo ) then
			DebugMessage("KL", "new CreepInfo: "..creepName, "info");
			KillLog_CreepInfo[creepName] = { min = creepLevel, max = creepLevel, class = creepClass, type = creepType, faction = creepFaction, family = creepFamily };
			creepInfo = KillLog_CreepInfo[creepName];
		else
			if ( creepLevel) then
				if ( not creepInfo.min or not creepInfo.max ) then
					DebugMessage("KL", "new level: "..creepName..", "..creepLevel, "info");
					creepInfo.min = creepLevel;
					creepInfo.max = creepLevel;
				elseif ( creepInfo.min > creepLevel ) then
					DebugMessage("KL", "new min: "..creepName..", "..creepLevel.." - "..creepInfo.max, "info");
					creepInfo.min = creepLevel;
				elseif ( creepInfo.max < creepLevel ) then
					DebugMessage("KL", "new max: "..creepName..", "..creepInfo.min.." - "..creepLevel, "info");
					creepInfo.max = creepLevel;
				end
			end
			if ( creepInfo.class ~= creepClass ) then
				if ( creepClass ) then
					DebugMessage("KL", "new class: "..creepName..", "..creepClass, "info");
				end
				creepInfo.class = creepClass;
			end
			if ( creepInfo.faction ~= creepFaction ) then
				if ( creepFaction ) then
					DebugMessage("KL", "new faction: "..creepName..", "..creepFaction, "info");
				end
				creepInfo.faction = creepFaction;
			end
			if ( creepType and not creepInfo.type ) then
				DebugMessage("KL", "new type: "..creepName..", "..creepType, "info");
				creepInfo.type = creepType;
			end
			
			-- available for beasts from UnitCreatureFamily; otherwise by scanning creepName
			if ( creepInfo.creepFamily ~= creepFamily ) then
				DebugMessage("KL", "Family updated: "..creepName..", "..creepFamily, "helper");
				creepInfo.family = creepFamily;
			end
		end

		if ( KillLog_Options.storeLocation ) then
			creepInfo.zone = GetZoneText();
			local mapData = KillLog_Map[creepInfo.zone]
			if ( mapData ) then
				if ( GetCurrentMapContinent() ~= mapData.continent or GetCurrentMapZone() ~= mapData.zone ) then
					SetMapZoom(mapData.continent, mapData.zone);
				end
				local mapX, mapY    = GetPlayerMapPosition("player");
				tempX         		= math.floor(100.0 * mapX);
				tempY         		= math.floor(100.0 * mapY);

				--[[if ( not creepInfo.x or not creepInfo.maxX ) then
					DebugMessage("KL", "new X coords: "..creepName..", ("..tempX..", "..tempX..")", "info");
					creepInfo.x         = tempX;
					creepInfo.maxX		= tempX;
				end
				if ( creepInfo.x > tempX ) then
					DebugMessage("KL", "new minX: "..creepName..", "..tempX.." - "..creepInfo.maxX, "info");
					creepInfo.x = tempX;
				end
				if ( creepInfo.maxX < tempX ) then
					DebugMessage("KL", "new maxX: "..creepName..", "..creepInfo.x.." - "..tempX, "info");
					creepInfo.maxX = tempX;
				end
				
				if ( not creepInfo.y or not creepInfo.maxY ) then
					DebugMessage("KL", "new Y coords: "..creepName..", ("..tempY..", "..tempY..")", "info");
					creepInfo.y         = tempY;
					creepInfo.maxY		= tempY;
				end
				if ( creepInfo.y > tempY ) then
					DebugMessage("KL", "new minY: "..creepName..", "..tempY.." - "..creepInfo.maxY, "info");
					creepInfo.y = tempY;
				end
				if ( creepInfo.maxY < tempY ) then
					DebugMessage("KL", "new maxY: "..creepName..", "..creepInfo.y.." - "..tempY, "info");
					creepInfo.maxY = tempY;
				end]]
				
				local minX, maxX, minY, maxY;
				
				if ( not creepInfo.loc ) then
					creepInfo.loc = tempX.."-"..tempY.."/"..tempX.."-"..tempY
					DebugMessage("KL", "Saving new coords: "..creepName..", ("..tempX.." - "..tempY..") ("..tempX.." - "..tempY..")", "info");
				else
					DebugMessage("KL", "Checking coords: "..creepName, "info");
					local newMinX, newMaxX, newMinY, newMaxY
					
					breakPoint = string.find(creepInfo.loc,"/")
					minMidPoint = string.find(creepInfo.loc,"-")
					maxMidPoint = string.find(creepInfo.loc,"-",breakPoint)
					
					minX = tonumber(string.sub(creepInfo.loc, 1, minMidPoint - 1))
					maxX = tonumber(string.sub(creepInfo.loc, breakPoint + 1, maxMidPoint - 1))
					minY = tonumber(string.sub(creepInfo.loc, minMidPoint + 1, breakPoint - 1))
					maxY = tonumber(string.sub(creepInfo.loc, maxMidPoint + 1))
					
					if ( minX > tempX ) then
						minX = tempX
					end
					if ( maxX < tempX ) then
						maxX = tempX
					end
					
					if ( minY > tempY ) then
						minY = tempY
					end
					if ( maxY < tempY ) then
						maxY = tempY
					end
					creepInfo.loc = minX.."-"..minY.."/"..maxX.."-"..maxY
					DebugMessage("KL", "Location: "..minX.."-"..minY.."/"..maxX.."-"..maxY, "info");
				end
			end
		end
	end

	if ( KillLog_Options.portrait and KillLog_CreepPortrait ) then
		if ( not KillLog_CreepPortrait[creepName] and KillLog_CreepPortraitID <= KillLog_Options.portrait ) then
			local portrait = getglobal("KillLog_ListFrame_CreepPortrait"..KillLog_CreepPortraitID);
			if ( portrait ) then
				DebugMessage("KL", "Portrait["..KillLog_CreepPortraitID.."]: for "..creepName, "helper");
				SetPortraitTexture(portrait, unit);
				KillLog_CreepPortrait[creepName] = KillLog_CreepPortraitID;
				KillLog_CreepPortraitID = KillLog_CreepPortraitID + 1;
			end
		end
	end

	if ( unit == "target" and not UnitIsDead(unit) and (not UnitIsTapped(unit) or UnitIsTappedByPlayer(unit) ) and UnitCanAttack("player", unit) ) then
			KillLogFrame_StoreTrivialCreepName(creepName, creepLevel);
			if ( creepLevel ) then
				DebugMessage("KL", "Gathering details for <"..creepName.."> level <"..creepLevel..">", "info");
			else	
				DebugMessage("KL", "Gathering details for <"..creepName..">", "info");
			end
	end
end

--[[
--	check if we should have received exp or not
--  the highest level creep we've seen would need to return a grey color
--  and we need to have just struck this creep
--  we do not want to either receive credit twice for this kill or receive credit for someone else's kill
--]]
function KillLogFrame_CheckTrivialCreepName(creepName, creepLevel)
	if ( KillLogFrame.NoXpGain or not creepName or (creepLevel and KillLog_GetDifficultyRating(creepLevel) == 1) ) then
		DebugMessage("KL", "NoXPGain", "helper");
		return true;
	end
	if ( KillLog_CreepInfo[creepName] ) then
		if ( (KillLog_CreepInfo[creepName]["type"] and KillLog_CreepInfo[creepName]["type"] == "Critter") or KillLogFrame.NoXpGain ) then
			DebugMessage("KL", "Critter or Boss", "helper");
			return true;
		elseif ( not creepLevel and KillLog_CreepInfo[creepName]["max"] and KillLog_GetDifficultyRating(KillLog_CreepInfo[creepName]["max"]) == 1 ) then
			DebugMessage("KL", "No Level", "helper");
			return true;
		end
	end
	DebugMessage("KL", "CheckTrivialCreepName - returning nil", "helper");
	return nil;
end

function KillLogFrame_StoreTrivialCreepName(creepName, creepLevel)
	if ( KillLogFrame_CheckTrivialCreepName(creepName, creepLevel) ) then
		KillLogFrame.lastHitSelfToOther = creepName;
		DebugMessage("KL", "Details gathered for <"..KillLogFrame.lastHitSelfToOther..">", "info");
	end
end

function KillLogFrame_CheckMaxDamage(attackName, attackType, attackDamage, damage)
	if ( not KillLog_Options.storeMax or not KillLog_AllCharacterData or not KillLog_AllCharacterData["max"] ) then
		return;
	else
		DebugMessage("KL", "Checking Max Damage: "..attackName.." "..attackType.." "..attackDamage.." "..damage, "helper");
		attackDamage = 0 + attackDamage;
		if ( not KillLog_AllCharacterData["max"][attackName] ) then
			KillLog_AllCharacterData["max"][attackName] = { hit = 0, crit = 0 };
		end
		if ( attackDamage > KillLog_AllCharacterData["max"][attackName][attackType] ) then
			KillLog_AllCharacterData["max"][attackName][attackType] = attackDamage;
			if ( KillLog_Options.notifyMax ) then
				if ( not SCT or not KillLog_Options.sctSupport ) then	
					UIErrorsFrame:AddMessage(format(KILLLOG_NEW_MAX, attackName, attackType, attackDamage), 1.0, 0.0, 0.0, 1.0, UIERRORS_HOLD_TIME);
					DebugMessage("KL", "Message sent via UIErrorsFrame", "helper")
				else
					if ( not KillLog_Options.color ) then
						SCT_Color = {r = 1.0, g = 1.0, b = 1.0}
						SCT:DisplayCustomEvent(format(KILLLOG_NEW_MAX, attackName, attackType, attackDamage), SCT_Color, 0, 1);
						DebugMessage("KL", "Message sent via SCT using default colors", "helper")
					else
						SCT_Color = {r = KillLog_Options.color.r, g = KillLog_Options.color.g, b = KillLog_Options.color.b}
						SCT:DisplayCustomEvent(format(KILLLOG_NEW_MAX, attackName, attackType, attackDamage), SCT_Color, 0, 1);
						DebugMessage("KL", "Message sent via SCT using custom colors", "helper")
					end
				end
			end
			KillLog_SendUpdate();
		end
	end
end

function KillLogFrame_RecordData(creepTableData, method, number)
	local listData, index, data, message, amount, field;

	listData = { };
	message = "updating: ";
	
	if ( KillLog_Options.storeOverall and KillLog_AllCharacterData and KillLog_AllCharacterData["overall"] ) then
		if ( not KillLog_AllCharacterData["overall"][creepTableData.creepName] ) then
			KillLog_AllCharacterData["overall"][creepTableData.creepName] = { };
		end
		table.insert(listData, KillLog_AllCharacterData["overall"][creepTableData.creepName]);
		message = message.."overall, ";
	end
	if ( KillLog_Options.session and KillLog_SessionData ) then
		index = table.foreach(KillLog_SessionData, function(k,v) if ( v.name == creepTableData.creepName ) then return k; end return nil; end);
		if ( not index ) then
			table.insert(KillLog_SessionData, 1, { name = creepTableData.creepName });
		elseif ( index ~= 1 ) then
			data = KillLog_SessionData[index];
			for index = index, 2, -1 do
				KillLog_SessionData[index] = KillLog_SessionData[index-1];
			end
			KillLog_SessionData[1] = data;
		end
		table.insert(listData, KillLog_SessionData[1]);
		message = message.."session, ";
	end
	if ( KillLog_Options.storeLevel and KillLog_AllCharacterData and KillLog_AllCharacterData["level"] ) then
		local currentLevel = UnitLevel("player");
		if ( not KillLog_AllCharacterData["level"][currentLevel] ) then
			KillLog_AllCharacterData["level"][currentLevel] = { };
			KillLog_AllCharacterData["level"][currentLevel][creepTableData.creepName] = { };
			
			DebugMessage("KL", "Level "..currentLevel.." data added!", "function");
		else
			if ( not KillLog_AllCharacterData["level"][currentLevel][creepTableData.creepName] ) then
				KillLog_AllCharacterData["level"][currentLevel][creepTableData.creepName] = { };
			end
		end
		table.insert(listData, KillLog_AllCharacterData["level"][currentLevel][creepTableData.creepName]);
		message = message.."level";
	end
	DebugMessage("KL", message, "helper");

	local updateData = function(struct, field, amount)
		if ( not struct[field] ) then
			message = message..", "..field.." = "..amount;
			-- force numeric context
			struct[field] = 0 + amount;
		else
			message = message..", "..field.." = "..struct[field].." + "..amount;
			struct[field] = struct[field] + amount;
			message = message.." => "..struct[field];
		end
	end;

	for index, data in pairs(listData) do
		message = "data["..index.."]: ";
		--"xp", "bonusXp", "bonusType", "groupXp"
		if ( creepTableData.xp ) then
			updateData(data, "xp", creepTableData.xp);
		end
		if ( creepTableData.bonusType and creepTableData.bonusXp ) then
			if ( creepTableData.bonusType == KILLLOG_LABEL_RESTED ) then
				updateData(data, "rested", creepTableData.bonusXp);
			elseif  ( creepTableData.bonusType == KILLLOG_LABEL_GROUP ) then
				updateData(data, "group", creepTableData.bonusXp);
			elseif  ( creepTableData.bonusType == KILLLOG_LABEL_RAID ) then
				updateData(data, "raid", creepTableData.bonusXp);
			else
				--updateData(data, "rested", creepTableData.bonusXp);
				DebugMessage("KL", "Bonus experience of type "..creepTableData.bonusType.." not recognized; data not stored!", "error");
			end
		end
		if ( creepTableData.groupXp ) then
			updateData(data, "group", creepTableData.groupXp);
		end
		if ( creepTableData.raidXp ) then
			updateData(data, "raid", 0 - creepTableData.raidXp);
		end
		if ( method  ) then
			if ( number ) then
				updateData(data, method, number);
				--DebugMessage("KL", "method <"..method.."> number <"..number..">", "info");
			end
		end
		DebugMessage("KL", message, "info");
	end
	KillLog_SendUpdate();
	return nil;
end

function KillLogFrame_RecordMiscXp(xpType, xp)
	if ( not KillLog_AllCharacterData ) then
		return;
	end
	if ( KillLog_AllCharacterData[xpType.." xp"] ) then
		KillLog_AllCharacterData[xpType.." xp"] = xp + KillLog_AllCharacterData[xpType.." xp"];
	else
		KillLog_AllCharacterData[xpType.." xp"] = xp;
	end
	DebugMessage("KL", "Misc "..xpType.." XP: "..xp, "info");
	KillLog_SendUpdate();
end

function KillLogFrame_RecordDeath(creepName)
	local KILLLOG_RECORD_NUMBERS = table.getn(KillLog_AllCharacterData["death"]) + 1;
	if ( KillLog_Options.storeDeath and KillLog_AllCharacterData and KillLog_AllCharacterData["death"] ) then
		KillLog_AllCharacterData.totalDeath = KILLLOG_RECORD_NUMBERS;
		table.insert(KillLog_AllCharacterData["death"], { time = date(), level = UnitLevel("player"), creepName = creepName})
		KillLog_SendUpdate();
	end
end

function KillLog_SendUpdate()
		-- clear the selection so that the recent creep will be selected instead
	if ( not KillLogFrame:IsVisible() ) then
		KillLog_ListFrame.selectedCreepID = nil;
	elseif ( KillLog_GeneralFrame:IsVisible() ) then
		KillLog_GeneralFrame_OnShow();
	elseif ( KillLog_ListFrame:IsVisible() ) then
		KillLog_ListFrame_OnShow();
	elseif ( KillLog_DeathFrame:IsVisible() ) then
		KillLog_DeathFrame_OnShow();
	end
end

function KillLog_Tooltip(creepName)
	local creepName = UnitName("mouseover");
	local width;
	-- If the unit is dead, then instead of Beast the tooltip will say corpse
	local tooltipType;
	if ( UnitIsDead("mouseover") ) then
		tooltipType = "Corpse";
		DebugMessage("KL", "Unit: "..tooltipType, "helper");
	else
		tooltipType = UnitCreatureType("mouseover");
		if ( not tooltipType == nil ) then
			DebugMessage("KL", "Unit: "..tooltipType, "info");
		end
	end
	
	if ( tooltipType and GameTooltipTextLeft2:GetText() == format(UNIT_TYPE_LETHAL_LEVEL_TEMPLATE, tooltipType) ) then
		local creepInfo = KillLog_CreepInfo[creepName];
		if ( creepInfo.min and creepInfo.max ) then
			if ( creepInfo.min == creepInfo.max ) then
				GameTooltipTextLeft2:SetText(format(UNIT_TYPE_LEVEL_TEMPLATE, creepInfo.min, tooltipType));
			else
				GameTooltipTextLeft2:SetText(KILLLOG_LABEL_LEVEL.." "..creepInfo.min.." - "..creepInfo.max.." "..tooltipType);
			end
			width = 20 + GameTooltipTextLeft2:GetWidth();
			if ( GameTooltip:GetWidth() < width ) then
				GameTooltip:SetWidth(width);
			end
		end
	end

	if ( KillLog_AllCharacterData and KillLog_AllCharacterData["overall"] and KillLog_AllCharacterData["overall"][creepName] ) then
		local linesAdded = 0;
		if ( KillLog_AllCharacterData["overall"][creepName]["kill"] ) then
			if ( KillLog_AllCharacterData["overall"][creepName]["xp"] ) then
				GameTooltip:AddLine(format(KILLLOG_TOOLTIP_KILL_COUNT, KillLog_AllCharacterData["overall"][creepName]["kill"], (KillLog_AllCharacterData["overall"][creepName]["xp"]/KillLog_AllCharacterData["overall"][creepName]["kill"])), 1.0, 1.0, 0);
				linesAdded = linesAdded + 1;
			else
				GameTooltip:AddLine(format(KILLLOG_TOOLTIP_KILL_COUNT, KillLog_AllCharacterData["overall"][creepName]["kill"], 0), 1.0, 1.0, 0);
				linesAdded = linesAdded + 1;
			end
		end
		if ( KillLog_AllCharacterData["overall"][creepName]["death"] ) then
			GameTooltip:AddLine(format(KILLLOG_TOOLTIP_DEATH_COUNT, KillLog_AllCharacterData["overall"][creepName]["death"]), 1.0, 0, 0);
			linesAdded = linesAdded + 1;
		end
		if ( linesAdded ~= 0 ) then
			-- Adjust width and height to account for new lines
			GameTooltip:SetHeight(GameTooltip:GetHeight() + (14 * linesAdded));
			local tooltipLineCount = GameTooltip:NumLines();
			for i=(tooltipLineCount-linesAdded+1), tooltipLineCount, 1 do
				width = 20 + getglobal(GameTooltip:GetName().."TextLeft"..i):GetWidth();
				if ( GameTooltip:GetWidth() < width ) then
					GameTooltip:SetWidth(width);
				end
			end
		end
	end
end

function KillLog_UpdateData()
	local creepName, data;
	-- data version nil => 1
	if ( not KillLog_Options.dataVersion ) then
		for creepName, data in pairs(KillLog_CreepInfo) do
			if ( data.elite ) then
				data.class = "elite";
				data.elite = nil;
			end
		end

		local server, charList, char, data;
		for server, charList in pairs(KillLog_CharacterData) do
			for char, data in pairs(charList) do
				charList[char] = { ["overall"] = data };
			end
		end
		KillLog_Options.dataVersion = 1;
	
	-- data version 1 => 2
	elseif ( KillLog_Options.dataVersion == 1 ) then
		for creepName, data in pairs(KillLog_CreepInfo) do
			if ( not data.family ) then
				data.family = KillLog_GetCreepFamily(creepName);
			end
		end
		KillLog_Options.dataVersion = 2;

	-- data version 2 => 3
	elseif ( KillLog_Options.dataVersion == 2 ) then
		KillLog_Options.storeMax = true;
		KillLog_Options.notifyMax = true;
		KillLog_Options.dataVersion = 3;
			DEFAULT_CHAT_FRAME:AddMessage("dataVersion updated to: "..KillLog_Options.dataVersion)
	-- data version 3 => 4
	elseif ( KillLog_Options.dataVersion == 3 ) then
		for creepName, data in pairs(KillLog_CreepInfo) do
			if ( data.model ) then
				data.family = data.model;
				data.model  = nil;
			end
		end
		KillLog_Options.dataVersion = 4;
	-- data version 4 => 5
	elseif ( KillLog_Options.dataVersion == 4 ) then
		local server, charList, char, data;
		for server, charList in pairs(KillLog_CharacterData) do
			for char, data in pairs(charList) do
				if ( data["max"] and data["max"]["default"] ) then
					if ( not data["max"]["Default"]) then
						data["max"]["Default"] = data["max"]["default"];
					else
						if ( data["max"]["Default"]["hit"] < data["max"]["default"]["hit"] ) then
							data["max"]["Default"]["hit"] = data["max"]["default"]["hit"];
						end
						if ( data["max"]["Default"]["crit"] < data["max"]["default"]["crit"] ) then
							data["max"]["Default"]["crit"] = data["max"]["default"]["crit"];
						end
					end
					data["max"]["default"] = nil;
				end
				if ( data["max"] and data["max"]["default (pet)"] ) then
					if ( not data["max"]["Default (pet)"]) then
						data["max"]["Default (pet)"] = data["max"]["default (pet)"];
					else
						if ( data["max"]["Default (pet)"]["hit"] < data["max"]["default (pet)"]["hit"] ) then
							data["max"]["Default (pet)"]["hit"] = data["max"]["default (pet)"]["hit"];
						end
						if ( data["max"]["Default (pet)"]["crit"] < data["max"]["default (pet)"]["crit"] ) then
							data["max"]["Default (pet)"]["crit"] = data["max"]["default (pet)"]["crit"];
						end
					end
					data["max"]["default (pet)"] = nil;
				end
			end
		end
		KillLog_Options.dataVersion = 5;
	-- data version 5 => 6
	elseif ( KillLog_Options.dataVersion == 5 ) then
		KillLog_Options.storeDeath = true;
		KillLog_Options.dataVersion = 6;
	-- data version 6 => 7
	elseif ( KillLog_Options.dataVersion == 6 ) then
		for creepName, data in pairs(KillLog_CreepInfo) do
			if ( data.min and data.min == -1 ) then
				data.min = nil;
			end
			if ( data.max and data.min == -1 ) then
				data.max = nil;
			end
		end
		KillLog_Options.dataVersion = 7;
	-- data version 7 => 8
	elseif ( KillLog_Options.dataVersion == 7 ) then
		KillLog_Options.debugLevel = 4;
		DebugMessage("KL", "Updating Global Variables", "warning");
		
		KillLog_Options.version = KILLLOG_VERSION;
		KillLog_Options.sctSupport = true;
		KillLog_Options.color = {r = 1.0, g = 1.0, b = 1.0}
		KillLog_Options.maxLevel = KILLLOG_MAX_LEVEL;

		KillLog_Options.debugLevel = nil;
		KillLog_Options.dataVersion = 8;
	-- data version 8 => 9
	elseif ( KillLog_Options.dataVersion == 8 ) then
		KillLog_Options.debugLevel = 4;
		DebugMessage("KL", "Updating Saved Data", "warning");
		for creepName, data in pairs(KillLog_CreepInfo) do
			if ( data.x and data.y ) then
				data.x = math.floor(data.x)
				data.y = math.floor(data.y)
			end
		end
		
		KillLog_Options.debugLevel = nil;
		KillLog_Options.dataVersion = 9;
	-- data version 9 => 10
	elseif ( KillLog_Options.dataVersion == 9 ) then
		KillLog_Options.debugLevel = 4;
		DebugMessage("KL", "Updating Saved Data", "warning");
		for creepName, data in pairs(KillLog_CreepInfo) do
			if ( data.x and data.y and data.maxX and data.maxY ) then
				data.loc = math.floor(data.x).."-"..math.floor(data.y).."/"..math.floor(data.maxX).."-"..math.floor(data.maxY);
				data.x = nil;
				data.y = nil;
				data.maxX = nil;
				data.maxY = nil;
			elseif ( data.x and data.y ) then
				data.loc = math.floor(data.x).."-"..math.floor(data.y).."/"..math.floor(data.x).."-"..math.floor(data.y);
				data.x = nil;
				data.y = nil;
			end
		end
		
		KillLog_Options.debugLevel = nil;
		KillLog_Options.dataVersion = 10;
		
		-- data version ???? => current
		-- since we are attempting to update the data in a while loop, this will ensure that nothing
		-- strange happens causing an infinite loop
	else
		KillLog_Options.dataVersion = KILLLOG_DATA_VERSION;
	end

end

--	Same as GetDifficultyColor but also accepts characterLevel to compare based upon
--  when you are level 40 looking at what you killed at level 20, it should be colored
--  as if you were level 20
function KillLog_GetDifficultyColor(creepLevel, atCharacterLevel)
	local characterLevel = UnitLevel("player");
	local atLevelDiff = 0;
	local actualLevel = 0;
	if ( not atCharacterLevel or atCharacterLevel == characterLevel ) then
		return GetDifficultyColor(creepLevel);
	else
		atLevelDiff = creepLevel - atCharacterLevel;
		actualLevel = atLevelDiff + characterLevel;
		
		return GetDifficultyColor(actualLevel);
	end
end

function KillLog_GetDifficultyRating(creepLevel, atCharacterLevel)
	local color = KillLog_GetDifficultyColor(creepLevel, atCharacterLevel);
	for index, color2 in pairs(KILLLOG_DIFFICULTY_COLOR) do
		if ( color.r == color2.r and color.g == color2.g and color.b == color2.b ) then
			return index;
		end
	end
	return 0;
end

function KillLog_GetCreepFamily(creepName)
	local index, patternList, pattern, family, match, pos;
	for family, patternList in pairs(KillLog_CreepFamily[1]) do
		for index, pattern in pairs(patternList) do
			match, pos = string.find(creepName, pattern.."()");
			if ( match and (string.len(creepName) == pos or string.sub(creepName, pos+1, pos+1) == " ") ) then
				return family;
			end
		end
	end
	return nil;
end

function KL_LoadData(max)
	if ( not max ) then
		max = 200;
	end
	for index=1, max, 1 do
		KillLog_AllCharacterData["overall"]["A Sample Creep  "..index] = { kill = index, xp = index*2 };
		KillLog_AllCharacterData["overall"]["B Sample Creep  "..index] = { kill = index, xp = index*2 };
		KillLog_AllCharacterData["overall"]["C Sample Creep  "..index] = { kill = index, xp = index*2 };
		KillLog_AllCharacterData["overall"]["Z Sample Creep  "..index] = { kill = index, xp = index*2 };

		KillLog_CreepInfo["A Sample Creep  "..index] = { min = index, max = index };
	end
end

function KL_RemoveData()
	for creepName, data in pairs(KillLog_AllCharacterData["overall"]) do
		if ( string.find(creepName, "Sample Creep") ) then
			KillLog_AllCharacterData["overall"][creepName] = nil;
		end
	end
	for creepName, data in pairs(KillLog_CreepInfo) do
		if ( string.find(creepName, "Sample Creep") ) then
			KillLog_AllCharacterData["overall"][creepName] = nil;
		end
	end
end
