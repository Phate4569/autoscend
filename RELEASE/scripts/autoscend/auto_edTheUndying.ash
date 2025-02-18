script "auto_edTheUndying.ash"

boolean isActuallyEd()
{
	return (my_class() == $class[Ed] || my_path() == "Actually Ed the Undying");
}

int ed_spleen_limit()
{
	int limit = 5;
	foreach sk in $skills[Extra Spleen, Another Extra Spleen, Yet Another Extra Spleen, Still Another Extra Spleen, Just One More Extra Spleen, Okay Seriously\, This is the Last Spleen]
	{
		if(have_skill(sk))
		{
			limit += 5;
		}
	}
	return limit;
}

void ed_initializeSettings()
{
	if (isActuallyEd())
	{
		set_property("auto_100familiar", $familiar[Egg Benedict]);
		set_property("auto_crackpotjar", "done");
		set_property("auto_cubeItems", false);
		set_property("auto_day1_dna", "finished");
		set_property("auto_getBeehive", false);
		set_property("auto_getStarKey", false);
		set_property("auto_grimstoneFancyOilPainting", false);
		set_property("auto_grimstoneOrnateDowsingRod", false);
		set_property("auto_holeinthesky", false);
		set_property("auto_lashes", "");
		set_property("auto_needLegs", false);
		set_property("auto_renenutet", "");
		set_property("auto_servantChoice", "");
		set_property("auto_useCubeling", false);
		set_property("auto_wandOfNagamar", false);

		set_property("auto_edSkills", -1);
		set_property("auto_chasmBusted", false);
		set_property("auto_renenutetBought", 0);

		set_property("auto_edCombatCount", 0);
		set_property("auto_edCombatRoundCount", 0);

		set_property("choiceAdventure1002", 1);
		set_property("choiceAdventure1023", "");
		set_property("desertExploration", 100);
		set_property("nsTowerDoorKeysUsed", "Boris's key,Jarlsberg's key,Sneaky Pete's key,Richard's star key,skeleton key,digital key");
		set_property("auto_delayHauntedKitchen", true);
	}
}

void ed_initializeSession()
{
	if (isActuallyEd())
	{
		if(get_property("hpAutoRecoveryItems") != "linen bandages")
		{
			set_property("auto_hpAutoRecoveryItems", get_property("hpAutoRecoveryItems"));
			set_property("auto_hpAutoRecovery", get_property("hpAutoRecovery"));
			set_property("auto_hpAutoRecoveryTarget", get_property("hpAutoRecoveryTarget"));
			set_property("hpAutoRecoveryItems", "linen bandages");
			set_property("hpAutoRecovery", 0.0);
			set_property("hpAutoRecoveryTarget", 0.1);
		}
	}
}

void ed_terminateSession()
{
	if (isActuallyEd())
	{
		if(get_property("hpAutoRecoveryItems") == "linen bandages")
		{
			set_property("hpAutoRecoveryItems", get_property("auto_hpAutoRecoveryItems"));
			set_property("hpAutoRecovery", get_property("auto_hpAutoRecovery"));
			set_property("hpAutoRecoveryTarget", get_property("auto_hpAutoRecoveryTarget"));
			set_property("auto_hpAutoRecoveryItems", "");
			set_property("auto_hpAutoRecovery", 0.0);
			set_property("auto_hpAutoRecoveryTarget", 0.0);
		}
	}
}

void ed_initializeDay(int day)
{
	if (!isActuallyEd())
	{
		return;
	}

	set_property("auto_renenutetBought", 0);

	if (!get_property("breakfastCompleted").to_boolean() && day != 1)
	{
		cli_execute("breakfast");
	}

	if(day == 1)
	{
		if(get_property("auto_day_init").to_int() < 1)
		{
			if(item_amount($item[transmission from planet Xi]) > 0)
			{
				use(1, $item[transmission from planet xi]);
			}
			if(item_amount($item[Xiblaxian holo-wrist-puter simcode]) > 0)
			{
				use(1, $item[Xiblaxian holo-wrist-puter simcode]);
			}

			visit_url("tutorial.php?action=toot");
			use(item_amount($item[Letter to Ed the Undying]), $item[Letter to Ed the Undying]);
			use(item_amount($item[Pork Elf Goodies Sack]), $item[Pork Elf Goodies Sack]);
			tootGetMeat();

			equipBaseline();
		}
	}
	else if(day == 2)
	{
		equipBaseline();
		ovenHandle();

		if(get_property("auto_day_init").to_int() < 2)
		{
			if(get_property("auto_dickstab").to_boolean() && chateaumantegna_available())
			{
				boolean[item] furniture = chateaumantegna_decorations();
				if(!furniture[$item[Ceiling Fan]])
				{
					chateaumantegna_buyStuff($item[Ceiling Fan]);
				}
			}

			if(item_amount($item[gym membership card]) > 0)
			{
				use(1, $item[gym membership card]);
			}

			if(item_amount($item[Seal Tooth]) == 0)
			{
				acquireHermitItem($item[Seal Tooth]);
			}
			pullXWhenHaveY($item[hand in glove], 1, 0);
			pullXWhenHaveY($item[blackberry galoshes], 1, 0);
			pullXWhenHaveY(whatHiMein(), 1, 0);
		}
	}

	// ed overrides normal day initialization
	set_property("auto_day_init", day);
}

boolean L13_ed_towerHandler()
{
	if (!isActuallyEd())
	{
		return false;
	}
	if(get_property("auto_sorceress") != "")
	{
		return false;
	}
	if(item_amount($item[Thwaitgold Scarab Beetle Statuette]) > 0)
	{
		set_property("auto_sorceress", "finished");
		council();
		return true;
	}

	council();
	if(contains_text(visit_url("place.php?whichplace=nstower"), "ns_10_sorcfight"))
	{
		auto_log_info("We found the jerkwad!! Revenge!!!!!", "blue");

		string page = "place.php?whichplace=nstower&action=ns_10_sorcfight";
		autoAdvBypass(page, $location[Noob Cave]);

		if(item_amount($item[Thwaitgold Scarab Beetle Statuette]) > 0)
		{
			set_property("auto_sorceress", "finished");
			council();
		}
		return true;
	}
	else
	{
		if(haveAnyIotmAlternativeRestSiteAvailable() && doFreeRest())
		{
			cli_execute("scripts/autoscend/auto_post_adv.ash");
			return true;
		}
		auto_log_warning("Please check your quests, but you might just not be at level 13 yet in order to continue.", "red");
		if((my_level() < 13) && elementalPlanes_access($element[spooky]))
		{
			boolean tryJungle = false;
			if(have_effect($effect[Jungle Juiced]) > 0)
			{
				tryJungle = true;
			}

			if(((my_inebriety() + 1) < inebriety_limit()) && (item_amount($item[Coinspiracy]) > 0) && (have_effect($effect[Jungle Juiced]) == 0))
			{
				buyUpTo(1, $item[Jungle Juice]);
				autoDrink(1, $item[Jungle Juice]);
				tryJungle = true;
			}

			buffMaintain($effect[Experimental Effect G-9], 0, 1, 1);
			if(my_primestat() == $stat[Mysticality])
			{
				buffMaintain($effect[Perspicacious Pressure], 0, 1, 1);
				buffMaintain($effect[Glittering Eyelashes], 0, 1, 1);
				buffMaintain($effect[Erudite], 0, 1, 1);
			}

			if(tryJungle)
			{
				autoAdv(1, $location[The Deep Dark Jungle]);
			}
			else
			{
				if(item_amount($item[Personal Ventilation Unit]) > 0)
				{
					autoEquip($slot[acc2], $item[Personal Ventilation Unit]);
				}
				autoAdv(1, $location[The Secret Government Laboratory]);
			}
			return true;
		}
		else if((my_level() < 13) && elementalPlanes_access($element[stench]))
		{
			autoAdv(1, $location[Pirates of the Garbage Barges]);
			return true;
		}
		else
		{
			auto_log_info("We must be missing a sidequest. We can't find the jerk adventurer. Must pretend we are alive...", "blue");
		}
	}

	return false;
}

