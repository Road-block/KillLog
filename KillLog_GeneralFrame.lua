--[[
path: /KillLog/
filename: KillLog_GeneralFrame.xml
author: Daniel Risse <dan@risse.com>
update: Detritis <Slynx - Quel'Thalas>	
created: Mon, 17 Jan 2005 17:33:00 -0800
updated: Thurs, 2 Feb 2007

general frame: Listing of interesting statistics
]]

KILLLOG_MAXHIT_COUNT = 18;
KILLLOG_GENERAL_NUMBER = 25;
temp = 0;
xpTotal = 0;

function KillLog_GeneralFrame_OnLoad()
  local color;
  if (MATERIAL_TITLETEXT_COLOR_TABLE and MATERIAL_TITLETEXT_COLOR_TABLE.Parchment) then
    color = MATERIAL_TITLETEXT_COLOR_TABLE.Parchment;
    KillLog_GeneralFrameHitTitle:SetTextColor(color[1], color[2], color[3]);
    KillLog_GeneralFrameXpTitle:SetTextColor(color[1], color[2], color[3]);
    KillLog_GeneralFrameCreepTitle:SetTextColor(color[1], color[2], color[3]);
  end
  if (MATERIAL_TEXT_COLOR_TABLE and MATERIAL_TEXT_COLOR_TABLE.Parchment) then
    color = MATERIAL_TEXT_COLOR_TABLE.Parchment;
    local index;
    for index = 1, KILLLOG_MAXHIT_COUNT, 1 do
      getglobal("KillLog_GeneralFrameHit" .. index):SetTextColor(color[1], color[2], color[3]);
    end
    for index = 1, KILLLOG_MAXHIT_COUNT - 3, 1 do
      getglobal("KillLog_GeneralFrameXp" .. index):SetTextColor(color[1], color[2], color[3]);
      getglobal("KillLog_GeneralFrameCreep" .. index):SetTextColor(color[1], color[2], color[3]);
    end
  end
end

