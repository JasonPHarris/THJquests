sub EVENT_SIGNAL {
    if ($signal == 666) {
        plugin::UpdateEoMAward($client);
        return;
    }

    if ($signal == 100) {
        # This needs to be refactored into a source method
        my $semaphore_title = $client->GetBucket('flag-semaphore');
        if ($semaphore_title) {
            plugin::AddTitleFlag($semaphore_title, $client);
            $client->DeleteBucket('flag-semaphore');
        }
        plugin::EnableTitles($client);
    } 
}

sub EVENT_ENTERZONE {
    my $default_size = $client->GetDefaultRaceSize();
    $client->ChangeSize($default_size);

	plugin::CommonCharacterUpdate($client);

	if (!plugin::is_eligible_for_zone($client, $zonesn)) {
		$client->Message(4, "Your vision blurs. You lose conciousness and wake up in a familiar place.");
		$client->MovePC(151, 185, -835, 4, 390); # Bazaar Safe Location.
    }

    if (!$client->IsTaskCompleted(3) && !$client->IsTaskActive(3)) {
        $client->AssignTask(3);
    } elsif ($client->IsTaskCompleted(3) && (!$client->IsTaskCompleted(4) && !$client->IsTaskActive(4))) {
        $client->AssignTask(4);
    }

    my $entity_list = plugin::val('$entity_list');
    my @npcs = $entity_list->GetNPCList();
    if (plugin::IsTHJ() && $instanceid) {
        foreach my $npc (@npcs) {
            my $expedition = quest::get_expedition();
            if ($expedition) {
                plugin::ScaleInstanceNPC($npc, $expedition->GetMemberCount());
            }
        }
    }
}