boolean L13_ed_councilWarehouse()
{
	if (!isActuallyEd())
	{
		return false;
	}
	if(get_property("auto_sorceress") != "finished")
	{
		return false;
	}

	if(item_amount($item[7965]) == 0)
	{
		autoAdv(1, $location[The Secret Council Warehouse]);
	}
	else
	{
		//Complete: Should not get here though.
		abort("Tried to adventure in the Council Warehouse after finding theMcMuffin.");
		return false;
	}
	while((item_amount($item[Warehouse Map Page]) > 0) && (item_amount($item[Warehouse Inventory Page]) > 0))
	{
		use(item_amount($item[Warehouse Inventory Page]), $item[Warehouse Inventory Page]);
	}
	if(get_property("lastEncounter") == "You Found It!")
	{
		council();
		auto_log_info("McMuffin is found!", "blue");
		auto_log_info("Ed Combats: " + get_property("auto_edCombatCount"), "blue");
		auto_log_info("Ed Combat Rounds: " + get_property("auto_edCombatRoundCount"), "blue");

		return false;
	}
	return true;
}

boolean handleServant(servant who)
{
	if (!isActuallyEd())
	{
		return false;
	}
	if(who == $servant[none])
	{
		#use_servant($servant[none]);
		return false;
	}
	if(!have_servant(who))
	{
		return false;
	}
	if(my_servant() != who)
	{
		return use_servant(who);
	}
	return true;
}

boolean handleServant(string name)
{
	if (!isActuallyEd())
	{
		return false;
	}
	name = to_lower_case(name);
	if((name == "priest") || (name == "ka"))
	{
		return handleServant($servant[Priest]);
	}
	if((name == "maid") || (name == "meat"))
	{
		return handleServant($servant[Maid]);
	}
	if((name == "belly-dancer") || (name == "belly") || (name == "dancer") || (name == "bellydancer") || (name == "pickpocket") || (name == "steal"))
	{
		return handleServant($servant[Belly-Dancer]);
	}
	if((name == "cat") || (name == "item") || (name == "itemdrop"))
	{
		return handleServant($servant[Cat]);
	}
	if((name == "bodyguard") || (name == "block"))
	{
		return handleServant($servant[Bodyguard]);
	}
	if((name == "scribe") || (name == "stats") || (name == "stat"))
	{
		return handleServant($servant[Scribe]);
	}
	if((name == "assassin") || (name == "stagger"))
	{
		return handleServant($servant[Assassin]);
	}
	if(name == "none")
	{
		return handleServant($servant[None]);
	}
	return false;
}

boolean ed_doResting()
{
	if (isActuallyEd())
	{
		int maxBuff = 675 - my_turncount();
		while(haveAnyIotmAlternativeRestSiteAvailable() && doFreeRest())
		{
			buffMaintain($effect[Purr of the Feline], 30, 3, maxBuff);
			buffMaintain($effect[Hide of Sobek], 30, 3, maxBuff);
			buffMaintain($effect[Bounty of Renenutet], 30, 3, maxBuff);
			buffMaintain($effect[Prayer of Seshat], 15, 3, maxBuff);
			buffMaintain($effect[Wisdom of Thoth], 15, 3, maxBuff);
			buffMaintain($effect[Power of Heka], 15, 3, maxBuff);
		}
		return true;
	}
	return false;
}

