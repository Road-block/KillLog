--[[
path: /KillLog/
filename: KillLog_DeathFrame.lua
author: Daniel Risse <dan@risse.com>
update: Detritis <Slynx - Quel'Thalas>	
created: Mon, 17 Jan 2005 17:33:00 -0800
updated: Thurs, 04 Jan 2007 15:30:00

death frame: Listing of your deaths
]]
KILLLOG_DEATH_TITLEBUTTON_HEIGHT = 30;
KILLLOG_NUM_DISPLAY = 10;
KILLLOG_TEXT_COLOR = { r = 1, g = 1, b = 1 };

function KillLog_DeathFrame_OnShow()
  KillLog_DeathFrame_Update()
end

function KillLog_Death_TitleDropDown_OnLoad()
  UIDropDownMenu_Initialize(this, KillLog_Death_TitleDropDown_Initialize, "MENU");
end

function KillLog_Death_TitleDropDown_Initialize()
  local info = { };
  info.text = KILLLOG_LABEL_DELETE;
  info.func = function() StaticPopup_Show("KILLLOG_DEATH_DELETE"); end;
  UIDropDownMenu_AddButton(info);
end

function KillLog_DeathFrame_OnClick(button)
  --[[if ( not KillLog_AllCharacterData or not KillLog_AllCharacterData["death"] or table.getn(KillLog_AllCharacterData["death"]) == 0 ) then
	else
		if ( button == "LeftButton" ) then
			local deathID = this:GetID() + FauxScrollFrame_GetOffset(KillLog_DeathScrollFrame);

			if( deathID > 0 ) then
	            local realm = GetCVar("realmName");
				local player = UnitName("player");
				local numEntries = table.getn(KillLog_CharacterData[realm][player]["death"] );

                if ( deathID > numEntries ) then
                    deathID = numEntries
                else
                    deathID = deathID
                end

				KillLog_DeathFrame_Highlight:SetVertexColor(KILLLOG_TEXT_COLOR.r, KILLLOG_TEXT_COLOR.g, KILLLOG_TEXT_COLOR.b);
    			KillLog_DeathFrame_HighlightFrame:SetPoint("TOPLEFT", "KillLog_DeathButton"..deathID, "TOPLEFT", 10, 0);
    			KillLog_DeathFrame_HighlightFrame:Show();
			end
		elseif ( button == "RightButton" ) then
			ToggleDropDownMenu(1, nil, KillLog_Death_TitleDropDown, "KillLog_List_Title"..this:GetID(), 10, 0);
			DebugMessage("[KL - Death]", "Death ID: "..this:GetID() + FauxScrollFrame_GetOffset(KillLog_DeathScrollFrame), "error");
		end
	end]]
end

function KillLog_DeathFrame_Update()
  local realm = GetCVar("realmName");
  local player = UnitName("player");
  local numEntries = table.getn(KillLog_CharacterData[realm][player]["death"]);
  -- local KillLog_ListFrame.deathList = {};

  -- Update scroll frame
  FauxScrollFrame_Update(KillLog_DeathScrollFrame, numEntries, KILLLOG_NUM_DISPLAY, KILLLOG_DEATH_TITLEBUTTON_HEIGHT, nil, nil, nil, KillLog_DeathFrame_HighlightFrame, 293, 316);
  local scrollFrameOffset = FauxScrollFrame_GetOffset(KillLog_DeathScrollFrame);

  if (not KillLog_AllCharacterData or not KillLog_AllCharacterData["death"] or table.getn(KillLog_AllCharacterData["death"]) == 0) then
    deathTitle = getglobal("KillLog_DeathButtonTitleText");
    deathTitle:SetText("Death History");

    deathText = getglobal("KillLog_DeathButton1Text");
    deathText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
    deathText:SetText("    " .. KILLLOG_NOT_AVAILABLE);
  else
    deathTitle = getglobal("KillLog_DeathButtonTitleText");
    deathTitle:SetText("Death History");

    if (numEntries < 10) then
      KILLLOG_NUM_DISPLAY = numEntries;
    else
      KILLLOG_NUM_DISPLAY = KILLLOG_NUM_DISPLAY;
    end

    --[[for index, data in pairs(KillLog_AllCharacterData["death"]) do
			table.insert(KillLog_ListFrame.deathList, index);
			QuickSort(KillLog_ListFrame.deathList, function(a,b) if (a.index ~= b.index) then return a.index > b.index; end return a.index < b.index; end);
		end]]


    for index = KILLLOG_NUM_DISPLAY, 1, -1 do
      local creepIndex = index + scrollFrameOffset;
      local creepName = KillLog_CharacterData[realm][player]["death"][creepIndex].creepName
      local deathLevel = KillLog_CharacterData[realm][player]["death"][creepIndex].level
      local deathTime = KillLog_CharacterData[realm][player]["death"][creepIndex].time

      deathText = getglobal("KillLog_DeathButton" .. index .. "Text");

      deathText:SetTextColor(KILLLOG_TEXT_COLOR.r, KILLLOG_TEXT_COLOR.g, KILLLOG_TEXT_COLOR.b);
      if (creepIndex < 10) then
        deathText:SetText(format(KILLLOG_DEATH_FORMAT1, creepIndex, creepName, deathLevel, deathTime))
      elseif (creepIndex < 100) then
        deathText:SetText(format(KILLLOG_DEATH_FORMAT2, creepIndex, creepName, deathLevel, deathTime))
      else
        deathText:SetText(format(KILLLOG_DEATH_FORMAT3, creepIndex, creepName, deathLevel, deathTime))
      end
      deathText:Show()

      KillLog_DeathFrame_Highlight:SetVertexColor(KILLLOG_TEXT_COLOR.r, KILLLOG_TEXT_COLOR.g, KILLLOG_TEXT_COLOR.b);
      KillLog_DeathFrame_HighlightFrame:SetPoint("TOPLEFT", "KillLog_DeathButton1", "TOPLEFT", 10, 0);
      -- * Show again when decided if you want to do anything to this data * --
      KillLog_DeathFrame_HighlightFrame:Hide();
      deathText:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
    end
  end
end