sub EVENT_DEATH {
    # Debug info remains unchanged
    quest::debug("killer_id " . $killer_id);
    quest::debug("killer_damage " . $killer_damage);
    quest::debug("killer_spell " . $killer_spell);
    quest::debug("killer_skill " . $killer_skill);
    quest::debug("killed_entity_id " . $killed_entity_id);
    quest::debug("combat_start_time " . $combat_start_time);
    quest::debug("combat_end_time " . $combat_end_time);
    quest::debug("damage_received " . $damage_received);
    quest::debug("healing_received " . $healing_received);
    quest::debug("killed_corpse_id " . $killed_corpse_id);
    quest::debug("killed_x " . $killed_x);
    quest::debug("killed_y " . $killed_y);
    quest::debug("killed_z " . $killed_z);
    quest::debug("killed_h " . $killed_h);
    quest::debug("killed_merc_id " . $killed_merc_id);
    quest::debug("killed_npc_id " . $killed_npc_id);

    if ($client->IsHardcore()) {
        my $player_name = $client->GetCleanName();
        my $player_class = plugin::GetPrettyClassString($client);
        my $death_zone = $zoneln; # Get the zone name where the player died
        
        # Arrays of announcement prefixes for variety in format - now including zone info
        my @announcement_prefixes = (
            "The legend of $player_name ($player_class) ends in Hardcore mode within the depths of $death_zone",
            "$player_name ($player_class) has fallen in Hardcore mode while exploring $death_zone",
            "$player_name ($player_class) has been defeated in Hardcore mode in the perilous realm of $death_zone",
            "The saga of $player_name ($player_class) concludes in Hardcore mode amidst the dangers of $death_zone",
            "$player_name ($player_class) has met their end in Hardcore mode in the wilds of $death_zone",
            "$player_name ($player_class) has departed the mortal realm in Hardcore mode while venturing through $death_zone",
            "The journey of $player_name ($player_class) is over in Hardcore mode in the treacherous lands of $death_zone",
            "$player_name ($player_class) has perished in Hardcore mode within the hostile territory of $death_zone",
            "$player_name ($player_class) has breathed their last in Hardcore mode while traversing $death_zone",
            "The tale of $player_name ($player_class) closes in Hardcore mode during their expedition in $death_zone"
        );
        
        # Alternate zone-specific formats that vary the zone placement
        my @zone_variant_prefixes = (
            "In the heart of $death_zone, $player_name ($player_class) has met their fate in Hardcore mode",
            "The dangerous realm of $death_zone claims another as $player_name ($player_class) falls in Hardcore mode",
            "Among the shadows of $death_zone, $player_name ($player_class) has been vanquished in Hardcore mode",
            "$death_zone has become the final resting place of $player_name ($player_class) in Hardcore mode",
            "The chronicles of $death_zone now tell of $player_name ($player_class)'s demise in Hardcore mode",
            "Within the infamous $death_zone, $player_name ($player_class)'s adventure ends in Hardcore mode",
            "The treacherous terrain of $death_zone has claimed $player_name ($player_class) in Hardcore mode",
            "$death_zone will forever remember where $player_name ($player_class) fell in Hardcore mode",
            "The spirits of $death_zone bear witness as $player_name ($player_class) perishes in Hardcore mode",
            "Written in the stones of $death_zone is the final chapter of $player_name ($player_class) in Hardcore mode"
        );

        
        
        # Combine both prefix arrays for more variety
        push(@announcement_prefixes, @zone_variant_prefixes);
        
        # Select a random prefix format
        my $prefix_index = int(rand(scalar @announcement_prefixes));
        my $announcement_prefix = $announcement_prefixes[$prefix_index];
        
        # Check if player killed themselves
        if ($killer_id == $client->GetID()) {
            # Self-death flavor text options with more variety
            my @self_death_flavors = (
                "succumbed to their own folly",
                "met an untimely end by their own hand",
                "fell victim to their own miscalculation",
                "discovered the hard way that gravity still works",
                "became their own worst enemy",
                "made a fatal mistake",
                "perished from their own recklessness",
                "found out actions have consequences",
                "learned a harsh lesson too late",
                "took a risk that didn't pay off",
                "achieved a perfect self-defeat",
                "mastered the art of self-destruction",
                "accidentally tested their own mortality",
                "experimented with their own demise",
                "found an innovative way to perish",
                "proved that no one is immune to their own mistakes",
                "has been betrayed by their own tactics",
                "discovered a new way to fail spectacularly",
                "contributed to the tome of 'what not to do'",
                "created a cautionary tale for future adventurers"
            );
            
            # Select random self-death flavor text
            my $random_index = int(rand(scalar @self_death_flavors));
            my $self_death_flavor = $self_death_flavors[$random_index];
            
            # Announce self-caused death with varied formatting
            my $announcement = "$announcement_prefix, having $self_death_flavor!";
            plugin::WorldAnnounce($announcement);
        }
        else {
            my $killer_mob = $entity_list->GetMobID($killer_id);
            my $killer_name = $killer_mob ? $killer_mob->GetCleanName() : "Unknown";
            
            # Check if death was caused by a spell
            if ($killer_spell < 0xFFFF) {
                # Get the spell name
                my $spell_name = quest::getspellname($killer_spell);
                
                # Varied spell death descriptions
                my @spell_death_formats = (
                    "obliterated by $killer_name\'s $spell_name",
                    "consumed by the arcane power of $killer_name\'s $spell_name",
                    "reduced to ashes by $killer_name\'s devastating $spell_name",
                    "unable to withstand $killer_name\'s potent $spell_name",
                    "melted away under $killer_name\'s $spell_name",
                    "vaporized by the sheer force of $killer_name\'s $spell_name",
                    "torn apart by the energies of $killer_name\'s $spell_name",
                    "banished from existence by $killer_name\'s $spell_name",
                    "struck down by $killer_name\'s masterful casting of $spell_name",
                    "consumed by the eldritch might of $killer_name\'s $spell_name"
                );
                
                # Select a random spell death format
                my $format_index = int(rand(scalar @spell_death_formats));
                my $spell_death_format = $spell_death_formats[$format_index];
                
                # Announce spell-caused death
                my $announcement = "$announcement_prefix, $spell_death_format!";
                plugin::WorldAnnounce($announcement);
            }
            else {
                # Death was caused by a skill - use more varied death descriptions
                my %death_flavors = (
                    # 1H Blunt (0)
                    0 => [
                        "crushing blow that shattered bone",
                        "skull-cracking mace swing that echoed through the realm",
                        "bone-shattering club strike that ended all hope",
                        "merciless hammer blow that crushed their spirit",
                        "brutal cudgel that found its mark with deadly precision",
                        "mighty swing that pulverized their defenses",
                        "thunderous mace impact that silenced their battle cry",
                        "devastating club strike that left nothing but ruins"
                    ],
                    
                    # 1H Slashing (1)
                    1 => [
                        "razor-sharp blade that cut through armor like paper",
                        "deadly sword strike that severed life's thread",
                        "vicious slash that opened their final chapter",
                        "precise cut that found the gap in their defense",
                        "merciless blade that drank deeply of their lifeblood",
                        "swift sword dance that ended with a crimson flourish",
                        "masterful stroke that proved too quick to counter",
                        "elegant blade work that wrote their epitaph in red"
                    ],
                    
                    # 2H Blunt (2)
                    2 => [
                        "mighty war hammer that left nothing to bury",
                        "devastating maul that rewrote the landscape with their remains",
                        "earth-shaking smash that sent tremors through the realm",
                        "colossal club that flattened both armor and wearer",
                        "bone-crushing staff that demonstrated the meaning of force",
                        "titanic hammer blow that redefined 'pulverized'",
                        "mountainous maul that created a new crater",
                        "two-handed masterpiece of destruction"
                    ],
                    
                    # 2H Slashing (3)
                    3 => [
                        "massive cleaving strike that divided both body and soul",
                        "devastating great sword that carved a path through legend",
                        "whirling executioner's blade that harvested their final moments",
                        "sweeping death blow that cleared the field of resistance",
                        "merciless beheading strike that separated glory from defeat",
                        "gigantic blade that brought swift judgment",
                        "cleaving arc that finished what destiny began",
                        "enormous sword that wrote 'the end' in one stroke"
                    ],
                    
                    # Archery (7)
                    7 => [
                        "perfectly aimed arrow that found the heart of the matter",
                        "deadly bow shot that traveled through legend to find its mark",
                        "piercing shaft that delivered the message of mortality",
                        "whistling arrow to the heart that silenced all ambition",
                        "long-range precision shot that defied both distance and fate",
                        "arrow's flight that ended faster than prayer",
                        "master archer's mark that closed their final chapter",
                        "impossible shot that made history instead of missing it"
                    ],
                    
                    # Backstab (8)
                    8 => [
                        "treacherous backstab that wrote betrayal in blood",
                        "dagger from the shadows that ended what trust began",
                        "assassin's blade that whispered death's greeting",
                        "poisoned backstab that worked its treachery through the veins",
                        "cowardly strike from behind that denied a warrior's death",
                        "silent blade that spoke volumes in the end",
                        "shadowy execution that came without warning",
                        "deadly surprise that proved looking forward wasn't enough"
                    ],
                    
                    # Bash (10)
                    10 => [
                        "thunderous shield bash that collapsed both guard and guarded",
                        "staggering blow that knocked them from the world of the living",
                        "crushing shield edge that created a new definition of impact",
                        "mighty slam that echoed through the halls of legend",
                        "brutal body check that sent them on a one-way journey",
                        "decisive shield strike that ended all debate",
                        "defensive weapon turned offensive masterpiece",
                        "protective equipment that delivered terminal protection"
                    ],             

                    # Hand to Hand (28)
                    28 => [
                        "fierce bare-handed attack that proved weapons optional",
                        "lightning-fast martial arts that wrote poetry in pain",
                        "deadly pressure-point strike that stopped more than just chi",
                        "bare-knuckled fury that pummeled through defense",
                        "expert combat technique that found every vital weakness",
                        "empty hand filled with deadly purpose",
                        "martial mastery that made weapons seem redundant",
                        "flurry of strikes that left no time for last words"
                    ],
                    
                    # Kick (30)
                    30 => [
                        "bone-shattering kick that rearranged their skeletal structure",
                        "deadly roundhouse that came full circle to mortality",
                        "brutal stomp that ground ambition into dust",
                        "crushing leg sweep that took more than just their footing",
                        "powerful heel strike that stamped 'expired' on their journey",
                        "lethal kick that stepped over the line between life and death",
                        "martial footnote that closed their book for good",
                        "strike that proved legs are weapons too"
                    ],
                    
                    # 1H Piercing (36)
                    36 => [
                        "precise rapier thrust that found the heart of the matter",
                        "deadly dagger plunge that pierced all pretensions",
                        "heart-seeking blade that fulfilled its singular purpose",
                        "surgical piercing strike that operated with terminal success",
                        "deep puncturing wound that released their spirit to the void",
                        "slender blade that proved width is no measure of deadliness",
                        "pinpoint accuracy that found the vital spot",
                        "needle-like precision that threaded between armor plates"
                    ], 
                    
                    # 2H Piercing (77)
                    77 => [
                        "impaling spear thrust that pinned their legend to history",
                        "devastating pike charge that ran through all resistance",
                        "heart-piercing lance that skewered dreams and bearer alike",
                        "massive puncture wound that created a passage for their spirit",
                        "skewering strike that threaded them into the tapestry of fallen",
                        "polearm precision that extended the reach of death",
                        "piercing shaft that created a new opening in their defenses",
                        "spear point that found the terminal weakness"
                    ]
                );
                
                # Default flavors for unknown skills with more variety
                my @default_flavors = (
                    "brutal attack that brooked no survival",
                    "lethal strike that settled all accounts",
                    "vicious assault that left no room for recovery",
                    "deadly blow that wrote the final chapter",
                    "merciless onslaught that overwhelmed all defense",
                    "devastating technique that proved too advanced to counter",
                    "fierce combat prowess that outmatched all resistance",
                    "relentless aggression that pursued beyond hope",
                    "savage onslaught that tore through determination",
                    "overwhelming force that crushed both body and spirit",
                    "perfect execution that left nothing to chance",
                    "combat mastery that transcended their defenses",
                    "tactical brilliance that found every weakness",
                    "supreme demonstration of martial superiority",
                    "unstoppable attack that defied all countermeasures"
                );
                
                # Get random flavor text from the appropriate array
                my $death_flavor;
                if (exists $death_flavors{$killer_skill}) {
                    my $flavor_options = $death_flavors{$killer_skill};
                    my $random_index = int(rand(scalar @$flavor_options));
                    $death_flavor = $flavor_options->[$random_index];
                } else {
                    # Select random default flavor
                    my $random_index = int(rand(scalar @default_flavors));
                    $death_flavor = $default_flavors[$random_index];
                }
                
                # Announce skill-caused death with varied formatting
                my $announcement = "$announcement_prefix, destroyed by $killer_name\'s $death_flavor!";
                plugin::WorldAnnounce($announcement);
            }
        }
    }
}

