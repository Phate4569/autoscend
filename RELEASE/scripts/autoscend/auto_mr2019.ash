script "auto_mr2019.ash"

# This is meant for items that have a date of 2019

int auto_sausageEaten()
{
	return get_property("_sausagesEaten").to_int();
}

int auto_sausageLeftToday()
{
	return 23 - auto_sausageEaten();
}

int auto_sausageUnitsNeededForSausage(int numSaus)
{
	return 111 * numSaus;
}

int auto_sausageMeatPasteNeededForSausage(int numSaus)
{
	return ceil(auto_sausageUnitsNeededForSausage(numSaus).to_float() / 10.0);
}

int auto_sausageFightsToday()
{
	return get_property("_sausageFights").to_int();
}

boolean auto_sausageGrind(int numSaus)
{
	return auto_sausageGrind(numSaus, false);
}

boolean auto_sausageGrind(int numSaus, boolean failIfCantMakeAll)
{
	// Some paths are pretty meat-intensive early. Just in case...
	boolean canDesert = (get_property("lastDesertUnlock").to_int() == my_ascensions());
	if(my_turncount() < 90 || !canDesert)
	{
		return false;
	}

	if(in_tcrs()) return false;

	int casingsOwned = item_amount($item[magical sausage casing]);

	if(casingsOwned == 0)
		return false;

	if(numSaus <= 0)
		return false;

	if(casingsOwned < numSaus)
	{
		if(failIfCantMakeAll)
		{
			return false;
		}
		numSaus = casingsOwned;
	}

	int sausMade = get_property("_sausagesMade").to_int();
	int pastesNeeded = 0;
	int pastesAvail = item_amount($item[meat paste]);
	int meatToSave = 5000;
	if(auto_my_path() == "Community Service")
		meatToSave = 500;
	for i from 1 to numSaus
	{
		int sausNum = i + sausMade;
		int pastesForThisSaus = auto_sausageMeatPasteNeededForSausage(sausNum);
		if((pastesNeeded + pastesForThisSaus - pastesAvail) * 10 + meatToSave > my_meat())
		{
			if(failIfCantMakeAll)
			{
				return false;
			}
			if(i == 1)
			{
				return false;
			}
			numSaus = i - 1;
			break;
		}
		pastesNeeded += pastesForThisSaus;
	}

	auto_log_info("Let's grind some sausage!", "blue");
	if(!create(numSaus, $item[magical sausage]))
	{
		auto_log_warning("Something went wrong while grinding sausage...", "red");
		return false;
	}
	loopHandlerDelayAll();

	return true;
}

boolean auto_sausageEatEmUp(int maxToEat)
{
	if(in_tcrs()) return false;

	if(!canEat($item[magical sausage]))
	{
		return false;
	}

	// if maxToEat is 0, eat as many sausages as possible while respecting the reserve
	boolean noMP = my_class() == $class[Vampyre];
	int sausage_reserve_size = noMP ? 0 : 3;
	if (maxToEat == 0)
	{
		maxToEat = auto_sausageLeftToday();
	}
	else
	{
		sausage_reserve_size = 0;
	}

	if(item_amount($item[magical sausage]) <= sausage_reserve_size || get_property("auto_saveMagicalSausage").to_boolean())
		return false;

	if(auto_sausageLeftToday() <= 0)
		return false;

	int originalMp = my_maxmp();
	if(!noMP)
	{
		auto_log_info("We're gonna slurp up some sausage, let's make sure we have enough max mp", "blue");
		cli_execute("checkpoint");
		maximize("mp,-tie", false);
	}
	// I could optimize this a little more by eating more sausage at once if you have enough max mp...
	// but meh.
	while(maxToEat > 0 && item_amount($item[magical sausage]) > sausage_reserve_size)
	{
		if(auto_sausageLeftToday() <= 0)
			break;
		if(!noMP)
		{
			int desiredMp = max(my_maxmp() - 999, 0);
			int mpToBurn = max(my_mp() - desiredMp, 0);
			if(mpToBurn > 0)
				cli_execute("burn " + mpToBurn);
		}
		if(!eat(1, $item[magical sausage]))
		{
			auto_log_warning("Somehow failed to eat a sausage! What??", "red");
			return false;
		}
		maxToEat--;
	}

	// burn any mp that'll go away when equipment switches back
	if(!noMP)
	{
		int mpToBurn = max(my_mp() - originalMp, 0);
		if(mpToBurn > 0)
			cli_execute("burn " + mpToBurn);
		cli_execute("outfit checkpoint");
	}

	return true;
}

