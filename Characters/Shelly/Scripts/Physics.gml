//This handles most of the actual physics, it doesn't handle collisions
if underwater
{
	if inbubble
		vspeed -= 0.05
	else if (vspeed < 0)
		vspeed += 0.25 * gravity_multiplier
	else
		vspeed += 0.5 * gravity_multiplier
	if (vspeed > 7)
		vspeed = 7
}
else if inbubble
{
	vspeed -= 0.3
	vspeed *= 0.97
}
else
	vspeed += 1.5 * gravity_multiplier
water_current = collision_point(x, y, obj_underwater_current, 1, 1)
timesincelastjump++
if instance_exists(water_current)
{
	hspeed += lengthdir_x(0.5, water_current.image_angle)
	vspeed += lengthdir_y(1.3, water_current.image_angle)
	if (timesincelastjump < 30)
		vspeed *= (0.95 + (0.05 * abs(lengthdir_x(1, water_current.image_angle))))
	else
		vspeed *= 0.95
	if (snailtype == 0)
	{
		in_water_current = lerp(in_water_current, 1, 0.1)
		if (global.player_underwater_current_timer < 100)
			global.player_underwater_current_timer += 1
	}
}
else if (snailtype == 0)
{
	in_water_current = lerp(in_water_current, 0, 0.05)
	if (global.player_underwater_current_timer > 0)
	{
		global.player_underwater_current_timer -= 0.3
		if (groundedremember > 0)
			global.player_underwater_current_timer -= 1
	}
}
if (vspeed < 0)
{
	if (inputjump == 0)
	{
		if (inbubble == 0)
		{
			if (!global.save_fixed_jump_height)
			{
				if underwater
					vspeed += 0.5 * gravity_multiplier
				else
					vspeed += 2 * gravity_multiplier
			}
		}
	}
}
if underwater
{
	hspeed += (inputx * 0.45) * speed_multiplier
	hspeed *= underwater_friction
}
else if inbubble
{
	hspeed += (inputx * 0.4) * speed_multiplier
	hspeed *= 0.97
	hspeed = clamp(hspeed, -12, 12)
}
else
	hspeed = (inputx * 10) * speed_multiplier
if place_meeting(x, y, obj_conveyor_belt)
{
	if (!underwater)
		hspeed += (global.conveyor_belt_speed * sign(global.conveyor_belt_direction)) * conveyor_multiplier
	else
		hspeed += ((global.conveyor_belt_speed * sign(global.conveyor_belt_direction)) * 0.1) * conveyor_multiplier
	if (snailtype == 0)
	{
		if (global.player_on_conveyor_timer <= 0)
			global.player_on_conveyor_timer = 1
		bonus_speed_by_conveyor = (global.conveyor_belt_speed * sign(global.conveyor_belt_direction)) * conveyor_multiplier
	}
}
groundedremember--
jumpremember--
if (place_free(x, (y + 10)) == 0)
{
	groundedremember = 5
	airjumps = jump_count - 1
	if (snailtype == 0)
	{
		global.input_analysis_performing_jump_timer = 0
		if (!(place_meeting(x, (y + 5), obj_conveyor_belt)))
			global.player_on_conveyor_timer = 0
	}
}
if inputjumppress
	jumpremember = 10
if inbubble
{
	if (jumpremember >= 0)
	{
		jumpremember = 1
		groundedremember = -1
		airjumps = jump_count
		inbubble = 0
		if (snailtype == 0)
		{
			sound = audio_play_sound(choose(sou_BubbleLeave_A, sou_BubbleLeave_B), 0.8, false)
			audio_sound_gain_fx(sound, 0.75, 0)
			audio_sound_pitch(sound, (0.85 + random(0.3)))
			scr_exit_bubble()
		}
	}
}