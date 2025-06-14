sub list_unlock_progress {
    my $client = shift;
    
    my @flags = quest::GetProgressionFlagsList();
    
    for my $flag (@flags) {
        my $flag_name = $flag->{name};
        my $description = $flag->{description};
        
        if ($client->IsProgressionFlagUnlocked($flag_name)) {
            plugin::YellowText("You have unlocked access to $description.");
        } else {
            plugin::YellowText("You have NOT unlocked access to $description.");
        }
    }
}

sub list_stage_prereq {
    my ($client, $target_flag) = @_;
    
    my @stages = quest::GetProgressionStagesForFlag($target_flag);
    
    for my $stage (@stages) {
        my $stage_name = $stage->{name};
        my $completed = $client->IsProgressionStageUnlocked($stage_name) ? "Completed" : "Not Completed";       
        
        my $display_name = $stage_name;
        $display_name =~ s/\b(\w)/\U$1/g;  
        
        plugin::YellowText("$display_name: $completed");
    }
}

sub is_stage_complete {
    my ($client, $stage_name) = @_;
    
    return $client->IsProgressionStageUnlocked($stage_name);
}

sub is_flag_complete {
    my ($client, $flag_name) = @_;

    return $client->IsProgressionFlagUnlocked($flag_name);
}

sub is_eligible_for_zone {
    my ($client, $zone_name, $inform) = @_;    
    $inform //= 0;

    return 1 if $client->GetGM();

    my $zone_id = quest::GetZoneID($zone_name);

    if ($client->IsZoneUnlockedByProgression($zone_id)) {
        return 1;
    } else {
        if ($inform) {
            $client->Message(263, "You are not yet ready to experience that memory.");
        }
        return 0;
    }
}