boolean auto_sausageEatEmUp() {
	return auto_sausageEatEmUp(0);
}

boolean auto_sausageGoblin()
{
	return auto_sausageGoblin($location[none], "");
}

boolean auto_sausageGoblin(location loc)
{
	return auto_sausageGoblin(loc, "");
}

boolean auto_sausageGoblin(location loc, string option)
{
	// Sausage Goblins have super low encounter priority so they will be overriden
	// by all sorts stuff like superlikelies, wanderers and semi-rares.
	// The good news is, being overridden just means adventure there again to get it

	if(!possessEquipment($item[Kramco Sausage-o-Matic&trade;]))
	{
		return false;
	}

	// My (Malibu Stacey) and Ezandora's spading appears to guarantee the first
	// 7 sausage goblins using a formula of 3n+1 adventures since the previous.
	// After that, you're on your own (hey it's better than nothing).
	// Also that doesn't apply to the first goblin, it's always 100%.
	int sausageFights = get_property("_sausageFights").to_int();
	if (sausageFights >= 7)
	{
		return false;
	}

	int currentGoblinCeiling = (3 * (sausageFights + 1)) + 1;
	if (sausageFights > 0 && (total_turns_played() - get_property("_lastSausageMonsterTurn").to_int()) < currentGoblinCeiling)
	{
		return false;
	}

	if(loc == $location[none])
	{
		return true;
	}

	autoEquip($item[Kramco Sausage-o-Matic&trade;]);
	return autoAdv(1, loc, option);
}

boolean pirateRealmAvailable()
{
	if(!is_unrestricted($item[PirateRealm membership packet]))
	{
		return false;
	}
	if((get_property("prAlways").to_boolean() || get_property("_prToday").to_boolean()))
	{
		return true;
	}
	return false;
}

boolean LX_unlockPirateRealm()
{
	if(!pirateRealmAvailable())                       return false;
	if(possessEquipment($item[PirateRealm eyepatch])) return false;
	if(my_adventures() < 40)                          return false;

	visit_url("place.php?whichplace=realm_pirate&action=pr_port");
	return true;
}

boolean auto_saberChoice(string choice)
{
	if(!is_unrestricted($item[Fourth of May Cosplay Saber]))
	{
		return false;
	}
	if(!possessEquipment($item[Fourth of May Cosplay Saber]))
	{
		return false;
	}
	if(get_property("_saberMod").to_int() != 0)
	{
		return false;
	}

	int choiceNum = 5; // Maybe Later
	switch(choice)
	{
	case "mp regen":
	case "mp":
		choiceNum = 1;
		break;
	case "ml":
	case "monster level":
		choiceNum = 2;
		break;
	case "res":
	case "resistance":
		choiceNum = 3;
		break;
	case "fam":
	case "fam weight":
	case "familiar weight":
	case "weight":
		choiceNum = 4;
		break;
	}

	string page = visit_url("main.php?action=may4", false);
	page = visit_url("choice.php?pwd=&whichchoice=1386&option=" + choiceNum);
	return true;
}

boolean auto_saberDailyUpgrade(int day)
{
	if (isActuallyEd())
	{
		return auto_saberChoice("mp");
	}

	if(day == 1)
	{
		return auto_saberChoice("ml");
	}
	else
	{
		return auto_saberChoice("res");
	}

	return false;
}

monster auto_saberCurrentMonster()
{
	if (get_property("_saberForceMonsterCount") == "0")
	{
		return $monster[none];
	}
	return get_property("_saberForceMonster").to_monster();
}

/* Out-of-combat Saber check: doesn't check that it's equipped
 */
