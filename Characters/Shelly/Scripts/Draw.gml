//The draw event, draw sprites and stuff. Eye rendering code is NOT handled here.
//Return false at the end if you want to handle the bubble rendering code yourself.

if underwater
{
    if (airjumps > 0 && groundedremember < 5)
        bubbleindicator = lerp(bubbleindicator, 1, 0.1)
    else
        bubbleindicator = lerp(bubbleindicator, 0, 0.2)
    if (bubbleindicator >= 0.02)
    {
        bblsize = ((0.5 + (sin((time * 0.1)) * 0.05)) * bubbleindicator)
        draw_sprite_ext(spr_bubble, image_index, x, ((y + 15) + (15 * bblsize)), bblsize, bblsize, house_tilt, image_blend, 1)
        bblsize = ((0.5 + (sin(((time * 0.08) + 34)) * 0.05)) * bubbleindicator)
        draw_sprite_ext(spr_bubble, image_index, (x - 20), ((y + 15) + (15 * bblsize)), bblsize, bblsize, house_tilt, image_blend, 1)
        bblsize = ((0.5 + (sin(((time * 0.085) + 15.3)) * 0.05)) * bubbleindicator)
        draw_sprite_ext(spr_bubble, image_index, (x + 20), ((y + 15) + (15 * bblsize)), bblsize, bblsize, house_tilt, image_blend, 1)
    }
}
house_height = lerp(house_height, (1 + (vspeed * 0.05)), 0.2)
house_height = clamp(house_height, 0.4, 1.6)
house_width = clamp((1 / house_height), 0.8, 5)
house_tilt = lerp(house_tilt, hspeed, 0.1)
house_sprite = spr_snail_house
if (gun_equipped == 1)
    house_sprite = spr_snail_house_gun
if (gun_equipped == 2)
    house_sprite = spr_snail_house_gun2
if (gun_equipped == 3)
    house_sprite = spr_snail_house_gun3
if (gun_equipped == 4)
    house_sprite = spr_snail_house_gun4 //undertale mod tool wtf why did i have to fix this myself
draw_sprite_ext(house_sprite, 0, (x - (15 * lookdir)), (y + 16), (house_width * lookdir), house_height, house_tilt, col_snail_shell, 1)
draw_sprite_ext(house_sprite, 1, (x - (15 * lookdir)), (y + 16), (house_width * lookdir), house_height, house_tilt, col_snail_outline, 1)
draw_sprite_ext(spr_player_base, 0, x, y, (image_xscale * lookdir), image_yscale, image_angle, col_snail_body, 1)
draw_sprite_ext(spr_player_base, 1, x, y, (image_xscale * lookdir), image_yscale, image_angle, col_snail_outline, 1)