function KillLog_GeneralFrame_OnShow()
  local maxHitList = { };
  if (KillLog_AllCharacterData and KillLog_AllCharacterData["max"]) then
    local spell, data;
    for spell, data in pairs(KillLog_AllCharacterData["max"]) do
      if (data.hit ~= 0) then
        table.insert(maxHitList, { name = spell .. " hit", value = data.hit });
      end
      if (data.crit ~= 0) then
        table.insert(maxHitList, { name = spell .. " crit", value = data.crit });
      end
    end
  end

  local index, fontString;
  if (table.getn(maxHitList) == 0) then
    table.insert(maxHitList, "placeholder");
    KillLog_GeneralFrameHit1:SetText("    " .. KILLLOG_LIST_UNKNOWNTYPE);
    KillLog_GeneralFrameHit1:Show();
  else
    QuickSort(maxHitList, function(a, b) if (a.value ~= b.value) then return a.value > b.value; end return a.name < b.name; end);
    for index = 1, KILLLOG_MAXHIT_COUNT, 1 do
      fontString = getglobal("KillLog_GeneralFrameHit" .. index);
      if (maxHitList[index]) then
        fontString:SetText("    " .. maxHitList[index].name .. ": " .. maxHitList[index].value);
        fontString:Show();
      end
    end
  end

  if (table.getn(maxHitList) > KILLLOG_MAXHIT_COUNT) then
    KillLog_GeneralFrameXpTitle:SetPoint("TOPLEFT", "KillLog_GeneralFrameHit18", "BOTTOMLEFT", 0, -14);
  else
    KillLog_GeneralFrameXpTitle:SetPoint("TOPLEFT", "KillLog_GeneralFrameHit" .. table.getn(maxHitList), "BOTTOMLEFT", 0, -14);
  end

  local xpList = { };
  local creepList = { total = 0 };
  local questTotal = 0;
  local explorationTotal = 0;

  if (KillLog_AllCharacterData and KillLog_AllCharacterData["overall"]) then
    local xp, rested, group, raid, total = 0, 0, 0, 0;
    if (KillLog_AllCharacterData["quest xp"]) then
      table.insert(xpList, { name = KILLLOG_LABEL_QUEST, value = 0 + KillLog_AllCharacterData["quest xp"] });
      questTotal = 0 + KillLog_AllCharacterData["quest xp"];
    end
    if (KillLog_AllCharacterData["exploration xp"]) then
      table.insert(xpList, { name = KILLLOG_LABEL_EXPLORATION, value = 0 + KillLog_AllCharacterData["exploration xp"] });
      explorationTotal = 0 + KillLog_AllCharacterData["exploration xp"];
    end

    for creepName, data in pairs(KillLog_AllCharacterData["overall"]) do
      if (data.xp) then
        xp = xp + data.xp;
      end
      if (data.rested) then
        rested = rested + data.rested;
        xp = xp - data.rested;
      end
      if (data.group) then
        group = group + data.group;
        xp = xp - data.group;
      end
      if (data.raid) then
        raid = raid + data.raid;
        xp = xp - data.raid;
      end
    end

    if (xp ~= 0) then
      table.insert(xpList, { name = KILLLOG_LABEL_CREEP_XP, value = xp });
    end
    if (rested ~= 0) then
      table.insert(xpList, { name = KILLLOG_LABEL_RESTED, value = rested });
    end
    if (group ~= 0) then
      table.insert(xpList, { name = KILLLOG_LABEL_GROUP, value = group });
    end
    if (raid ~= 0) then
      table.insert(xpList, { name = KILLLOG_LABEL_RAID, value = raid });
    end

    xpTotal = questTotal + explorationTotal + xp + rested + group + raid;
    table.insert(xpList, { name = "Total", value = xpTotal });
  end

  if (xpTotal == 0) then
    table.insert(xpList, "placeholder");
    KillLog_GeneralFrameXp1:SetText("    " .. KILLLOG_LIST_UNKNOWNTYPE);
    KillLog_GeneralFrameXp1:Show();
  else
    QuickSort(xpList, function(a, b) if (a.value ~= b.value) then return a.value > b.value; end return a.name < b.name; end);
    for index = 1, KILLLOG_MAXHIT_COUNT, 1 do
      fontString = getglobal("KillLog_GeneralFrameXp" .. index);
      if (xpList[index]) then
        fontString:SetText("    " .. xpList[index].name .. ": " .. xpList[index].value);
        fontString:Show();
      end
    end
  end

  KillLog_GeneralFrameCreepTitle:SetPoint("TOPLEFT", "KillLog_GeneralFrameXp" .. table.getn(xpList), "BOTTOMLEFT", 0, -14);
  KillLog_GeneralFrameCreepTitle:Show();

  local totalKill, normalKill, rareKill, eliteKill, rareEliteKill, worldBossKill = 0, 0, 0, 0, 0, 0;
  local totalDeath, tableDeath, normalDeath, rareDeath, eliteDeath, rareEliteDeath, worldBossDeath = 0, 0, 0, 0, 0, 0, 0;


  tableDeath = table.getn(KillLog_AllCharacterData["death"])

  for creepName, data in pairs(KillLog_AllCharacterData["overall"]) do
    if (data.kill) then
      if (KillLog_CreepInfo and KillLog_CreepInfo[creepName]) then
        classCheck = KillLog_CreepInfo[creepName].class;
        totalKill = totalKill + data.kill;
        if (KillLog_CreepInfo and classCheck ~= "rare" and classCheck ~= "elite" and classCheck ~= "rareelite" and classCheck ~= "worldboss") then
          normalKill = normalKill + data.kill;
        end
        if (KillLog_CreepInfo and classCheck == "rare") then
          rareKill = rareKill + data.kill;
        end
        if (KillLog_CreepInfo and classCheck == "elite") then
          eliteKill = eliteKill + data.kill;
        end
        if (KillLog_CreepInfo and classCheck == "rareelite") then
          rareEliteKill = rareEliteKill + data.kill;
        end
        if (KillLog_CreepInfo and classCheck == "worldboss") then
          worldBossKill = worldBossKill + data.kill;
        end
      end
    end

    if (data.death) then
      if (KillLog_CreepInfo and KillLog_CreepInfo[creepName]) then
        classCheck = KillLog_CreepInfo[creepName].class;
        totalDeath = totalDeath + data.death;
        if (KillLog_CreepInfo and classCheck ~= "rare" and classCheck ~= "elite" and classCheck ~= "rareelite" and classCheck ~= "worldboss") then
          normalDeath = normalDeath + data.death;
        end
        if (KillLog_CreepInfo and classCheck == "rare") then
          rareDeath = rareDeath + data.death;
        end
        if (KillLog_CreepInfo and classCheck == "elite") then
          eliteDeath = eliteDeath + data.death;
        end
        if (KillLog_CreepInfo and classCheck == "rareelite") then
          rareEliteDeath = rareEliteDeath + data.death;
        end
        if (KillLog_CreepInfo and classCheck == "worldboss") then
          worldBossDeath = worldBossDeath + data.death;
        end
      end
    end
  end

  DebugMessage("KL", "Table Death: " .. tableDeath, "helper");
  DebugMessage("KL", "Overall Death: " .. totalDeath, "helper");

  table.insert(creepList, { name = "Total Kills", value = totalKill });
  table.insert(creepList, { name = "    Normal Kills", value = normalKill });
  table.insert(creepList, { name = "    Rare Kills", value = rareKill });
  table.insert(creepList, { name = "    Elite Kills", value = eliteKill });
  table.insert(creepList, { name = "    Rare Elite Kills", value = rareEliteKill });
  table.insert(creepList, { name = "    WorldBoss Kills", value = worldBossKill });

  if (totalDeath > tableDeath) then
    table.insert(creepList, { name = "Total Deaths", value = totalDeath });
  else
    table.insert(creepList, { name = "Total Deaths", value = tableDeath });
  end
  table.insert(creepList, { name = "    Normal Deaths", value = normalDeath });
  table.insert(creepList, { name = "    Rare Deaths", value = rareDeath });
  table.insert(creepList, { name = "    Elite Deaths", value = eliteDeath });
  table.insert(creepList, { name = "    Rare Elite Deaths", value = rareEliteDeath });
  table.insert(creepList, { name = "    WorldBoss Deaths", value = worldBossDeath });

  if (totalKill == 0 and(totalDeath == 0 or tableDeath == 0)) then
    table.insert(creepList, "placeholder");
    KillLog_GeneralFrameCreep1:SetText("    " .. KILLLOG_LIST_UNKNOWNTYPE);
    KillLog_GeneralFrameCreep1:Show();
  else
    -- QuickSort(creepList, function(a,b) if (a.value ~= b.value) then return a.value > b.value; end return a.name < b.name; end);
    for index = 1, KILLLOG_MAXHIT_COUNT, 1 do
      fontString = getglobal("KillLog_GeneralFrameCreep" .. index);
      if (creepList[index]) then
        fontString:SetText("    " .. creepList[index].name .. ": " .. creepList[index].value);
        fontString:Show();
      end
    end
  end

  if (table.getn(maxHitList) > 18) then
    hitList = 18
  else
    hitList = table.getn(maxHitList)
  end

  temp = table.getn(creepList) + table.getn(xpList) + hitList

  DebugMessage("KL", "temp: " .. temp, "info");
  DebugMessage("KL", "maxHitList: " .. hitList .. " xpList: " .. table.getn(xpList) .. " creepList: " .. table.getn(creepList), "info");
  if (temp > 15) then
    FauxScrollFrame_Update(KillLog_GeneralFrameScrollFrame, temp, 1, 13);
  end
end