boolean ed_buySkills()
{
	if (!isActuallyEd())
	{
		return false;
	}
	if(my_level() <= get_property("auto_edSkills").to_int())
	{
		return false;
	}
	int possEdPoints = 0;

	string page = visit_url("place.php?whichplace=edbase&action=edbase_book");
	matcher my_skillPoints = create_matcher("You may memorize (\\d\+) more page", page);
	if(my_skillPoints.find())
	{
		int skillPoints = to_int(my_skillPoints.group(1));
		auto_log_info("Skill points found: " + skillPoints);
		possEdPoints = skillPoints - 1;
		if(have_skill($skill[Bounty of Renenutet]) && have_skill($skill[Wrath of Ra]) && have_skill($skill[Curse of Stench]))
		{
			skillPoints = 0;
		}
		while(skillPoints > 0)
		{
			skillPoints = skillPoints - 1;
			int skillid = 20;
			if(!have_skill($skill[Curse of Vacation]))
			{
				skillid = 19;
			}
			if(!have_skill($skill[Curse of Fortune]))
			{
				skillid = 18;
			}
			if(!have_skill($skill[Curse of Heredity]))
			{
				skillid = 17;
			}
			if(!have_skill($skill[Curse of Yuck]))
			{
				skillid = 16;
			}
			if(!have_skill($skill[Curse of Indecision]))
			{
				skillid = 15;
			}
			if(!have_skill($skill[Curse of the Marshmallow]))
			{
				skillid = 14;
			}
			if(!have_skill($skill[Wrath of Ra]))
			{
				skillid = 13;
			}
			if(!have_skill($skill[Bounty of Renenutet]))
			{
				skillid = 6;
			}
			if(!have_skill($skill[Shelter of Shed]))
			{
				skillid = 5;
			}
			if(!have_skill($skill[Blessing of Serqet]))
			{
				skillid = 4;
			}
			if(!have_skill($skill[Hide of Sobek]))
			{
				skillid = 3;
			}
			if(!have_skill($skill[Power of Heka]))
			{
				skillid = 2;
			}
			if(!have_skill($skill[Lash of the Cobra]))
			{
				skillid = 12;
			}
			if(!have_skill($skill[Purr of the Feline]))
			{
				skillid = 11;
			}
			if(!have_skill($skill[Storm of the Scarab]))
			{
				skillid = 10;
			}
			if(!have_skill($skill[Roar of the Lion]))
			{
				skillid = 9;
			}
			if(!have_skill($skill[Howl of the Jackal]))
			{
				skillid = 8;
			}
			if(!have_skill($skill[Wisdom of Thoth]))
			{
				skillid = 1;
			}
			if(!have_skill($skill[Fist of the Mummy]))
			{
				skillid = 7;
			}
			if(!have_skill($skill[Prayer of Seshat]))
			{
				skillid = 0;
			}

			visit_url("choice.php?pwd&skillid=" + skillid + "&option=1&whichchoice=1051");
		}
	}

	page = visit_url("place.php?whichplace=edbase&action=edbase_door");
	matcher my_imbuePoints = create_matcher("Impart Wisdom unto Current Servant ..100xp, (\\d\+) remain.", page);
	int imbuePoints = 0;
	if(my_imbuePoints.find())
	{
		imbuePoints = to_int(my_imbuePoints.group(1));
		auto_log_info("Imbuement points found: " + imbuePoints);
	}
	possEdPoints += imbuePoints;

	if(possEdPoints > get_property("edPoints").to_int())
	{
		set_property("edPoints", possEdPoints);
	}

	page = visit_url("place.php?whichplace=edbase&action=edbase_door");
	matcher my_servantPoints = create_matcher("You may release (\\d\+) more servant", page);
	if(my_servantPoints.find())
	{
		int servantPoints = to_int(my_servantPoints.group(1));
		auto_log_info("Servants points found: " + servantPoints);
		while(servantPoints > 0)
		{
			servantPoints -= 1;
			int sid = -1;
			if(!have_servant($servant[Assassin]))
			{
				sid = 7;
			}
			if(!have_servant($servant[Bodyguard]))
			{
				sid = 4;
			}
			if(!have_servant($servant[Belly-Dancer]))
			{
				sid = 2;
			}
			if(!have_servant($servant[Scribe]))
			{
				sid = 5;
			}
			if(!have_servant($servant[Maid]))
			{
				sid = 3;
				if((my_level() >= 9) && (imbuePoints > 5) && !have_servant($servant[Scribe]))
				{
					#If we are at the third servant and have enough imbues, get the Scribe instead.
					sid = 5;
				}
			}
			if(!have_servant($servant[Cat]))
			{
				sid = 1;
			}
			if(!have_servant($servant[Priest]))
			{
				sid = 6;
			}
			if(sid != -1)
			{
				visit_url("choice.php?whichchoice=1053&option=3&pwd&sid=" + sid);
			}
		}
	}

	if((imbuePoints > 0) && (my_level() >= 3))
	{
		visit_url("charsheet.php");

		servant current = my_servant();
		while(imbuePoints > 0)
		{
			servant tryImbue = $servant[none];

			if(get_property("auto_dickstab").to_boolean())
			{
				if(have_servant($servant[Priest]) && ($servant[Priest].experience < 81))
				{
					tryImbue = $servant[Priest];
				}
				else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 441))
				{
					tryImbue = $servant[Scribe];
				}
				else if(have_servant($servant[Maid]) && ($servant[Maid].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Maid];
				}
			}
			else
			{
				if(have_servant($servant[Priest]) && ($servant[Priest].experience < 81))
				{
					tryImbue = $servant[Priest];
				}
				else if(have_servant($servant[Cat]) && ($servant[Cat].experience < 199))
				{
					tryImbue = $servant[Cat];
				}
				else if(have_servant($servant[Maid]) && ($servant[Maid].experience < 199))
				{
					tryImbue = $servant[Maid];
				}
				else if(have_servant($servant[Belly-Dancer]) && ($servant[Belly-Dancer].experience < 341))
				{
					tryImbue = $servant[Belly-Dancer];
				}
				else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 99))
				{
					tryImbue = $servant[Scribe];
				}
				else if(have_servant($servant[Maid]) && ($servant[Maid].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Maid];
				}
				else if(have_servant($servant[Cat]) && ($servant[Cat].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Cat];
				}
				else if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 441) && (my_level() >= 12))
				{
					tryImbue = $servant[Scribe];
				}
				else
				{
					if((imbuePoints > 4) && (my_level() >= 9))
					{
						if(have_servant($servant[Scribe]) && ($servant[Scribe].experience < 341))
						{
							tryImbue = $servant[Scribe];
						}
					}
				}
			}

			if(tryImbue != $servant[none])
			{
				if(handleServant(tryImbue))
				{
					auto_log_info("Trying to imbue " + tryImbue + " with glorious wisdom!!", "green");
					visit_url("choice.php?whichchoice=1053&option=5&pwd=");
				}
			}
			imbuePoints = imbuePoints - 1;
		}
		handleServant(current);
	}

	set_property("auto_edSkills", my_level());
	return true;
}

boolean ed_eatStuff()
{
	if (!isActuallyEd())
	{
		return false;
	}

	// fill up on Mummified Beef Haunches as they are Ed's main source of turn-gen
	int canEat = min((spleen_left() / 5), item_amount($item[Mummified Beef Haunch]));
	if (canEat > 0)
	{
		autoChew(canEat, $item[Mummified Beef Haunch]);
	}

	// ideally, we should only need the above in this function as the code below 
	// should be handled by consumeStuff();

	// expose semi-rare counters
	if (!contains_text(get_counters("Fortune Cookie", 0, 200), "Fortune Cookie"))
	{
		boolean shouldEatCookie = (my_meat() >= npc_price($item[Fortune Cookie]) && fullness_left() > 0 && my_level() < 12);
		if (inebriety_left() > 0)
		{
			shouldEatCookie = (shouldEatCookie && !autoDrink(1, $item[Lucky Lindy]));
		}
		if (shouldEatCookie)
		{
			buyUpTo(1, $item[Fortune Cookie], npc_price($item[Fortune Cookie]));
			autoEat(1, $item[Fortune Cookie]);
		}
	}

	// use knapsack algorithm implementation to fill stomach and liver
	// once we have less than 3 adventures left and a full spleen (and all spleen upgrades)
	if (spleen_limit() == 35 && spleen_left() == 0 && my_adventures() < 3)
	{
		if (fullness_left() > 0)
		{
			return auto_knapsackAutoConsume("eat", false);
		}
		if (inebriety_left() > 0)
		{
			return auto_knapsackAutoConsume("drink", false);
		}
	}

	return true;
}

