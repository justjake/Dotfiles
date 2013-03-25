module Pathfinder
    module RC
        # All personal functions go in Pathfinder::RC
        def coup_de_grace
            %Q[
                Full-round action.
                Melee attack, automatically crits
                Add sneak attack damage

                If the target survives, make
                FORT DC10 + Damage dealth or die
            ]
        end

        def full_attack_damage(weapon_dmg_fn)
            attack = bab

        end
    end
end