sub EVENT_EXP_GAIN {
    plugin::CustomEventExpGainEntry();
}

sub EVENT_AA_EXP_GAIN {
    plugin::CustomEventAAExpGainEntry();
}

sub EVENT_EQUIP_ITEM_CLIENT {
    plugin::CustomEventItemEquipEntry();

    if ($slot_id == 21) {
        # Simple Ring of the Hero, for Tutorial Quest 2
        if ($client->IsTaskActivityActive(4, 0) && $item_id == 150000) {
            $client->UpdateTaskActivity(4, 0, 1);
            return;
        }
        if ($client->IsTaskActivityActive(4, 1) && $item_id == 1150000) {
            $client->UpdateTaskActivity(4, 01, 1);
            return;
        }
        if ($client->IsTaskActivityActive(4, 2) && $item_id == 2150000) {
            $client->UpdateTaskActivity(4, 2, 1);
            return;
        }
        if ($item_id == 2150000) {
            plugin::dispatch_popup("symp_tutorial");
        } {
            plugin::dispatch_popup("power_source");
        }
    }

    symp_proc_tutorial_helper($item_id, $client);
}

sub EVENT_UNEQUIP_ITEM_CLIENT {
    plugin::CustomEventItemUnequipEntry();
}

sub EVENT_DESTROY_ITEM_CLIENT {
    if ($item_id == 2827) {
        my $account_key 	= $client->AccountID() . "-ess-items-destroyed";
        quest::set_data($account_key, (quest::get_data($account_key) || 0) + 1);
    }

    plugin::CustomEventDestroyEntry($item, $quantity);
}

