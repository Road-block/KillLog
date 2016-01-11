--[[
path: /KillLog/
filename: KillLog_ListFrame.xml
author: Daniel Risse <dan@risse.com>
update: Detritis <Slynx - Quel'Thalas>	
created: Mon, 17 Jan 2005 17:33:00 -0800
updated: Thurs, 2 Feb 2007

list frame: a listing of the creeps you have fought
]]

KILLLOG_LIST_TITLEBUTTON_HEIGHT = 15;
KILLLOG_LIST_CREEPS_DISPLAYED   = 12;
KILLLOG_LIST_MAX_PORTRAITS      = 99;
-- this is used so that the tab (level XX) is the correct width
KILLLOG_LIST_LEVEL_XX           = KILLLOG_LIST_LEVEL..KILLLOG_MAX_LEVEL;
tabID							= 1;

-- define Static Popup windows
StaticPopupDialogs["KILLLOG_LIST_CHANGE_TYPE"] = {
	text = KILLLOG_STATIC_CHANGE_TYPE_BLURB,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function()
		KillLog_ListFrame_ChangeCreepType(KillLog_ListFrame.dropDownMenuID, getglobal(this:GetParent():GetName().."EditBox"):GetText());
	end,
	EditBoxOnEnterPressed = function()
		KillLog_ListFrame_ChangeCreepType(KillLog_ListFrame.dropDownMenuID, getglobal(this:GetParent():GetName().."EditBox"):GetText());
	end,
	OnShow = function()
		local editBox = getglobal(this:GetName().."EditBox");
		editBox:SetFocus();
		local creepData = KillLog_ListFrame_GetCreepName(KillLog_ListFrame.dropDownMenuID);
		local creepInfo = KillLog_CreepInfo[creepData.name];
		if ( creepInfo and creepInfo.type ) then
			editBox:SetText(creepInfo.type);
		end
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	timeout = 0,
	exclusive = 1,
};

StaticPopupDialogs["KILLLOG_LIST_CHANGE_FAMILY"] = {
	text = KILLLOG_STATIC_CHANGE_FAMILY_BLURB,
	button1 = ACCEPT,
	button2 = CANCEL,
	hasEditBox = 1,
	OnAccept = function()
		local creepData = KillLog_ListFrame_GetCreepName(KillLog_ListFrame.dropDownMenuID);
		local creepInfo = KillLog_CreepInfo[creepData.name];
		if ( creepInfo and creepInfo.family ) then
			oldFamily = creepInfo.family
		end
		KillLog_ListFrame_ChangeCreepFamily(KillLog_ListFrame.dropDownMenuID, getglobal(this:GetParent():GetName().."EditBox"):GetText(), oldFamily);
	end,
	EditBoxOnEnterPressed = function()
		--KillLog_ListFrame_ChangeCreepFamily(KillLog_ListFrame.dropDownMenuID, getglobal(this:GetParent():GetName().."EditBox"):GetText());
	end,
	OnShow = function()
		local editBox = getglobal(this:GetName().."EditBox");
		editBox:SetFocus();
		local creepData = KillLog_ListFrame_GetCreepName(KillLog_ListFrame.dropDownMenuID);
		local creepInfo = KillLog_CreepInfo[creepData.name];
		if ( creepInfo and creepInfo.family ) then
			editBox:SetText(creepInfo.family);
		end
	end,
	OnHide = function()
		if ( ChatFrameEditBox:IsVisible() ) then
			ChatFrameEditBox:SetFocus();
		end
		getglobal(this:GetName().."EditBox"):SetText("");
	end,
	timeout = 0,
	exclusive = 1,
};

StaticPopupDialogs["KILLLOG_LIST_DELETE"] = {
	text    = KILLLOG_STATIC_DELETE_BLURB,
	button1 = YES,
	button2 = NO,
	OnAccept = function()
	    KillLog_ListFrame_DeleteCreep(KillLog_ListFrame.dropDownMenuID);
	end,
	timeout = 0
};

function KillLog_ListFrame_OnLoad()
	this.display = { };
	this.selectedCreepID = nil;
	this.selectedCreepName = nil;
end

function KillLog_ListFrame_OnShow()
	if ( not KillLog_ListFrame.selectedTab or KillLog_ListFrame.selectedTab == 1 ) then
		KillLog_ListFrame.selectedTab = 1;
		KillLog_ListFrame_CreateSessionDisplay();
	end
	if ( KillLog_SessionData and KillLog_SessionData[1] and not KillLog_ListFrame.selectedCreepID ) then
		KillLog_ListFrame.selectedCreepName = KillLog_SessionData[1].name;
	end
	KillLog_ListFrame_DefineDisplay();
	KillLog_ListFrame_SetSelection(KillLog_ListFrame_GetSelection());
	KillLog_ListFrame_Update();
end

function KillLog_ListFrame_OnHide()
end

