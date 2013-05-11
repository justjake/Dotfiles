module Pathfinder
    # All personal functions go in Pathfinder::RC
    module RC
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
