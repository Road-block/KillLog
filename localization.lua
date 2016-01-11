--[[
path: /KillLog/
filename: localization.lua
author: Daniel Risse <dan@risse.com>
update: Detritis <Slynx - Quel'Thalas>	
created: Mon, 17 Jan 2005 17:33:00 -0800
updated: Thurs, 26 Jan 2007

Kill Log: A record of your exploits fighting creeps in Azeroth
]]

-- text for GUI window title
KILLLOG_TITLE                     = "Kill Log "..KILLLOG_VERSION;

-- text for GUI bottom tabs
KILLLOG_TAB_GENERAL               = "General";
KILLLOG_TAB_LIST                  = "List";
KILLLOG_TAB_DEATH                 = "Death";
KILLLOG_TAB_OPTIONS               = "Options";

KILLLOG_LABEL_DEFAULT             = "Default";
KILLLOG_LABEL_PET                 = "(pet)";
KILLLOG_LABEL_HIT                 = "hit";
KILLLOG_LABEL_CRIT                = "crit";
KILLLOG_LABEL_DAMAGE			  = "hit";
KILLLOG_LABEL_HEAL				  = "heals";

-- text for GUI top tabs on LIST tab
KILLLOG_LIST_OVERALL              = "Overall";
KILLLOG_LIST_SESSION              = "Session";
KILLLOG_LIST_LEVEL                = "Level";

-- text for creeps without defined type
KILLLOG_LIST_UNKNOWNTYPE          = "Unknown";
KILLLOG_LIST_NORMALTYPE			  = "Normal";

-- these are used both for the Sort labels and for the labels in the detail
KILLLOG_LABEL_RECENT              = "Recent";
KILLLOG_LABEL_TYPE                = "Type";
KILLLOG_LABEL_FAMILY              = "Family";
KILLLOG_LABEL_CLASS               = "Class";
KILLLOG_LABEL_NAME                = "Name";
KILLLOG_LABEL_LEVEL               = "Level";
KILLLOG_LABEL_LOCATION            = "Location";
KILLLOG_LABEL_KILL                = "Kill";
KILLLOG_LABEL_DEATH               = "Death";
KILLLOG_LABEL_XP                  = "Xp";
KILLLOG_LABEL_RESTED              = "Rested";
KILLLOG_LABEL_GROUP               = "Group";
KILLLOG_LABEL_RAID                = "Raid";

-- these are for changing the creep type
KILLLOG_LABEL_CHANGE_FAMILY       	= "Change Creep Family";
KILLLOG_STATIC_CHANGE_FAMILY_BLURB 	= "Enter the new family type for this creep";
KILLLOG_LABEL_CHANGE_TYPE         	= "Change Creep Type";
KILLLOG_STATIC_CHANGE_TYPE_BLURB  	= "Enter the new type for this creep";
KILLLOG_LABEL_DELETE              	= "Delete Creep Entry";
KILLLOG_STATIC_DELETE_BLURB       	= "Are you certain you wish to remove this entry?";


-- formatting for updating tooltip
KILLLOG_TOOLTIP_KILL_COUNT        	= "Kill %d, avg. xp. %d";
KILLLOG_TOOLTIP_DEATH_COUNT       	= "Death %d";

KILLLOG_NEW_MAX                   	= "New maximum damage: %s %s for %s!";
KILLLOG_NEW_MAX_HEAL             	= "New maximum healing: %s %s for %s!";

KILLLOG_MAXHIT_TITLE              	= "Maximum Hits";
KILLLOG_MAXHEALS_TITLE              = "Maximum Heals";
KILLLOG_EXPERIENCE_TITLE          	= "Experience Summary";
KILLLOG_CREEP_TITLE               	= "Creep Summary";
KILLLOG_LABEL_QUEST               	= "Quest";
KILLLOG_LABEL_EXPLORATION         	= "Exploration";
KILLLOG_LABEL_CREEP_XP           	= "Creep";
KILLLOG_NOT_AVAILABLE             	= "Not available";