int auto_saberChargesAvailable()
{
	if(!is_unrestricted($item[Fourth of May cosplay saber kit]))
	{
		return 0;
	}
	if(!possessEquipment($item[Fourth of May cosplay saber]))
	{
		return 0;
	}
	return (5 - get_property("_saberForceUses").to_int());
}

string auto_combatSaberBanish()
{
	set_property("_auto_saberChoice", 1);
	return "skill " + $skill[Use the Force];
}

string auto_combatSaberCopy()
{
	set_property("_auto_saberChoice", 2);
	return "skill " + $skill[Use the Force];
}

string auto_combatSaberYR()
{
	set_property("_auto_saberChoice", 3);
	return "skill " + $skill[Use the Force];
}

string auto_spoonGetDesiredSign()
{
	string spoonsign = get_property("auto_spoonsign").to_lower_case();

	string statSign(string musc, string myst, string mox)
	{
		switch(my_primestat())
		{
			case $stat[Muscle]:
				return musc;
			case $stat[Mysticality]:
				return myst;
			case $stat[Moxie]:
				return mox;
			default:
				abort("Invalid mainstat, what?");
				return "butts"; // needed or mafia complains about missing return value
		}
	}
	// coerce spoonsign to be one of the nine signs, instead of shorthands
	switch(spoonsign)
	{
		case "knoll":
			return statSign("mongoose", "wallaby", "vole");
		case "canadia":
			return statSign("platypus", "opossum", "marmot");
		case "gnomad":
			return statSign("wombat", "blender", "packrat");
		case "mongoose":
		case "wallaby":
		case "vole":
		case "platypus":
		case "opossum":
		case "marmot":
		case "wombat":
		case "blender":
		case "packrat":
			return spoonsign;
		// a couple extra alternate labels
		case "clover":
			return "marmot";
		case "famweight":
		case "weight":
		case "familiar weight":
		case "familiar":
		case "fam":
			return "platypus";
		case "food":
			return "opossum";
		case "booze":
			return "blender";
		default:
			// spoonsign is invalid or none/false/whatever to say don't do this
			return "";
	}
}

void auto_spoonTuneConfirm()
{
	if(!possessEquipment($item[hewn moon-rune spoon]) || !auto_is_valid($item[hewn moon-rune spoon]))
	{
		// couldn't change signs if we wanted to
		return;
	}

	if(get_property("auto_spoonconfirmed").to_int() == my_ascensions())
	{
		return;
	}

	string spoonsign = auto_spoonGetDesiredSign();
	if(spoonsign == "")
	{
		// the user doesn't want to change signs
		return;
	}

	if(user_confirm("You're currently set to change signs to " + spoonsign + " after wrapping up your business in your current sign. Do you want to interrupt the script to go change that? Will default to 'No' in 15 seconds.", 15000, false))
	{
		abort("Alright, please go change auto_spoonsign via the autoscend relay script and then rerun.");
	}
	else
	{
		set_property("auto_spoonconfirmed", my_ascensions());
	}
}