skill ed_nextUpgrade()
{
	int coins = item_amount($item[Ka Coin]);
	int canEat = (spleen_limit() - my_spleen_use()) / 5;

	if (!have_skill($skill[Upgraded Legs]) && get_property("auto_needLegs").to_boolean())
	{
		return $skill[Upgraded Legs]; // 10 Ka
	}
	else if (!have_skill($skill[Extra Spleen]) && canEat < 1)
	{
		return $skill[Extra Spleen]; // 5 Ka
	}
	else if (!have_skill($skill[Another Extra Spleen]) && canEat < 1)
	{
		return $skill[Another Extra Spleen]; // 10 Ka
	}
	else if (!have_skill($skill[Replacement Stomach]))
	{
		return $skill[Replacement Stomach]; // 30 Ka
	}
	else if (!have_skill($skill[Upgraded Legs]))
	{
		return $skill[Upgraded Legs]; // 10 Ka
	}
	else if (!have_skill($skill[More Legs]))
	{
		return $skill[More Legs]; // 20 Ka
	}
	else if (!have_skill($skill[Yet Another Extra Spleen]) && have_skill($skill[Another Extra Spleen]))
	{
		return $skill[Yet Another Extra Spleen]; // 15 Ka
	}
	else if (!have_skill($skill[Still Another Extra Spleen]))
	{
		return $skill[Still Another Extra Spleen]; // 20 Ka
	}
	else if (!have_skill($skill[Just One More Extra Spleen]))
	{
		return $skill[Just One More Extra Spleen]; // 25 Ka
	}
	else if (!have_skill($skill[Replacement Liver]))
	{
		return $skill[Replacement Liver]; // 30 Ka
	}
	else if (!have_skill($skill[Elemental Wards]))
	{
		return $skill[Elemental Wards]; // 10 Ka
	}
	else if (!have_skill($skill[Okay Seriously, This is the Last Spleen]))
	{
		return $skill[Okay Seriously, This is the Last Spleen];  // 30 Ka
	}
	else if (!possessEquipment($item[The Crown of Ed the Undying]) && !have_skill($skill[Tougher Skin]))
	{
		return $skill[Tougher Skin];  // 10 Ka
	}
	else if (!have_skill($skill[More Elemental Wards]))
	{
		return $skill[More Elemental Wards]; // 20 Ka
	}
	else if (!have_skill($skill[Even More Elemental Wards]))
	{
		return $skill[Even More Elemental Wards]; // 30 Ka
	}
	else if (!have_skill($skill[Healing Scarabs]) && my_daycount() >= 2)
	{
		return $skill[Healing Scarabs]; // 10 Ka
	}
	else if (!have_skill($skill[Tougher Skin]) && my_daycount() >= 2 && coins >= 50)
	{
		return $skill[Tougher Skin]; // 10 Ka
	}
	else if (!have_skill($skill[Armor Plating]) && my_daycount() >= 2 && coins >= 50)
	{
		return $skill[Armor Plating]; // 10 Ka
	}
	else if (!have_skill($skill[Upgraded Spine]) && my_daycount() >= 2 && coins >= 50)
	{
		return $skill[Upgraded Spine]; // 20 Ka
	}
	else if (!have_skill($skill[Upgraded Arms]) && my_daycount() >= 2 && coins >= 50)
	{
		return $skill[Upgraded Arms]; // 20 Ka
	}
	else if (!have_skill($skill[Arm Blade]) && my_daycount() >= 4 && coins >= 100)
	{
		return $skill[Arm Blade]; // 20 Ka
	}
	else if (!have_skill($skill[Bone Spikes]) && my_daycount() >= 4 && coins >= 100)
	{
		return $skill[Bone Spikes]; // 20 Ka
	}
	return $skill[none];
}

int ed_KaCost(skill upgrade)
{
	static int[skill] kaNeeded = {
		$skill[Extra Spleen]: 5,
		$skill[Another Extra Spleen]: 10,
		$skill[Upgraded Legs]: 10,
		$skill[Tougher Skin]: 10,
		$skill[Armor Plating]: 10,
		$skill[Healing Scarabs]: 10,
		$skill[Elemental Wards]: 10,
		$skill[Yet Another Extra Spleen]: 15,
		$skill[Still Another Extra Spleen]: 20,
		$skill[More Legs]: 20,
		$skill[Upgraded Arms]: 20,
		$skill[Upgraded Spine]: 20,
		$skill[Bone Spikes]: 20,
		$skill[Arm Blade]: 20,
		$skill[More Elemental Wards]: 20,
		$skill[Just One More Extra Spleen]: 25,
		$skill[Replacement Stomach]: 30,
		$skill[Replacement Liver]: 30,
		$skill[Okay Seriously, This is the Last Spleen]: 30,
		$skill[Even More Elemental Wards]: 30
	};
	if (kaNeeded contains upgrade)
	{
		return kaNeeded[upgrade];
	} else {
		return -1;
	}
}

