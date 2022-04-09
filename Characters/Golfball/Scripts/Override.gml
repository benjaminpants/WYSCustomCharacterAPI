image_xscale = 0.5
image_yscale = 0.5
with (obj_catwarning)
{
	instance_destroy()
}


if (golfball_current_phase == 0)
{
	
	if (snailtype == 0)
	{
		golfball_current_angle = point_direction(x,y,mouse_x,mouse_y)
	}
	else if (object_index == obj_evil_snail)
	{
		golfball_current_angle = point_direction(obj_player.x,obj_player.y,mouse_x,mouse_y) + 180
	}
	else
	{
		golfball_current_angle = point_direction(x,y,x + irandom_range(-300,300),y + irandom_range(-300,300))
	}
	
	golfball_current_strength = clamp(point_distance(x,y,mouse_x,mouse_y) / 7, 5, 50)

	if (floor(vspeed) == 0 and round(hspeed) == 0 and not place_free(x,y+3))
	{
		golfball_still = true
		golfball_air_puts = 1
	}
	else
	{
		golfball_still = false
		if (inbubble)
		{
			vspeed -= 0.1
			if (golfball_air_puts == 1)
			{
				golfball_current_strength *= 0.3
			}
			else
			{
				golfball_current_strength *= 0.8
			}
		}
		else
		{
			golfball_current_strength *= 0.6
		}
	}
	
	if (object_index == obj_evil_snail)
	{
		golfball_current_strength *= 0.98
	}

	if (inputjumppress)
	{
		//golfball_current_phase = 1
		if (golfball_still)
		{
			motion_add(golfball_current_angle, golfball_current_strength)
			timesincelastjump = 0
			if (snailtype == 0)
			{
				audio_play_sound(sou_FallingBlock,0,false)
			}
		}
		else
		{
			if (golfball_air_puts > 0)
			{
				golfball_air_puts--
				if (not inbubble)
				{
					if (snailtype == 0)
					{
						audio_play_sound(sou_FallingBlock,0,false)
					}
					vspeed = 0
					hspeed = 0
				}
				else
				{
					if (snailtype == 0)
					{
						audio_play_sound(sou_UnderwFallingBlock,0,false)
					}
				}
				motion_add(golfball_current_angle, golfball_current_strength)
				timesincelastjump = 0
				if (inbubble and golfball_air_puts == 0)
				{
					if (snailtype == 0)
					{
						sound = audio_play_sound(choose(sou_BubbleLeave_A, sou_BubbleLeave_B), 0.8, false)
						audio_sound_gain_fx(sound, 0.75, 0)
						audio_sound_pitch(sound, (2 + random(0.2)))
						scr_exit_bubble()
					}
					inbubble = 0
				}
			}
		}
	}
	

}

if (!inbubble)
{
	vspeed += 1.5
}
else
{
	vspeed *= 0.94
}
hspeed *= underwater ? 0.985 : 0.97

water_current = collision_point(x, y, obj_underwater_current, 1, 1)
timesincelastjump++
if instance_exists(water_current)
{
	if (timesincelastjump > 20)
	{
		vspeed = 0.7
	}
	golfball_air_puts = 2
	if (snailtype == 0)
	{
		in_water_current = lerp(in_water_current, 1, 0.1)
		if (global.player_underwater_current_timer < 100)
			global.player_underwater_current_timer += 1
	}
}

if (not place_free(x + hspeed,y))
{
	hspeed *= -0.82
	if (snailtype == 0)
	{
		audio_play_sound(choose(sou_landing_1, sou_landing_2, sou_landing_3),0,false)
	}
	if (inbubble)
	{
		if (snailtype == 0)
		{
			sound = audio_play_sound(choose(sou_BubbleLeave_A, sou_BubbleLeave_B), 0.8, false)
			audio_sound_gain_fx(sound, 0.75, 0)
			audio_sound_pitch(sound, (2 + random(0.2)))
			scr_exit_bubble()
		}
		inbubble = 0
	}
}

if (not place_free(x,y + vspeed))
{
	if ((vspeed <= 10) and (vspeed >= 0))
	{
		vspeed = 0
		while (place_free(x,y + 1))
		{
			y++
		}
		while (not place_free(x,y + 1))
		{
			y--
		}
	}
	else
	{
		vspeed *= -0.7
		if (snailtype == 0)
		{
			audio_play_sound(choose(sou_landing_1, sou_landing_2, sou_landing_3),0,false)
		}
	}
	if (inbubble)
	{
		if (snailtype == 0)
		{
			sound = audio_play_sound(choose(sou_BubbleLeave_A, sou_BubbleLeave_B), 0.8, false)
			audio_sound_gain_fx(sound, 0.75, 0)
			audio_sound_pitch(sound, (2 + random(0.2)))
			scr_exit_bubble()
		}
		inbubble = 0
	}
}





return false

}
else
{
image_xscale = 1
image_yscale = 1
//dont close the bracket, the end bracket will be added by the code, lol