boolean auto_spoonReadyToTuneMoon()
{
	if(!possessEquipment($item[hewn moon-rune spoon]) || !auto_is_valid($item[hewn moon-rune spoon]))
	{
		// need a valid spoon to change moon signs
		return false;
	}

	string currsign = my_sign().to_lower_case();
	string spoonsign = auto_spoonGetDesiredSign();

	if(spoonsign == "")
	{
		// the user doesn't want to change signs automatically
		return false;
	}

	if(spoonsign == currsign)
	{
		// we'd just be changing to the same sign, so do nothing
		return false;
	}

	boolean isKnoll = $strings[mongoose, wallaby, vole] contains currsign;
	boolean isCanadia = $strings[platypus, opossum, marmot] contains currsign;
	boolean isGnomad = $strings[wombat, blender, packrat] contains currsign;

	boolean toKnoll = $strings[mongoose, wallaby, vole] contains spoonsign;
	boolean toCanadia = $strings[platypus, opossum, marmot] contains spoonsign;
	boolean toGnomad = $strings[wombat, blender, packrat] contains spoonsign;

	if(!toKnoll && !toCanadia && !toGnomad)
	{
		abort("Something weird is going on with auto_spoonsign. It's not an invalid/blank value, but also not a knoll, canadia, or gnomad sign? This is impossible.");
	}

	if(my_sign() == "Vole" && (get_property("cyrptAlcoveEvilness") > 26 || get_property("questL07Cyrptic") == "unstarted"))
	{
		// we want to stay vole long enough to do the alcove, since the initiative helps
		return false;
	}

	if(isKnoll && !toKnoll)
	{
		if(get_property("lastDesertUnlock").to_int() < my_ascensions())
		{
			// we want to get the meatcar via the knoll store
			return false;
		}
		if((auto_get_campground() contains $item[Asdon Martin Keyfob]) && is_unrestricted($item[Asdon Martin Keyfob]))
		{
			// we want to get the bugbear outfit before switching away for easy bread access
			if(!buyUpTo(1, $item[bugbear beanie]) || !buyUpTo(1, $item[bugbear bungguard]))
			{
				return false;
			}
		}
	}

	if(isCanadia && !toCanadia && item_amount($item[logging hatchet]) == 0)
	{
		// want to make sure we've grabbed the logging hatchet before switching away from canadia
		return false;
	}

	if(isGnomad && !toGnomad && auto_is_valid($skill[Torso Awaregness]) && !auto_have_skill($skill[Torso Awaregness]))
	{
		// we want to know about our torso before swapping away from gnomad signs
		return false;
	}

	if(currsign == "opossum" && my_fullness() == 0)
	{
		// we want to eat something before swapping away from opossum
		return false;
	}

	if(currsign == "blender" && my_inebriety() == 0)
	{
		// we want to drink something before swapping away from blender
		return false;
	}

	return true;
}

boolean auto_spoonTuneMoon()
{
	if(!auto_spoonReadyToTuneMoon())
	{
		return false;
	}

	slot wasspoon = $slot[none];
	foreach sl in $slots[acc1, acc2, acc3]
	{
		if(equipped_item(sl) == $item[hewn moon-rune spoon])
		{
			equip(sl, $item[none]);
			wasspoon = sl;
			break;
		}
	}

	string spoonsign = auto_spoonGetDesiredSign();
	int signnum = 0;
	foreach sign in $strings[mongoose, wallaby, vole, platypus, opossum, marmot, wombat, blender, packrat]
	{
		++signnum;
		if(sign == spoonsign)
		{
			break;
		}
	}

	string res = visit_url('inv_use.php?whichitem=10254&pwd=' + my_hash());
	boolean cantune = (res.index_of("You can't figure out the angle to see the moon's reflection in the spoon anymore.") == -1);
	if(cantune)
	{
		auto_log_info("Changing signs to " + spoonsign + ", sign #" + signnum, "blue");
		visit_url('inv_use.php?whichitem=10254&pwd&doit=96&whichsign=' + signnum, true);
		cli_execute("refresh all");
	}
	else
	{
		auto_log_warning("Tried to change signs to " + spoonsign + ", but moon has already been tuned", "red");
	}

	if(wasspoon != $slot[none])
	{
		equip(wasspoon, $item[hewn moon-rune spoon]);
	}

	return cantune;
}

boolean auto_beachCombAvailable()
{
	if(!is_unrestricted($item[Beach Comb Box]) || !possessEquipment($item[Beach Comb]))
	{
		return false;
	}

	return true;
}

int auto_beachCombHeadNumFrom(string name)
{
	int head;
	switch (name.to_lower_case())
	{
		case "hot":
			head = 1; break;
		case "cold":
			head = 2; break;
		case "stench":
			head = 3; break;
		case "spooky":
			head = 4; break;
		case "sleaze":
			head = 5; break;
		case "muscle":
			head = 6; break;
		case "mysticality":
		case "myst":
			head = 7; break;
		case "moxie":
			head = 8; break;
		case "init":
		case "initiative":
			head = 9; break;
		case "weight":
		case "familiar":
			head = 10; break;
		case "exp":
		case "stats":
			head = 11; break;
	}
	return head;
}

