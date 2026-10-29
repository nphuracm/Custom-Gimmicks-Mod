// Skin 4 is an ordinary CGM skin: only explicitly selected legacy sprite IDs
// enter the geometry adapter. UI mode never changes lane_sprites or stock art.
function cgm_legacy200_note_sprite(sprite, frame, px, py, sx, sy, angle, tint, alpha, held = false)
{
    if (sprite == sp_lg_holdbody)
    {
        var allison_alpha = frame < 0.5 && variable_instance_exists(cc, "mod_chorus_greenleft_overlay") ? clamp(cc.mod_chorus_greenleft_overlay, 0, 1) : 0;
        py -= 6 * (1 - allison_alpha);
        sy += (held ? 6 : 13) * (1 - allison_alpha);
        cgm_legacy200_draw_hold_body(frame, px, py, sx, sy, angle, tint, alpha, allison_alpha);
        return;
    }
    draw_sprite_ext(sprite, frame, px, py, sx, sy, angle, tint, alpha);
}

function cgm_legacy200_hold_sprite(sprite, frame, px, py, sx, sy, angle, tint, alpha)
{
    cgm_legacy200_note_sprite(sprite, frame, px, py, sx, sy, angle, tint, alpha, true);
}

function cgm_legacy200_draw_hold_body(frame, px, py, sx, height, angle, tint, alpha, allison_alpha = 0)
{
    // Exact nontransparent columns of the original 24x1 sp_holdFill:
    // transparent | light edge | 20 fill columns | light edge | transparent.
    // Keep the original x pivot 12 and all caller transforms/color/opacity.
    var right = ((floor(frame) mod 2) + 2) mod 2;
    var colors = right ? [make_color_rgb(255, 180, 245), make_color_rgb(255, 140, 239)]
                       : [make_color_rgb(180, 237, 255), make_color_rgb(140, 228, 255)];
    var tint_r = color_get_red(tint) / 255;
    var tint_g = color_get_green(tint) / 255;
    var tint_b = color_get_blue(tint) / 255;
    var ca = dcos(angle);
    var sa = dsin(angle);
    var bounds = [-11, -10, 10, 11];
    draw_primitive_begin(pr_trianglelist);
    for (var band = 0; band < 3; band++)
    {
        var base = colors[band == 1 ? 1 : 0];
        var allison_color = band == 1 ? make_color_rgb(180, 255, 220) : make_color_rgb(206, 255, 233);
        if (allison_alpha > 0) base = merge_color(base, allison_color, allison_alpha);
        var color = make_color_rgb(color_get_red(base) * tint_r,
            color_get_green(base) * tint_g, color_get_blue(base) * tint_b);
        var left = bounds[band] * sx;
        var right_x = bounds[band + 1] * sx;
        // Compute the lower edge explicitly on the CPU, rather than deriving
        // it in a shader from a huge sprite scale and an interpolated UV.
        var x0 = px + left * ca;
        var y0 = py - left * sa;
        var x1 = px + right_x * ca;
        var y1 = py - right_x * sa;
        var x2 = x0 + height * sa;
        var y2 = y0 + height * ca;
        var x3 = x1 + height * sa;
        var y3 = y1 + height * ca;
        draw_vertex_color(x0, y0, color, alpha);
        draw_vertex_color(x1, y1, color, alpha);
        draw_vertex_color(x2, y2, color, alpha);
        draw_vertex_color(x1, y1, color, alpha);
        draw_vertex_color(x3, y3, color, alpha);
        draw_vertex_color(x2, y2, color, alpha);
    }
    draw_primitive_end();
}

