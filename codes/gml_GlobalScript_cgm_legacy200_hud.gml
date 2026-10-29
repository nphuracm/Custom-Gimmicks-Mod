// Retain the old sprite fonts' transparent vertical padding explicitly.
function cgm_legacy200_draw_sprite_text(sprite, text, center_x, text_y, spacing, alpha)
{
    static score_bounds = [[13,16,2,1],[0,0,0,0],[13,13,2,1],[13,15,3,1],[13,13,3,4],[13,13,4,5],[13,13,3,4],[13,13,1,1],[13,13,2,4],[13,13,2,4],[14,14,1,1],[14,14,1,2],[13,16,1,1],[0,0,0,0],[14,16,1,2],[13,13,2,4],[12,10,9,11],[13,10,7,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[13,14,1,3],[0,0,0,0],[0,0,0,0],[13,14,2,2],[0,0,0,0],[14,14,1,1],[13,14,1,2],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,1,4],[13,13,2,4],[14,13,1,4],[13,13,1,4],[13,13,2,4],[13,13,3,4],[13,13,1,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,1],[13,13,2,4],[13,13,2,4],[13,13,3,3],[13,13,1,4],[13,13,3,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[0,0,0,0],[13,16,2,1],[13,13,1,1],[13,14,2,3],[13,13,2,4],[13,14,2,3],[13,14,2,3],[13,14,2,3],[13,13,2,4],[13,14,2,2],[13,13,2,4],[13,13,1,4],[0,0,0,0],[13,13,1,4],[13,13,1,4],[13,14,3,3],[13,14,2,3],[13,14,2,3],[13,14,2,3],[13,14,2,2],[13,14,2,3],[13,14,2,3],[13,13,2,4],[13,14,2,3],[13,14,2,3],[13,14,3,2],[13,14,2,3],[13,14,1,2],[13,14,2,3],[13,13,2,4],[13,13,1,4],[15,13,2,4],[13,14,3,1]];
    static combo_bounds = [[13,16,2,1],[0,0,0,0],[13,13,2,1],[13,15,3,1],[13,13,3,4],[11,10,12,11],[13,13,3,4],[13,13,1,1],[13,13,2,4],[13,13,2,4],[14,14,1,1],[14,14,1,2],[13,16,1,1],[13,13,7,5],[14,16,1,2],[13,13,2,4],[12,10,9,11],[13,10,7,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[12,10,9,11],[13,14,1,3],[0,0,0,0],[0,0,0,0],[13,14,2,2],[0,0,0,0],[14,14,1,1],[13,14,1,2],[12,10,9,11],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,1,4],[13,13,2,4],[14,13,1,4],[13,13,1,4],[13,13,2,4],[12,10,9,11],[13,13,1,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,1],[13,13,2,4],[13,13,2,4],[13,13,3,3],[12,10,9,11],[13,13,3,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[13,13,2,4],[0,0,0,0],[13,16,2,1],[13,13,1,1],[13,14,2,3],[13,13,2,4],[13,14,2,3],[13,14,2,3],[13,14,2,3],[13,13,2,4],[13,14,2,2],[13,13,2,4],[13,13,1,4],[0,0,0,0],[13,13,1,4],[13,13,1,4],[13,14,3,3],[13,14,2,3],[13,14,2,3],[13,14,2,3],[13,14,2,2],[13,14,2,3],[13,14,2,3],[13,13,2,4],[13,14,2,3],[13,14,2,3],[13,14,3,2],[13,14,2,3],[13,14,1,2],[13,14,2,3],[13,13,2,4],[13,13,1,4],[15,13,2,4],[13,14,3,1]];
    var bounds = (sprite == sp_lg_combofont) ? combo_bounds : score_bounds;
    text = string(text);
    var width = 0;
    for (var i = 1; i <= string_length(text); i++)
    {
        var index = ord(string_char_at(text, i)) - 32;
        if (index < 0 || index >= array_length(bounds)) continue;
        width += bounds[index][2] + spacing;
    }
    width = max(0, width - spacing);
    var pen_x = center_x - (width / 2);
    for (var i = 1; i <= string_length(text); i++)
    {
        var index = ord(string_char_at(text, i)) - 32;
        if (index < 0 || index >= array_length(bounds)) continue;
        var box = bounds[index];
        if (box[2] > 0 && box[3] > 0)
            draw_sprite_part_ext(sprite, index, box[0], box[1], box[2], box[3],
                pen_x, text_y - 1 + box[1], 1, 1, c_white, alpha);
        pen_x += box[2] + spacing;
    }
}


function cgm_legacy200_draw_shell()
{
        draw_set_color(c_white);
        draw_set_halign(fa_center);
        draw_sprite(sp_gameplayoverlay, 0, 0, 0);
        if (global.course_mode) draw_sprite(sp_lg_coursescore_overlay, 0, 0, 34);
        cgm_legacy200_draw_sprite_text(sp_scorefont_acc_new, round(global.currentscore), 284, -3, -2, mod_uialpha);
        cgm_legacy200_draw_sprite_text(sp_scorefont_ex_new, round(global.gamescore), 284, 13, -2, mod_uialpha);
        if (global.course_mode)
            cgm_legacy200_draw_sprite_text(sp_scorefont_course_new, round(global.current_course_score + global.currentscore), 32, 29, -2, mod_uialpha);
        draw_set_font(fnt_phosphor);
    }

function cgm_legacy200_draw_caption(song_alpha)
{
        var legacy_title = global.songname;
        if (global.selected_title == "images2") legacy_title = global.songartist;
        if (room == scene_gameplay_opt && currentms >= 100727)
            legacy_title = "You are now experiencing lane " + ((currentms >= 125176) ? "*" : string(global.experiencing_lane + 1));
        draw_set_font(fnt_phosphor);
        draw_set_color(c_black);
        draw_set_alpha(song_alpha);
        draw_text_o(3, 169, legacy_title);
        draw_set_color(c_white);
        draw_set_alpha(mod_uialpha);
    }

function cgm_legacy200_draw_difficulty()
{
        draw_set_font(fnt_phosphor);
    var diff_color = c_white;
    switch (global.df_load)
    {
        case "OPENING": diff_color = 2227968; break;
        case "MIDDLE": diff_color = 16749568; break;
        case "FINALE": diff_color = 255; break;
        case "SHATTER": diff_color = 8421504; break;
        case "ENCORE": diff_color = 16711858; break;
        case "OPENING_STORY": diff_color = 2227968; break;
        case "MIDDLE_STORY": diff_color = 16749568; break;
        case "FINALE_STORY": diff_color = 255; break;
        case "ENCORE_STORY": diff_color = 16711858; break;
        default: if (global.boundary_shatter) diff_color = 8421504; break;
    }

    // Same BACKSTAGE predicate as the native ENCORE difficulty plaque.
    if (global.df_load == "ENCORE" && struct_exists(global.song_list[global.song_id_last], "enc_data") && !struct_get_fallback(global.song_list[global.song_id_last].enc_data, "hide_backstage", false))
        diff_color = make_color_rgb(255, 0, 110);

    var level_text = "Level " + string(global.songdifficulty);
    if (global.songdifficulty == "17+++") level_text = "Level " + string(irandom(25));
    var level_box_x = 312 - string_width(level_text);
    draw_set_halign(fa_right);
    draw_set_color(diff_color);
    draw_rectangle(level_box_x, 154, 320, 163, false);
    draw_set_color(c_white);
    draw_rectangle(level_box_x, 153, 320, 153, false);
    draw_rectangle(level_box_x - 1, 153, level_box_x - 1, 163, false);
    draw_text_o(317, 156, level_text);
    draw_set_color(c_black);
    draw_rectangle(level_box_x - 1, 152, 320, 152, false);
    draw_rectangle(level_box_x - 2, 152, level_box_x - 2, 162, false);
    draw_set_color(diff_color);
    if (level_box_x > 208)
    {
        draw_rectangle(208, 164, 320, 164, false);
        draw_set_color(c_white);
        draw_rectangle(208, 163, level_box_x - 2, 163, false);
        draw_set_color(c_black);
        draw_rectangle(208, 162, level_box_x - 3, 162, false);
    }
    else
    {
        draw_rectangle(level_box_x, 164, 320, 164, false);
        draw_set_color(c_white);
        draw_rectangle(level_box_x - 1, 164, level_box_x - 1, 164, false);
        draw_set_color(c_black);
        draw_rectangle(level_box_x - 2, 163, level_box_x - 2, 164, false);
    }

        draw_set_font(global.default_font);
    }
