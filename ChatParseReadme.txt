----
Name
----

ChatParse


----
Note
----

The idea for this code is going to be released soon as part of Sky.  Since
that will have much more functionality, I have decided not to confuse thing
and release this separately.  It is only being packaged with KillLog now
and not a stand-alone AddOn.


-----------
Description
-----------

This AddOn will ease gathering information from any chat messages.  I am
using it to scrap experience and creep names from Combat messages, but it
should work well beyond that as well.

To interface with this AddOn, you need to register what you are going to
be watching.  To register a chat message, you must provide a table
specifying:
    	event     -- which event throws the message
	func      -- what to call into with the match
	template  -- the format specification used to output the message
	fields    -- [optional] what names should be assigned to the matches
	AddOn     -- [optional] the name of your AddOn

If you provide fields, then I will call into your function passing a 
table of named parameters correllating to your specification.

provided that you specify template = "You hit %s for %d damage.";

If you don't specify fields, then the input to your callback function
will be:
"You hit Creep X for 1 damage."

-- fields = { "creepName" };
{ creepName = "Creep X" }

-- fields = { nil, "damage" };
{ damage = "1" }

-- fields = { "creepName", "damage" };
{ creepName = "Creep X", damage = "1" }


By specifying the AddOn name, you can do a couple special things:
* If you specify multiple templates for the same event, I will attempt
  to match them all, in the order that they were registered.  When I find a
  match, I will call the function specified.  If that function returns
  nil, then I will not attempt to match that event for any additional
  specifications from the same AddOn.

* You can tell me to stop watching events for your AddOn.
  This would be if you have a configuration option and the user can
  enable/disable your AddOn.
  ChatParse_UnregisterEvent({AddOn = "MyAddOn"});

  Note, you may also specify the specific event to stop watching:
  ChatParse_UnregisterEvent({
	AddOn = "MyAddOn",
	event = "CHAT_MSG_COMBAT_SELF_HITS",
  });


--------
Examples
--------

--  example #1; gather name and damage for a standard hit

function MyAddOn_OnLoad()
	local info = { };
	info.AddOn    = "MyAddOn";
	info.event    = "CHAT_MSG_COMBAT_SELF_HITS";
	info.func     = MyAddOn_LogHit
	info.template = COMBATHITSELFOTHER; -- "You hit %s for %d."
	info.fields   = { "creepName", "damage" };
	ChatParse_RegisterEvent(info);
end

function MyAddOn_LogHit(input)
	MyAddOn_TotalDamage = MyAddOn_TotalDamage + input.damage;
	MyAddOn_LastCreep   = input.creepName;
end


-- example #2, matching experience, attempting to find rested match first

function MyAddOn_OnLoad()
	local info = { };
	info.AddOn    = "MyAddOn";
	info.event    = "CHAT_MSG_COMBAT_XP_GAIN";
	info.func     = MyAddOn_LogXp;

	info.template = COMBATLOG_XPGAIN_EXHAUSTION1; --"%s dies, you gain %d experience. (%s exp %s bonus)"
	info.fields   = { "creepName", "xp", "bonusXp", "bonusType" };
	ChatParse_RegisterEvent(info);

	-- attempt to match this template second as this spec will also match the above template
	info.template = COMBATLOG_XPGAIN_FIRSTPERSON; --"%s dies, you gain %d experience."
	info.fields   = { "creepName", "xp" };
	ChatParse_RegisterEvent(info);
end

function MyAddOn_LogXp(input)
	MyAddOn_TotalXp = MyAddOn_TotalXp + input.xp;
	MyAddOn_CreepKilled = input.creepName;
	if ( input.bonusXp and input.bonusType == "Rested" ) then
		MyAddOn_RestedXp = MyAddOn_RestedXp + input.bonusXp;
	end
	return nil;
end


-------
History
-------

+ Version 1
  * initial release


----------------
More information
----------------

To check for updates, please visit:
  http://wow.risse.com/

Please let me know if you encounter any errors while using this AddOn!


------
Author
------

Daniel Risse <dan@risse.com>
