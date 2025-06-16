sub EVENT_SAY {
   my $charid = $client->CharacterID();
   my $player_name = $client->GetCleanName();
   my $is_hardcore = $client->IsHardcore();
   
   # Initial greeting
   if($text =~ /Hail/i) {
   	if($is_hardcore) {
   		$client->Message(4, "The spectral figure materializes before you, its ethereal form wavering like mist. Ancient eyes pierce through the veil of death, and a voice echoes directly into your mind...");
   		plugin::NPCTell("Mortal... you stand at the threshold between triumph and tragedy. I am the Keeper of the Lost, guardian of souls whose journeys have met their end.");
   		$client->Message(4, "Your journey has reached a crossroads in death, but the greatest adventures are not always ended by a single fall. I offer you two paths: [" . quest::saylink("relinquish") . "] your sacred oath and continue your journey anew, or embrace the void and let your journey be [" . quest::saylink("cast to oblivion") . "] forever.");
   		plugin::YellowText("You cannot leave Shadowrest until you make a decision about your fate.");
   	} else {
   		$client->Message(4, "The spectral figure regards you with ancient eyes, its form more solid and approving than before.");
   		plugin::NPCTell("Ah, mortal... I sense the change within you. The sacred oath has been released, your trial complete. You are no longer bound to the path of ultimate trial.");
   		$client->Message(4, "You have chosen to continue your journey on a different path, yet you linger in this realm of shadows. Shall I [" . quest::saylink("banish") . "] you back to the world where your deeds await?");
   	}
   }
   
   # Relinquish hardcore status
   elsif($text =~ /relinquish/i && $is_hardcore) {
   	$client->Message(4, "The Keeper's form brightens with approval. To release your sacred oath is to choose a different path. Your journey will continue, though the crucible of ultimate trial will be but memory.");
   	plugin::YellowText("WARNING: Relinquishing hardcore status will remove your hardcore flag permanently. You will continue your journey but lose all hardcore achievements and status.");
   	$client->SendMarqueeMessage(10, "WARNING: This will permanently remove your hardcore status!", 5000);
   	$client->Message(4, "Speak the words '[" . quest::saylink("I release my sacred oath") . "]' to confirm your choice, or '[" . quest::saylink("I reconsider") . "]' to step back from this decision.");
   }
   
   # Cast to oblivion (delete character)
   elsif($text =~ /cast to oblivion/i && $is_hardcore) {
   	$client->Message(13, "The Keeper's eyes blaze with otherworldly fire, and shadows writhe around its form. To choose oblivion is to let your journey end here, to allow your path to fade into eternal darkness.");
   	plugin::YellowText("DANGER: Casting to oblivion will PERMANENTLY DELETE your character. This action cannot be undone!");
   	$client->SendMarqueeMessage(13, "DANGER: This will PERMANENTLY DELETE your character!", 8000);
   	$client->Message(13, "If you truly wish your journey to end, speak these final words: '[" . quest::saylink("I end my journey") . "]'. Otherwise, say '[" . quest::saylink("I reconsider") . "]' to step back from this final choice.");
   }
   
   # Confirmation for relinquishing hardcore
   elsif($text =~ /I release my sacred oath/i) {
   	$client->Message(4, "The Keeper nods solemnly, raising ethereal hands to weave ancient magics. The bonds of your ultimate trial dissolve around you like morning mist.");
   	plugin::NPCTell("It is done. You are freed from the burden of the ultimate path. Rise, mortal, and continue your journey among the living.");
   	$client->SetHardcore(0);
   	$client->Message(4, "The world shimmers around you as you are cast back to life...");
   	plugin::YellowText("Your hardcore flag has been removed. You may continue your Heroes' Journey.");
   	$client->SendMarqueeMessage(15, "Hardcore status removed. You may continue your Heroes' Journey", 4000);
   	$client->GoToBind();
   }
   
   # Confirmation for deletion
   elsif($text =~ /I end my journey/i) {
   	$client->Message(13, "The Keeper's form grows massive and terrible, shadows consuming the very air around you. Your choice is made, mortal. Let your journey end here, among the annals of those who dared the ultimate trial.");
   	plugin::NPCTell("May your deeds be remembered, even as your journey reaches its end. Farewell, $player_name...");
   	plugin::YellowText("Your character is being deleted. Your journey ends here. Farewell, $player_name.");
   	$client->SendMarqueeMessage(13, "YOUR JOURNEY HAS CONCLUDED - FAREWELL", 6000);
   	quest::settimer("delete_character_$player_name", 7);
   }
   
   # Reconsider decision
   elsif($text =~ /I reconsider/i) {
   	$client->Message(4, "The Keeper's form dims slightly, and a hint of approval crosses its spectral features. Even the greatest heroes must sometimes pause to consider their path.");
   	plugin::NPCTell("Return to me when you have made your choice. I am eternal, and I will wait for your decision.");
   }
   
   # Banish non-hardcore players
   elsif($text =~ /banish/i && !$is_hardcore) {
   	$client->Message(4, "The Keeper nods with finality, raising its hands as reality begins to shimmer around you.");
   	plugin::NPCTell("Return to the realm of the living, mortal. Your journey continues on a different path, but it continues nonetheless.");
   	$client->Message(4, "The world fades around you as you return to continue your Heroes' Journey...");
   	$client->GoToBind();
   }
   
   # Prevent hardcore options for non-hardcore players
   elsif(($text =~ /relinquish/i || $text =~ /cast to oblivion/i) && !$is_hardcore) {
   	$client->Message(13, "The Keeper's voice echoes with confusion. You speak of oaths that no longer bind you, mortal. Your path has already been chosen.");
   	plugin::NPCTell("Seek [" . quest::saylink("banish") . "]ment from this realm instead.");
   }
   
   # Prevent banish for hardcore players
   elsif($text =~ /banish/i && $is_hardcore) {
   	$client->Message(13, "The Keeper's form darkens with displeasure. You are still bound by your sacred oath, mortal. Make your choice first - release your oath or end your journey.");
   }
   
   # Default response for unrecognized text
   else {
   	$client->Message(13, "The Keeper's form flickers with annoyance. Speak clearly, mortal, or waste not my eternal vigil with meaningless words.");
   }
}

sub EVENT_TIMER {
   if($timer =~ /^delete_character_(.+)$/) {
   	my $player_name = $1;
   	quest::DeleteCharacter($player_name);
   }
}