sub EVENT_CONNECT {
    if (plugin::GetSoulmark($client)) {
        plugin::DisplayWarning($client);
    }
   
    plugin::CommonCharacterUpdate($client);
    plugin::OnLoginUpdate($client);

    if (!$client->GetBucket("First-Login")) {
        quest::settimer("first-login", 5);
    }

    if (plugin::MultiClassingEnabled()) {
        if (!$client->IsTaskCompleted(3) && !$client->IsTaskActive(3)) {
            $client->AssignTask(3);
        } elsif ($client->IsTaskCompleted(3) && (!$client->IsTaskCompleted(4) && !$client->IsTaskActive(4))) {
            $client->AssignTask(4);
        }

        plugin::dispatch_popup("welcome");
    }

    if (!plugin::is_eligible_for_zone($client, $zonesn)) {
		$client->Message(4, "Your vision blurs. You lose conciousness and wake up in a familiar place.");
		$client->MovePC(151, 185, -835, 4, 390); # Bazaar Safe Location.
	}
}

sub EVENT_TIMER {
    if (!$client->GetBucket("First-Login")) {
        quest::settimer("first-login", 10);

        $client->SetBucket("First-Login", 1);
        $client->SummonItem(18471); #A Faded Writ
        $client->Message(263, "You find a small note in your pocket.");
        
        my $name = $client->GetCleanName();
        my $full_class_name = plugin::GetPrettyClassString($client);

        my $solo = $client->IsSolo();
        my $hardcore = $client->IsHardcore();
        my $self_found = $client->IsSelfFound();
        
        # Build the announcement with status flags in a single set of parentheses
        my $announcement = "$name ($full_class_name) has logged in for the first time!";
        
        # Create a status string with all applicable statuses
        my @statuses;
        if ($solo) {
            push(@statuses, "Solo");
        }
        if ($self_found) {
            push(@statuses, "Self Found");
        }
        if ($hardcore) {
            push(@statuses, "Hardcore");
        }
        
        # Only add the status parentheses if there are any statuses to show
        if (scalar @statuses > 0) {
            $announcement .= " (" . join(", ", @statuses) . ")";
        }

        plugin::WorldAnnounce($announcement);
        plugin::AwardSeasonalItems($client);
    }

}