-- called to update which creeps and headers are visible in list
function KillLog_ListFrame_Update()
	local numEntries = KillLog_ListFrame_GetNumCreepEntries();

	-- ScrollFrame update
	FauxScrollFrame_Update(KillLog_ListScrollFrame, numEntries, KILLLOG_LIST_CREEPS_DISPLAYED, KILLLOG_LIST_TITLEBUTTON_HEIGHT, nil, nil, nil, KillLog_List_HighlightFrame, 293, 316);
	local scrollFrameOffset = FauxScrollFrame_GetOffset(KillLog_ListScrollFrame);

	-- Update the creep listing
	KillLog_List_HighlightFrame:Hide();
	local index;
	local creepID, creepTitle, creepTitleTag, creepHighlight, creepNormalText, creepHighlightText, creepDisabledText, creepData, color, creepInfo, order, tag;
	for index=1, KILLLOG_LIST_CREEPS_DISPLAYED, 1 do
		creepID            = index + scrollFrameOffset;
		creepTitle         = getglobal("KillLog_List_Title"..index);
		creepCreep		   = getglobal("KillLog_List_Title"..index.."Creep");
		creepTitleTag      = getglobal("KillLog_List_Title"..index.."Tag");
		creepHighlight     = getglobal("KillLog_List_Title"..index.."Highlight");
		
		if ( creepID > numEntries ) then
			creepTitle:Hide();
		else
			creepData = KillLog_ListFrame_GetCreepName(creepID);
			color = nil;
			if ( creepData.isHeader ) then
				if ( creepData.name ) then
					creepCreep:SetText(creepData.name);
				else
					creepCreep:SetText("");
				end

				if ( creepData.isCollapsed ) then
					creepTitle:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
				else
					creepTitle:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
				end
				creepHighlight:SetTexture("Interface\\Buttons\\UI-PlusButton-Hilight");
				color = QuestDifficultyColor["header"];

				tag = creepData.tag;
			else
				creepCreep:SetText("  "..creepData.name);
				
				creepTitle:SetNormalTexture("");
				creepHighlight:SetTexture("");
				creepInfo = KillLog_CreepInfo[creepData.name];
				if ( creepInfo and creepInfo.max ) then
					if ( tabID == 3 ) then
						local levelValue =  KillLog_ListFrame.levelValues[KillLog_ListFrame_LevelDropDown.selectedID]
						color = KillLog_GetDifficultyColor(creepInfo.max,levelValue);
						--color = GetDifficultyColor(creepInfo.max);
						--DebugMessage("KL - List", "creepName, "..creepData.name.." - levelValue, "..levelValue,"info");
						--DebugMessage("KL - List", "creepName, "..creepData.name.." - color, "..color.r..","..color.g..","..color.b,"helper");
					else
						color = KillLog_GetDifficultyColor(creepInfo.max);
					end
				elseif ( creepInfo and creepInfo.class == "worldboss" ) then
					color = { r = 0.8, g = 0.6, b = 1 };
				else
					color = { r = 0, g = 1, b = 1 };
				end
				order, tag = KillLog_ListFrame.getSortInfo(creepData.name);
			end
			
			if ( tag ) then
				creepTitleTag:SetText("("..tag..")");
				-- Shrink text to accomdate creep classes without wrapping
				creepCreep:SetWidth(310 - 5 - creepTitleTag:GetWidth());
			else
				creepTitleTag:SetText("");
				-- Reset to max text width
				creepCreep:SetWidth(310);
			end

			creepTitleTag:SetTextColor(color.r, color.g, color.b);
			creepTitle:SetTextColor(color.r, color.g, color.b);
			creepCreep:SetTextColor(color.r, color.g, color.b);
			creepTitle.r = color.r;
			creepTitle.g = color.g;
			creepTitle.b = color.b;
			creepTitle:Show();

			-- Place the highlight and lock the highlight state
			if ( KillLog_ListFrame.selectedCreepID and KillLog_ListFrame_GetSelection() == creepID ) then
				KillLog_List_CreepHighlight:SetVertexColor(creepTitle.r, creepTitle.g, creepTitle.b);
				KillLog_List_HighlightFrame:SetPoint("TOPLEFT", "KillLog_List_Title"..index, "TOPLEFT", 0, 0);
				KillLog_List_HighlightFrame:Show();
				creepTitleTag:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
				creepTitle:LockHighlight();
			else
				creepTitle:UnlockHighlight();
			end
		end
	end

	if ( numEntries == 0 ) then
		KillLog_ListFrameCollapseAllButton:Disable();
	else
		KillLog_ListFrameCollapseAllButton:Enable();
		-- Set the expand/collapse all button texture
		local numHeaders = 0;
		local notExpanded = 0;
		-- Somewhat redundant loop, but cleaner than the alternatives
		for index=1, numEntries, 1 do
			creepData = KillLog_ListFrame_GetCreepName(index);
			if ( creepData.name and creepData.isHeader ) then
				numHeaders = numHeaders + 1;
				if ( creepData.isCollapsed ) then
					notExpanded = notExpanded + 1;
				end
			end
		end
		-- If all headers are not expanded then show collapse button, otherwise show the expand button
		if ( notExpanded ~= numHeaders ) then
			KillLog_ListFrameCollapseAllButton.collapsed = nil;
			KillLog_ListFrameCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-MinusButton-Up");
		else
			KillLog_ListFrameCollapseAllButton.collapsed = 1;
			KillLog_ListFrameCollapseAllButton:SetNormalTexture("Interface\\Buttons\\UI-PlusButton-Up");
		end

		-- If no selection then set it to the first available creep
		if ( KillLog_ListFrame_GetSelection() == 0 ) then
			KillLog_ListFrame_SetFirstValidSelection();
		end
	end
end

function KillLog_ListFrame_SetSelection(creepID)
	if ( creepID == 0 or not creepID ) then
		KillLog_ListDetailFrame:Hide();
		return;
	end
	DebugMessage("KL - List", "SetSelection("..creepID..")", "function");

	KillLog_ListFrame_SelectCreepEntry(creepID);
	local creepData = KillLog_ListFrame_GetCreepName(creepID);
	if ( creepData.isHeader ) then
		if ( creepData.isCollapsed ) then
			KillLog_ListFrame_ExpandHeader(creepID);
		else
			KillLog_ListFrame_CollapseHeader(creepID);
		end
		return;
	else
		-- get XML id
		local scrollFrameOffset = FauxScrollFrame_GetOffset(KillLog_ListScrollFrame);
		local id = creepID - scrollFrameOffset;

		-- Set newly selected creep and highlight it
		KillLog_ListFrame.selectedCreepID = creepID;
		if ( creepID > scrollFrameOffset and creepID <= (scrollFrameOffset + KILLLOG_LIST_CREEPS_DISPLAYED) and creepID <= KillLog_ListFrame_GetNumCreepEntries() ) then
			local titleButton = getglobal("KillLog_List_Title"..id);
			titleButton:LockHighlight();
			getglobal("KillLog_List_Title"..id.."Tag"):SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
			KillLog_List_CreepHighlight:SetVertexColor(titleButton.r, titleButton.g, titleButton.b);
			KillLog_List_HighlightFrame:SetPoint("TOPLEFT", "KillLog_List_Title"..id, "TOPLEFT", 5, 0);
			KillLog_List_HighlightFrame:Show();
		end
	end
	if ( KillLog_ListFrame_GetSelection() > KillLog_ListFrame_GetNumCreepEntries() ) then
		return;
	end
	KillLog_ListFrame_UpdateCreepDetails();
