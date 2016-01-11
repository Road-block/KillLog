--[[
path: /ChatParse/
filename: ChatParse.lua
author: "Daniel Risse" <dan@risse.com>
created: Thu, 03 Feb 2004 00:38:00 -0600
updated:

Chat Parse: Used to scrap information from Chat Messages



	COMBATLOG_XPGAIN_EXHAUSTION1_GROUP = "%s dies, you gain %d experience. (%s exp %s bonus, +%d group bonus)";

	local spec = ChatParse_FormatToPattern(COMBATLOG_XPGAIN_EXHAUSTION1_GROUP, "creepName", "xp", CHAT_PARSE_VALUE1, CHAT_PARSE_NAME1, "group");

	local message = format(COMBATLOG_XPGAIN_EXHAUSTION1_GROUP, "Creep X", 100, "+20", "rested", 10);
	-- Creep X dies, you gain 100 experience. (+20 exp rested bonus, +10 group bonus)

	local match = ChatParse_MatchPattern(message, spec);
	if ( match ) then
		DebugMessage("test", "Wahoo!!!"..match.creepName, "info");
	end
]]


local ChatParse_Events = { };

function ChatParse_OnLoad()
	if ( not DebugMessage ) then
		DebugMessage = function(x,y,z) if ( z == "error" ) then DEFAULT_CHAT_FRAME:AddMessage(format("|cffff0000[%s]: %s|r", x, y)) end end;
	else
		--[[ test
		local info = { };
		info.AddOn    = "ChatParse";

		info.event    = "CHAT_MSG_COMBAT_XP_GAIN";
		info.func     = function(t) DebugMessage("CP - test", "Match1 -- name: "..t.creepName.. "  xp: "..t.xp.."  "..t.bonusType..": "..t.bonusXp, "info"); return nil; end;
		info.template = COMBATLOG_XPGAIN_EXHAUSTION1; --"%s dies, you gain %d experience. (%s exp %s bonus)"
		info.fields   = { "creepName", "xp", "bonusXp", "bonusType" };
		ChatParse_RegisterEvent(info);
		
		info.event    = "CHAT_MSG_COMBAT_XP_GAIN";
		info.func     = function(t) DebugMessage("CP - test", "Match2 -- name: "..t.creepName.. "  xp: "..t.xp, "info"); return nil; end;
		info.template = COMBATLOG_XPGAIN_FIRSTPERSON; --"%s dies, you gain %d experience."
		info.fields   = { "creepName", "xp" };
		ChatParse_RegisterEvent(info);
		
		info.event    = "CHAT_MSG_COMBAT_SELF_HITS";
		info.func     = function(t) DebugMessage("CP - test", "Match3 -- name: "..t.creepName, "info"); return nil; end;
		info.template = COMBATHITSELFOTHER; -- "You hit %s for %d."
		info.fields   = { "creepName" };
		ChatParse_RegisterEvent(info);
		]]
	end
end

function ChatParse_OnEvent(event)
	if ( not ChatParse_Events[event] ) then
		--this:UnregisterEvent(event);
		DebugMessage("CP", "OnEvent("..event..") called but nothing registered...", "warning");
	else
		local index, info, match, processed, string;
		processed = { };
		for index, info in pairs(ChatParse_Events[event]) do
			if ( not info.AddOn or not processed[info.AddOn] ) then
				--[[
				if ( info.input ) then
					string = info.input()
				else
					string = arg1;
				end
				match = ChatParse_MatchPattern(string, info.patternSpec);
				]]
				match = ChatParse_MatchPattern(arg1, info.patternSpec);
				if ( match ) then
					result = info.func(match);
					if ( not result and info.AddOn ) then
						processed[info.AddOn] = true;
					end
				end
			end
		end
	end
end