KILLLOG_DEATH_TITLE					= "Death History";
--KILLLOG_DEATH_FORMAT1				= "%d: Killed by <%s> at\n    level <%d> on <%s>";
--KILLLOG_DEATH_FORMAT2				= "%d: Killed by <%s> at\n      level <%d> on <%s>";
--KILLLOG_DEATH_FORMAT3				= "%d: Killed by <%s> at\n        level <%d> on <%s>";

KILLLOG_DEATH_FORMAT1				= "%d: <%s> killed you\n    at level <%d> on <%s>";
KILLLOG_DEATH_FORMAT2				= "%d: <%s> killed you\n      at level <%d> on <%s>";
KILLLOG_DEATH_FORMAT3				= "%d: <%s> killed you\n        at level <%d> on <%s>";


-- binding texts
BINDING_HEADER_KILLLOG            	= "Kill Log";
BINDING_NAME_KILLLOG_TOGGLE       	= "Toggle the Kill Log window";
BINDING_NAME_KILLLOG_GENERAL      	= "Open to general information";
BINDING_NAME_KILLLOG_LIST         	= "Open to lists of creep encounters";
BINDING_NAME_KILLLOG_DEATH        	= "Open to list of your deaths";
BINDING_NAME_KILLLOG_OPTIONS      	= "Open to configuration options";


-- used for button in Cosmos menu
KILLLOG_BUTTON_TEXT               	= BINDING_HEADER_KILLLOG;
KILLLOG_BUTTON_SUBTEXT            	= "Count and xp";
KILLLOG_BUTTON_TIP                	= "A record of your exploits fighting creeps in Azeroth";


-- used to fill creep family
-- this is FAR from complete
KILLLOG_CREEP_FAMILIES = {
	["Basilisk"]   	= { "Basilisk" },
	["Kodo"]       	= { "Kodo" },
	["Slime"]      	= { "Slime" },
	["Threshadon"] 	= { "Threshadon" },
	["Zhevra"]     	= { "Zhevra" },
	["Whelp"]      	= { "Whelp" },
	["Critter"]	   	= { "Adder", "Hare", "Rat" },
	["Dwarf"]      	= { "Dwarf" },
	["Gnome"]     	= { "Gnome" },
	["Gnoll"]      	= { "Gnoll", "Mosshide", "Redridge", "Riverpaw" },
	["Human"]      	= { "Defias", "Kul Tiras", "Scarlet", "Tirisfal" },
	["Kobold"]     	= { "Kobold" },
	["Murloc"]     	= { "Murloc" },
	["Naga"]       	= { "Naga", "Slitherblade" },
	["Ogre"]       	= { "Ogre", "Mo'grosh" },
	["Orc"]        	= { "Orc", "Blackrock" },
	["Quillboar"]  	= { "Quillboar" },
	["Skeleton"]	= { "Skeleton" },
	["Trogg"]      	= { "Stonesplinter", "Trogg" },
	["Worgen"]     	= { "Worgen" },
	["Zombie"]		= { "Zombie", "Rotting Dead", "Ravaged Corpse" },
	["Elemental"]  = { "Elemental" },
	["Demon"]		= { "Demon", "Darkhound" },
	["Mechanical"] = { "Mechanical" },
	["Centaur"]		= { "Gelkis" },
}

-- strings for the opions tab
-- these are placeholders and not very descriptive yet...
KILLLOG_OPTION_STORE_MAX					= "Track damage";
KILLLOG_OPTION_TOOLTIP_STORE_MAX			= "Track max damage";
KILLLOG_OPTION_NOTIFY_MAX					= "Notify max";
KILLLOG_OPTION_TOOLTIP_NOTIFY_MAX			= "Display notification upon new max damage";
KILLLOG_OPTION_STORE_CREEP					= "Store creep info";
KILLLOG_OPTION_TOOLTIP_STORE_CREEP			= "Store creep info";
KILLLOG_OPTION_STORE_LOCATION				= "Store location";
KILLLOG_OPTION_TOOLTIP_STORE_LOCATION		= "Track the location that you encountered the creep";
KILLLOG_OPTION_SESSION						= "Track session info";
KILLLOG_OPTION_TOOLTIP_SESSION				= "Track session info";
KILLLOG_OPTION_DEBUG						= "Show Debug info";