sub handle_death {
    my ($npc, $x, $y, $z, $entity_list) = @_;

    my $zoneid          = plugin::val('$zoneid');
    my $instanceid      = plugin::val('$instanceid');
    my $instanceversion = plugin::val('$instanceversion');

    if (!$instanceversion && !$instanceid) {
        return;
    }

    my $npc_name = lc($npc->GetCleanName());
    $npc_name =~ s/^[#\s]+|[#\s]+$//g;

    if (quest::DoesProgressionStageExist($npc_name)) {
        my $flag_mob = quest::spawn2(26000, 0, 0, $x, $y, ($z + 10), 0);
        my $new_npc = $entity_list->GetNPCByID($flag_mob);       
        
        $new_npc->SetEntityVariable("Flag-Name", $npc_name);
    }    
}

sub update_character_max_level {
    my $client = shift;
    my $CharMaxLevel = 51;

    if (plugin::IsTHJ()) {
        $CharMaxLevel = 50;
    }

    if ($client->IsProgressionFlagUnlocked('RoK')) {
        $CharMaxLevel = 60;
    }
    if ($client->IsProgressionFlagUnlocked('PoP')) {
        $CharMaxLevel = 65;
    } 
    if ($client->IsProgressionFlagUnlocked('GoD')) {
        $CharMaxLevel = 70;
    }

    my $current_cap = $client->GetBucket("CharMaxLevel") || 0;
    if ($current_cap != $CharMaxLevel) {
        $client->SetBucket("CharMaxLevel", $CharMaxLevel);        
        plugin::YellowText("Your Level Cap has been set to $CharMaxLevel.");
    }
}

sub convert_old_progression_data {
    my $client = shift;

    if ($client->GetAccountBucket("legacy_flag_converted")) {
        return;
    }
    
    my @flags_to_convert = ('RoK', 'SoV', 'SoL', 'PoP', 'GoD', 'OoW', 'DoN', 'FNagafen');
    
    foreach my $stage (@flags_to_convert) {
        my $old_flag_data = quest::get_data($client->AccountID() . "-progress-flag-$stage");
        
        next unless $old_flag_data;
        
        my %old_progress = plugin::DeserializeHash($old_flag_data);
        
        foreach my $objective_name (keys %old_progress) {
            if ($old_progress{$objective_name}) {
                my $clean_name = lc($objective_name);
                $clean_name =~ s/^\s+|\s+$//g;
                
                if (quest::DoesProgressionStageExist($clean_name)) {
                    my $result = $client->UnlockProgressionStage($clean_name);
                    if ($result) {
                        plugin::Debug("Converted progression stage: $clean_name");
                    }
                } else {
                    plugin::Debug("Warning: Stage '$clean_name' not found in new progression system");
                }
            }
        }
        
        quest::delete_data($client->AccountID() . "-progress-flag-$stage");
    }
    
    update_character_max_level($client);    

    $client->SetAccountBucket("legacy_flag_converted", 1);

    plugin::YellowText("Progression data conversion completed.");
}

sub handle_killed_merit {
    my ($npc, $client, $entity_list) = @_;
}

sub get_progression_flag_description {
    my ($client, $flag_name) = @_;
    return quest::GetProgressionFlagDescription($flag_name);
}

sub progression_flag_exists {
    my ($client, $flag_name) = @_;
    return quest::DoesProgressionFlagExist($flag_name);
}

sub progression_stage_exists {
    my ($client, $stage_name) = @_;
    return quest::DoesProgressionStageExist($stage_name);
}

sub get_zone_progression_flag {
    my ($client, $zone_id) = @_;
    return quest::GetProgressionFlagForZone($zone_id);
}

sub unlock_progression_stage {
    my ($client, $stage_name) = @_;
    
    if ($client->UnlockProgressionStage($stage_name)) {
        plugin::YellowText("You have gained a progression flag!");
        plugin::BlueText("Your memories become more clear, you see the way forward drawing closer.");
        
        update_character_max_level($client);
        
        return 1;
    }
    
    return 0;
}

sub unlock_stage {
    my ($client, $stage_name) = @_;
    
    $stage_name = lc($stage_name);
    $stage_name =~ s/^\s+|\s+$//g; 
    
    if (!quest::DoesProgressionStageExist($stage_name)) {
        quest::debug("Error: Stage [$stage_name] does not exist.");
        return 0;
    }

    if ($client->IsProgressionStageUnlocked($stage_name)) {
        quest::debug("Stage: $stage_name already unlocked");
        return 0;
    }
    
    if ($client->UnlockProgressionStage($stage_name)) {
        my $flag_name = quest::GetProgressionFlagForStage($stage_name);

        plugin::YellowText("You have gained a progression flag!");
        plugin::BlueText("Your memories become more clear, you see the way forward drawing closer.");
        
        if ($flag_name eq 'RoK') {
            plugin::BlueText("Your mind flashes with recollections of savage lands; dense jungles, desolate swamps, and fiery wastes.");
        }
        elsif ($flag_name eq 'SoV') {
            plugin::BlueText("You almost feel a chill in your bones as your mind fills with visions of endless ice plains, and fortresses filled with Giants and Dragons alike.");
        }
        elsif ($flag_name eq 'SoL') {
            plugin::BlueText("Your mind recoils at the eldritch horror; dark shadows whisper to you of rites and mysteries alike.");
        }
        elsif ($flag_name eq 'PoP') {
            plugin::BlueText("You sense a disturbance in the planes; a power grows near... again.");
        }
        elsif ($flag_name eq 'GoD') {
            plugin::BlueText("You remember an island lost to the mists, conquered and shattered, yet its people's will remains unbroken.");
        }
        elsif ($flag_name eq 'OoW') {
            plugin::BlueText("You recall the Overlord of the invasion, sitting in his throne as he surveys the worlds he regards as prey.");
        }
        elsif ($flag_name eq 'DoN') {
            plugin::BlueText("You recall the ancient dragons, and grow fearful at the prospect of them stirring once more.");
        }
        
        update_character_max_level($client);
        
        return 1;
    }
}

sub is_valid_progression_instance {
    my ($zoneid, $instanceid, $instanceversion) = @_;

    if ($instanceversion == quest::get_rule("Custom:StaticInstanceVersion")) {
        return 1;
    } else {
        return 0;
    }
}

1;