end

function KillLog_ListFrame_UpdateCreepDetails()
	local creepID = KillLog_ListFrame_GetSelection();
	local creepData = KillLog_ListFrame_GetCreepName(creepID);
	if ( not creepData or creepData.isHeader ) then
		return;
	end

	if ( creepData.portrait and KillLog_ListDetailFrame.portrait ~= creepData.portrait ) then
		getglobal("KillLog_ListFrame_CreepPortrait"..KillLog_ListDetailFrame.portrait):Hide();
		getglobal("KillLog_ListFrame_CreepPortrait"..creepData.portrait):Show();
		KillLog_ListDetailFrame.portrait = creepData.portrait;
	end

	if ( creepData.name ) then
		KillLog_ListFrame_DetailCreepName:SetText(creepData.name);

		local creepInfo = KillLog_CreepInfo[creepData.name];
		if ( not creepInfo ) then
			KillLog_ListFrame_CreepPortraitBorderNormal:Show();
			KillLog_ListFrame_CreepPortraitBorderSpecial:Hide();
			KillLog_ListFrame_CreepPortraitPVPIcon:Hide();
			KillLog_ListFrame_DetailCreepSubName:SetText(KILLLOG_LABEL_LEVEL.." ?");
		else
			if ( creepInfo.class == "worldboss" or creepInfo.class == "elite" ) then
				KillLog_ListFrame_CreepPortraitBorderNormal:Hide();
				KillLog_ListFrame_CreepPortraitBorderSpecial:Show();
				KillLog_ListFrame_CreepPortraitBorderSpecialTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Elite");
			elseif ( creepInfo.class == "rareelite" ) then
				KillLog_ListFrame_CreepPortraitBorderNormal:Hide();
				KillLog_ListFrame_CreepPortraitBorderSpecial:Show();
				KillLog_ListFrame_CreepPortraitBorderSpecialTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare-Elite");
			elseif ( creepInfo.class == "rare" ) then
				KillLog_ListFrame_CreepPortraitBorderNormal:Hide();
				KillLog_ListFrame_CreepPortraitBorderSpecial:Show();
				KillLog_ListFrame_CreepPortraitBorderSpecialTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-Rare");
			else
				KillLog_ListFrame_CreepPortraitBorderNormal:Show();
				KillLog_ListFrame_CreepPortraitBorderSpecial:Hide();
			end

			if ( creepInfo.faction ) then
				KillLog_ListFrame_CreepPortraitPVPIcon:SetTexture("Interface\\TargetingFrame\\UI-PVP-"..creepInfo.faction);
				KillLog_ListFrame_CreepPortraitPVPIcon:Show();
			else
				KillLog_ListFrame_CreepPortraitPVPIcon:Hide();
			end

			local subName = KILLLOG_LABEL_LEVEL.." ";
			if ( not creepInfo.min ) then
				subName = subName.."?? ";
			elseif ( creepInfo.min == creepInfo.max ) then
				subName = subName..creepInfo.min.." ";
			else
				subName = subName..creepInfo.min.."-"..creepInfo.max.." ";
			end
			if ( creepInfo.type ) then
				subName = subName..creepInfo.type.." ";
			end
			if ( creepInfo.family ) then
				subName = subName.."("..creepInfo.family..") ";
			end
			KillLog_ListFrame_DetailCreepSubName:SetText(subName);

			local location = "";
			--[[if ( creepInfo.zone and creepInfo.x and creepInfo.y ) then
				if ( creepInfo.maxX or creepInfo.maxY ) then
					location = format("%s (%d, %d) (%d, %d)", creepInfo.zone, creepInfo.x, creepInfo.y, creepInfo.maxX,  creepInfo.maxY);
				else
					location = format("%s (%d, %d) (%d, %d)", creepInfo.zone, creepInfo.x, creepInfo.y, creepInfo.x,  creepInfo.y);
				end]]
			if ( creepInfo.zone and creepInfo.loc ) then
				breakPoint = string.find(creepInfo.loc,"/")
				minMidPoint = string.find(creepInfo.loc,"-")
				maxMidPoint = string.find(creepInfo.loc,"-",breakPoint)
					
				minX = tonumber(string.sub(creepInfo.loc, 1, minMidPoint - 1))
				maxX = tonumber(string.sub(creepInfo.loc, breakPoint + 1, maxMidPoint - 1))
				minY = tonumber(string.sub(creepInfo.loc, minMidPoint + 1, breakPoint - 1))
				maxY = tonumber(string.sub(creepInfo.loc, maxMidPoint + 1))
					
				location = format("%s (%d, %d) (%d, %d)", creepInfo.zone, minX, minY, maxX, maxY);
			elseif ( creepInfo.zone ) then
				location = format("%s", creepInfo.zone)
			end
			KillLog_ListFrame_DetailCreepLocation:SetText(location);
		end

		local creepStats = KillLog_ListFrame["displaySource"][creepData.name];
		if ( not creepStats ) then
			KillLog_ListFrame_KillStat:SetText("0");
			KillLog_ListFrame_DeathStat:SetText("0");
			KillLog_ListFrame_XpStat:SetText("0");
			KillLog_ListFrame_RestedStat:SetText("0");
			KillLog_ListFrame_GroupStat:SetText("0");
			KillLog_ListFrame_RaidStat:SetText("0");
		else
			if ( creepStats.kill ) then
				KillLog_ListFrame_KillStat:SetText(creepStats.kill);
			else
				KillLog_ListFrame_KillStat:SetText("0");
			end
			if ( creepStats.death ) then
				KillLog_ListFrame_DeathStat:SetText(creepStats.death);
			else
				KillLog_ListFrame_DeathStat:SetText("0");
			end
			if ( creepStats.xp ) then
				KillLog_ListFrame_XpStat:SetText(creepStats.xp);
			else
				KillLog_ListFrame_XpStat:SetText("0");
			end

			if ( creepStats.rested ) then
				KillLog_ListFrame_RestedStat:SetText(creepStats.rested);
			else
				KillLog_ListFrame_RestedStat:SetText("0");
			end
			if ( creepStats.group ) then
				KillLog_ListFrame_GroupStat:SetText(creepStats.group);
			else
				KillLog_ListFrame_GroupStat:SetText("0");
			end
			if ( creepStats.raid ) then
				KillLog_ListFrame_RaidStat:SetText(creepStats.raid);
			else
				KillLog_ListFrame_RaidStat:SetText("0");
			end
		end
		KillLog_ListDetailFrame:Show();
	end