sub EVENT_DISCONNECT {
    # Removes invulnerability effects when disconnecting from the server.
    $client->BuffFadeByEffect(40);
}

sub EVENT_POPUPRESPONSE {
    plugin::check_tutorial_popup_response($popupid, $client);  
       
    if ($popupid == 58240) {        
        my $x = $client->GetEntityVariable("bazaar_x") + int(rand(11)) - 5;
        my $y = $client->GetEntityVariable("bazaar_y") + int(rand(11)) - 5;
        my $z = $client->GetEntityVariable("bazaar_z");
        my $h = $client->GetEntityVariable("bazaar_h");
        my $bind_loc = $client->GetEntityVariable("bazaar_zone");

        $client->SetBucket("Return-X", $client->GetX());
        $client->SetBucket("Return-Y", $client->GetY());
        $client->SetBucket("Return-Z", $client->GetZ());
        $client->SetBucket("Return-H", $client->GetHeading());
        $client->SetBucket("Return-Zone", $zoneid);
        $client->SetBucket("Return-Instance", $instanceid);

        $client->SpellEffect(218,1);
        $client->MovePC($bind_loc, $x, $y, $z, rand(512));
    }
}

sub EVENT_TASK_COMPLETE {
    if ($task_id == 3 && !$client->IsTaskCompleted(4)) {
        $client->AssignTask(4);
    }
}

sub EVENT_LEVEL_UP {
    plugin::CommonCharacterUpdate($client);

    if ($client->GetGM()) {
        return;
    }
    
    my $new_level = $client->GetLevel();
    if ($new_level == $client->GetBucket("CharMaxLevel")) {
        my $name = $client->GetCleanName();
        my $full_class_name = plugin::GetPrettyClassString($client);

        plugin::WorldAnnounce("$name ($full_class_name) has reached Level $new_level!");
    }
}

sub EVENT_CLICKDOOR {
	my $target_zone = plugin::get_target_door_zone($zonesn, $doorid, $version);

    if (!plugin::is_eligible_for_zone($client, $target_zone, 1)) {		
		return 1;
    }
}

sub EVENT_WARP {
    my $name = $client->GetCleanName();
    my $current_x = $client->GetX();
    my $current_y = $client->GetY();
    my $current_z = $client->GetZ();
    my $distance = sqrt(($current_x - $from_x) ** 2 + ($current_y - $from_y) ** 2 + ($current_z - $from_z) ** 2);
    my $account_key = $client->AccountID() . "-WarpCount";
    my $soulmark = quest::get_data($client->AccountID() . "-CheaterFlag");

    my @warp_events = plugin::DeserializeList(quest::get_data($account_key));

    # Enqueue the current warp event with timestamp
    push @warp_events, time();

    # Clean up array elements older than 30 days
    my $thirty_days_in_seconds = 30 * 24 * 60 * 60;
    @warp_events = grep { time() - $_ <= $thirty_days_in_seconds } @warp_events;

    # Count recent warp events
    my $recent_warp_count = scalar(@warp_events);

    my $enforcement = 0;

    quest::set_data($account_key, plugin::SerializeList(@warp_events));

    if ($distance > 100 || $soulmark) {
        my $admin_message = "Large Warp Detected. Character: $name Zone: $zonesn From: $from_x, $from_y, $from_z To: $current_x, $current_y, $current_z Distance: $distance";

        if ($soulmark) {
            $admin_message .= "\nAccount has Soulmark. Reason: $soulmark";            
        }

        if ($recent_warp_count) {
            $admin_message .= "\nPrevious 30-day Warp Count: $recent_warp_count";
        }

        if ($soulmark && $recent_warp_count > 10) {
            $admin_message .= "\nHigh 30-day Warp Count. Enforcement Engaged.";
            $enforcement = 1;
        }

        # Send the admin message
        quest::discordsend("monitor", $admin_message);
        quest::debug($admin_message);

        if ($enforcement) {
            $client->WorldKick();
        }
    }
}

