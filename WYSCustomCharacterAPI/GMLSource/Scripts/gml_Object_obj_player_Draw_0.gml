//INJECT

if inbubble
{
    inbubble_flash = max(0, (inbubble_flash - 0.025))
    inbubble_whobble = ((1 + ((sin((inbubble_flash * 30)) * 0.3) * inbubble_flash)) + (abs((speed * 0.01)) * (1 - inbubble_flash)))
    draw_sprite_ext(spr_bubblewubble, 0, (x + lengthdir_x(((-speed) * 0.7), direction)), (y + lengthdir_y(((-speed) * 0.7), direction)), ((1 * inbubble_whobble) + (inbubble_flash * 0.3)), ((1 / inbubble_whobble) + (inbubble_flash * 0.3)), direction, obj_levelstyler.col_bubbles, 1)
    if (abs((hspeed - hspeed_last)) > 2)
    {
        inbubble_flash += ((abs((hspeed - hspeed_last)) - 2) * 0.1)
        inbubble_flash = clamp(inbubble_flash, 0, 1)
    }
    hspeed_last = hspeed
}