end

---- these are funcions that I cannot see the source of
---- I am just guessing at their behavior

-- 	 I have played with calling the corresponding QuestLog functions and now understand how these are supposed to behave
--   if the creep that you have selected is within a collapsed header, then this will refer to an index greater than
--   KillLog_ListFrame_GetNumCreepEntries() which can be passed into the _GetCreepName() function
-- 	 For my implementation, I do not reshuffle my table when things are collapsed and expanded, so it would be
--   difficult to mimic this behavior.  I do not know when I would ever need to get a selection that was not
--   visible though, so I am not going to worry about this for now.
function KillLog_ListFrame_GetSelection()
	DebugMessage("KL - List", "GetSelection()", "function");
	if ( KillLog_ListFrame.selectedCreepID ) then
		return KillLog_ListFrame.selectedCreepID;
	else
		if ( KillLog_ListFrame.selectedCreepName ) then
			local index;
			for index=1, table.getn(KillLog_ListFrame.display), 1 do
				local creepData = KillLog_ListFrame_GetCreepName(index);
				if ( not creepData ) then
					break;
				elseif ( creepData.name == KillLog_ListFrame.selectedCreepName ) then
					KillLog_ListFrame.selectedCreepID = index;
					return index;
				end
			end
			return index;
		end
	end
	return 0;
end

-- 	 if idea #2 seems correct above, this should store name in addition to ID
--   never mind, this is called with a header as well, which cannot be selected... back to square one
function KillLog_ListFrame_SelectCreepEntry(creepID)
	DebugMessage("KL - List", "SelectCreepEntry("..creepID..")", "function");
	--KillLog_ListFrame.selectedCreepID = creepID;
	local creepData = KillLog_ListFrame_GetCreepName(creepID);
	if ( creepData and not creepData.isHeader ) then
		if ( creepData.name ) then
			KillLog_ListFrame.selectedCreepName = creepData.name;
		else
			KillLog_ListFrame.selectedCreepName = nil;
		end
	end
end

-- returns name, isHeader, isCollapsed, min, max, class, pvp, kill, death, xp, restedXp, groupXp, raidXp
-- returns { name, isHeader, isCollapsed }
function KillLog_ListFrame_GetCreepName(creepID)
	DebugMessage("KL - List", "GetCreepName("..creepID..")", "function");
	local offset = 0;
	local index;
	for index=1, table.getn(KillLog_ListFrame.display), 1 do
		if ( index == creepID + offset ) then
			return KillLog_ListFrame.display[index];
		end
		if ( KillLog_ListFrame.display[index].isHeader and KillLog_ListFrame.display[index].isCollapsed ) then
			offset = offset + KillLog_ListFrame.display[index].isCollapsed;
			index = index + KillLog_ListFrame.display[index].isCollapsed;
		end
	end
	return nil;
end

function KillLog_ListFrame_ExpandHeader(creepID)
	--local debug = "ExpandHeader("..creepID..") ";
	-- expand ALL headers
	if ( creepID == 0 ) then
		local index, creepData;
		for index, creepData in pairs(KillLog_ListFrame.display) do
			if ( creepData.isHeader ) then
				--debug = debug.."["..index.."] "..creepData.isCollapsed..",  ";
				creepData.isCollapsed = nil;
			end
		end
	-- expand single headers
	else
		local creepData = KillLog_ListFrame_GetCreepName(creepID);
		--debug = debug.."["..creepID.."] "..creepData.isCollapsed;
		creepData.isCollapsed = nil;
	end
	--DebugMessage("KL - List", debug, "info");
	KillLog_ListFrame.selectedCreepID = nil;
	KillLog_ListFrame_Update();
end

function KillLog_ListFrame_CollapseHeader(creepID)
	--local debug = "CollapseHeader("..creepID..") ";
	local count = 0;
	local index;
	-- collapse ALL headers
	--  within block, creepID is changed to the current header index
	if ( creepID == 0 ) then
		creepID = 1;
		for index=2, table.getn(KillLog_ListFrame.display), 1 do
			if ( not KillLog_ListFrame.display[index].isHeader ) then
				count = count + 1;
			else
				KillLog_ListFrame.display[creepID].isCollapsed = count;
				count = 0;
				creepID = index;
				--debug = debug.."["..index.."] "..KillLog_ListFrame.display[creepID].isCollapsed..",  ";
			end
		end
		KillLog_ListFrame.display[creepID].isCollapsed = count;
		--debug = debug.."["..index.."] "..KillLog_ListFrame.display[creepID].isCollapsed;
	-- collapse single header
	else
		local headerData = KillLog_ListFrame_GetCreepName(creepID);
		for index=creepID+1, table.getn(KillLog_ListFrame.display), 1 do
			local creepData = KillLog_ListFrame_GetCreepName(index);
			if ( not creepData or creepData.isHeader ) then
				break;
			end
			count = count + 1;
		end
		headerData.isCollapsed = count;
		--debug = debug.."["..creepID.."] "..headerData.isCollapsed;
	end
	--DebugMessage("KL - List", debug, "info");
	KillLog_ListFrame.selectedCreepID = nil;
	KillLog_ListFrame_Update();