sub EVENT_ALT_CURRENCY_MERCHANT_BUY {

    if ($item_id == 24151) {
        $client->AddAlternateCurrencyValue(1, 10);
        $client->RemoveAlternateCurrencyValue($currency_id, $item_cost);
        $client->RemoveItem(24151);
        plugin::YellowText("You unpack the bundle of Delivery Vouchers");
        return 1;
    }
}

sub EVENT_DISCOVER_ITEM {
    my $name = $client->GetCleanName();
    
    # Only announce upgraded items
    if ($itemid >= 700000) {        
        plugin::WorldAnnounceItem("$name has discovered: {item}.",$itemid);  
    }  
}

sub symp_proc_tutorial_helper {
    my $item_id = shift;
    my $client = shift;

    if ($item_id) {
        #pre-computed list of symp proc item ID bases
        my @sym_clicks = (
            6307, 6309, 6313, 7305, 900012, 900014, 1113, 1117, 1156, 1173, 
            1904, 2404, 5203, 5214, 5730, 5764, 6017, 6020, 6024, 6036, 
            6310, 6315, 6323, 6324, 6332, 6335, 6343, 6350, 6359, 6382, 
            6383, 6402, 6404, 6408, 6616, 6626, 7036, 7318, 7372, 7405, 
            10333, 10383, 10404, 10994, 11028, 11906, 11973, 12375, 13168, 
            13380, 13400, 13500, 13743, 13744, 13815, 13987, 13988, 13991, 
            14338, 14746, 14762, 20627, 21798, 21863, 21885, 21886, 21892, 
            22819, 22890, 23498, 24745, 24779, 24789, 24793, 25566, 25577, 
            25980, 25998, 26000, 26001, 26009, 26553, 27280, 27717, 28812, 
            28813, 28814, 28815, 28817, 28908, 29248, 29430, 29442, 30511, 
            31210, 31212, 31373, 62269, 68444, 68744, 68775, 68837, 69044, 
            69047, 69049, 69051, 69054, 69055, 69095, 69112, 69113, 69116, 
            69155
        );

        my $item_root = ($item_id % 1000000);

        if (grep { $_ == $item_root } @sym_clicks) {
            plugin::dispatch_popup("symp_tutorial", $client);
        }
    }
}

sub EVENT_COMBINE_VALIDATE {
	if ($recipe_id == 10344) {
		if ($validate_type =~/check_zone/i) {
			if ($zone_id != 289 && $zone_id != 290) {
				return 1;
			}
		}
	}

    if ($recipe_id == 927863) {
        my $name = $client->GetCleanName();
        plugin::WorldAnnounceItem("$name has forged the {item} within the Crucible of the Elements! Hail the Prismatic Conquerer!", 2017730);
        plugin::AddTitleFlag(678, $client);
    }

    if ($recipe_id == 927864) {
        my $name = $client->GetCleanName();
        plugin::WorldAnnounceItem("$name has claimed the {item} from the grasp of history! Hail the Truthbearer!", 2017731);
        plugin::AddTitleFlag(679, $client);
    }
	
	return 0;
}

