sub get_formatted_player_identity {
    my ($client) = @_;
    my $name = $client->GetCleanName();
    my $class = plugin::GetPrettyClassString($client);

    my @modes;
    push @modes, "Solo"       if $client->IsSolo();
    push @modes, "Self-Found" if $client->IsSelfFound();
    push @modes, "Hardcore"   if $client->IsHardcore();

    my $mode_str = join(", ", @modes);
    return $mode_str ? "$name [$class] ($mode_str)" : "$name [$class]";
}

sub get_player_mode_string {
    my ($client) = @_;

    my @modes;
    push @modes, "Solo"       if $client->IsSolo();
    push @modes, "Self-Found" if $client->IsSelfFound();
    push @modes, "Hardcore"   if $client->IsHardcore();

    return join(", ", @modes);
}

sub hardcore_death {
    my ($client, $killer_id, $killed_by_type, $killer_spell, $killer_skill, $zoneln) = @_;

	if (!$client->IsHardcore() || $client->GetGM()) {
		return;
	}
    
    my $player_identity = get_formatted_player_identity($client);
    my $death_zone = $zoneln; # Get the zone name where the player died
    
    # Simplified announcement prefixes - still varied but not excessive
    my @announcement_prefixes = (
        "$player_identity has fallen in hardcore mode in $death_zone",
        "The hardcore journey of $player_identity ends in $death_zone", 
        "$player_identity met their end in hardcore mode while exploring $death_zone",
        "Hardcore player $player_identity perished in the depths of $death_zone",
        "$player_identity has been defeated in hardcore mode in $death_zone",
        "The saga of hardcore $player_identity concludes in $death_zone",
        "$player_identity breathed their last in $death_zone",
        "The tale of $player_identity comes to an end in $death_zone",
        "$player_identity has joined the fallen in $death_zone",
        "Hardcore adventurer $player_identity found their fate in $death_zone"
    );
    
    # Select a random prefix format
    my $prefix_index = int(rand(scalar @announcement_prefixes));
    my $announcement_prefix = $announcement_prefixes[$prefix_index];
    
    # Handle different death types
    if ($killed_by_type == 1) { # DUEL
        # Track duel deaths
        my $killer_count = quest::get_data("hc-deaths.Duel");
        $killer_count++;
        quest::set_data("hc-deaths.Duel", $killer_count);
        
        # Duel death announcements
        my @duel_flavors = (
            "fell in honorable combat",
            "was bested in a duel",
            "lost their final challenge",
            "met defeat in single combat",
            "found their match in battle",
            "fell to a worthy opponent",
            "was outmatched in fair combat",
            "fought valiantly but fell",
            "met their end with honor",
            "gave their all in combat",
            "faced defeat with courage",
            "was conquered in the arena"
        );
        
        my $random_index = int(rand(scalar @duel_flavors));
        my $duel_flavor = $duel_flavors[$random_index];
        
        my $announcement = "$announcement_prefix, having $duel_flavor! ($killer_count)";
        plugin::WorldAnnounce($announcement);
    }
    elsif ($killed_by_type == 2) { # PVP
        # Track PVP deaths
        my $killer_count = quest::get_data("hc-deaths.PVP");
        $killer_count++;
        quest::set_data("hc-deaths.PVP", $killer_count);
        
        # PVP death announcements
        my @pvp_flavors = (
            "fell to another player's blade",
            "was slain in player combat",
            "met their end in PvP",
            "was defeated by a fellow adventurer",
            "lost the ultimate player battle",
            "was cut down by another warrior",
            "fell victim to player warfare",
            "was eliminated in PvP combat",
            "succumbed to another's skill",
            "was outplayed in battle",
            "met their match among players",
            "was conquered by a rival"
        );
        
        my $random_index = int(rand(scalar @pvp_flavors));
        my $pvp_flavor = $pvp_flavors[$random_index];
        
        my $announcement = "$announcement_prefix, having $pvp_flavor! ($killer_count)";
        plugin::WorldAnnounce($announcement);
    }
    elsif ($killed_by_type == 3) { # ENV_LAVA
        # Track lava deaths
        my $killer_count = quest::get_data("hc-deaths.Lava");
        $killer_count++;
        quest::set_data("hc-deaths.Lava", $killer_count);
        
        # Lava death announcements
        my @lava_flavors = (
            "discovered lava is indeed hot",
            "took an unplanned lava bath",
            "melted in molten rock",
            "learned to respect volcanic terrain",
            "became one with the magma",
            "found lava to be unforgiving",
            "was consumed by molten fire",
            "stepped into liquid death",
            "learned lava burns everything",
            "was claimed by the volcano",
            "dissolved in molten stone",
            "found the heat unbearable",
            "was swallowed by fire and stone",
            "having forgotten that the floor is, indeed, lava"
        );
        
        my $random_index = int(rand(scalar @lava_flavors));
        my $lava_flavor = $lava_flavors[$random_index];
        
        my $announcement = "$announcement_prefix, having $lava_flavor! ($killer_count)";
        plugin::WorldAnnounce($announcement);
    }
    elsif ($killed_by_type == 4) { # ENV_FALL
        # Track fall deaths
        my $killer_count = quest::get_data("hc-deaths.Fall Damage");
        $killer_count++;
        quest::set_data("hc-deaths.Fall Damage", $killer_count);
        
        # Fall damage death announcements
        my @fall_flavors = (
            "forgot how to fly",
            "learned gravity still works",
            "took the express route down",
            "discovered the ground is hard",
            "had a sudden meeting with the earth",
            "fell from a great height",
            "found gravity unforgiving",
            "took a fatal tumble",
            "learned to look before leaping",
            "discovered falling hurts",
            "met the ground at high speed",
            "took their final plunge",
            "learned cliff edges are dangerous",
            "found the bottom the hard way",
            "having received the ultimate reminder that gravity does, in fact, exist"
        );
        
        my $random_index = int(rand(scalar @fall_flavors));
        my $fall_flavor = $fall_flavors[$random_index];
        
        my $announcement = "$announcement_prefix, having $fall_flavor! ($killer_count)";
        plugin::WorldAnnounce($announcement);
    }
    elsif ($killed_by_type == 5) { # ENV_DROWN
        # Track drowning deaths
        my $killer_count = quest::get_data("hc-deaths.Drowning");
        $killer_count++;
        quest::set_data("hc-deaths.Drowning", $killer_count);
        
        # Drowning death announcements
        my @drown_flavors = (
            "forgot how to breathe underwater",
            "discovered gills are not optional",
            "learned swimming is important",
            "found the bottom of the deep end",
            "became fish food",
            "took their final dive",
            "learned water and lungs don't mix",
            "found the depths too deep",
            "was claimed by the waters",
            "discovered they weren't part fish",
            "learned to respect deep water",
            "found drowning is no joke",
            "was overcome by the tide",
            "learned air is precious underwater"
        );
        
        my $random_index = int(rand(scalar @drown_flavors));
        my $drown_flavor = $drown_flavors[$random_index];
        
        my $announcement = "$announcement_prefix, having $drown_flavor! ($killer_count)";
        plugin::WorldAnnounce($announcement);
    }
    elsif ($killed_by_type == 6) { # ENV_TRAP
        # Track trap deaths
        my $killer_count = quest::get_data("hc-deaths.Traps");
        $killer_count++;
        quest::set_data("hc-deaths.Traps", $killer_count);
        
        # Trap death announcements
        my @trap_flavors = (
            "triggered their final trap",
            "found the hard way traps still work",
            "discovered an explosive surprise",
            "learned to check for traps too late",
            "became a cautionary tale about dungeon safety",
            "met an ingenious death trap",
            "walked into their doom",
            "found a trap with their face",
            "learned dungeon safety the hard way",
            "was outsmarted by ancient mechanisms",
            "discovered traps are still deadly",
            "fell for a classic trick",
            "became another trap statistic",
            "learned to watch their step too late"
        );
        
        my $random_index = int(rand(scalar @trap_flavors));
        my $trap_flavor = $trap_flavors[$random_index];
        
        my $announcement = "$announcement_prefix, having $trap_flavor! ($killer_count)";
        plugin::WorldAnnounce($announcement);
    }
    # Check if player killed themselves (NPC type with self-damage)
    elsif ($killer_id == $client->GetID()) {
        # Track self-inflicted deaths
        my $killer_count = quest::get_data("hc-deaths.Self-Inflicted");
        $killer_count++;
        quest::set_data("hc-deaths.Self-Inflicted", $killer_count);
        
        # Streamlined self-death flavor text
        my @self_death_flavors = (
            "made a fatal mistake",
            "fell victim to their own actions",
            "learned gravity still works",
            "became their own worst enemy",
            "discovered actions have consequences",
            "took a risk that didn't pay off",
            "found an innovative way to perish",
            "contributed to the 'what not to do' manual",
            "learned from their mistakes too late",
            "was defeated by poor judgment",
            "discovered curiosity killed more than cats",
            "made a spectacularly bad decision",
            "learned some experiments are fatal",
            "found a creative way to fail",
            "was undone by their own hand",
            "having accidentally committed Sudoku"
        );
        
        # Select random self-death flavor text
        my $random_index = int(rand(scalar @self_death_flavors));
        my $self_death_flavor = $self_death_flavors[$random_index];
        
        # Announce self-caused death
        my $announcement = "$announcement_prefix, having $self_death_flavor! ($killer_count)";
        plugin::WorldAnnounce($announcement);
    }
    else { # Default NPC death (killed_by_type == 0)
        my $killer_mob = $entity_list->GetMobID($killer_id);
        my $killer_name = $killer_mob ? $killer_mob->GetCleanName() : "Unknown";
        
        # Track NPC killer deaths
        my $killer_count = quest::get_data("hc-deaths.$killer_name");
        $killer_count++;
        quest::set_data("hc-deaths.$killer_name", $killer_count);
        
        # Check if death was caused by a spell
        if ($killer_spell < 0xFFFF) {
            # Get the spell name
            my $spell_name = quest::getspellname($killer_spell);
            
            # Concise spell death descriptions
            my @spell_death_formats = (
                "obliterated by $killer_name\'s $spell_name",
                "consumed by $killer_name\'s $spell_name",
                "unable to withstand $killer_name\'s $spell_name",
                "struck down by $killer_name\'s $spell_name",
                "overwhelmed by $killer_name\'s $spell_name",
                "incinerated by $killer_name\'s $spell_name",
                "devastated by $killer_name\'s $spell_name",
                "annihilated by $killer_name\'s $spell_name",
                "destroyed by $killer_name\'s $spell_name",
                "eliminated by $killer_name\'s $spell_name"
            );
            
            # Select a random spell death format
            my $format_index = int(rand(scalar @spell_death_formats));
            my $spell_death_format = $spell_death_formats[$format_index];
            
            # Announce spell-caused death
            my $announcement = "$announcement_prefix, $spell_death_format! ($killer_count)";
            plugin::WorldAnnounce($announcement);
        }
        else {
            # Death was caused by a skill - simplified but flavorful descriptions
            my %death_flavors = (
                # 1H Blunt (0)
                0 => [
                    "crushing mace blow",
                    "bone-shattering club strike",
                    "devastating hammer impact",
                    "brutal cudgel swing",
                    "pulverizing mace strike",
                    "skull-crushing blow",
                    "thunderous club impact",
                    "bone-breaking hammer swing"
                ],
                
                # 1H Slashing (1)
                1 => [
                    "deadly sword strike",
                    "precise blade work",
                    "razor-sharp cut",
                    "swift sword technique",
                    "masterful blade strike",
                    "surgical sword cut",
                    "lightning-fast slash",
                    "expert swordplay",
                    "flawless blade technique"
                ],
                
                # 2H Blunt (2)
                2 => [
                    "mighty war hammer blow",
                    "devastating maul strike",
                    "earth-shaking smash",
                    "colossal two-handed impact",
                    "thundering hammer strike",
                    "bone-pulverizing blow",
                    "massive crushing strike",
                    "devastating war club swing"
                ],
                
                # 2H Slashing (3)
                3 => [
                    "massive cleaving strike",
                    "devastating great sword blow",
                    "sweeping executioner's blade",
                    "powerful two-handed slash",
                    "mighty cleaving blow",
                    "overwhelming sword strike",
                    "devastating blade sweep",
                    "crushing two-handed cut"
                ],
                
                # Archery (7)
                7 => [
                    "perfectly aimed arrow",
                    "deadly bow shot",
                    "piercing arrow to the heart",
                    "master archer's precision",
                    "fatal arrow strike",
                    "pinpoint archery",
                    "lethal bow work",
                    "expert marksmanship",
                    "flawless arrow placement"
                ],
                
                # Backstab (8)
                8 => [
                    "treacherous backstab",
                    "assassin's blade from the shadows",
                    "deadly strike from behind",
                    "poisoned dagger work",
                    "silent death from the shadows",
                    "lethal surprise attack",
                    "stealthy killing blow",
                    "shadowy assassination",
                    "deadly sneak attack"
                ],
                
                # Bash (10)
                10 => [
                    "thunderous shield bash",
                    "crushing shield strike",
                    "devastating shield slam",
                    "bone-crushing bash",
                    "pulverizing shield blow",
                    "mighty shield impact",
                    "overwhelming shield strike",
                    "brutal defensive maneuver"
                ],

                # Hand to Hand (28)
                28 => [
                    "deadly martial arts technique",
                    "bare-handed combat mastery",
                    "pressure-point strike",
                    "flurry of devastating blows",
                    "lethal unarmed combat",
                    "bone-crushing martial arts",
                    "masterful hand-to-hand technique",
                    "devastating fighting combination",
                    "expert martial prowess"
                ],
                
                # Kick (30)
                30 => [
                    "bone-shattering kick",
                    "devastating roundhouse",
                    "crushing stomp",
                    "powerful leg sweep",
                    "thunderous kick",
                    "skull-crushing boot",
                    "devastating leg strike",
                    "bone-breaking kick technique"
                ],
                
                # 1H Piercing (36)
                36 => [
                    "precise rapier thrust",
                    "heart-seeking dagger",
                    "surgical piercing strike",
                    "deadly puncture wound",
                    "expert thrusting technique",
                    "pinpoint piercing blow",
                    "lethal stabbing strike",
                    "masterful piercing attack",
                    "fatal puncturing thrust"
                ], 
                
                # 2H Piercing (77)
                77 => [
                    "impaling spear thrust",
                    "devastating pike charge",
                    "heart-piercing lance",
                    "skewering polearm strike",
                    "mighty spear thrust",
                    "bone-piercing lance strike",
                    "overwhelming polearm technique",
                    "devastating two-handed thrust"
                ]
            );
            
            # Simplified default flavors for unknown skills
            my @default_flavors = (
                "brutal attack",
                "lethal strike", 
                "devastating blow",
                "overwhelming assault",
                "masterful technique",
                "superior combat skill",
                "deadly combat prowess",
                "expert fighting ability",
                "crushing combat technique",
                "overwhelming force"
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
            
            # Announce skill-caused death
            my $announcement = "$announcement_prefix, destroyed by $killer_name\'s $death_flavor! ($killer_count)";
            plugin::WorldAnnounce($announcement);
        }
    }
}

sub hardcore_level_up {
	my ($client) = @_;

    if (!$client->IsHardcore() || $client->GetGM()) {
        return;
    }
    
    my $new_level = $client->GetLevel();
    my $player_identity = get_formatted_player_identity($client);
    my $max_level = $client->GetBucket("CharMaxLevel");
    
    my $is_level_cap = ($new_level == $max_level);
    
    my $cooldown_key = "levelup_cooldown";
    my $in_cooldown = $client->GetBucket($cooldown_key);
    
    if ($is_level_cap || !$in_cooldown) {
        plugin::WorldAnnounce("$player_identity has reached Level $new_level!");
		$client->SetBucket($cooldown_key, "1", "1h");
    }
}

sub hardcore_raid_kill {
    my ($client, $killed_npc) = @_;
    
    if (!$client->IsHardcore() || $client->GetGM()) {
        return;
    }
    
    my $npc_type_id = $killed_npc->GetNPCTypeID();
    
    my %raid_bosses = (
        # Classic Era
        1001 => ["Lady Vox", "the ancient white dragon", "Permafrost Keep"],
        1002 => ["Lord Nagafen", "the ancient red dragon", "Nagafen's Lair"],
        1003 => ["Phinigel Autropos", "the Last Knight of the Kedge", "Kedge Keep"],
        1004 => ["Cazic-Thule", "the God of Fear himself", "the Plane of Fear"],
        1005 => ["Dread", "one of Cazic-Thule's terror minions", "the Plane of Fear"],
        1006 => ["Fright", "one of Cazic-Thule's fear minions", "the Plane of Fear"],
        1007 => ["Terror", "one of Cazic-Thule's dread minions", "the Plane of Fear"],
        1008 => ["Innoruuk", "the Prince of Hate himself", "the Plane of Hate"],
        1009 => ["Maestro of Rancor", "the organ-playing lieutenant of Innoruuk", "the Plane of Hate"],
        1010 => ["Eye of Veeshan", "the physical manifestation of the Dragon Mother", "the Plane of Sky"],
        1011 => ["The Hand of Veeshan", "Veeshan's mighty avatar", "the Plane of Sky"],
        1012 => ["Sister of the Spire", "the powerful drake of the spire", "the Plane of Sky"],
        1013 => ["Bazzt Zzzt", "the Queen of the Sky Bees", "the Plane of Sky"],
        1014 => ["The Spiroc Lord", "ruler of the Spiroc birds", "the Plane of Sky"],
        1015 => ["Overseer of Air", "the pegasus island overlord", "the Plane of Sky"],
        1016 => ["Keeper of Souls", "guardian of the tormented spirits", "the Plane of Sky"],
        1017 => ["Gorgalosk", "the mighty pegasus island beast", "the Plane of Sky"],
        1018 => ["Protector of Sky", "defender of the harpy realm", "the Plane of Sky"],
        1019 => ["Noble Dojorn", "the honorable monk master", "the Plane of Sky"],
        1020 => ["Master Yael", "the imprisoned wizard of immense power", "the Hole"],
        1021 => ["Sir Lucan D'Lere", "the fallen paladin guildmaster", "West Freeport"],

        # Ruins of Kunark
        1022 => ["Silverwing", "the silver dragon of the Ring of Scale", "Veeshan's Peak"],
        1023 => ["Nexona", "the guardian dragon of Veeshan's Peak", "Veeshan's Peak"],
        1024 => ["Phara Dar", "the mighty dragon of the Ring", "Veeshan's Peak"],
        1025 => ["Druushk", "the draconic guardian of the peak", "Veeshan's Peak"],
        1026 => ["Xygoz", "the Melodic Dragon of harmonious death", "Veeshan's Peak"],
        1027 => ["Hoshkar", "the Ring of Scale's stalwart guardian", "Veeshan's Peak"],
        1028 => ["Trakanon", "the Undead Dragon and Scourge of Sebilis", "Old Sebilis"],
        1029 => ["Venril Sathir", "the immortal Iksar Lich King", "Karnor's Castle"],
        1030 => ["Gorenaire", "the Ice Dragon of the wasteland", "the Dreadlands"],
        1031 => ["Severilous", "the Emerald Dragon of the jungle", "the Emerald Jungle"],
        1032 => ["Talendor", "the General of the Ring of Scale", "the Skyfire Mountains"],
        1033 => ["Faydedar", "the Lava Dragon of the deep", "Timorous Deep"],
        1034 => ["Overking Bathezid", "the supreme ruler of the Sarnak", "Chardok"],
        1035 => ["Queen Velazul Di'Zok", "the regal Sarnak matriarch", "Chardok"],
        1036 => ["Prince Selrach Di'Zok", "the Sarnak heir to the throne", "Chardok"],
        1037 => ["Kelorek`Dar", "the Ancient Othmir of legend", "Cobalt Scar"],

        # Scars of Velious
        1038 => ["Vulak'Aerr", "the ultimate dragon of the temple", "the Temple of Veeshan"],
        1039 => ["Aaryonar", "the mighty guardian dragon", "the Temple of Veeshan"],
        1040 => ["Lendiniara the Keeper", "the ancient dragon keeper", "the Temple of Veeshan"],
        1041 => ["Gozzrem", "the named dragon of the halls", "the Temple of Veeshan"],
        1042 => ["Telkorenar", "the dragon guardian of quests", "the Temple of Veeshan"],
        1043 => ["Jorlleag", "the mighty temple dragon", "the Temple of Veeshan"],
        1044 => ["Skyfire", "the guardian dragon of flame", "the Temple of Veeshan"],
        1045 => ["Zordakalicus", "the noble guardian dragon", "the Temple of Veeshan"],
        1046 => ["Eashen of the Sky", "the celestial dragon lord", "the Temple of Veeshan"],
        1047 => ["Dozekar the Cursed", "the final boss of the Halls of Testing", "the Temple of Veeshan"],
        1048 => ["Casalen", "the named drake of the halls", "the Temple of Veeshan"],
        1049 => ["Essedera", "the drake guardian of trials", "the Temple of Veeshan"],
        1050 => ["Grozzmel", "the testing drake of power", "the Temple of Veeshan"],
        1051 => ["Krigara", "the trial drake of the halls", "the Temple of Veeshan"],
        1052 => ["Lepethida", "the drake guardian of tests", "the Temple of Veeshan"],
        1053 => ["Midayor", "the testing drake of trials", "the Temple of Veeshan"],
        1054 => ["Tavekalem", "the drake of the trials", "the Temple of Veeshan"],
        1055 => ["Ymmeln", "the final drake of testing", "the Temple of Veeshan"],
        1056 => ["Nanzata the Warder", "the earth elemental warder", "the Sleeper's Tomb"],
        1057 => ["Hraashna the Warder", "the fire elemental warder", "the Sleeper's Tomb"],
        1058 => ["Tukaaram the Warder", "the water elemental warder", "the Sleeper's Tomb"],
        1059 => ["Ventani the Warder", "the air elemental warder", "the Sleeper's Tomb"],
        1060 => ["Kerafyrm", "the Sleeper, the ultimate prismatic dragon", "the Sleeper's Tomb"],
        1061 => ["The Progenitor", "the ancient progenitor of the tomb", "the Sleeper's Tomb"],
        1062 => ["The Final Arbiter", "the ultimate judge of the tomb", "the Sleeper's Tomb"],
        1063 => ["Master of the Guard", "the supreme guardian of the sleepers", "the Sleeper's Tomb"],
        1064 => ["Tunare", "the Mother of All and Goddess of Nature", "the Plane of Growth"],
        1065 => ["Guardian of Tunare", "the divine protector of nature", "the Plane of Growth"],
        1066 => ["King Tormax", "the Storm Giant King of Kael", "Kael Drakkel"],
        1067 => ["Derakor the Vindicator", "the giant champion warrior", "Kael Drakkel"],
        1068 => ["Statue of Rallos Zek", "the war god's stone avatar", "Kael Drakkel"],
        1069 => ["Idol of Rallos Zek", "the war god's sacred idol", "Kael Drakkel"],
        1070 => ["Avatar of War", "the ultimate embodiment of warfare", "Kael Drakkel"],
        1071 => ["Klandicar", "the ancient dragon of the necropolis", "the Western Wastes"],
        1072 => ["Sontalak", "the ancient temple guardian dragon", "the Western Wastes"],
        1073 => ["Lord Yelinak", "the leader of the Claws of Veeshan", "Skyshrine"],
        1074 => ["Zlandicar", "the undead brother of Klandicar", "the Dragon Necropolis"],
        1075 => ["Wuoshi", "the ancient dragon of the rings", "the Wakening Land"],
        1076 => ["Dain Frostreaver IV", "the king of the Coldain dwarves", "Icewell Keep"],
        1077 => ["Velketor the Sorcerer", "the powerful giant sorcerer", "Velketor's Labyrinth"],
        1078 => ["Bristlebane the King of Thieves", "the God of Mischief himself", "the Plane of Mischief"],

        # Shadows of Luclin
        1079 => ["Va Dyn Kar", "the guardian of the Vex Thal keys", "the Umbral Plains"],
        1080 => ["Kaas Thox Xi Ans Dyek", "the first shadow blob guardian", "Vex Thal"],
        1081 => ["Thall Va Xakra", "the northern tower guardian", "Vex Thal"],
        1082 => ["Diabo Xi Xin", "the master of the eastern path", "Vex Thal"],
        1083 => ["Diabo Xi Va", "the master of the western path", "Vex Thal"],
        1084 => ["Diabo Xi Xin Thall", "the Master of Sacred Shadows", "Vex Thal"],
        1085 => ["Thall Va Kelun", "the second floor guardian", "Vex Thal"],
        1086 => ["Thall Xundraux Diabo", "the eastern path boss", "Vex Thal"],
        1087 => ["Diabo Xi Va Temariel", "the western path boss", "Vex Thal"],
        1088 => ["Va Xi Aten Ha Ra", "the shadow guardian of the third floor", "Vex Thal"],
        1089 => ["Kaas Thox Xi Aten Ha Ra", "the northern shadow blob guardian", "Vex Thal"],
        1090 => ["Aten Ha Ra", "the High Priestess of the Akheva", "Vex Thal"],
        1091 => ["High Priest of Ssraeshza", "the supreme Shissar priest", "Ssraeshza Temple"],
        1092 => ["Arch Lich Rhag'Zadune", "the undead lich master", "Ssraeshza Temple"],
        1093 => ["Vyzh'dra the Cursed", "the cursed shissar serpent", "Ssraeshza Temple"],
        1094 => ["Xerkizh the Creator", "the Shissar creator-god", "Ssraeshza Temple"],
        1095 => ["Emperor Ssraeshza", "the ultimate ruler of the Shissar Empire", "Ssraeshza Temple"],
        1096 => ["Praesertum Bikun", "the Shard of the Shoulder", "Sanctus Seru"],
        1097 => ["Praesertum Vantorus", "the Shard of the Hand", "Sanctus Seru"],
        1098 => ["Praesertum Rhugol", "the Shard of the Eye", "Sanctus Seru"],
        1099 => ["Praesertum Matpa", "the Shard of the Heart", "Sanctus Seru"],
        1100 => ["Lord Inquisitor Seru", "the Supreme Inquisitor of the Combine", "Sanctus Seru"],
        1101 => ["Shei Vinitras", "the Akheva outcast leader", "the Akheva Ruins"],
        1102 => ["The Insanity Crawler", "the corrupted shadow creature", "the Akheva Ruins"],
        1103 => ["The Itraer Vius", "the ancient Akheva construct", "the Akheva Ruins"],
        1104 => ["Evolved Burrower", "the enhanced fungal creature", "the Deep"],
        1105 => ["Doomshade", "the tormented spirit of the plains", "the Umbral Plains"],
        1106 => ["Rumblecrush", "the stone giant guardian", "the Umbral Plains"],
        1107 => ["Grieg Veneficus", "the master of the necropolis", "Grieg's End"],
        1108 => ["Khati Sha the Twisted", "the corrupted crystal guardian", "Acrylia Caverns"],

        # Planes of Power
        1109 => ["Grummus", "the Blight of the Diseased", "the Plane of Disease"],
        1110 => ["Bertoxxulous", "the Plaguebringer himself", "the Crypt of Decay"],
        1111 => ["Terris Thule", "the Dream Scorcher", "the Lair of Terris Thule"],
        1112 => ["The Seventh Hammer", "the Avatar of Justice", "the Plane of Justice"],
        1113 => ["Aerin`Dar", "the Champion of the Plane of Valor", "the Plane of Valor"],
        1114 => ["Agnarr the Storm Lord", "the Lord of storms and lightning", "the Bastion of Thunder"],
        1115 => ["Saryrn", "the Mistress of Torment", "the Plane of Torment"],
        1116 => ["Keeper of Sorrows", "the guardian of the tormented realm", "the Plane of Torment"],
        1117 => ["Mithaniel Marr", "the Lightbringer", "the Temple of Marr"],
        1118 => ["Tallon Zek", "the Beholder of Battle", "Drunder, the Fortress of Zek"],
        1119 => ["Vallon Zek", "the Governor of War", "Drunder, the Fortress of Zek"],
        1120 => ["Rallos Zek the Warlord", "the Warlord himself", "Drunder, the Fortress of Zek"],
        1121 => ["Solusek Ro", "the Burning Prince", "Solusek Ro's Tower"],
        1122 => ["Fennin Ro", "the Tyrant of Fire", "Doomfire, the Burning Lands"],
        1123 => ["Coirnav the Avatar of Water", "the Avatar of Water", "the Reef of Coirnav"],
        1124 => ["The Rathe Council", "the Council of Twelve", "Vegarlson, the Earthen Badlands"],
        1125 => ["Avatar of Earth", "the Avatar of Earth", "Vegarlson, the Earthen Badlands"],
        1126 => ["Xegony the Queen of Air", "the Queen of Air", "Eryslai, the Kingdom of Wind"],
        1127 => ["Neimon of Air", "the Air Trial boss", "the Plane of Time"],
        1128 => ["Kazrok of Fire", "the Fire Trial boss", "the Plane of Time"],
        1129 => ["Anar of Water", "the Water Trial boss", "the Plane of Time"],
        1130 => ["Rythor of the Undead", "the Undead Trial boss", "the Plane of Time"],
        1131 => ["Craet of Earth", "the Earth Trial boss", "the Plane of Time"],
        1132 => ["Quarm", "the ultimate multi-headed beast", "the Plane of Time"],
        1133 => ["Manaetic Behemoth", "the mechanical construct", "the Plane of Innovation"]
    );
    
    if (exists $raid_bosses{$npc_type_id}) {
        my $bucket_key = "first_kill.$npc_type_id";
        my $already_killed = $client->GetBucket($bucket_key);
        
        if (!$already_killed) {
            my ($boss_name, $flavor_text, $zone_name) = @{$raid_bosses{$npc_type_id}};
            
            my $player_identity = get_formatted_player_identity($client);
            
            my $announcement = "$player_identity has slain $boss_name, $flavor_text, in $zone_name!";
            plugin::WorldAnnounce($announcement);
            
            $client->SetBucket($bucket_key, "1", "never");
        }
    }
}