function ChatParse_RegisterEvent(info)
	if ( type(info) ~= "table" ) then
		DebugMessage("CP", "Input to ChatParse_RegisterEvent must be a table!", "error");
		return nil;
	elseif ( not info.event or type(info.event) ~= "string" ) then
		DebugMessage("CP", "Input to ChatParse_RegisterEvent must contain an event to watch!", "error");
		return nil;
	elseif ( not info.func or type(info.func) ~= "function" ) then
		DebugMessage("CP", "Input to ChatParse_RegisterEvent must contain a function to call back to!", "error");
		return nil;
	elseif ( not info.template or type(info.template) ~= "string" ) then
		DebugMessage("CP", "Input to ChatParse_RegisterEvent must contain a template to match against the Chat message!", "error");
		return nil;

	elseif ( not ChatParse_Events[info.event] ) then
		ChatParseFrame:RegisterEvent(info.event);
		ChatParse_Events[info.event] = { };
		--table.setn(ChatParse_Events[info.event], 0);
	end

	if ( not info.AddOn ) then
		DebugMessage("CP", "Input to ChatParse_RegisterEvent did not contain AddOn name; this is needed to ChatParse_UnregisterEvent and to stop looking for additional matches.", "warning");
	end
	DebugMessage("CP", "new spec for event: "..info.event, "parser");

	local spec = ChatParse_FormatToPattern(info.template, info.fields, info.english);
	if ( spec ) then
		table.insert(ChatParse_Events[info.event], { func = info.func, patternSpec = spec, AddOn = info.AddOn, input = info.input });
	end
end

function ChatParse_UnregisterEvent(info)
	if ( type(info) ~= "table" ) then
		DebugMessage("CP", "Input to ChatParse_UnregisterEvent must be a table!", "error");
		return nil;
	elseif ( not info.AddOn or type(info.AddOn) ~= "string" ) then
		DebugMessage("CP", "Input to ChatParse_UnregisterEvent must contain an AddOn to stop watching!", "error");
		return nil;
	end
	local event, specList, index, spec;

	for event, specList in pairs(ChatParse_Events) do
		if ( not info.event or event == info.event ) then
			for index, spec in pairs(specList) do
				if ( info.AddOn == spec.AddOn ) then
					table.remove(ChatParse_Events[event], index);
				end
			end
			if ( table.getn(ChatParse_Events[event]) == 0 ) then
				ChatParse_Events[event] = nil;
				ChatParseFrame:UnregisterEvent(event);
			end
		end
	end
end

-- ("%s hits you for %d damage.", "creep", "damage");
-- this function will convert a format string into a pattern that will extract
-- named parameters from the string

function ChatParse_FormatToPattern(template, fields, english)
	DebugMessage("CP", "template: "..template, "parser");
	local ret = { pattern = template };
	ret.pattern = string.gsub(ret.pattern, "%(", "%%(");
	ret.pattern = string.gsub(ret.pattern, "%)", "%%)");
	ret.pattern = string.gsub(ret.pattern, "%.", "%%.");
	ret.pattern = string.gsub(ret.pattern, "%+", "%%+");
	ret.pattern = string.gsub(ret.pattern, "%[", "%%[");
	ret.pattern = string.gsub(ret.pattern, "%]", "%%]");
	-- attempt to match localization strings with strange characters
	-- ret.pattern = string.gsub(ret.pattern, "[^%w%p%s]+", ".+");

	local index, field, count, matchCount, fieldCount;
	matchCount = 0;
	fieldCount = 0;
	local replaceFunc = function(i, m)
		if ( i == "" ) then
			matchCount = matchCount + 1;
			i = matchCount;
		else
			i = 0 + i;
		end
		DebugMessage("CP", "Match: "..i..", "..m, "parser");
		if ( not fields[i] ) then
			if ( m == "d" ) then
				return "[0-9]+";
			elseif ( m == "s" ) then
				return ".+";
			end
		else
			fieldCount = fieldCount + 1;
			ret[fieldCount] = fields[i];
			fields[i] = nil;
			if ( m == "d" ) then
				return "([0-9]+)";
			elseif ( m == "s" ) then
				return "(.+)";
			end
		end
	end;
	ret.pattern, count = string.gsub(ret.pattern, "%%(%d*)$?([ds])", replaceFunc);
	if ( next(fields) ) then
		if ( english ) then
			DebugMessage("CP", "More names passed than substitution items!\n  "..template.."\n  "..english, "error");
		else
			DebugMessage("CP", "More names passed than substitution items!", "error");
		end
	elseif ( english and template ~= english ) then
		DebugMessage("CP", "Please provide this information to Frenn to assist in figuring out why crit's are not being stored!\n  "..template.."\n  "..english.."\n  "..ret.pattern, "error");
	end
	DebugMessage("CP", "pattern: "..ret.pattern, "parser");
	return ret;
end


function ChatParse_MatchPattern(message, spec)
	local match = { string.gmatch(message, spec.pattern)() };
	if ( table.getn(match) ~= 0 ) then
		local ret = { };
		local index;
		for index=1, table.getn(match), 1 do
			if ( spec[index] ) then
				ret[spec[index]] = match[index];
			end
		end
		return ret;
	end
	return nil;
end