sub EVENT_COMBINE_SUCCESS {
    if ($recipe_id =~ /^1090[4-7]$/) {
        $client->Message(1,
            "The gem resonates with power as the shards placed within glow unlocking some of the stone's power. ".
            "You were successful in assembling most of the stone but there are four slots left to fill, ".
            "where could those four pieces be?"
        );
    }
    elsif ($recipe_id =~ /^10(903|346|334)$/) {
        my %reward = (
            melee  => {
                10903 => 67665,
                10346 => 67660,
                10334 => 67653
            },
            hybrid => {
                10903 => 67666,
                10346 => 67661,
                10334 => 67654
            },
            priest => {
                10903 => 67667,
                10346 => 67662,
                10334 => 67655
            },
            caster => {
                10903 => 67668,
                10346 => 67663,
                10334 => 67656
            }
        );
        my $type = plugin::ClassType($class);
        quest::summonfixeditem($reward{$type}{$recipe_id});
        quest::summonfixeditem(67704); # Item: Vaifan's Clockwork Gemcutter Tools
        $client->Message(1,"Success");
    }
}

our %SWAP_ITEM_MAP = (
    # Gauntlet and Hammer swaps
    11668 => 11669,
    11669 => 11668,
    
    # Epic swaps
    14383 => 800000,
    10099 => 800001,
    800000 => 14383,
    800001 => 10099,
);

our %CYCLE_ITEM_MAP = (
    2017731 => 2017734,
    2017734 => 2017735,
    2017735 => 2017815,
    2017815 => 2017816,
    2017816 => 2017817,
    2017817 => 2017818,
    2017818 => 2017731,
);

sub EVENT_ITEM_CLICK_CAST_CLIENT {
    if (plugin::CustomEventItemClickCastEntry()) {
        return;
    }

    if ($spell_id == 36878) {
        if (plugin::HasTitle($item_id)) {
            $client->Message(289, "You already have that title, and cannot claim it again.");
            return 1;
        }
        plugin::AddTitleFlag($item_id, $client);
    }

    my $swapped = plugin::transform_item($client, $item_id, $slot_id, \%SWAP_ITEM_MAP, 0);
    
    if (!$swapped && $spell_id == 36874) {
        plugin::transform_item($client, $item_id, $slot_id, \%CYCLE_ITEM_MAP, 1);
    }
}

sub EVENT_CAST_ON {
    # Define groups of mutually exclusive spells
    my %exclusive_groups = (
        'elemental_forms' => [
            2789, 2790, 2791, 2792, 2793, 2794, 2795, 2796, 2797, 2798, 2799, 2800,
            38329, 38330, 38331, 38333, 38334, 38335, 38336, 38337, 38338, 38340, 38341, 38342
        ],
        'pyromancy' => [8406, 8407, 8408],
        'cryomancy' => [11103, 11104, 11105]
    );
    
    foreach my $group_name (keys %exclusive_groups) {
        my $spell_group = $exclusive_groups{$group_name};
        
        if (grep { $_ == $spell_id } @$spell_group) {
            foreach my $id (@$spell_group) {
                next if $id == $spell_id; 
                $client->BuffFadeBySpellID($id);
            }
            last;
        }
    }

    if ($caster_id && $spell) {
        my @global_buffs = (43002, 43003, 43004, 43005, 43006, 43007, 43008, 17779);
        
        if (!(grep { $_ == $spell_id } @global_buffs) && 
            $caster_id == $client->GetID() && 
            $spell->GetBuffDuration() > 0) {
            
            plugin::dispatch_popup("self_buff", $client);
        }
    }
}

sub EVENT_CAST_BEGIN {
    if ($spell_id == 2931 && $zoneid != 159) {
        $client->Message(289, "This may only be used inside Sanctus Seru.");
        $client->InterruptSpell();
        return 1;
    }
}