end

function KillLog_ListFrame_GetNumCreepEntries()
	local count = table.getn(KillLog_ListFrame.display);
	local index, creepData;
	for index, creepData in pairs(KillLog_ListFrame.display) do
		if ( creepData.isCollapsed and creepData.isHeader ) then
			count = count - creepData.isCollapsed;
		end
	end
	return count;
end

-- this function will update our table that determines what we are going to show
-- This should be called when the window is shown, or if the sorting or filtering changes
function KillLog_ListFrame_DefineDisplay()
	local collapsed = { };
	table.foreach(KillLog_ListFrame.display, function(k,v) if ( v.isHeader and v.isCollapsed ) then collapsed[v.name] = 0; end return nil; end);

	KillLog_ListFrame.display = { };
	local tempDisplay = { };

	if ( not KillLog_ListFrame.getSortInfo ) then
		DebugMessage("KL - List", "no getSortInfo!!!", "error");
		KillLog_ListFrame.getSortInfo = KillLog_ListFrame_GetSortInfo_Type;
	end

	if ( KillLog_ListFrame.displaySource ) then
		local countEntries = nil;
		if ( KillLog_ListFrame_SortDropDownText:GetText() == KILLLOG_LABEL_NAME ) then
			countEntries = true;
		end
		local headerCount = { };
		local header, tag, header
		table.foreach(KillLog_ListFrame.displaySource, 
			function(k,v)
				order, tag, header = KillLog_ListFrame.getSortInfo(k);
				if ( order ) then
					if ( countEntries ) then
						tag = 1;
					end
					if ( not header ) then
						header = ALL;
					end
					if ( not KillLog_Options.trivial and order ~= 0 and KillLog_CreepInfo[k] and KillLog_CreepInfo[k].max and KillLog_GetDifficultyRating(KillLog_CreepInfo[k].max) == 1 ) then
					    order = 0;
					end
					if ( order ~= 0 ) then
						if ( tag and type(tag) == "number" ) then
							if ( not headerCount[header] ) then
								headerCount[header] = 0;
							end
							headerCount[header] = headerCount[header] + tag;
						end
						table.insert(tempDisplay, { name = k, lower = strlower(k), header = header, order = order });
					end
				end
				return nil;
			end
		);
		if ( table.getn(tempDisplay) ~= 0) then
			QuickSort(tempDisplay, KillLog_ListFrame_SortFunction);

			local lastHeader = tempDisplay[1].header;
			local creepID = 1;
			local headerID = 1;
			local wasCollapsed = collapsed[lastHeader];

			local portrait;
			table.insert(KillLog_ListFrame.display, { name = lastHeader, isHeader = 1, tag = headerCount[lastHeader] });
			table.foreachi(tempDisplay,
				function(k,v)
					if ( v.header ~= lastHeader ) then
						lastHeader = v.header;
						table.insert(KillLog_ListFrame.display, { name = lastHeader, isHeader = 1, tag = headerCount[lastHeader] });
						if ( wasCollapsed ) then
							KillLog_ListFrame.display[headerID].isCollapsed = wasCollapsed;
						end
						creepID = creepID + 1;
						headerID = creepID;
						wasCollapsed = collapsed[lastHeader];
					end
					portrait = KillLog_CreepPortrait[v.name];
					if ( not portrait ) then
						portrait = "Default";
					end
					table.insert(KillLog_ListFrame.display, { name = v.name, portrait = portrait });
					creepID = creepID + 1;

					if ( wasCollapsed ) then
						wasCollapsed = wasCollapsed + 1;
					end
					return nil;
				end
			);
			if ( wasCollapsed ) then
				KillLog_ListFrame.display[headerID].isCollapsed = wasCollapsed;
			end
		end
	end
end


function KillLog_ListTitleButton_OnClick(button)
	local creepID = this:GetID() + FauxScrollFrame_GetOffset(KillLog_ListScrollFrame);
	if ( button == "LeftButton" ) then 
		KillLog_ListFrame_SetSelection(creepID);
		KillLog_ListFrame_Update();

	elseif ( button == "RightButton" ) then
		creepData = KillLog_ListFrame_GetCreepName(creepID);
		if ( creepData and not creepData.isHeader ) then
			KillLog_ListFrame.dropDownMenuID = creepID;
			ToggleDropDownMenu(1, nil, KillLog_List_TitleDropDown, "KillLog_List_Title"..this:GetID(), 10, 0);
		end
	end
end

function KillLog_ListDetailFrame_OnClick(button)
	if ( button == "RightButton" ) then
		KillLog_ListFrame.dropDownMenuID = KillLog_ListFrame.selectedCreepID;
		ToggleDropDownMenu(1, nil, KillLog_List_TitleDropDown, "KillLog_ListDetailFrame", 10, 0);
	end
end


function KillLog_ListFrame_CollapseAllButton_OnClick()
	if ( this.collapsed ) then
		KillLog_ListFrame_ExpandHeader(0);
		this.collapsed = nil;
	else
		KillLog_ListFrame_CollapseHeader(0);
		KillLog_ListScrollFrameScrollBar:SetValue(0);
		this.collapsed = true;
	end
end

function KillLog_ListFrame_SetFirstValidSelection()
	KillLog_ListFrame_SetSelection(KillLog_ListFrame_GetFirstValidSelection());
end

function KillLog_ListFrame_GetFirstValidSelection()
	local creepID, creepData;
	for creepID=1, KillLog_ListFrame_GetNumCreepEntries(), 1 do
		creepData = KillLog_ListFrame_GetCreepName(creepID);
		if ( creepData and not creepData.isHeader ) then
			return creepID;
		end
	end
end


