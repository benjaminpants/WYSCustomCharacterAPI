scr_move_like_a_snail = function(argument0, argument1, argument2, argument3) //dear god
{
    inputx = clamp(argument0, -1, 1)
    inputjump = argument1
    inputjumppress = argument2
    snailtype = argument3
	if (object_index == obj_player)
	{
		if (tracked_character != global.current_character)
		{
			room_restart()
			return false
		}
	}
	//INJECT MULTIPLIERS
	//INJECT COMPLETE OVERRIDE
	//INJECT PHYSICS
    //INJECT JUMP
    //INJECT COLLISIONS
    return;
}

