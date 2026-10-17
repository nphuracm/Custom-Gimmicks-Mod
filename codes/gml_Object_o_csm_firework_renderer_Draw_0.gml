var items = [];
var colors = [];

for (var kind = 0; kind < 2; kind++)
{
    var obj = (kind == 0) ? o_csm_firework : o_csm_firework_burst;
    var n = instance_number(obj);
    for (var i = 0; i < n; i++)
    {
        var ins = instance_find(obj, i);
        var col;
        if (kind == 0)
        {
            if (cc.currentms < ins.launch_ms || cc.currentms >= ins.burst_ms) continue;
            col = ins.image_blend;
        }
        else
        {
            if (!ins.ps_live || cc.currentms < ins.birth_ms || cc.currentms >= ins.retire_ms) continue;
            ins.sync();
            col = ins.burst_col;
        }
        array_push(items, { kind: kind, ins: ins, col: col });
        var found = false;
        for (var c = 0; c < array_length(colors); c++)
            if (colors[c] == col) { found = true; break; }
        if (!found) array_push(colors, col);
    }
}

if (array_length(items) == 0) exit;

if (!surface_exists(mask_surf)) mask_surf = surface_create(320, 180);
if (!surface_exists(mask_surf)) exit;

gpu_push_state();
var old_alpha = draw_get_alpha();
var old_color = draw_get_color();
draw_set_alpha(1);
draw_set_color(c_white);
gpu_set_texfilter(false);
gpu_set_alphatestenable(true);
gpu_set_alphatestref(1);

for (var c = 0; c < array_length(colors); c++)
{
    surface_target(mask_surf);
    draw_clear_alpha(c_black, 0);
    gpu_set_blendmode_ext_sepalpha(bm_inv_dest_color, bm_inv_src_color, bm_inv_dest_alpha, bm_inv_src_alpha);
    for (var i = 0; i < array_length(items); i++)
    {
        var it = items[i];
        if (it.col != colors[c]) continue;
        var ins = it.ins;
        if (it.kind == 0)
            draw_sprite_ext(sp_sc_firework_star, 0, ins.x, ins.y, ins.image_xscale, ins.image_xscale, ins.image_angle, c_white, 1);
        else
            particle_system_draw(ins.ps, sp_sc_firework_particle);
    }
    surface_untarget();
    gpu_set_blendmode(bm_normal);
    draw_surface_ext(mask_surf, 0, 0, 1, 1, 0, colors[c], 1);
}

gpu_set_alphatestenable(false);
draw_set_color(old_color);
draw_set_alpha(old_alpha);
gpu_pop_state();
