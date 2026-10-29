if (!instance_exists(cc))
{
    instance_destroy();
    exit;
}

release = function()
{
    for (var i = 0; i < array_length(sprites); i++)
        if (sprite_exists(sprites[i])) sprite_delete(sprites[i]);
    sprites = [];
    if (surface_exists(surf)) surface_free(surf);
    surf = -1;
};

restore = function()
{
    for (var i = 0; i < 4; i++)
        obj_note_rendering.lane_sprites[i] = cc.current_sg_skin;
    for (var i = 4; i < 7; i++)
        obj_note_rendering.lane_sprites[i] = cc.current_bp_skin;
};

bake = function(a)
{
    var normal = [cc.current_sg_skin[0], cc.current_sg_skin[2], cc.current_bp_skin[0], cc.current_bp_skin[1]];
    var allison = [sp_note_chip_allison, sp_note_hold_allison, sp_note_bumper_allison, sp_note_bumper_timing_allison];
    surf = surface_create(128, 64);
    if (!surface_exists(surf)) return false;
    var out = [];
    surface_target(surf);
    draw_clear_alpha(c_black, 0);
    gpu_set_texfilter(false);
    var cy = 0;
    for (var i = 0; i < 4; i++)
    {
        var w = sprite_get_width(normal[i]);
        var h = sprite_get_height(normal[i]);
        draw_sprite_ext(normal[i], 0, sprite_get_xoffset(normal[i]), cy + sprite_get_yoffset(normal[i]), 1, 1, 0, c_white, 1);
        draw_sprite_ext(allison[i], 0, sprite_get_xoffset(normal[i]), cy + sprite_get_yoffset(normal[i]), 1, 1, 0, c_white, a);
        array_push(out, sprite_create_from_surface(surf, 0, cy, w, h, false, false, sprite_get_xoffset(normal[i]), sprite_get_yoffset(normal[i])));
        cy += h;
    }
    surface_untarget();
    sprites = out;
    obj_note_rendering.lane_sprites[0] = [out[0], out[0], cc.current_sg_skin[2] == sp_lg_holdbody ? sp_lg_holdbody : out[1], out[0], sp_empty];
    obj_note_rendering.lane_sprites[1] = obj_note_rendering.lane_sprites[0];
    obj_note_rendering.lane_sprites[4] = [out[2], out[3], sp_empty];
    return true;
};

var a = variable_instance_exists(cc, "mod_chorus_greenleft_overlay") ? clamp(cc.mod_chorus_greenleft_overlay, 0, 1) : 0;
var mark = round(a * 255);
var skin_changed = base_chip != cc.current_sg_skin[0] || base_hold != cc.current_sg_skin[2] || base_bumper != cc.current_bp_skin[0] || base_timing != cc.current_bp_skin[1];
if (mark == built && !skin_changed) exit;
base_chip = cc.current_sg_skin[0];
base_hold = cc.current_sg_skin[2];
base_bumper = cc.current_bp_skin[0];
base_timing = cc.current_bp_skin[1];
built = mark;
release();

if (mark >= 255)
{
    obj_note_rendering.lane_sprites[0] = [sp_note_chip_allison, sp_note_chip_allison, sp_note_hold_allison, sp_note_chip_allison, sp_empty];
    obj_note_rendering.lane_sprites[1] = obj_note_rendering.lane_sprites[0];
    obj_note_rendering.lane_sprites[4] = [sp_note_bumper_allison, sp_note_bumper_timing_allison, sp_empty];
}
else if (mark <= 0)
{
    restore();
}
else
{
    if (!bake(a)) restore();
}
