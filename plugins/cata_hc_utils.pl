sub hardcore_death {
    my ($client, $killer_id, $killed_by_type, $killer_spell, $killer_skill, $zoneln) = @_;
    
    my $player_name = $client->GetCleanName();
    my $player_class = plugin::GetPrettyClassString($client);
    my $death_zone = $zoneln; # Get the zone name where the player died
    
    # Simplified announcement prefixes - still varied but not excessive
    my @announcement_prefixes = (
        "$player_name ($player_class) has fallen in hardcore mode in $death_zone",
        "The hardcore journey of $player_name ($player_class) ends in $death_zone", 
        "$player_name ($player_class) met their end in hardcore mode while exploring $death_zone",
        "Hardcore player $player_name ($player_class) perished in the depths of $death_zone",
        "$player_name ($player_class) has been defeated in hardcore mode in $death_zone",
        "The saga of hardcore $player_name ($player_class) concludes in $death_zone",
        "$player_name ($player_class) breathed their last in $death_zone",
        "The tale of $player_name ($player_class) comes to an end in $death_zone",
        "$player_name ($player_class) has joined the fallen in $death_zone",
        "Hardcore adventurer $player_name ($player_class) found their fate in $death_zone"
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