function KillLog_ListFrame_Tab_OnClick()
	tabID = this:GetID();
	if ( KillLog_ListFrame.selectedTab == tabID ) then
		return;
	end

	PanelTemplates_DeselectTab(getglobal("KillLog_ListFrame_ToggleTab"..KillLog_ListFrame.selectedTab));
	PanelTemplates_SelectTab(this);
	KillLog_ListFrame.selectedTab = tabID;

	if ( tabID == 1 ) then
		KillLog_ListFrame_CreateSessionDisplay();
	elseif ( tabID == 2 ) then
		if ( KillLog_AllCharacterData and KillLog_AllCharacterData["overall"] ) then
			KillLog_ListFrame.displaySource = KillLog_AllCharacterData["overall"];
		else
			KillLog_ListFrame.displaySource = { };
		end
	elseif ( tabID == 3 ) then
		if ( KillLog_AllCharacterData and KillLog_AllCharacterData["level"] ) then
			KillLog_ListFrame.displaySource = KillLog_AllCharacterData["level"][KillLog_ListFrame.displayLevel];
		else
			KillLog_ListFrame.displaySource = { };
		end
	end

	-- the sort method "recent" is only valid for the first tab
	-- When they click another tab, update their sort method to the second one (type)
	if ( tabID == 1 ) then
		UIDropDownMenu_SetSelectedID(KillLog_ListFrame_SortDropDown, 1);
		KillLog_ListFrame.getSortInfo = KILLLOG_LIST_SORT[1].infoFunc;
		KillLog_ListFrame_SortDropDownText:SetText(KILLLOG_LIST_SORT[1].name);
	elseif ( tabID ~= 1 and KillLog_ListFrame_SortDropDown.selectedID == 1 ) then
		UIDropDownMenu_SetSelectedID(KillLog_ListFrame_SortDropDown, 2);
		KillLog_ListFrame.getSortInfo = KILLLOG_LIST_SORT[2].infoFunc;
		KillLog_ListFrame_SortDropDownText:SetText(KILLLOG_LIST_SORT[2].name);
	end

	KillLog_ListFrame.selectedCreepID = nil;
	KillLog_ListFrame_DefineDisplay();
	KillLog_ListFrame_SetSelection(KillLog_ListFrame_GetSelection());
	KillLog_ListFrame_Update();
end

function KillLog_ListFrame_CreateSessionDisplay()
	KillLog_ListFrame.displaySource = { };
	if ( KillLog_SessionData ) then
		local sessionCount = table.getn(KillLog_SessionData);
		local index, creepData;
		for index, creepData in pairs(KillLog_SessionData) do
			creepData.order = sessionCount - index;
			KillLog_ListFrame.displaySource[creepData.name] = creepData
		end
	end
end


---------------------
-- Drop Down menus --
---------------------

-- sort drop down
function KillLog_ListFrame_SortDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, KillLog_ListFrame_SortDropDown_Initialize);
	UIDropDownMenu_SetWidth(90);
	UIDropDownMenu_SetSelectedID(KillLog_ListFrame_SortDropDown, 1);
	KillLog_ListFrame.getSortInfo = KILLLOG_LIST_SORT[1].infoFunc;
end

function KillLog_ListFrame_SortDropDown_OnShow()
end

function KillLog_ListFrame_SortDropDown_Initialize()
	--KillLog_ListFrame_SortDropDown_Load(GetTradeSkillInvSlots());
	local info = { };
	info.func = KillLog_ListFrame_SortDropDownButton_OnClick;
	local index, data;
	for index, data in pairs(KILLLOG_LIST_SORT) do
		info.text = data.name;
		if ( index == KillLog_ListFrame_SortDropDown.selectedID ) then
			info.checked = true;
			UIDropDownMenu_SetText(data.name, KillLog_ListFrame_SortDropDown);
		else
			info.checked = nil;
		end
		UIDropDownMenu_AddButton(info);
	end
	if ( KillLog_ListFrame.selectedTab == 1 ) then
		UIDropDownMenu_EnableButton(1, 1);
	else
		UIDropDownMenu_DisableButton(1, 1);
	end
end

function KillLog_ListFrame_SortDropDownButton_OnClick()
	UIDropDownMenu_SetSelectedID(KillLog_ListFrame_SortDropDown, this:GetID());

	KillLog_ListFrame.getSortInfo = KILLLOG_LIST_SORT[this:GetID()].infoFunc;

	KillLog_ListFrame.selectedCreepID = nil;
	KillLog_ListFrame_DefineDisplay();
	KillLog_ListFrame_SetSelection(KillLog_ListFrame_GetSelection());
	KillLog_ListFrame_Update();
end


-- level drop down
function KillLog_ListFrame_LevelDropDown_OnShow()
	KillLog_ListFrame.levelValues = { };
    
	local index, data;
	if ( KillLog_AllCharacterData and KillLog_AllCharacterData["level"] ) then
		for index, data in pairs(KillLog_AllCharacterData["level"]) do
           	if ( table.getn(KillLog_ListFrame.levelValues) < 31 ) then
				table.insert(KillLog_ListFrame.levelValues, index);
			end
		end
	end
	UIDropDownMenu_Initialize(this, KillLog_ListFrame_LevelDropDown_Initialize);
	if ( table.getn(KillLog_ListFrame.levelValues) < 2 ) then
		KillLog_ListFrame_LevelDropDownButton:Disable();
		if ( table.getn(KillLog_ListFrame.levelValues) == 1 ) then
			KillLog_ListFrame_LevelDropDownText:SetText(KillLog_ListFrame.levelValues[1]);
		end
	else
		QuickSort(KillLog_ListFrame.levelValues, function(a,b) return a > b; end);
		if ( not KillLog_ListFrame_LevelDropDown.selectedID ) then
			UIDropDownMenu_SetSelectedID(this, 1);
		end
        KillLog_ListFrame_LevelDropDownText:SetText(KillLog_ListFrame.levelValues[KillLog_ListFrame_LevelDropDown.selectedID]);
	end
end

