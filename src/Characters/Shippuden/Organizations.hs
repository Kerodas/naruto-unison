{-# LANGUAGE OverloadedLists #-}
{-# OPTIONS_HADDOCK hide     #-}

module Characters.Shippuden.Organizations (cs) where

import Characters.Base

import qualified Model.Skill as Skill

cs :: [Category -> Character]
cs =
  [ Character
    "Shisui Uchiha"
    "An operative of the Hidden Leaf Village, Shisui gained the rare Mangekyō Sharingan after witnessing his friend die on a mission. Known as Shisui the Teleporter for his perfect mastery of the Teleportation Technique, the former jōnin prodigy is compassionate and open-minded to a fault. His signature technique makes him all but impossible to flank and allows him to beleaguer his opponents without leaving himself vulnerable."
    [ [ Skill.new
        { Skill.name      = "Susanoo"
        , Skill.desc      = "Shisui surrounds himself with chakra armor, gaining 45 permanent destructible defense. While Shisui has destructible defense from this skill, he gains a stack of Susanoo every turn and this skill becomes [Tsukumo][b]. Stacks of Susanoo last as long as he has destructible defense from this skill."
        , Skill.classes   = [Chakra]
        , Skill.cost      = [Blood]
        , Skill.cooldown  = 3
        , Skill.dur       = Action 0
        , Skill.start     =
          [ To Self do
                defend 0 45
                vary "Susanoo" "Tsukumo"
                onBreak do
                    cancelChannel "Tsukumo"
                    remove "Susanoo"
                    vary "Susanoo" baseVariant
          ]
        , Skill.effects   =
          [ To Self addStack ]
        }
      , Skill.new
        { Skill.name      = "Tsukumo"
        , Skill.desc      = "Shisui's Susanoo sprays a barrage of needles that deal 15 damage to all enemies and weaken their damage by 5. The weakening effect lasts for as many turns as Shisui has stacks of Susanoo."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Blood]
        , Skill.effects   =
          [ To Enemies do
                damage 15
                stacks <- userStacks "Susanoo"
                apply stacks [Weaken All Flat 5]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Teleportation Technique"
        , Skill.desc      = "For 2 turns, if an enemy uses a skill on Shisui, he will deal 15 damage to them and become invulnerable for the rest of the turn."
        , Skill.classes   = [Physical, Invisible]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Self $ trapFrom 2 (CounterAll All) do
                damage 15
                self $ apply (-1) [Invulnerable All]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Kotoamatsukami"
        , Skill.desc      = "Using his Mangekyō Sharingan, Shisui traps an enemy in a powerful genjutsu. The next time they use a skill, their team will lose 1 random chakra. Until they use a skill, Shisui can use this skill with no chakra cost to transfer Kotoamatsukami to a different enemy."
        , Skill.classes   = [Mental, Ranged, Invisible]
        , Skill.cost      = [Blood, Gen]
        , Skill.effects   =
          [ To Enemy do
                self $ vary "Kotoamatsukami" "Kotoamatsukami"
                trap 0 (OnAction All) do
                    self $ vary "Kotoamatsukami" baseVariant
                    deplete 1
                trap 0 OnDeath $ self $ vary "Kotoamatsukami" baseVariant
          ]
        }
      , Skill.new
        { Skill.name      = "Kotoamatsukami"
        , Skill.desc      = "Using his Mangekyō Sharingan, Shisui traps an enemy in a powerful genjutsu. The next time they use a skill, their team will lose 1 random chakra. Until they use a skill, Shisui can use this skill with no chakra cost to transfer Kotoamatsukami to a different enemy."
        , Skill.classes   = [Mental, Ranged, Invisible]
        , Skill.cost      = []
        , Skill.effects   =
          [ To Enemy do
                everyone $ removeTrap "Kotoamatsukami"
                trap 0 (OnAction All) do
                    self $ vary "Kotoamatsukami" baseVariant
                    deplete 1
          ]
        }
      ]
    , [ invuln "Block" "Shisui" [Physical] ]

    ]
  , Character
    "Sai"
    "An operative of the Hidden Leaf Village's elite Root division, Sai is quietly expressive and artistic. He uses a set of brushes with chakra-infused ink to give life to his illustrations, which usually take the form of powerful black-and-white beasts."
    [ [ Skill.new
        { Skill.name      = "Super Beast Scroll: Lions"
        , Skill.desc      = "Sai draws a pack of lions that attack an enemy, dealing 30 damage to them and providing 20 destructible defense to Sai for 1 turn."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Gen, Rand]
        , Skill.effects   = [ To Enemy $ damage 30
                            , To Self  $ defend 1 20
                            ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Super Beast Scroll: Snake"
        , Skill.desc      = "Sai draws a snake that paralyzes an enemy with its bite, stunning their physical and chakra skills for 1 turn and preventing them from reducing damage or becoming invulnerable. During [Ink Mist], this skill becomes [Super Beast Scroll: Bird][g]."
        , Skill.classes   = [Physical, Melee, Bypassing]
        , Skill.cost      = [Gen]
        , Skill.effects   =
          [ To Enemy $ apply 1 [Stun Physical, Stun Chakra, Expose] ]
        }
      , Skill.new
        { Skill.name      = "Super Beast Scroll: Bird"
        , Skill.desc      = "Sai draws a bird in the air, which deals 25 damage to an enemy and stuns them for 1 turn."
        , Skill.classes   = [Physical, Melee, Bypassing]
        , Skill.cost      = [Gen]
        , Skill.effects   =
          [ To Enemy do
                damage 25
                apply 1 [Stun All]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Ink Mist"
        , Skill.desc      = "Streams of ink coil in the air around Sai and his allies for 3 turns, obscuring them from enemies and allowing Sai to draw three-dimensionally. If an enemy uses a skill to stun someone on Sai's team, their target becomes invulnerable for 1 turn. If an enemy uses a skill that gains, depletes, or absorbs chakra, Sai's team gains 1 random chakra. If an enemy uses a skill that deals non-affliction damage to someone on Sai's team, Sai's damage increases by 10 for 1 turn."
        , Skill.classes   = [Mental, Bypassing]
        , Skill.cost      = [Rand, Rand]
        , Skill.effects   =
          [ To Enemies $ trap 3 OnChakra $ self $ gain [Rand]
          , To Allies do
                trap 3 OnStunned $ apply 1 [Invulnerable All]
                trap 3 (OnDamaged NonAffliction) $
                    self $ apply 1 [Strengthen All Flat 10]
          , To Self $ vary' 3 "Super Beast Scroll: Snake"
                              "Super Beast Scroll: Bird"
          ]
        }
      ]
    , [ invuln "Ink Clone" "Sai" [Chakra] ]
    ]
  , Character
    "Yamato"
    "An operative of the Hidden Leaf Village's elite Root division, Yamato has had many identities, also going by the names Kinoe and Tenzō. The sole survivor of Orochimaru's horrifying experiments on children, he carries the first Hokage's wood-manipulation abilities along with his DNA. His mastery of power supppression makes him a grave threat against hosts of tailed beasts and others who accumulate power gradually."
    [ [ Skill.new
        { Skill.name      = "Tenth Edict on Enlightenment"
        , Skill.desc      = "Using the legendary chakra-suppression technique with which Hashirama subdued tailed beasts, Yamato negates all power an enemy has accumulated. They completely reset to their state at the start of the game, except that their health is not restored."
        , Skill.classes   = [Chakra, Melee]
        , Skill.cost      = [Blood, Blood, Rand]
        , Skill.charges   = 1
        , Skill.effects   =
          [ To Enemy do
                health <- target health
                factory
                setHealth health
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Wood Clone"
        , Skill.desc      = "Yamato protects himself or an ally with a clone of wood for 1 turn, countering the first non-mental skill an enemy uses on them. If countered, the attacker receives 20 damage and the target gains 20 permanent destructible defense, and [Tenth Edict on Enlightenment] is recharged."
        , Skill.classes   = [Physical, Melee, Invisible]
        , Skill.cost      = [Blood]
        , Skill.cooldown  = 2
        , Skill.effects   =
          [ To Ally do
                trapFrom 1 (Counter All) $ damage 20
                trap 1 (Counter All) do
                    defend 0 20
                    self resetCharges
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Four-Pillar Architecture"
        , Skill.desc      = "If used on an ally, a wooden house rises from the ground around Yamato's team and provides all of them with 20 permanent destructible defense. If used on an enemy, a wooden prison rises from the ground around the enemy team and applies 20 permanent destructible barrier to all of them."
        , Skill.classes   = [Chakra, Ranged, Bypassing]
        , Skill.cost      = [Blood, Nin]
        , Skill.cooldown  = 4
        , Skill.effects   =
          [ To Ally  $ allies  $ defend  0 20
          , To Enemy $ enemies $ barrier 0 20
          ]
        }
      ]
    , [ invuln "Wood Wall" "Yamato" [Physical] ]
    ]
  , Character
    "Fū Yamanaka"
    "An operative of the Hidden Leaf Village's elite Root division, Fū is emotionless and ruthlessly straightforward. His only drive is unswerving loyalty to Danzō. His combination of long-distance Yamanaka genjutsu and his personal form of taijutsu makes him a formidable threat in any situation, but his trump card is the ability to swap his consciousness into the body of an opponent and make use of all their skills."
    [ [ Skill.new
        { Skill.name      = "Tantō Slash"
        , Skill.desc      = "Fū slashes an enemy with his tantō, dealing 25 damage. Deals 15 additional damage if the target is affected by [Mind Transfer]."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Tai]
        , Skill.effects   =
          [ To Enemy do
                bonus <- 15 `bonusIf` targetHas "Mind Transfer"
                damage (25 + bonus)
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Mind Transfer"
        , Skill.desc      = "Fū takes over an enemy's mind and steals all removable beneficial effects on them. The target's destructible defense is transferred to Fū, and Fū's destructible barrier is transferred to the target. While active, Fū detects all invisible effects and enemy cooldowns."
        , Skill.classes   = [Chakra]
        , Skill.cost      = [Gen]
        , Skill.cooldown  = 3
        , Skill.dur       = Control 3
        , Skill.start     = [ To Enemy commandeer ]
        , Skill.effects   =
          [ To Enemy do
                tag 1
                enemies $ hide' "revealed" 1 [Reveal]
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Mind Transfer Puppet Curse"
        , Skill.desc      = "Fū defends himself or an ally with a puppet trap. For 2 turns, the first enemy who uses a non-mental skill on the target will be countered. If an enemy is countered, Fū's skills are replaced by their skills for 4 turns and their skills are replaced by [Puppet Curse: Attack] for 4 turns. Effects from Fū's usage of their skills are canceled when Fū's skills revert."
        , Skill.classes   = [Mental, InvisibleTraps, Unreflectable]
        , Skill.cost      = [Gen]
        , Skill.cooldown  = 3
        , Skill.effects   =
          [ To Ally $ trapFrom' 2 (Counter NonMental) do
                setFace (-4)
                copyAll 4
                tag (-4)
                teach 4 Shallow 4
                teachOne 4 3 Deep 5
                self do
                    resetAll
                    bomb (-4) [] [ To Done resetAll ]
          ]
        }
      ]
    , [ invuln "Dodge" "Fū" [Physical] ]
    , [ Skill.new
        { Skill.name      = "Puppet Curse: Attack"
        , Skill.desc      = "Trapped in a puppet, little can be done but flail about and hope to hit someone! Deals 15 damage to an enemy."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Rand]
        , Skill.effects   =
          [ To Enemy $ damage 15 ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Puppet Curse: Defend"
        , Skill.desc      = "Trapped in a puppet, little can be done but flail about and hope to block an attack! The puppet becomes invulnerable for 1 turn."
        , Skill.classes   = [Physical, Melee]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 4
        , Skill.effects   =
          [ To Self $ apply 1 [Invulnerable All] ]
        }
      ]
    ]
  , Character
    "Torune Aburame"
    "An operative of the Hidden Leaf Village's elite Root division, Torune was born with rare venom-resistant antibodies that allow him to carry the Aburame clan's most dangerous species of beetle. The venom beetles cover his skin like armor, protecting him and infesting anyone who dares to touch him."
    [ [ Skill.new
        { Skill.name      = "Nano-Sized Venom Beetles"
        , Skill.desc      = "Torune applies a Venom Beetle to an enemy, dealing 5 affliction damage for 5 turns, and gains 15 permanent destructible defense. Whoever destroys Torune's destructible defense from this skill will have a Venom Beetle applied to them. While Torune has destructible defense from this skill, this skill costs 1 random chakra but does not provide any destructible defense."
        , Skill.classes   = [Bane, Melee]
        , Skill.cost      = [Blood]
        , Skill.cooldown  = 0
        , Skill.effects   =
          [ To Enemy $ apply' "Venom Beetle" 5 [Afflict 5]
          , To Self do
                defend 0 15
                onBreak $ addStacks "Venom Beetle" 1
          ]
        , Skill.changes   =
            changeWithDefense "Nano-Sized Venom Beetles" \x ->
              x { Skill.cost = [Rand]
                , Skill.effects = take 1 $ Skill.effects x
                }
        }
      ]
    , [ Skill.new
        { Skill.name      = "Jar of Poison"
        , Skill.desc      = "Torune applies a Venom Beetle to all enemies, dealing 5 affliction damage to each for 5 turns, and gains 30 permanent destructible defense. Whoever destroys Torune's destructible defense from this skill will have a Venom Beetle applied to them. While Torune has destructible defense from this skill, this skill costs 1 random chakra but does not provide any destructible defense."
        , Skill.classes   = [Bane, Melee]
        , Skill.cost      = [Blood, Blood]
        , Skill.cooldown  = 0
        , Skill.effects   =
          [ To Enemies $ apply' "Venom Beetle" 5 [Afflict 5]
          , To Self do
                defend 0 30
                onBreak $ addStacks "Venom Beetle" 1
          ]
        , Skill.changes   =
            changeWithDefense "Jar of Poison" \x ->
              x { Skill.cost    = [Rand, Rand]
                , Skill.effects = take 1 $ Skill.effects x
                }
        }
      ]
    , [ Skill.new
        { Skill.name      = "Venom Explosion"
        , Skill.desc      = "Torune detonates all Venom Beetles on an enemy, depleting 1 random chakra for each Venom Beetle destroyed. "
        , Skill.require   = HasU 1 "Venom Beetle"
        , Skill.classes   = [Bane, Melee]
        , Skill.cost      = [Blood, Blood, Rand]
        , Skill.cooldown  = 2
        , Skill.effects   =
          [ To Enemy do
                stacks <- targetStacks "Venom Beetle"
                deplete stacks
          ]
        }
      ]
    , [ invuln "Dodge" "Torune" [Physical] ]
    ]
  , Character
    "Danzō Shimura"
    "The founder and leader of the Hidden Leaf Village's elite Root division, Danzō has had a hand in almost every important global event since he came to power. His numerous implanted Sharingans allow him to repeatedly cheat death."
    [ [ Skill.new
        { Skill.name      = "Izanagi"
        , Skill.desc      = "Danzō gains 10 Sharingan and loses 1 each turn. If his health reaches 0, he regains 10 health per Sharingan and loses all Sharingan. When he has no Sharingan remaining, this skill becomes [Reverse Tetragram Sealing][r][r][r]."
        , Skill.classes   = [Mental, Resource]
        , Skill.cost      = [Blood]
        , Skill.dur       = Ongoing 0
        , Skill.start     =
          [ To Self do
                addStacks "Sharingan" 10
                vary "Izanagi" "Izanagi"
          ]
        , Skill.effects   =
          [ To Self $ unlessM (userHas "paused") do
                removeStack "Sharingan"
                unlessM (userHas "Sharingan") do
                    cancelChannel "Izanagi"
                    vary "Izanagi" "Reverse Tetragram Sealing"
                    trap' 1 OnRes do
                        cancelChannel "Izanagi"
                        vary "Izanagi" "Reverse Tetragram Sealing"
                        stacks <- userStacks "Sharingan"
                        setHealth (10 * stacks)
                        remove "Sharingan"
          ]
        }
      , Skill.new
        { Skill.name      = "Izanagi"
        , Skill.desc      = "Pauses the effect of [Izanagi] for 1 turn."
        , Skill.classes   = [Mental]
        , Skill.cost      = [Blood]
        , Skill.effects   = [ To Self $ flag' "paused"]
        }
      , Skill.new
        { Skill.name      = "Reverse Tetragram Sealing"
        , Skill.desc      = "Kills Danzō and makes all enemies immune to effects from each other for 3 turns. In 3 turns, enemies who are not invulnerable die."
        , Skill.classes   = [Mental, Bypassing, Unremovable]
        , Skill.cost      = [Rand, Rand, Rand]
        , Skill.effects   =
          [ To Enemies $ delay (-3) kill
          , To Self do
                enemies $ apply (-3) [Seal]
                kill
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Vacuum Wave"
        , Skill.desc      = "Danzō exhales slicing blades of air at an enemy, dealing 20 piercing damage. Deals 15 additional damage if the target is affected by [Kotoamatsukami]."
        , Skill.classes   = [Chakra, Ranged]
        , Skill.cost      = [Rand]
        , Skill.cooldown  = 1
        , Skill.effects   =
          [ To Enemy do
                bonus <- 15 `bonusIf` userHas "Kotoamatsukami"
                pierce (20 + bonus)
          ]
        }
      ]
    , [ Skill.new
        { Skill.name      = "Kotoamatsukami"
        , Skill.desc      = "Danzō infiltrates the mind of an enemy. The next time they use a skill, its effects will be nullified, they will be stunned for 2 turns, and this skill will be replaced by the skill they used for 2 turns. Danzō's copy of their skill has no chakra cost or cooldown and ends when this skill reverts."
        , Skill.classes   = [Mental, Ranged, Invisible, Uncounterable, Unreflectable]
        , Skill.cost      = [Blood, Gen, Gen]
        , Skill.cooldown  = 9
        , Skill.effects   =
          [ To Enemy do
                userSlot <- user slot
                apply 2 [Replace 2 userSlot "Kotoamatsukami"]
                trap 2 (Countered Uncounterable) do
                    remove "Kotoamatsukami"
                    removeTrap "Kotoamatsukami"
                    apply' "Kotoamatsukami Stun" 2 [Stun All]
          ]
        }
      ]
    , [ invuln "Summoning: Baku" "Danzō" [Chakra, Summon] ]
    ]
  ]
