function cgm_legacy200_lane_self()
{
    if (!cgm_legacy200_ui_enabled() || sprite_index != sp_laneOverlay || floor(image_index) != 0)
    {
        draw_self();
        exit;
    }
    draw_sprite_ext(sp_laneOverlay_old, 0, x, y, image_xscale, image_yscale,
        image_angle, image_blend, image_alpha);
    draw_sprite_ext(sp_lg_frame_upper, 0, x, y, image_xscale, image_yscale,
        image_angle, image_blend, image_alpha);
}

function cgm_legacy200_receptor_self()
{
    if (!cgm_legacy200_ui_enabled() || sprite_index != sp_holdnote_overlay || floor(image_index) != 0)
    {
        draw_self();
        exit;
    }
    draw_sprite_ext(sp_lg_asset_receptors, 0, x, y, image_xscale, image_yscale,
        image_angle, image_blend, image_alpha);
}

// Only the stock beam gets the 2.0.0 appearance. Allison and custom beam
// sprites retain the native draw path and their own chart-controlled color.
function cgm_legacy200_stock_beam()
{
    return cgm_legacy200_ui_enabled() && (sprite_index == sp_pressindicator_iidxstyle || sprite_index == sp_pressindicator_iidxstyle_allison);
}

function cgm_legacy200_press_draw()
{
    draw_sprite_ext(sprite_index == sp_pressindicator_iidxstyle ? sp_lg_press : sprite_index, image_index, x, y, image_xscale, image_yscale,
        image_angle, image_blend, image_alpha);
}

function cgm_legacy200_press_cancel_tweens()
{
    // TweenEasyScale in 2.0.0 replaced the previous scale animation. Cancel
    // only this beam's scale tracks so a quick re-press cannot resume an older
    // release after the new 0.0625-second activation finishes. Legacy tracks
    // store an explicit id; a self scope reference is not a stable numeric ID.
    var xhash = variable_get_hash("image_xscale");
    var yhash = variable_get_hash("image_yscale");
    var kept = 0;
    for (var i = 0; i < array_length(cc.ui_tweens); i++)
    {
        var tween = cc.ui_tweens[i];
        if (tween[0] == id && (tween[1] == xhash || tween[1] == yhash)) continue;
        cc.ui_tweens[kept] = tween;
        kept++;
    }
    array_resize(cc.ui_tweens, kept);
}

function cgm_legacy200_hit_draw(px, py, dx, dy, tint, alpha)
{
    var saved_color = draw_get_color();
    var saved_alpha = draw_get_alpha();
    draw_set_color(tint);
    draw_set_alpha(alpha);
    draw_rectangle(px - dx, py - dy, px + dx, py + dy, true);
    draw_set_color(saved_color);
    draw_set_alpha(saved_alpha);
}

function cgm_legacy200_hit_particle_add(system, px, py, vx, vy, angle, spin, sx, sy, alpha, frame, tint, diamond, index)
{
    particle_system_add_particle(system, px, py, vx, vy, angle, spin, sx, sy, alpha, frame, tint);
    if (diamond && index >= 2) return;
    instance_create_depth(px, py, -1000, cgm_legacy200_hit_particle,
    {
        legacy_diamond: diamond,
        legacy_judgement: frame,
        legacy_frame: frame,
        legacy_vx: vx,
        legacy_vy: vy
    });
}

// Resolve presentation before drawing, including objects that existed before a
// chart/MPF mode change. Both mode paths store explicit IDs in the tween queue.
function cgm_legacy200_beam_sync()
{
    var legacy = cgm_legacy200_stock_beam();
    if (!variable_instance_exists(id, "cgm_beam_native_depth"))
    {
        cgm_beam_native_depth = depth;
        cgm_beam_style = false;
    }
    if (cgm_beam_style == legacy) return;
    cgm_beam_style = legacy;
    depth = legacy ? -1000 : cgm_beam_native_depth;
    cgm_legacy200_press_cancel_tweens();
    if (pressed)
    {
        cc.CreateUiTween(0, 0.0625, id, "image_xscale", EaseOutCubic, image_xscale, 1);
        cc.CreateUiTween(0, 0.0625, id, "image_yscale", EaseOutCubic, image_yscale, 1);
    }
    else
    {
        cc.CreateUiTween(0, 0.25, id, "image_xscale", EaseOutCubic, image_xscale, 0);
    }
}

function cgm_legacy200_hit_update(advance)
{
    if (!variable_instance_exists(id, "cgm_hit_age")) return;
    var legacy = cgm_legacy200_ui_enabled();
    if (advance) cgm_hit_age += cc.delta_s * (legacy ? 2 : 1);
    var old_colors = [c_yellow, c_yellow, c_fuchsia, c_aqua, c_red];
    image_blend = legacy ? old_colors[judgement] : cgm_hit_native_color;
    dx = EaseOutExpo(min(cgm_hit_age, 1/3), 0, cgm_hit_wide ? (legacy ? 30 : 27) : 15, 1/3);
    dy = EaseOutExpo(min(cgm_hit_age, 1/3), 0, 7, 1/3);
    image_alpha = 1 - EaseOutExpo(clamp(cgm_hit_age - 1/6, 0, 1/3), 0, 1, 1/3);
}

function cgm_legacy200_press_on()
{
cgm_legacy200_press_cancel_tweens();
if (cgm_legacy200_stock_beam())
{
    cc.CreateUiTween(0, 0.0625, id, "image_xscale", EaseOutCubic, 1, 1);
    cc.CreateUiTween(0, 0.0625, id, "image_yscale", EaseOutCubic, 0, 1);
}
else
{
    cc.CreateUiTween(0, 0.25, id, "image_xscale", EaseLinear, 1, 1);
    cc.CreateUiTween(0, 0.0625, id, "image_yscale", EaseOutCubic, 0, 1);
}
}

function cgm_legacy200_press_off()
{
cgm_legacy200_press_cancel_tweens();
if (cgm_legacy200_stock_beam())
{
    cc.CreateUiTween(0, 0.25, id, "image_xscale", EaseOutCubic, 1, 0);
    cc.CreateUiTween(0, 0.25, id, "image_yscale", EaseOutCubic, 1, 1);
}
else
{
    cc.CreateUiTween(0, 0.25, id, "image_xscale", EaseOutCubic, 1, 0);
}
}
