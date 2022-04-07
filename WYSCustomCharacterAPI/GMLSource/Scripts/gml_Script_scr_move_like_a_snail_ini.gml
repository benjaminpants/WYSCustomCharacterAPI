scr_move_like_a_snail_ini = function() //gml_Script_scr_move_like_a_snail_ini
{
    groundedremember = -1
    jumpremember = -1
    airjumps = 0
    underwater = 0
    timesincelastjump = 0
    if instance_exists(obj_levelstyler_underwater)
        underwater = 1
    inbubble = 0
	speed_multiplier = 1
	gravity_multiplier = 1
	jump_multiplier = 1
	jump_count = 2
	conveyor_multiplier = 1
	underwater_friction = 0.95
	trail_color = c_white
	//INJECT
}