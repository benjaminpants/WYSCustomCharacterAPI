//This determines what the evil shellys/evil snails will draw.
draw_sprite_ext(spr_evil_snail_inside, image_index, x, y, (lookdir * aw_OUT_xscale), (image_yscale * aw_OUT_yscale), (image_angle + aw_OUT_angle), inside_col, image_alpha)
draw_sprite_ext(sprite_index, image_index, x, y, (lookdir * aw_OUT_xscale), (image_yscale * aw_OUT_yscale), (image_angle + aw_OUT_angle), outside_col, image_alpha)