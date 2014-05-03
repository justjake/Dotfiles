module Pathfinder
    # All personal functions go in Pathfinder::RC
    module RC

        # Save DC for assassination.
        # To attempt to assassinate a target, the ninja must first study her 
        # target for 1 round as a standard action. On the following round, if 
        # the ninja makes a sneak attack against the target and the target is 
        # denied its Dexterity bonus to AC, the sneak attack has the 
        # additional effect of possibly killing the target. This attempt 
        # automatically fails if the target recognizes the ninja as an enemy. 
        # If the sneak attack is successful and the target of this attack 
        # fails a Fortitude save, it dies. The DC of this save is equal to 
        # 10 + 1/2 the ninja’s level + the ninja’s Charisma modifier.
        def assassinate
            10 + level / 2 + charisma.modifier
        end


        # Full-round action.
        # Melee attack, automatically hits+crits
        # Add sneak attack damage
        # 
        # If the target survives, make
        # FORT DC10 + Damage dealth or die]
        def coup_de_grace(dag_dice = 2)
            print %Q[Full-round action.
Melee attack, automatically hits+crits
Add sneak attack damage

If the target survives, make
FORT DC10 + Damage dealth or die]
            # single-handed sneak attack plus an extra dagger for the crit
            sneak() + dagger(dag_dice) + roll(1, 4)
        end

        def attack(detriment = -2)
            bab + detriment + dexterity.modifier + check()
        end

        def full_attack(bonus = 2)
            max_bonus = bab
            detriments = [-2, -5, -10]
            (detriments * 2).map { |d| attack(d)  }
        end

        # these are simple +2 2d6 magic daggers
        def dagger(d6 = 2)
            roll(1, 4) + [2] + [sum(roll(d6))]
        end

        # sneak attack damage: 8d6 at lvl 15
        def sneak
            roll(8, 6)
        end

        def full_damage(hits = 6, bonus = 0, &block)
            hits.times.map do
                res = dagger()
                res += [bonus] if bonus
                res += yield() if block_given?
                res
            end
        end

        # full sneak attack hits 6 times at lvl 15
        # 3 times for BAB
        # 3 times for two-weapon fighting
        # default bonus 1 for dirty fighting
        def full_sneak(hits = 6, bonus = 1)
            puts "dagger, bonus, sneak..."
            full_damage { sneak() }
        end
    end
end