KILLLOG_OPTION_TOOLTIP						= "Creep stats";
KILLLOG_OPTION_TOOLTIP_TOOLTIP				= "When mouse-overing creeps, display kill and death count";
KILLLOG_OPTION_STORE_DEATH					= "Track deaths";
KILLLOG_OPTION_TOOLTIP_STORE_DEATH			= "Track deaths";
KILLLOG_OPTION_STORE_OVERALL				= "Track overall info";
KILLLOG_OPTION_TOOLTIP_STORE_OVERALL		= "Track overall info";
KILLLOG_OPTION_TRIVIAL						= "List trivial creeps";
KILLLOG_OPTION_TOOLTIP_TRIVIAL				= "Include trivial creeps in lists";
KILLLOG_OPTION_TOOLTIP_DEBUG				= "Show Debug info";

KILLLOG_OPTION_STORE_LEVEL					= "Track by level";
KILLLOG_OPTION_TOOLTIP_STORE_LEVEL			= "Track per level info";
KILLLOG_OPTION_SLIDER_STORE_LEVEL			= "level";
KILLLOG_OPTION_SLIDER_TOOLTIP_STORE_LEVEL	= "Number of levels to track";

KILLLOG_OPTION_PORTRAIT						= "Enable portraits";
KILLLOG_OPTION_TOOLTIP_PORTRAIT				= "Enable portraits";
KILLLOG_OPTION_SLIDER_PORTRAIT				= "portrait";
KILLLOG_OPTION_SLIDER_TOOLTIP_PORTRAIT		= "Number of portraits to use";
--New
KILLLOG_OPTION_SLIDER_DEBUG					= "debug";
KILLLOG_OPTION_SLIDER_TOOLTIP_DEBUG			= "Debug level to use";

KILLLOG_OPTION_SCT_SUPPORT					= "Enable SCT";
KILLLOG_OPTION_TOOLTIP_SCT_SUPPORT			= "Enable SCT for notifications";

KILLLOG_CLEAR								= "Clear";
KILLLOG_CLEAR_CONFIRMATION					= "Are you certain, this will erase ALL of the information that has been gathered for ALL of your characters.\n\nWarning!!!\n This will reload the UI after erasing.";