sub EVENT_SAY {
    my $is_hardcore = $client->IsHardcore();
    my $is_solo = $client->IsSolo();
    my $is_self_found = $client->IsSelfFound();
    quest::debug("Hardcore: [$is_hardcore], Solo: [$is_solo], Self Found: [$is_self_found]");
    if ($client->GetGM()) {
        if ($text=~/#awardtitle\s*(.*)/i) {
            $client->Message(13, "Disregard the command not recognized error.");
            my $arguments = $1; # Captures everything after #awardtitle
            
            my $tar_client = $client->GetTarget();
            if ($tar_client && $tar_client->IsClient()) {
                $tar_client = $tar_client->CastToClient();
            } else {
                return;
            }

            # Validate that there is exactly one argument which is a number
            if ($arguments =~ /^\s*(\d+)\s*$/) {
                my $number = $1; # Captures the number
                # Proceed with awarding the title using $number
                    
                $client->Message(13, "Awarding TitleSet $number to " . $tar_client->GetName());
                plugin::AddTitleFlag($number, $tar_client->CastToClient());
                plugin::CommonCharacterUpdate($tar_client->CastToClient());
                $tar_client->Signal(1);
            } else {
                $client->Message(13, "Invalid input. Please provide a single numeric argument.");
            }
          } elsif ($text=~/#setbucket\s+(\S+)(?:\s+(\d))?/i) {
            my ($flag, $number) = ($1, $2 // 1);  # Default $number to 1 if not provided
            my $tar_client = $client->GetTarget();
            if ($tar_client && $tar_client->IsClient()) {
               $tar_client = $tar_client->CastToClient();
            } else {
                return;
            }
            if ($number >= 0 && $number <= 9) {
                my $client_name = $tar_client->GetCleanName();
                $tar_client->SetBucket("$flag", "$number");
                $tar_client->Message(4, "You completed a quest!");
                $client->Message(4, "Writing to acct ID=".$tar_client->AccountID());
                $client->Message(4, "Writing to char ID=".$tar_client->CharacterID());
                $client->Message(4, "'$flag' bucket set to '$number' for $client_name.");
            } else {
                $client->Message(13, "Invalid number. Please provide a number between 0 and 9.");
            }
        } elsif ($text=~/#setpopflag\s+(\S+)(?:\s+(\d))?/i) {
            my ($flag, $number) = ($1, $2 // 1);  # Default $number to 1 if not provided

            my $tar_client = $client->GetTarget();
            if ($tar_client && $tar_client->IsClient()) {
                $tar_client = $tar_client->CastToClient();
            } else {
                return;
            }

            if ($number >= 0 && $number <= 9) {
                my $client_name = $tar_client->GetCleanName();
                $tar_client->SetAccountBucket("pop.flags.$flag", "$number");
                $tar_client->Message(4, "You receive a character flag!");
                $client->Message(4, "'$flag' flag set to '$number' for $client_name.");
            } else {
                $client->Message(13, "Invalid number. Please provide a number between 0 and 9.");
            }
        } elsif ($text=~/#resetpopflags/i) {
            my $tar_client = $client->GetTarget();
            if ($tar_client && $tar_client->IsClient()) {
                $tar_client = $tar_client->CastToClient();
            } else {
                return;
            }

            my @zoneflags = POPZoneFlags();
            foreach my $zoneflag (@zoneflags) {
                $tar_client->ClearZoneFlag($zoneflag);
            }
    
            my $client_name = $tar_client->GetCleanName();
            $tar_client->DeleteAccountBucket("pop");
            $tar_client->Message(4, "Your Planes of Power flags have been reset.");
            $client->Message(4, "Planes of Power flags reset for $client_name.");
        } elsif ($text=~/#pop/i) {
            my @flags = POPFlags();
            my $tar_client = $client->GetTarget() ? $client->GetTarget() : $client;
	    my $client_name = $tar_client->GetCleanName();
            if ($tar_client && $tar_client->IsClient()) {
                $tar_client = $tar_client->CastToClient();
            } else {
                return;
            }
            quest::message(315, "Target's Planes of Power flags are as follows:");

            foreach my $flag (sort {$a cmp $b} @flags) {
                my $current_value = $tar_client->GetAccountBucket("pop.flags.$flag");
                if ($current_value eq "") {
                    $current_value = 0;
                    #resetpopf
                }

                $flag =~ s/pop\.flags\.//ig;

                quest::message(315, "Flag: $flag Current: $current_value");
            }
        }
    }
}


sub POPFlags {
	my @flags = (
		"aerin",
		"adler",
		"agnarr",
		"arbitor",
		"arlyxir",
		"askr",
		"behemoth",
		"bertox",
		"codecay",
		"coirnav",
		"construct",
		"dresolik",
		"elder",
		"faye",
		"fennin",
		"garn",
		"grummus",
		"hedge",
		"jiva",
		"karana",
		"librarian",
		"maelin",
		"marr",
		"mavuin",
		"newleaf",
		"poxbourne",
		"rallos",
		"rathe",
		"saryrn",
		"shadyglade",
		"story",
		"tallon",
		"terris",
	 	"tribunal",
		"trell",
		"vallon",
	  	"valor",
		"xanamech"
	);

 	return @flags;
}

sub POPZoneFlags {
    my @zoneflags = (
        200,
        207,
        208,
        209,
        210,
        211,
        212,
        214,
        215,
        216,
        217,
        218,
        219,
        220,
        221,
        222,
        223
    );

    return @zoneflags;
}
