//This handles moving the player out of solid objects, and what to do when that occurs.
if (place_free((x + hspeed), y) == 0)
{
	if (snailtype == 0 || simulte_movements_on_ramps)
	{
		if (place_free((x + hspeed), (y - 10)) && (!(place_free(x, (y + 5)))))
		{
			y -= 10
			x += hspeed
			move_contact_solid(270, -1)
			x -= hspeed
			vspeed = min(vspeed, 0)
		}
		else
		{
			if (hspeed > 0)
				move_contact_solid(0, -1)
			else
				move_contact_solid(180, -1)
			hspeed = 0
		}
	}
	else
	{
		if (hspeed > 0)
			move_contact_solid(0, -1)
		else
			move_contact_solid(180, -1)
		hspeed = 0
	}
}
if (place_free(x, (y + vspeed)) == 0)
{
	if (vspeed > 0)
	{
		if (snailtype == 0)
		{
			if (vspeed > 7)
			{
				if global.underwater
					sound = audio_play_sound(choose(sou_UnderwLanding_01, sou_UnderwLanding_02, sou_UnderwLanding_03), 0.7, false)
				else
					sound = audio_play_sound(choose(sou_landing_1, sou_landing_2, sou_landing_3), 0.7, false)
				vol = (clamp(((vspeed - 7) * 0.03), 0, 0.5) * 0.75)
				audio_sound_gain_fx(sound, (vol * vol), 0)
				audio_sound_pitch(sound, (0.8 + (vol * 0.4)))
				if (vspeed > 35)
					gamepad_rumble = max(gamepad_rumble, 0.2)
			}
		}
		move_contact_solid(270, -1)
	}
	else if inbubble
	{
		if (snailtype == 0)
		{
			sound = audio_play_sound(choose(sou_BubbleLeave_A, sou_BubbleLeave_B), 0.8, false)
			audio_sound_gain_fx(sound, 0.75, 0)
			audio_sound_pitch(sound, (2 + random(0.2)))
			scr_exit_bubble()
		}
		inbubble = 0
		airjumps = jump_count - 1
	}
	else
	{
		move_contact_solid(90, -1)
		if (snailtype == 0)
		{
			if global.underwater
			{
				sound = audio_play_sound(choose(sou_CeilingTouch_A_underw, sou_CeilingTouch_B_underw, sou_CeilingTouch_C_underw), 0.2, false)
				audio_sound_gain_fx(sound, (abs(vspeed) / 18), 0)
				audio_sound_pitch(sound, (0.85 + random(0.3)))
			}
			else
			{
				sound = audio_play_sound(choose(sou_CeilingTouch_A, sou_CeilingTouch_B, sou_CeilingTouch_C), 0.2, false)
				audio_sound_gain_fx(sound, (abs(vspeed) / 120), 0)
				audio_sound_pitch(sound, (1.7 + random(0.3)))
			}
			if (global.setting_visual_details >= 2)
			{
				repeat round(abs((vspeed / 4)))
					part_particles_create(global.part_sys_fx, ((x - random(20)) + 10), (y - 20), global.part_type_ceilingTouch, 1)
			}
		}
	}
	vspeed = 0
}
if (place_free((x + hspeed), (y + vspeed)) == 0)
	hspeed = 0