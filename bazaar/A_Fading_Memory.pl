sub EVENT_SAY {
  if ($text=~/hail/i) {
    if (!$client->GetBucket('newbieRewardBits')) {
      quest::emote("laughs");
      quest::say("Oh my, you really don’t remember me do you? I could never forget a comrade in arms! 
                  Hail $name! Let me see that faded writ and I’ll give you something to jog your memory");
      if (!plugin::check_hasitem($client, 18471)) {
        $client->SummonItem(18471);
        $client->Message(263, "You find a small note in your pocket.");
      }
    } else {
      quest::emote("laughs");
      quest::say("I'm so glad to see you again!");
      RewardItems($client);
    }
  }
  if ($text=~/note/i) {
    $client->SummonItem(18471);
    $client->Message(263, "You find a small note in your pocket.");
  }
}

sub EVENT_ITEM {
  if (plugin::check_handin(\%itemcount, 18471 => 1)) {
    if (!$client->GetBucket('newbieRewardBits')) {
      RewardItems($client);
      quest::givecash(0,6,2,0);
    }
  } else {
    quest::say("I don't need this item, $name. Perhaps you should keep it.");
  }
  plugin::return_items(\%itemcount);
}

sub RewardItems {
  my ($client) = @_;

  my %classRewards = (
    1     => { items => [2005008, 2013514, 17708], cash => 3 },                   # Warrior
    2     => { items => [2009999, 2013542, 9985, 9993], cash => 3 },              # Cleric
    4     => { items => [2055623, 2013514, 59971], cash => 3 },                  # Paladin
    8     => { items => [2009998, 2008009, 2008500, 2008500, 2013514, 15239], cash => 3 },  # Ranger
    16    => { items => [2055623, 2013514, 899980, 15340], cash => 3 },          # Shadow Knight
    32    => { items => [2009999, 2013542, 899981, 9984, 9994], cash => 3 },     # Druid
    64    => { items => [2067133, 2013514, 17708], cash => 3 },                  # Monk
    128   => { items => [2009998, 2013514, 9992, 15703, 899983, 9992], cash => 3 },  # Bard
    256   => { items => [2009997, 2013514, 44531, 17708], cash => 3 },           # Rogue
    512   => { items => [2009999, 2013542, 899984, 9983, 9994], cash => 3 },     # Shaman
    1024  => { items => [2006012, 2013566, 899985, 9989, 15338], cash => 3 },    # Necromancer
    2048  => { items => [2006012, 2013566, 15372, 9986], cash => 3 },            # Wizard
    4096  => { items => [2006012, 2013566, 899986, 15315, 9994], cash => 3 },    # Magician
    8192  => { items => [2006012, 2013566, 899987, 15681, 9987], cash => 3 },    # Enchanter
    16384 => { items => [2067133, 2013514, 899988, 59971], cash => 3 },          # Beastlord
    32768 => { items => [2005003, 2013514, 17708], cash => 3 },                  # Berserker
  );

  my $playerClassBitmask = $client->GetClassesBitmask();
  my $rewardedClassesBitmask = $client->GetBucket('newbieRewardBits') || 0;
  my $rewardGiven = 0;

  if ($rewardedClassesBitmask == 0) {
    $client->SummonFixedItem(17423);
  }

  foreach my $classBitmask (keys %classRewards) {
    if (($playerClassBitmask & $classBitmask) && !($rewardedClassesBitmask & $classBitmask)) {
      foreach my $item (@{$classRewards{$classBitmask}->{items}}) {
        if ($item == 2008500 || !plugin::check_hasitem_exact($client, $item)) {
          $client->SummonFixedItem($item);
        }
      }
      $client->AddMoneyToPP(0, $classRewards{$classBitmask}->{cash}, 0, 0);
      $rewardedClassesBitmask |= $classBitmask;
      $rewardGiven = 1;
    }
  }

  if ($rewardGiven) {
    $client->SetBucket('newbieRewardBits', $rewardedClassesBitmask);

    my $response = "Hmmm… Does this refresh your memory at all? I think you’ll find that if you look around here long enough, things will seem more and more like you remember. If you are ready to start your adventure, speak to Tearel to learn how to get around.";
    if (plugin::MultiClassingEnabled()) {
      $response = "Hmmm… Does this refresh your memory at all? Perhaps your spirit yearns for something different this time around. Go and speak to the guild masters that have taken refuge here. They may just be willing to let you learn their ways. After you've decided which paths are for you, return to me for equipment more suited to your new endeavors. If you are ready to start your adventure, speak to Tearel to learn how to get around.";
    }

    quest::say($response);
  }
}