function KillLog_ListFrame_LevelDropDown_Initialize()
	local info = { };
	info.func = KillLog_ListFrame_LevelDropDownButton_OnClick;
	local index, data;
	for index, data in pairs(KillLog_ListFrame.levelValues) do
        info.text = data;
		if ( index == KillLog_ListFrame_LevelDropDown.selectedID ) then
			info.checked = true;
			UIDropDownMenu_SetText(data, KillLog_ListFrame_LevelDropDown);
		else
			info.checked = nil;
		end
        UIDropDownMenu_AddButton(info);
	end
end

function KillLog_ListFrame_LevelDropDownButton_OnClick()
	UIDropDownMenu_SetSelectedID(KillLog_ListFrame_LevelDropDown, this:GetID());

	KillLog_ListFrame.displayLevel = KillLog_ListFrame.levelValues[this:GetID()];
	KillLog_ListFrame_ToggleTab3:SetText(KILLLOG_LIST_LEVEL.." "..KillLog_ListFrame.displayLevel);

	if ( KillLog_ListFrame.selectedTab == 3 ) then
		KillLog_ListFrame.displaySource = KillLog_AllCharacterData["level"][KillLog_ListFrame.displayLevel];
		KillLog_ListFrame.selectedCreepID = nil;
		KillLog_ListFrame_DefineDisplay();
		KillLog_ListFrame_SetSelection(KillLog_ListFrame_GetSelection());
		KillLog_ListFrame_Update();
	end
end

-- title drop down
function KillLog_List_TitleDropDown_OnLoad()
	UIDropDownMenu_Initialize(this, KillLog_List_TitleDropDown_Initialize, "MENU");
end

function KillLog_List_TitleDropDown_Initialize()
	local info = { };
	info.text = KILLLOG_LABEL_CHANGE_FAMILY;
	info.func = function() StaticPopup_Show("KILLLOG_LIST_CHANGE_FAMILY"); end;
	UIDropDownMenu_AddButton(info);

	info.text = KILLLOG_LABEL_CHANGE_TYPE;
	info.func = function() StaticPopup_Show("KILLLOG_LIST_CHANGE_TYPE"); end;
	UIDropDownMenu_AddButton(info);

	info.text = KILLLOG_LABEL_DELETE;
	info.func = function() StaticPopup_Show("KILLLOG_LIST_DELETE"); end;
	UIDropDownMenu_AddButton(info);
end

function KillLog_ListFrame_ChangeCreepFamily(creepID, newFamily, oldFamily)
	local creepData = KillLog_ListFrame_GetCreepName(creepID);
	local creepInfo = KillLog_CreepInfo[creepData.name];
	if ( not creepInfo ) then
		KillLog_CreepInfo[creepData.name] = { };
		creepInfo = KillLog_CreepInfo[creepData.name];
	end
	creepInfo.family = newFamily;

	if ( oldFamily ) then
		DebugMessage("KL - List", "Old Family <"..oldFamily..">", "info");
		if ( KillLog_CreepFamily[1][oldFamily] ) then
			for k, v in pairs(KillLog_CreepFamily[1][oldFamily]) do
     			if(v == creepData.name) then
       				table.remove(KillLog_CreepFamily[1][oldFamily], k);
					DebugMessage("KL - List", "<"..creepData.name.."> removed from <"..oldFamily..">", "warning");
     			end
   			end
		end
	end

	if ( not KillLog_CreepFamily[1][newFamily] ) then
		KillLog_CreepFamily[1][newFamily] = { [1] = creepData.name }
		DebugMessage("KL - List", "New Family <"..newFamily.."> added.", "warning");
	else
		table.insert( KillLog_CreepFamily[1][newFamily], creepData.name )
		DebugMessage("KL - List", "<"..creepData.name.."> added to <"..newFamily..">", "warning");
	end

	KillLog_ListFrame.selectedCreepID = nil;
	KillLog_ListFrame_DefineDisplay();
	KillLog_ListFrame_SetSelection(KillLog_ListFrame_GetSelection());
	KillLog_ListFrame_Update();
end

function KillLog_ListFrame_ChangeCreepType(creepID, newType)
	local creepData = KillLog_ListFrame_GetCreepName(creepID);
	local creepInfo = KillLog_CreepInfo[creepData.name];
	if ( not creepInfo ) then
		KillLog_CreepInfo[creepData.name] = { };
		creepInfo = KillLog_CreepInfo[creepData.name];
	end
	creepInfo.type = newType;

	KillLog_ListFrame.selectedCreepID = nil;
	KillLog_ListFrame_DefineDisplay();
	KillLog_ListFrame_SetSelection(KillLog_ListFrame_GetSelection());
	KillLog_ListFrame_Update();
end

function KillLog_ListFrame_DeleteCreep(creepID)
	local creepData = KillLog_ListFrame_GetCreepName(creepID);
	if ( KillLog_ListFrame.displaySource[creepData.name] ) then
		KillLog_ListFrame.displaySource[creepData.name] = nil;
	end

	KillLog_ListFrame.selectedCreepID = nil;
	KillLog_ListFrame_DefineDisplay();
	KillLog_ListFrame_SetSelection(KillLog_ListFrame_GetSelection());
	KillLog_ListFrame_Update();
end

-----------------------
-- sorting functions --
-----------------------
function KillLog_ListFrame_SortFunction(a,b)
	if ( a.header ~= b.header ) then
		return a.header < b.header;
	end
	if ( a.order ~= b.order ) then
		return a.order > b.order;
	end
	return a.lower < b.lower;
end

function KillLog_ListFrame_GetSortInfo_Recent(creepName)
	local order, tag = 1, nil;
	if ( KillLog_ListFrame.displaySource[creepName] and KillLog_ListFrame.displaySource[creepName].order ) then
		order = 1 + KillLog_ListFrame.displaySource[creepName].order;
	end
	if ( KillLog_CreepInfo[creepName] and KillLog_CreepInfo[creepName].class ) then
		tag = KillLog_CreepInfo[creepName].class;
	end
	return order, tag;
