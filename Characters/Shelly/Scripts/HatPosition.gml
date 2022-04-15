//This complicated chunk of code determines the position the players hat should be, I've modified it to use variables for the offsets for easy modification.
//I would add these to the character configuration file, however, these functions are complex(or atleast complicated) and I haven't fully figured out how they work yet.

if victory
{
    if (obj_player.x < 60)
        x -= 10
    if (obj_player.y < 60)
        y -= 10
    if (obj_player.x > (room_width - 60))
        x += 10
    if (obj_player.y > (room_height - 60))
        y += 10
}
else if dead
{
    yspeed += 0.4
    x += xspeed
    y += yspeed
    image_angle += sign(image_angle)
}
else if (backpack_mode >= 0)
{
    backpack_mode--
    hat_anchor_x = ((obj_player.x - (26 * obj_player.lookdir)) + lengthdir_x((20 * obj_player.house_height), (90 + obj_player.house_tilt)))
    hat_anchor_y = ((obj_player.y + 16) + lengthdir_y((20 * obj_player.house_height), (90 + obj_player.house_tilt)))
    x = hat_anchor_x
    y = hat_anchor_y
    image_angle = (obj_player.house_tilt + 90)
    image_xscale = clamp((1 + ((y - yprevious) * 0.01)), 0.5, 2)
    image_yscale = (obj_player.lookdir / image_xscale)
    xspeed = 0
    yspeed = 0
}
else
{
    if global.underwater
    {
        smooth_lookdir = lerp(smooth_lookdir, obj_player.lookdir, 0.1)
        yspeed += 0.48
    }
    else
    {
        smooth_lookdir = lerp(smooth_lookdir, obj_player.lookdir, 0.25)
        yspeed += 0.98
    }
    hat_anchor_x = ((obj_player.x - (15 * smooth_lookdir)) + lengthdir_x((39 * obj_player.house_height), (90 + obj_player.house_tilt)))
    hat_anchor_y = ((obj_player.y + 16) + lengthdir_y((39 * obj_player.house_height), (90 + obj_player.house_tilt)))
    x = hat_anchor_x
    xspeed = obj_player.hspeed
    if glued_to_hat
        y = hat_anchor_y
    else
    {
        y += yspeed
        if (y > hat_anchor_y)
        {
            yspeed = min(yspeed, max(-10, obj_player.vspeed))
            y = hat_anchor_y
        }
        else
            y = lerp(hat_anchor_y, y, 0.9)
    }
    image_angle = obj_player.house_tilt
    image_yscale = clamp((1 + ((y - yprevious) * 0.01)), 0.5, 2)
    image_xscale = (obj_player.lookdir / image_yscale)
}
if global.underwater
{
    yspeed *= 0.9
    xspeed *= 0.95
}