boolean ed_needShop()
{
	if (!isActuallyEd())
	{
		return false;
	}

	if (have_skill($skill[Upgraded Legs]) && get_property("auto_needLegs").to_boolean())
	{
		set_property("auto_needLegs", false);
	}

	int coins = item_amount($item[Ka Coin]);

	if (get_property("auto_needLegs").to_boolean() && coins >= ed_KaCost($skill[Upgraded Legs]))
	{
		return true;
	}

	// check if we need mummified beef haunches
	int canEat = (spleen_limit() - my_spleen_use()) / 5;
	canEat = max(0, canEat - item_amount($item[Mummified Beef Haunch]));
	if (canEat > 0 && coins >= 15)
	{
		return true;
	}

	// check if we need emergency MP
	if (coins >= 1 && my_mp() < mp_cost($skill[Storm Of The Scarab]))
	{
		if (item_amount($item[Holy Spring Water]) < 1 && item_amount($item[Spirit Beer]) < 1 && item_amount($item[Sacramental Wine]) < 1)
		{
			return true;
		}
	}

	// check if we have skills or consumables to buy
	skill nextUpgrade = ed_nextUpgrade();
	int requiredKa = ed_KaCost(nextUpgrade);
	if (canEat < 1 && requiredKa != -1 && coins >= requiredKa)
	{
		return true;
	}
	else if (have_skill($skill[Okay Seriously, This is the Last Spleen]) && canEat < 1)
	{
		if (item_amount($item[Talisman of Renenutet]) < 1 && get_property("auto_renenutetBought").to_int() < 7 && coins >= (7 - get_property("auto_renenutetBought").to_int()))
		{
			return true;
		}
		else if (item_amount($item[Linen Bandages]) < 1 && coins >= 4)
		{
			return true;
		}
		else if (item_amount($item[Holy Spring Water]) < 1 && coins >= 1 && (my_maxmp() - my_mp() < 50))
		{
			return true;
		}
		else if (item_amount($item[Talisman of Horus]) < 1 && coins >= 5)
		{
			return true;
		}
		else if (item_amount($item[Spirit Beer]) < 1 && coins >= 30)
		{
			return true;
		}
		else if ((item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 1 && coins >= 30)
		{
			return true;
		}
		else if (item_amount($item[Sacramental Wine]) < 1 && coins >= 30)
		{
			return true;
		}
	}

	return false;
}

boolean ed_shopping()
{

	int ed_skillID(skill upgrade)
	{
		static int[skill] skillIDs = {
			$skill[Replacement Stomach]: 28,
			$skill[Replacement Liver]: 29,
			$skill[Extra Spleen]: 30,
			$skill[Another Extra Spleen]: 31,
			$skill[Yet Another Extra Spleen]: 32,
			$skill[Still Another Extra Spleen]: 33,
			$skill[Just One More Extra Spleen]: 34,
			$skill[Okay Seriously, This is the Last Spleen]: 35,
			$skill[Upgraded Legs]: 36,
			$skill[Upgraded Arms]: 37,
			$skill[Upgraded Spine]: 38,
			$skill[Tougher Skin]:  39,
			$skill[Armor Plating]: 40,
			$skill[Bone Spikes]: 41,
			$skill[Arm Blade]: 42,
			$skill[Healing Scarabs]: 43,
			$skill[Elemental Wards]: 44,
			$skill[More Elemental Wards]: 45,
			$skill[Even More Elemental Wards]: 46,
			$skill[More Legs]: 48
		};
		if (skillIDs contains upgrade)
		{
			return skillIDs[upgrade];
		} else {
			return -1;
		}
	}

	auto_log_info("Time to shop!", "red");
	wait(1);
	visit_url("choice.php?pwd=&whichchoice=1023&option=1", true);

	if (get_property("auto_breakstone").to_boolean())
	{
		string temp = visit_url("peevpee.php?action=smashstone&pwd&confirm=on", true);
		temp = visit_url("place.php?whichplace=edunder&action=edunder_hippy");
		temp = visit_url("choice.php?pwd&whichchoice=1057&option=1", true);
		set_property("auto_breakstone", false);
	}

	int coins = item_amount($item[Ka Coin]);
	//Handler for low-powered accounts
	if (!have_skill($skill[Upgraded Legs]) && get_property("auto_needLegs").to_boolean())
	{
		if (coins >= 10)
		{
			auto_log_info("Buying Upgraded Legs", "green");
			set_property("auto_needLegs", false);
			visit_url("place.php?whichplace=edunder&action=edunder_bodyshop");
			visit_url("choice.php?pwd&skillid=36&option=1&whichchoice=1052", true);
			visit_url("choice.php?pwd&option=2&whichchoice=1052", true);
			coins -= 10;
		}
		else
		{
			//Prevent other purchases from interrupting us.
			coins = 0;
		}
	}

	// fill spleen with mummified beef haunches.
	int canEat = (ed_spleen_limit() - my_spleen_use()) / 5;
	canEat -= item_amount($item[Mummified Beef Haunch]);
	while (coins >= 15 && canEat > 0)
	{
		visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=428", true);
		auto_log_info("Buying a mummified beef haunch!", "green");
		coins -= 15;
		canEat--;
	}

	// buy emergency MP restores.
	if (!get_property("lovebugsUnlocked").to_boolean() && coins >= 1 && item_amount($item[Holy Spring Water]) == 0 && my_mp() < mp_cost($skill[Storm Of The Scarab]))
	{
		auto_log_info("Buying Holy Spring Water", "green");
		visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=436", true);
		coins -= 1;
	}

	// buy skills
	if (canEat < 1)
	{
		skill nextUpgrade = ed_nextUpgrade();
		int requiredKa = ed_KaCost(nextUpgrade);
		if (requiredKa != -1 && coins >= requiredKa)
		{
			auto_log_info("Buying " + nextUpgrade.to_string() + " (" + requiredKa.to_string() + " Ka).", "green");
			int skillBuy = ed_skillID(nextUpgrade);
			if (skillBuy != 0)
			{
				visit_url("place.php?whichplace=edunder&action=edunder_bodyshop");
				visit_url("choice.php?pwd&skillid=" + skillBuy + "&option=1&whichchoice=1052", true);
				visit_url("choice.php?pwd&option=2&whichchoice=1052", true);
				coins -= requiredKa;
			}
		}
		else if (have_skill($skill[Okay Seriously, This is the Last Spleen]) && canEat < 1)
		{
			while (item_amount($item[Talisman of Renenutet]) < 7 && get_property("auto_renenutetBought").to_int() < 7 && coins >= 1)
		{
			auto_log_info("Buying Talisman of Renenutet", "green");
			visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=439", true);
			set_property("auto_renenutetBought", 1 + get_property("auto_renenutetBought").to_int());
				coins -= 1;
			}
			while (item_amount($item[Linen Bandages]) < 4 && coins >= 1)
			{
				auto_log_info("Buying Linen Bandages", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=429", true);
				coins -= 1;
			}
			if (item_amount($item[Holy Spring Water]) == 0 && coins >= 1)
			{
				auto_log_info("Buying Holy Spring Water", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=436", true);
				coins -= 1;
			}
			while (item_amount($item[Talisman of Horus]) < 2 && coins >= 5)
			{
				auto_log_info("Buying Talisman of Horus", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=693", true);
				coins -= 5;
			}
			if (item_amount($item[Spirit Beer]) == 0 && coins >= 30)
			{
				auto_log_info("Buying Spirit Beer", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=432", true);
				coins -= 2;
			}
			if ((item_amount($item[Soft Green Echo Eyedrop Antidote]) + item_amount($item[Ancient Cure-All])) < 2 && coins >= 30)
			{
				auto_log_info("Buying Ancient Cure-all", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=435", true);
				coins -= 3;
			}
			if (item_amount($item[Sacramental Wine]) == 0 && coins >= 30)
			{
				auto_log_info("Buying Sacramental Wine", "green");
				visit_url("shop.php?pwd=&whichshop=edunder_shopshop&action=buyitem&quantity=1&whichrow=433", true);
				coins -= 3;
			}
		}
	}

	visit_url("place.php?whichplace=edunder&action=edunder_leave");
	visit_url("choice.php?pwd=&whichchoice=1024&option=1", true);
	return true;
}

void ed_handleAdventureServant(location loc)
{
	if (loc == $location[Noob Cave])
	{
		return;
	}
	
	// the order servants are unlocked is
	// level 3 - Priest (extra Ka)
	// level 6 - Cat (item drops)
	// level 9 - Scribe (stats)
	// level 12 - Maid (meat drops)

	// Default to the Priest as we need Ka to get upgrades and fill spleen (and other miscellanea)
	servant myServant = $servant[Priest];

	if (my_spleen_use() == 35 && have_skill($skill[Even More Elemental Wards]) && my_level() < 13 && have_servant($servant[Scribe]))
	{
		// Ka is less important when we have a full spleen and all the skills we need
		// so default to getting stats if we're not level 13 yet.
		myServant = $servant[Scribe];
	}
	else if (my_level() > 12)
	{
		if (!have_skill($skill[Gift of the Maid]) && have_servant($servant[Maid]) && get_property("sidequestNunsCompleted") == "none")
		{
			myServant = $servant[Maid];
		}
		else if (!have_skill($skill[Gift of the Cat]) && have_servant($servant[Cat]))
		{
			myServant = $servant[Cat];
		}
	}

	// Initial Ka farming to get Spleen & Legs upgrades.
	if ($locations[Hippy Camp, The Neverending Party, The Secret Government Laboratory, The SMOOCH Army HQ, VYKEA] contains loc && my_daycount() == 1)
	{
		myServant = $servant[Priest];
	}

	// Locations where item drop is required for quest furthering purposes but we don't want to miss out on Ka if needed.
	if ($locations[The Goatlet, The eXtreme Slope, The Batrat and Ratbat Burrow, Cobb's Knob Harem, Twin Peak, The Black Forest, The Hidden Bowling Alley, The Copperhead Club, A Mob of Zeppelin Protesters, The Red Zeppelin] contains loc)
	{
		if (my_spleen_use() == 35 && have_skill($skill[Even More Elemental Wards]))
		{
			myServant = $servant[Cat];
		}
	}

	// Locations where item drop is required for quest furthering purposes and we won't get Ka regardless
	if ($locations[The Defiled Nook, Oil Peak, A-Boo Peak, The Haunted Laundry Room, The Haunted Wine Cellar] contains loc)
	{
		myServant = $servant[Cat];
	}

	// Locations where we won't get Ka and don't need item drop.
	if ($locations[The Dark Neck of the Woods, The Dark Heart of the Woods, The Dark Elbow of the Woods, The Defiled Alcove, The Defiled Cranny, The Defiled Niche, The Haunted Kitchen, The Haunted Billiards Room, The Haunted Library, The Haunted Bedroom, The Haunted Ballroom, The Haunted Bathroom, The Haunted Boiler Room] contains loc)
	{
		if (have_servant($servant[Scribe]))
		{
			myServant = $servant[Scribe];
		}
		else
		{
			if (have_servant($servant[Cat]))
			{
				myServant = $servant[Cat];
			}
		}
	}

	// Locations where meat drop is required for quest furthering purposes
	if (loc == $location[The Themthar Hills] && have_servant($servant[Maid]))
	{
		myServant = $servant[Maid];
	}

	// Special case for The Penultimate Fantasy Airship as we want to farm some items for quest furthering purposes
	// but it's also an excellent Ka farming zone and we have to spend a bunch of adventures there
	if (loc == $location[The Penultimate Fantasy Airship])
	{
		if (!possessEquipment($item[Mohawk wig]) || !possessEquipment($item[amulet of extreme plot significance]) || !possessEquipment($item[titanium assault umbrella]))
		{
			myServant = $servant[Cat];
		}
		else if (my_spleen_use() == 35 && have_skill($skill[Even More Elemental Wards]) && my_level() < 13 && have_servant($servant[Scribe]))
		{
			myServant = $servant[Scribe];
		}
	}

	handleServant(myServant);
}

boolean ed_preAdv(int num, location loc, string option)
{
	ed_handleAdventureServant(loc);
	return preAdvXiblaxian(loc);
}

boolean ed_autoAdv(int num, location loc, string option, boolean skipFirstLife)
{
	if((option == "") || (option == "auto_combatHandler"))
	{
		option = "auto_edCombatHandler";
	}

	if(!skipFirstLife)
	{
		ed_preAdv(num, loc, option);
	}

	if((my_hp() == 0) || (get_property("_edDefeats").to_int() > get_property("edDefeatAbort").to_int()))
	{
		auto_log_critical("Defeats detected: " + get_property("_edDefeats") + ", Defeat threshold: " + get_property("edDefeatAbort"), "green");
		abort("How are you here? You can't be here. Bloody Limit Mode (probably, maybe?)!!");
	}

	boolean status = false;
	while(num > 0)
	{
		set_property("autoAbortThreshold", "-10.0");
		num = num - 1;
		if(num > 1)
		{
			auto_log_info("This fight and " + num + " more left.", "blue");
		}
		cli_execute("auto_pre_adv");
		set_property("auto_disableAdventureHandling", true);
		set_property("auto_edCombatHandler", "");

		if(!skipFirstLife)
		{
			auto_log_info("Starting Ed Battle at " + loc, "blue");
			status = adv1(loc, 0, option);
			if(!status && (get_property("lastEncounter") == "Like a Bat Into Hell"))
			{
				set_property("auto_disableAdventureHandling", false);
				abort("Either a) We had a connection problem and lost track of the battle, or we were defeated multiple times beyond our usual UNDYING. Manually handle the fight and rerun.");
			}
		}
		if(last_monster() == $monster[Crate])
		{
			abort("We went to the Noob Cave for reals... uh oh");
		}

		string page = visit_url("main.php");
		if(contains_text(page, "whichchoice value=1023"))
		{
			auto_log_info("Ed has UNDYING once!" , "blue");
			if(!ed_shopping())
			{
				#If this visit_url results in the enemy dying, we don't want to continue
				visit_url("choice.php?pwd=&whichchoice=1023&option=2", true);
			}
			auto_log_info("Ed returning to battle Stage 1", "blue");

			if(get_property("_edDefeats").to_int() == 0)
			{
				auto_log_warning("Monster defeated in initialization, aborting attempt.", "red");
				set_property("auto_disableAdventureHandling", false);
				cli_execute("auto_post_adv.ash");
				return true;
			}

			#Catch if we lose the jump after first revival.
			if(get_property("_edDefeats").to_int() != 2)
			{
				status = adv1(loc, 0, option);
				if(last_monster() == $monster[Crate])
				{
					abort("We went to the Noob Cave for reals... uh oh");
				}
			}

			page = visit_url("main.php");
			if(contains_text(page, "whichchoice value=1023"))
			{
				auto_log_info("Ed has UNDYING twice! Time to kick ass!" , "blue");
				if(!ed_shopping())
				{
					#If this visit_url results in the enemy dying, we don't want to continue
					visit_url("choice.php?pwd=&whichchoice=1023&option=2", true);
				}
				auto_log_info("Ed returning to battle Stage 2", "blue");

				if(get_property("_edDefeats").to_int() == 0)
				{
					auto_log_warning("Monster defeated in initialization, aborting attempt.", "red");
					set_property("auto_disableAdventureHandling", false);
					cli_execute("auto_post_adv.ash");
					return true;
				}

				status = adv1(loc, 0, option);
				if(last_monster() == $monster[Crate])
				{
					abort("We went to the Noob Cave for reals... uh oh");
				}
			}
		}
		set_property("auto_disableAdventureHandling", false);

		if(get_property("_edDefeats").to_int() > get_property("edDefeatAbort").to_int())
		{
			abort("Manually forcing edDefeatAborts. We can't handle the battle.");
		}

		cli_execute("auto_post_adv.ash");
	}
	return status;
}

boolean ed_autoAdv(int num, location loc, string option)
{
	return ed_autoAdv(num, loc, option, false);
}

boolean L1_ed_island()
{
	if(!elementalPlanes_access($element[spooky]))
	{
		return false;
	}

	skill blocker = $skill[Still Another Extra Spleen];
	if(get_property("auto_dickstab").to_boolean())
	{
		if(turns_played() > 22)
		{
			return false;
		}
	}

	if((my_level() >= 10) || ((my_level() >= 8) && have_skill(blocker)))
	{
		return false;
	}
	if((my_level() >= 3) && (my_turncount() >= 2) && !get_property("controlPanel9").to_boolean())
	{
		visit_url("place.php?whichplace=airport_spooky_bunker&action=si_controlpanel");
		visit_url("choice.php?pwd=&whichchoice=986&option=9",true);
	}
	if((my_level() >= 3) && !get_property("controlPanel9").to_boolean() && (my_turncount() >= 2))
	{
		abort("Damn control panel is not set, WTF!!!");
	}

	#If we get some other CI quest, this might keep triggering, should we flag this?
	if((my_hp() > 20) && !possessEquipment($item[Gore Bucket]) && !possessEquipment($item[Encrypted Micro-Cassette Recorder]) && !possessEquipment($item[Military-Grade Fingernail Clippers]))
	{
		elementalPlanes_takeJob($element[spooky]);
		set_property("choiceAdventure988", 2);
	}

	if(item_amount($item[Gore Bucket]) > 0)
	{
		autoEquip($item[Gore Bucket]);
	}

	if(item_amount($item[Personal Ventilation Unit]) > 0)
	{
		autoEquip($slot[acc2], $item[Personal Ventilation Unit]);
	}
	if(possessEquipment($item[Gore Bucket]) && (get_property("goreCollected").to_int() >= 100))
	{
		visit_url("place.php?whichplace=airport_spooky&action=airport2_radio");
		visit_url("choice.php?pwd&whichchoice=984&option=1", true);
	}

	if((my_turncount() <= 1) && (my_meat() > 10000))
	{
		int need = min(4, (my_maxmp() - my_mp()) / 10);
		buyUpTo(need, $item[Doc Galaktik\'s Invigorating Tonic]);
		use(need, $item[Doc Galaktik\'s Invigorating Tonic]);
		cli_execute("auto_post_adv");
	}

	buffMaintain($effect[Experimental Effect G-9], 0, 1, 1);
	autoAdv(1, $location[The Secret Government Laboratory]);
	if(item_amount($item[Bottle-Opener Keycard]) > 0)
	{
		use(1, $item[Bottle-Opener Keycard]);
	}
	set_property("choiceAdventure988", 1);
	return true;
}

boolean L1_ed_islandFallback()
{
	if(elementalPlanes_access($element[spooky]))
	{
		return false;
	}

	if((my_level() >= 10) || ((my_level() >= 8) && have_skill($skill[Still Another Extra Spleen])) || ((my_level() >= 6) && have_skill($skill[Okay Seriously\, This Is The Last Spleen])))
	{
		if((spleen_left() < 5) || (my_adventures() > 10))
		{
			return false;
		}
	}

	if(!get_property("lovebugsUnlocked").to_boolean())
	{
		if(my_turncount() == 0)
		{
			while((my_mp() < mp_cost($skill[Storm of the Scarab])) && (my_mp() < my_maxmp()) && (my_meat() > 1500))
			{
				buyUpTo(1, $item[Doc Galaktik\'s Invigorating Tonic], 90);
				use(1, $item[Doc Galaktik\'s Invigorating Tonic]);
			}
		}
		else if(my_turncount() == 1)
		{
			if((is_unrestricted($item[Clan Pool Table])) && (get_property("_poolGames").to_int() < 3) && (item_amount($item[Clan VIP Lounge Key]) > 0))
			{
				visit_url("clan_viplounge.php?preaction=poolgame&stance=2");
				visit_url("clan_viplounge.php?preaction=poolgame&stance=2");
				visit_url("clan_viplounge.php?preaction=poolgame&stance=2");
			}
		}
	}

	if(get_property("neverendingPartyAlways").to_boolean() || get_property("_neverendingPartyToday").to_boolean())
	{
		backupSetting("choiceAdventure1322", 2);
		if(have_effect($effect[Tomes of Opportunity]) == 0)
		{
			backupSetting("choiceAdventure1324", 1);
			backupSetting("choiceAdventure1325", 2);
		}
		else
		{
			backupSetting("choiceAdventure1324", 5);
		}

		autoAdv(1, $location[The Neverending Party]);
		restoreSetting("choiceAdventure1322");
		restoreSetting("choiceAdventure1324");
		restoreSetting("choiceAdventure1325");
		return true;
	}
	if(elementalPlanes_access($element[stench]))
	{
		autoAdv(1, $location[Pirates of the Garbage Barges]);
		return true;
	}
	if(elementalPlanes_access($element[cold]))
	{
		if(get_property("_VYKEALoungeRaided").to_boolean())
		{
			if(get_property("_VYKEACafeteriaRaided").to_boolean())
			{
				set_property("choiceAdventure1115", 6);
			}
			else
			{
				set_property("choiceAdventure1115", 1);
			}
		}
		else
		{
			set_property("choiceAdventure1115", 9);
		}
		autoAdv(1, $location[VYKEA]);
		return true;
	}
	if(elementalPlanes_access($element[hot]))
	{
		//Maybe this is a good choice?
		set_property("choiceAdventure1094", 5);
		autoAdv(1, $location[The SMOOCH Army HQ]);
		set_property("choiceAdventure1094", 2);
		return true;
	}

	if (my_session_adv() == 0 && my_mp() >= mp_cost($skill[Wisdom Of Thoth]) && have_skill($skill[Wisdom Of Thoth]))
	{
		// use our free starting 5 mp to get Wisdom of Thoth to increase our max MP 
		// as we'll regen some when adventuring at the shore.
		use_skill(1, $skill[Wisdom Of Thoth]);
	}

	if(LX_islandAccess())
	{
		return true;
	}

	if (my_servant() == $servant[Priest] && my_servant().experience < 196)
	{
		// make sure we have a level 15 Priest if possible
		// so we get the extra Ka from Hippies and Goblins.
		buffMaintain($effect[Purr of the Feline], 10, 1, 10);
	}
	
	if (have_skill($skill[Upgraded Legs]) || item_amount($item[Ka coin]) >= 10)
	{
		if(have_outfit("Filthy Hippy Disguise") && is_wearing_outfit("Filthy Hippy Disguise"))
		{
			equip($slot[Pants], $item[None]);
			put_closet(item_amount($item[Filthy Corduroys]), $item[Filthy Corduroys]);
			equipBaseline();
		}
		if (have_skill($skill[More Legs]) && maximizeContains("-10ml"))
		{
			removeFromMaximize("-10ml");
		}
		auto_change_mcd(11);
		boolean retVal = autoAdv(1, $location[Hippy Camp]);
		if (item_amount($item[Filthy Corduroys]) > 0)
		{
			if (closet_amount($item[Filthy Corduroys]) > 0)
			{
				autosell(item_amount($item[Filthy Corduroys]), $item[Filthy Corduroys]);
			}
			else
			{
				put_closet(item_amount($item[Filthy Corduroys]), $item[Filthy Corduroys]);
			}
		}
		return retVal;
	}
	set_property("auto_needLegs", true);
	if (!maximizeContains("-10ml"))
	{
		addToMaximize("-10ml");
		auto_change_mcd(0);
	}
	return autoAdv(1, $location[The Outskirts of Cobb\'s Knob]);
}

boolean L9_ed_chasmStart()
{
	if (isActuallyEd() && !get_property("auto_chasmBusted").to_boolean())
	{
		auto_log_info("It's a troll on a bridge!!!!", "blue");

		string page = visit_url("place.php?whichplace=orc_chasm&action=bridge_done");
		autoAdvBypass("place.php?whichplace=orc_chasm&action=bridge_done", $location[The Smut Orc Logging Camp]);

		set_property("auto_chasmBusted", true);
		return true;
	}
	return false;
}

boolean L9_ed_chasmBuild()
{
	if (isActuallyEd() && !get_property("auto_chasmBusted").to_boolean())
	{
		auto_log_info("What a nice bridge over here...." , "green");

		string page = visit_url("place.php?whichplace=orc_chasm&action=bridge_done");
		autoAdvBypass("place.php?whichplace=orc_chasm&action=bridge_done", $location[The Smut Orc Logging Camp]);

		set_property("auto_chasmBusted", true);
		return true;
	}
	return false;
}

boolean L9_ed_chasmBuildClover(int need)
{
	if (isActuallyEd() && (need > 3) && (item_amount($item[Disassembled Clover]) > 2))
	{
		use(1, $item[disassembled clover]);
		backupSetting("cloverProtectActive", false);
		autoAdvBypass("adventure.php?snarfblat=295", $location[The Smut Orc Logging Camp]);
		if(item_amount($item[Ten-Leaf Clover]) > 0)
		{
			auto_log_info("Wandering adventure in The Smut Orc Logging Camp, boo. Gonna have to do this again.");
			use(item_amount($item[Ten-Leaf Clover]), $item[Ten-Leaf Clover]);
			restoreSetting("cloverProtectActive");
			return true;
		}
		restoreSetting("cloverProtectActive");
		visit_url("place.php?whichplace=orc_chasm&action=bridge"+(to_int(get_property("chasmBridgeProgress"))));
		return true;
	}
	return false;
}

boolean L11_ed_mauriceSpookyraven()
{
	if (isActuallyEd())
	{
		if(item_amount($item[7962]) == 0)
		{
			set_property("auto_ballroom", "finished");
			return true;
		}
	}
	return false;
}

boolean LM_edTheUndying()
{
	if (!isActuallyEd())
	{
		return false;
	}

	ed_buySkills();

	if(get_property("edPiece") != "hyena")
	{
		if(elementalPlanes_access($element[spooky]) || (my_level() >= 5))
		{
			adjustEdHat("ml");
		}
		else
		{
			adjustEdHat("myst");
		}
	}

	if(L1_ed_island() || L1_ed_islandFallback())
	{
		return true;
	}

	if(L5_getEncryptionKey())
	{
		return true;
	}

	if(LX_islandAccess())
	{
		return true;
	}

	if (closet_amount($item[Filthy Corduroys]) > 0)
	{
		take_closet(closet_amount($item[Filthy Corduroys]), $item[Filthy Corduroys]);
	}

	if (!get_property("breakfastCompleted").to_boolean())
	{
		cli_execute("breakfast");
	}

	if (item_amount($item[Seal Tooth]) == 0)
	{
		acquireHermitItem($item[Seal Tooth]);
	}

	if (my_level() >= 9)
	{
		if(haveAnyIotmAlternativeRestSiteAvailable() && doFreeRest())
		{
			cli_execute("scripts/autoscend/auto_post_adv.ash");
			return true;
		}
	}

	// as we do hippy side, the war is a 2 Ka quest (excluding sidequests but that shouldn't matter)
	// once the war is no longer a complete mess of spaghetti code, change this to do the whole war.
	if (L12_getOutfit() || L12_startWar())
	{
		return true;
	}
	// start the macguffin quest, conveniently the black forest is a 1.4 Ka zone.
	if (L11_blackMarket() || L11_forgedDocuments() || L11_mcmuffinDiary())
	{
		return true;
	}
	// The hidden city is mostly 2 Ka monsters so do it ASAP.
	if (L11_nostrilOfTheSerpent() || L11_unlockHiddenCity() || L11_hiddenCityZones() || L11_hiddenCity())
	{
		return true;
	}
	// Airship is 1.5 Ka or 1.8 Ka with the construct banished so third highest priorty after the war
	// Castle zones are all 1 Ka so may as well finish it off
	if (L10_plantThatBean() || L10_airship() || L10_basement() || L10_ground() || L10_topFloor())
	{
		return true;
	}
	// Smut Orcs are 1 Ka so build the bridge.
	if (L9_chasmStart() || L9_chasmBuild())
	{
		return true;
	}
	// L8 quest is all 1 Ka zones for Ed (unlikely to survive Ninja Snowmen Assassins so they don't count)
	if (L8_trapperStart() || L8_trapperGround() || L8_trapperGroar())
	{
		return true;
	}
	// Goblins are 1 Ka and the rewards are useful
	if (L5_haremOutfit() || L5_goblinKing())
	{
		return true;
	}
	// Bats are 1 Ka and the rewards are useful
	if (L4_batCave())
	{
		return true;
	}
	// need to do L2 quest to unlock the L3. 0.83 Ka zone or 1/1.25/1.67 with 1/2/3 banishes
	if (L2_mosquito() || L2_treeCoin() || L2_spookyMap() || L2_spookyFertilizer() || L2_spookySapling())
	{
		return true;
	}
	// should probably complete the tavern for drinking purposes (and rats are 1 Ka).
	if (L3_tavern())
	{
		return true;
	}
	// Copperhead Club & Mob of Zeppelin Protestors are 2 Ka zones (with a banish use) but we want to delay them so we can semi-rare Copperhead
	if (L11_mauriceSpookyraven() || L11_talismanOfNam() || L11_palindome())
	{
		return true;
	}

	return false;
}
