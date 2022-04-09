scr_move_like_a_snail = function(argument0, argument1, argument2, argument3) //dear god
{
	if (global.char_reset_ini)
	{
		scr_move_like_a_snail_ini()
		global.char_reset_ini = false
	}
    inputx = clamp(argument0, -1, 1)
    inputjump = argument1
    inputjumppress = argument2
    snailtype = argument3
	//INJECT MULTIPLIERS
	//INJECT COMPLETE OVERRIDE
	//INJECT PHYSICS
    //INJECT JUMP
    //INJECT COLLISIONS
    return;
}

