draw_sprite_ext(spr_ball,0,x, y, (((lookdir * 0.5) * image_xscale) * aw_OUT_xscale), ((image_yscale * 0.5) * aw_OUT_yscale), (image_angle + aw_OUT_angle), col_snail_body, 1)

draw_sprite_ext(spr_ball,0,mouse_x,mouse_y, 0.25, 0.25, 0, c_white, 1)


//draw_text(x,y,string(golfball_air_puts))
if (inbubble or (golfball_air_puts != 0) or golfball_still)
{
	draw_line_width_colour(x,y,x + lengthdir_x(golfball_current_strength * 3 ,golfball_current_angle), y + lengthdir_y(golfball_current_strength * 3,golfball_current_angle), 8, c_red, golfball_still ? c_green : c_blue)
}