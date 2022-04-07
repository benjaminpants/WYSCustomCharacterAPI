if (groundedremember >= 0 || airjumps > 0)
{
        if (jumpremember >= 0)
        {
            if (snailtype == 0)
            {
                if (global.input_analysis_performing_jump_timer <= 0)
                    global.input_analysis_performing_jump_timer = 1
                if global.underwater
                {
                    sound = audio_play_sound(choose(sou_UnderwJump_01, sou_UnderwJump_02, sou_UnderwJump_03, sou_UnderwJump_04, sou_UnderwJump_05, sou_UnderwJump_06), 0.9, false)
                    audio_sound_gain_fx(sound, 1.2, 0)
                }
                else
                {
                    sound = audio_play_sound(choose(sou_jump_01, sou_jump_02, sou_jump_03, sou_jump_04, sou_jump_05, sou_jump_06), 0.9, false)
                    audio_sound_gain_fx(sound, 0.2, 0)
                }
                if (random(1) < 0.5 and use_voice)
                {
                    if audio_is_playing(snail_voice_sound)
                        audio_stop_sound(snail_voice_sound)
                    if (!global.underwater)
                    {
                        snail_voice_sound = audio_play_sound(choose(sou_cuteJump_01, sou_cuteJump_02, sou_cuteJump_03, sou_cuteJump_04, sou_cuteJump_05, sou_cuteJump_06, sou_cuteJump_07), 0.9, false)
                        audio_sound_gain_fx(snail_voice_sound, 0.05, 0)
                        audio_sound_pitch(snail_voice_sound, (0.45 + random(0.1)))
                    }
                    else
                    {
                        snail_voice_sound = audio_play_sound(choose(sou_UnderwCuteJump_01, sou_UnderwCuteJump_02, sou_UnderwCuteJump_03, sou_UnderwCuteJump_04, sou_UnderwCuteJump_05, sou_UnderwCuteJump_06, sou_UnderwCuteJump_07), 0.9, false)
                        audio_sound_gain_fx(snail_voice_sound, 0.35, 0)
                        audio_sound_pitch(snail_voice_sound, (0.45 + random(0.1)))
                    }
                }
                if (groundedremember < 0)
                {
                    airjumps--
                    audio_sound_gain_fx(sound, 0.4, 0)
                    audio_sound_pitch(sound, 1.25)
                }
                else
                    timesincelastjump = 0
            }
            else if (groundedremember < 0)
                airjumps--
            jumpremember = -1
            groundedremember = -1
            vspeed = -25 * jump_multiplier
            if (snailtype == 0)
            {
                if (gun_equipped == 1)
                {
                    gun_cooldown = 5
                    idmerk = instance_create_layer((x - (lookdir * 13)), y, "Player", obj_sh_projectile)
                    idmerk.vspeed -= 20
                    idmerk.hspeed = 2
                    idmerk = instance_create_layer((x - (lookdir * 13)), y, "Player", obj_sh_projectile)
                    idmerk.vspeed -= 20
                    idmerk.hspeed = 4
                    idmerk = instance_create_layer((x - (lookdir * 13)), y, "Player", obj_sh_projectile)
                    idmerk.vspeed -= 20
                    idmerk.hspeed = -2
                    idmerk = instance_create_layer((x - (lookdir * 13)), y, "Player", obj_sh_projectile)
                    idmerk.vspeed -= 20
                    idmerk.hspeed = -4
                    if global.underwater
                        sound = audio_play_sound(sou_UnderwPop_04, 0.9, false)
                    else
                        sound = audio_play_sound(sou_shooter_plop_04, 0.9, false)
                    audio_sound_gain_fx(sound, 1, 0)
                }
                else if (gun_equipped == 2)
                {
                    gun_cooldown = 5
                    for (vsp = -5; vsp <= 5; vsp += 10)
                    {
                        idmerk = instance_create_layer((x - (lookdir * 13)), (y - 10), "Player", obj_sh_projectile)
                        idmerk.hspeed = (26 * lookdir)
                        old_yscale = idmerk.image_yscale
                        idmerk.image_yscale = idmerk.image_xscale
                        idmerk.image_xscale = old_yscale
                        idmerk.vspeed = vsp
                        idmerk.rotated = 1
                    }
                    if global.underwater
                        sound = audio_play_sound(sou_UnderwPop_04, 0.9, false)
                    else
                        sound = audio_play_sound(sou_shooter_plop_04, 0.9, false)
                    audio_sound_gain_fx(sound, 1, 0)
                }
                else if (gun_equipped == 3)
                {
                    if (airjumps == 0)
                    {
                        gun_cooldown = 5
                        idmerk = instance_create_layer((x - (lookdir * 13)), y, "Player", obj_sh_projectile)
                        idmerk.vspeed = 20
                        idmerk.hspeed = 2
                        idmerk = instance_create_layer((x - (lookdir * 13)), y, "Player", obj_sh_projectile)
                        idmerk.vspeed = 20
                        idmerk.hspeed = 4
                        idmerk = instance_create_layer((x - (lookdir * 13)), y, "Player", obj_sh_projectile)
                        idmerk.vspeed = 20
                        idmerk.hspeed = -2
                        idmerk = instance_create_layer((x - (lookdir * 13)), y, "Player", obj_sh_projectile)
                        idmerk.vspeed = 20
                        idmerk.hspeed = -4
                        if global.underwater
                            sound = audio_play_sound(sou_UnderwPop_04, 0.9, false)
                        else
                            sound = audio_play_sound(sou_shooter_plop_04, 0.9, false)
                        audio_sound_gain_fx(sound, 1, 0)
                    }
                }
            }
            if underwater
            {
                vspeed = -11
                if (snailtype == 0)
                {
                    if (global.setting_visual_details > 0)
                    {
                        repeat (5)
                            part_particles_create(global.part_sys_fx, ((x - random(40)) + 20), ((y - random(20)) + 20), global.part_type_underwBubbles, 1)
                    }
                }
            }
            if (snailtype == 0)
            {
                idmerk = instance_create_layer(x, (y + 20), "Fx", obj_fx_flare)
                idmerk.decay = 0.8
                idmerk.image_blend = trail_color
                idmerk.image_xscale = 0.25
                idmerk.image_yscale = 0.25
                idmerk.vspeed = 8
                idmerk = instance_create_layer(x, (y + 20), "Fx", obj_fx_flare)
                idmerk.decay = 0.9
                idmerk.image_blend = trail_color
                idmerk.image_xscale = 0.25
                idmerk.image_yscale = 0.25
                idmerk.vspeed = 3
                idmerk = instance_create_layer(x, (y + 20), "Fx", obj_fx_flare)
                idmerk.decay = 0.95
                idmerk.image_blend = trail_color
                idmerk.image_xscale = 0.25
                idmerk.image_yscale = 0.25
                idmerk.vspeed = 0
            }
        }
}