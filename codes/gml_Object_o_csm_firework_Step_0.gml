if (!instance_exists(cc))
{
    instance_destroy();
    exit;
}

var p = clamp((cc.currentms - launch_ms) / flight_ms, 0, 1);
var q = EaseOutQuad(p, 0, 1, 1);
y = lerp(ystart, target_y, q);
image_angle = 360 * q;
image_xscale = lerp(2, 1, q);
image_yscale = image_xscale;
image_blend = cc.mod_scfw_star_col;

if (!exploded && cc.currentms >= burst_ms)
{
    exploded = true;
    instance_create_depth(x, y, 255, o_csm_firework_burst, { burst_col: cc.mod_scfw_burst_col });
    instance_destroy();
}