boolean auto_canBeachCombHead(string name) {
	if (!auto_beachCombAvailable())
	{
	   return false;
	}
	int head = auto_beachCombHeadNumFrom(name);
	foreach _, usedHead in (get_property("_beachHeadsUsed").split_string(","))
	{
		if (to_string(head) == usedHead) { return false; }
	}
	return get_property("_freeBeachWalksUsed").to_int() < 11;
}

boolean auto_beachCombHead(string name)
{
	if(!auto_beachCombAvailable())   return false;
	if(!auto_canBeachCombHead(name)) return false;

	return cli_execute("beach head " + auto_beachCombHeadNumFrom(name));
}

int auto_beachCombFreeUsesLeft(){
	if(!auto_beachCombAvailable() || get_property("_freeBeachWalksUsed").to_int() >= 11){
		return 0;
	}
	return 11 - get_property("_freeBeachWalksUsed").to_int();
}

boolean auto_beachUseFreeCombs() {
	if(!auto_beachCombAvailable()) { return false; }
	if(get_property("_freeBeachWalksUsed").to_int() >= 11) { return false; }
	cli_execute("CombBeach free");
	return true;
}

// place.php?whichplace=campaway
boolean auto_campawayAvailable()
{
	return is_unrestricted($item[Distant Woods Getaway Brochure]) && get_property("getawayCampsiteUnlocked").to_boolean();
}

boolean auto_campawayGrabBuffs()
{
	if(!auto_campawayAvailable())
	{
		return false;
	}

	if(!get_property("_auto_contributedCampaway").to_boolean() && item_amount($item[campfire smoke]) + creatable_amount($item[campfire smoke]) > 0)
	{
		if(item_amount($item[campfire smoke]) == 0)
		{
			create(1, $item[campfire smoke]);
		}
		string message = "why is my computer on fire?";
		string temp = visit_url("inv_use.php?pwd=&which=3&whichitem=" + $item[campfire smoke].to_int());
		temp = visit_url("choice.php?pwd=&whichchoice=1394&option=1&message=" + message);
		set_property("_auto_contributedCampaway", true);
	}

	int lim = 4 - get_property("_campAwaySmileBuffs").to_int() - get_property("_campAwayCloudBuffs").to_int();
	for (int i=0; i < lim; i++)
	{
		visit_url("place.php?whichplace=campaway&action=campaway_sky");
	}
	return true;
}

int auto_pillKeeperUses()
{
	if (0 == equipmentAmount($item[Eight Days a Week Pill Keeper])
		|| (!is_unrestricted($item[Unopened Eight Days a Week Pill Keeper])))
	{
		return 0;
	}
	return spleen_left()/3 + 1 - get_property("_freePillKeeperUsed").to_boolean().to_int();
}

boolean auto_pillKeeperFreeUseAvailable()
{
	return !get_property("_freePillKeeperUsed").to_boolean();
}

boolean auto_pillKeeperAvailable()
{
	return auto_pillKeeperUses() > 0;
}

boolean auto_pillKeeper(int pill)
{
	if(auto_pillKeeperUses() == 0) return false;
	auto_log_info("Using pill keeper: consuming pill #" + pill, "blue");
	string page = visit_url("main.php?eowkeeper=1", false);
	page = visit_url("choice.php?pwd=&whichchoice=1395&pwd&option=" + pill, true);
	return true;
}

boolean auto_pillKeeper(string pill)
{
	int pillId;
	switch(pill.to_lower_case())
	{
	case "yr":
	case "yellow ray":
		pillID = 1; break;
	case "potion":
		pillID = 2; break;
	case "noncombat":
	case "bell":
		pillID = 3; break;
	case "resistance":
		pillID = 4; break;
	case "stat":
		pillID = 5; break;
	case "weight":
	case "fam weight":
		pillID = 6; break;
	case "semirare":
		pillID = 7; break;
	case "random":
		pillID = 8; break;
	default:
		abort("invalid argument to auto_pillKeeper: \"" + pill + "\"");
	}

	return auto_pillKeeper(pillId);
}