end

function KillLog_ListFrame_GetSortInfo_Type(creepName)
	local order, tag, header = 1, nil, KILLLOG_LIST_UNKNOWNTYPE;
	if ( KillLog_CreepInfo[creepName] ) then
		if ( KillLog_CreepInfo[creepName].max ) then
			order = KillLog_GetDifficultyRating(KillLog_CreepInfo[creepName].max);
		end
		if ( KillLog_CreepInfo[creepName].class ) then
			tag = KillLog_CreepInfo[creepName].class;
		end
		local creepStats = KillLog_ListFrame["displaySource"][creepName];
		if ( creepStats and creepStats.kill ) then
			tag = creepStats.kill;
		end
		if ( KillLog_CreepInfo[creepName].type ) then
			header = KillLog_CreepInfo[creepName].type;
		end
	end
	return order, tag, header;
end

function KillLog_ListFrame_GetSortInfo_Family(creepName)
	local order, tag, header = 1, nil, KILLLOG_LIST_UNKNOWNTYPE;
	if ( KillLog_CreepInfo[creepName] ) then
		if ( KillLog_CreepInfo[creepName].max ) then
			order = KillLog_GetDifficultyRating(KillLog_CreepInfo[creepName].max);
		end
		local creepStats = KillLog_ListFrame["displaySource"][creepName];
		if ( creepStats and creepStats.kill ) then
			tag = creepStats.kill;
		end
		if ( KillLog_CreepInfo[creepName].family ) then
			header = KillLog_CreepInfo[creepName].family;
		end
	end
	return order, tag, header;
end

function KillLog_ListFrame_GetSortInfo_Class(creepName)
	local order, tag, header = 1, nil, KILLLOG_LIST_NORMALTYPE;
	if ( KillLog_CreepInfo[creepName] ) then
		local creepStats = KillLog_ListFrame["displaySource"][creepName];
		if ( creepStats and creepStats.kill ) then
			order = creepStats.kill;
			tag = creepStats.kill;
		end
		if ( KillLog_CreepInfo[creepName].class ) then
			header = KillLog_CreepInfo[creepName].class;
		end
	end
	return order, tag, header;
end
	
function KillLog_ListFrame_GetSortInfo_Name(creepName)
	local tag = nil;
	if ( KillLog_CreepInfo[creepName] and KillLog_CreepInfo[creepName].class ) then
		tag = KillLog_CreepInfo[creepName].class;
	end
	local creepStats = KillLog_ListFrame["displaySource"][creepName];
	if ( not tag and creepStats and creepStats.kill ) then
		tag = creepStats.kill;
	end
	return 1, tag;
end

function KillLog_ListFrame_GetSortInfo_Level(creepName)
	local order, tag = 0, nil;
	if ( KillLog_CreepInfo[creepName] and KillLog_CreepInfo[creepName].max ) then
		order = 0 + KillLog_CreepInfo[creepName].max;
		tag = ""..order;
	end
	return order, tag;
end


function KillLog_ListFrame_GetSortInfo_Location(creepName)
	local order, tag, header = 1, nil, KILLLOG_LIST_UNKNOWNTYPE;
	if ( KillLog_CreepInfo[creepName] ) then
		local creepStats = KillLog_ListFrame["displaySource"][creepName];
		if ( creepStats and creepStats.kill ) then
			order = creepStats.kill;
			tag = creepStats.kill;
		end
		if ( KillLog_CreepInfo[creepName].zone ) then
			header = KillLog_CreepInfo[creepName].zone;
		end
	end
	return order, tag, header;
end


function KillLog_ListFrame_GetSortInfo_Kill(creepName)
	local order, tag = 0, nil;
	if ( KillLog_ListFrame.displaySource[creepName] and KillLog_ListFrame.displaySource[creepName].kill ) then
		order = 0 + KillLog_ListFrame.displaySource[creepName].kill;
		tag = order;
	end
	return order, tag;
end

function KillLog_ListFrame_GetSortInfo_Death(creepName)
	local order, tag = 0, nil;
	if ( KillLog_ListFrame.displaySource[creepName] and KillLog_ListFrame.displaySource[creepName].death ) then
		order = 0 + KillLog_ListFrame.displaySource[creepName].death;
		tag = order;
	end
	return order, tag;
end

function KillLog_ListFrame_GetSortInfo_Xp(creepName)
	local order, tag = 0, nil;
	if ( KillLog_ListFrame.displaySource[creepName] and KillLog_ListFrame.displaySource[creepName].xp ) then
		order = 0 + KillLog_ListFrame.displaySource[creepName].xp;
		tag = order;
	end
	return order, tag;
end

KILLLOG_LIST_SORT = {
	{ name = KILLLOG_LABEL_RECENT,	infoFunc = KillLog_ListFrame_GetSortInfo_Recent },
	{ name = KILLLOG_LABEL_NAME,	infoFunc = KillLog_ListFrame_GetSortInfo_Name },
	{ name = KILLLOG_LABEL_TYPE,	infoFunc = KillLog_ListFrame_GetSortInfo_Type },
	{ name = KILLLOG_LABEL_FAMILY,	infoFunc = KillLog_ListFrame_GetSortInfo_Family },
	{ name = KILLLOG_LABEL_CLASS,	infoFunc = KillLog_ListFrame_GetSortInfo_Class },
	{ name = KILLLOG_LABEL_LEVEL,	infoFunc = KillLog_ListFrame_GetSortInfo_Level },
	{ name = KILLLOG_LABEL_LOCATION,infoFunc = KillLog_ListFrame_GetSortInfo_Location },
	{ name = KILLLOG_LABEL_KILL,	infoFunc = KillLog_ListFrame_GetSortInfo_Kill },
	{ name = KILLLOG_LABEL_DEATH,	infoFunc = KillLog_ListFrame_GetSortInfo_Death },
	{ name = KILLLOG_LABEL_XP,		infoFunc = KillLog_ListFrame_GetSortInfo_Xp },
};

