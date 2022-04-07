var sprite_to_draw = spr_player1
if (vspeed < 0)
{
    sprite_to_draw = spr_player_up1
}
else if (vspeed > 0)
{
    sprite_to_draw = spr_player_down1
}
draw_sprite_ext(sprite_to_draw,0,x,y , lookdir, 1, 0, c_white, 1)