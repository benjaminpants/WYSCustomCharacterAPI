if (global.setting_visual_details == 0)
    return false;
if (global.spotlight_alpha <= 0.01)
    return false;
gpu_set_blendmode(bm_add)
with (obj_player)
{
	//INJECT
	if (col_spotlight != c_black)
			draw_sprite_ext(spr_flare, 0, x, y, 0.8, 0.8, 0, col_spotlight, global.spotlight_alpha)
}
gpu_set_blendmode(bm_normal)