if (!cc.ENABLE_DF_GRID_AND_SIDELINE) exit;

draw_set_alpha(cc.mod_df_sideline_alpha);
draw_sprite(sp_df_sideline, 0, -1 + (cc.mod_df_sideline * 114), 0);
draw_sprite(sp_df_sideline, 0, 320 - (cc.mod_df_sideline * 114), 0);

draw_set_color(c_white);
draw_set_alpha(cc.mod_df_whitebg);
draw_rectangle(-1, -1, room_width, room_height, false);
draw_sprite_part_ext(
    sp_df_grid,
    0,
    0, cc.mod_df_grid_top,
    320, cc.mod_df_grid_bottom - cc.mod_df_grid_top,
    0, cc.mod_df_grid_top,
    1, 1,
    cc.mod_df_grid_col,
    cc.mod_df_grid_alpha
);
draw_set_alpha(1);