if ( GetLocale() == "deDE" ) then
	-- text for GUI window title
	KILLLOG_TITLE                     = "Kill Log "..KILLLOG_VERSION;

	-- text for GUI bottom tabs
	KILLLOG_TAB_GENERAL               = "Allgemein";
	KILLLOG_TAB_LIST                  = "Liste";
	KILLLOG_TAB_DEATH                 = "Gestorben";
	KILLLOG_TAB_OPTIONS               = "Optionen";

	-- text for GUI top tabs on LIST tab
	KILLLOG_LIST_OVERALL              = "Alles";
	KILLLOG_LIST_SESSION              = "Sitzung";
	KILLLOG_LIST_LEVEL                = "Stufe";

	-- text for creeps without defined type (killed without ever mouseovering)
	KILLLOG_LIST_UNKNOWNTYPE          = "Unbekannt";
	KILLLOG_LIST_NORMALTYPE			  = "Normal";

	-- these are used both for the Sort labels and for the labels in the detail
	KILLLOG_LABEL_RECENT              = "Neueste";
	KILLLOG_LABEL_TYPE                = "Typ";
	KILLLOG_LABEL_FAMILY              = "Rasse";
	KILLLOG_LABEL_CLASS				  = "Kategorie";
	KILLLOG_LABEL_NAME                = "Name";
	KILLLOG_LABEL_LEVEL               = "Stufe";
	
	KILLLOG_LABEL_KILL                = "Getötet";
	KILLLOG_LABEL_DEATH               = "Gestorben";
	KILLLOG_LABEL_XP                  = "Erfahrung";
	KILLLOG_LABEL_RESTED              = "Erholt";
	KILLLOG_LABEL_GROUP               = "Gruppe";
	KILLLOG_LABEL_RAID                = "Raid";

	-- these are for changing the creep type
	KILLLOG_LABEL_CHANGE_FAMILY       = "Creep-Rasse verändern";
	KILLLOG_STATIC_CHANGE_FAMILY_BLURB = "Die neue Rasse fuer diesen Creep eingeben";
	KILLLOG_LABEL_CHANGE_TYPE         = "Creep-Typ verändern";
	KILLLOG_STATIC_CHANGE_TYPE_BLURB  = "Den neuen Typ für diesen Creep eingeben";
	KILLLOG_LABEL_DELETE              = "Creep-Eintrag löschen";
	KILLLOG_STATIC_DELETE_BLURB       = "Sind Sie sicher, dass Sie diesen Eintrag löschen möchten?";


	-- formatting for updating tooltip
	KILLLOG_TOOLTIP_KILL_COUNT        = "Getötet: %d, Erf. %d";
	KILLLOG_TOOLTIP_DEATH_COUNT       = "Gestorben: %d";

	KILLLOG_NEW_MAX                   = "Neuer maximaler Schaden: %s %s für %s!";

	KILLLOG_MAXHIT_TITLE              = "Härteste Schläge";
	KILLLOG_EXPERIENCE_TITLE          = "Erfahrungs-Zusammenfassung";
	KILLLOG_CREEP_TITLE               = "Creep-Zusammenfassung";
	KILLLOG_LABEL_QUEST               = "Quest";
	KILLLOG_LABEL_EXPLORATION         = "Entdeckung";
	KILLLOG_LABEL_CREEP_XP            = "Creep";
	KILLLOG_NOT_AVAILABLE             = "Nicht verfügbar";
	KILLLOG_LABEL_LOCATION			  = "Position";
	KILLLOG_DEATH_TITLE               = "Todes-Liste";
	KILLLOG_DEATH_FORMAT              = "%s gegen %s (mit Level %d)\n\n";

	-- binding texts
	BINDING_HEADER_KILLLOG            = "Kill Log";
	BINDING_NAME_KILLLOG_TOGGLE       = "Kill Log Fenster an/ausschalten";
	BINDING_NAME_KILLLOG_GENERAL      = "Die Allgemeinen Informationen öffnen";
	BINDING_NAME_KILLLOG_LIST         = "Die Creepliste aufrufen";
	BINDING_NAME_KILLLOG_DEATH        = "Die Liste eurer Tode öffnen";
	BINDING_NAME_KILLLOG_OPTIONS      = "Die Konfiguration öffnen";

	-- used for button in Cosmos menu
	KILLLOG_BUTTON_TEXT               = BINDING_HEADER_KILLLOG;
	KILLLOG_BUTTON_SUBTEXT            = "Count and xp";
	KILLLOG_BUTTON_TIP                = "A record of your exploits fighting creeps in Azeroth";
		
	-- used to fill creep family
	--   this is FAR from complete
	--KILLLOG_CREEP_FAMILIES = {
	--};
elseif ( GetLocale() == "frFR" ) then
	-- Traduit par Juki <Unskilled>

	-- text for GUI window title
	KILLLOG_TITLE                     = "Kill Log "..KILLLOG_VERSION;

	-- text for GUI bottom tabs
	KILLLOG_TAB_GENERAL               = "Général";
	KILLLOG_TAB_LIST                  = "Liste";
	KILLLOG_TAB_DEATH                 = "Mort";
	KILLLOG_TAB_OPTIONS               = "Options";

	KILLLOG_LABEL_DEFAULT             = "Défaut";
	KILLLOG_LABEL_PET                 = "(pet)";
	KILLLOG_LABEL_HIT                 = "hit";
	KILLLOG_LABEL_CRIT                = "crit";	

	-- text for GUI top tabs on LIST tab
	KILLLOG_LIST_OVERALL              = "Global";
	KILLLOG_LIST_SESSION              = "Session";
	KILLLOG_LIST_LEVEL                = "Niveau";

	-- text for creeps without defined type (killed without ever mouseovering)
	KILLLOG_LIST_UNKNOWNTYPE          = "Inconnu";
	KILLLOG_LIST_NORMALTYPE			  = "Normal";

	-- these are used both for the Sort labels and for the labels in the detail
	KILLLOG_LABEL_RECENT              = "Récent";
	KILLLOG_LABEL_TYPE                = "Type";
	KILLLOG_LABEL_FAMILY              = "Famille";
	KILLLOG_LABEL_CLASS				  = "Classe";
	KILLLOG_LABEL_NAME                = "Nom";
	KILLLOG_LABEL_LEVEL               = "Niveau";
	KILLLOG_LABEL_LOCATION			  = "Endroit";
	KILLLOG_LABEL_KILL                = "Kill";
	KILLLOG_LABEL_DEATH               = "Mort";
	KILLLOG_LABEL_XP                  = "XP";
	KILLLOG_LABEL_RESTED              = "En forme";
	KILLLOG_LABEL_GROUP               = "Groupe";
	KILLLOG_LABEL_RAID                = "Raid";

	-- these are for changing the creep type
	KILLLOG_LABEL_CHANGE_FAMILY       = "Changer Famille Creep";
	KILLLOG_STATIC_CHANGE_FAMILY_BLURB= "Entrez le nouveau type de famille pour ce Creep";
	KILLLOG_LABEL_CHANGE_TYPE         = "Changer Type Creep";
	KILLLOG_STATIC_CHANGE_TYPE_BLURB  = "Entrez le nouveau type pour ce Creep";
	KILLLOG_LABEL_DELETE              = "Supprimer Entrée Creep";
	KILLLOG_STATIC_DELETE_BLURB       = "Etes-vous certain de vouloir supprimer cette entrée ?";


	-- formatting for updating tooltip
	KILLLOG_TOOLTIP_KILL_COUNT        = "Kill %d, XP Moy. %d";
	KILLLOG_TOOLTIP_DEATH_COUNT       = "Mort %d";

	KILLLOG_NEW_MAX                   = "Nouveau Dégat Maximum : %s %s pour %s !";

	KILLLOG_MAXHIT_TITLE              = "Dégats Maximum";
	KILLLOG_EXPERIENCE_TITLE          = "Résumé Experience";
	KILLLOG_CREEP_TITLE               = "Résumé Creep";
	KILLLOG_LABEL_QUEST               = "Quête";
	KILLLOG_LABEL_EXPLORATION         = "Exploration";
	KILLLOG_LABEL_CREEP_XP            = "Creep";
	KILLLOG_NOT_AVAILABLE             = "Non disponible";

	KILLLOG_DEATH_TITLE               = "Historique Mort";
	KILLLOG_DEATH_FORMAT              = "%s contre %s (au niveau %d)\n\n";


	-- binding texts
	BINDING_HEADER_KILLLOG            = "Kill Log";
	BINDING_NAME_KILLLOG_TOGGLE       = "Afficher/Masquer la fenêtre Kill Log";
	BINDING_NAME_KILLLOG_GENERAL      = "Ouvrir les informations générales";
	BINDING_NAME_KILLLOG_LIST         = "Ouvrir la liste des Creep";
	BINDING_NAME_KILLLOG_DEATH        = "Ouvrir la liste de vos morts";
	BINDING_NAME_KILLLOG_OPTIONS      = "Ouvrir les options de configuration";

	-- used for button in Cosmos menu
	KILLLOG_BUTTON_TEXT               = BINDING_HEADER_KILLLOG;
	KILLLOG_BUTTON_SUBTEXT            = "Compteur et XP";
	KILLLOG_BUTTON_TIP                = "Un journal de vos exploits en Azeroth";

	-- used to fill creep family
	--   this is FAR from complete
	--KILLLOG_CREEP_FAMILIES = {
	--};

	--strings for the opions tab
	--  these are placeholders and not very descriptive yet...
	KILLLOG_OPTION_STORE_MAX                  = "Tracer dégats";
	KILLLOG_OPTION_TOOLTIP_STORE_MAX          = "Trace les dégats maximum.";
	KILLLOG_OPTION_NOTIFY_MAX                 = "Notifier maximum";
	KILLLOG_OPTION_TOOLTIP_NOTIFY_MAX         = "Affiche la notification des nouveaux dégats maximum.";
	KILLLOG_OPTION_STORE_CREEP                = "Stocker infos creep";
	KILLLOG_OPTION_TOOLTIP_STORE_CREEP        = "Stocke les informations creep.";
	KILLLOG_OPTION_SESSION                    = "Tracer infos session";
	KILLLOG_OPTION_TOOLTIP_SESSION            = "Trace les informations de la session.";

	KILLLOG_OPTION_TOOLTIP                    = "Stats creep";
	KILLLOG_OPTION_TOOLTIP_TOOLTIP            = "Quand vous passez la souris sur les creeps, affiche le compteur de kill et de mort.";
	KILLLOG_OPTION_STORE_DEATH                = "Tracer morts";
	KILLLOG_OPTION_TOOLTIP_STORE_DEATH        = "Trace vos morts.";
	KILLLOG_OPTION_STORE_OVERALL              = "Tracer infos globales";
	KILLLOG_OPTION_TOOLTIP_STORE_OVERALL      = "Trace les informations globales.";
	KILLLOG_OPTION_TRIVIAL                    = "Lister trivial creeps";
	KILLLOG_OPTION_TOOLTIP_TRIVIAL            = "Inclure les trivial creeps dans les listes.";

	KILLLOG_OPTION_STORE_LEVEL                = "Tracer par niveau";
	KILLLOG_OPTION_TOOLTIP_STORE_LEVEL        = "Trace les informations par niveau.";
	KILLLOG_OPTION_SLIDER_STORE_LEVEL         = "Niveau";
	KILLLOG_OPTION_SLIDER_TOOLTIP_STORE_LEVEL = "Nombre de niveaux à tracer.";

	KILLLOG_OPTION_PORTRAIT                   = "Activer portraits";
	KILLLOG_OPTION_TOOLTIP_PORTRAIT           = "Active les portraits.";
	KILLLOG_OPTION_SLIDER_PORTRAIT            = "Portrait";
	KILLLOG_OPTION_SLIDER_TOOLTIP_PORTRAIT    = "Nombre de portraits à utiliser.";

	KILLLOG_CLEAR                             = "Effacer";
	KILLLOG_CLEAR_CONFIRMATION                = "Etes-vous sûr ? Ceci effaçera TOUTES les informations qui ont été récoltées pour TOUS vos personnages.";
end

--[[
VSENVIRONMENTALDAMAGE_DROWNING_SELF = "You are drowning and lose %d health.";
VSENVIRONMENTALDAMAGE_FALLING_SELF = "You fall and lose %d health.";
VSENVIRONMENTALDAMAGE_FATIGUE_SELF = "You are exhausted and lose %d health.";
VSENVIRONMENTALDAMAGE_FIRE_SELF = "You suffer %d points of fire damage.";
VSENVIRONMENTALDAMAGE_LAVA_SELF = "You lose %d health for swimming in lava.";
VSENVIRONMENTALDAMAGE_SLIME_SELF = "You lose %d health for swimming in slime.";

ERR_QUEST_REWARD_EXP_I = "Experience gained: %d."; -- %d is amount of xp gain
ERR_ZONE_EXPLORED_XP = "Discovered %s: %d experience gained";

]]

