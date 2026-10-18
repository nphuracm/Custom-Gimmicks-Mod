for (var i = 0; i < array_length(sprites); i++)
    if (sprite_exists(sprites[i])) sprite_delete(sprites[i]);
if (surface_exists(surf)) surface_free(surf);
if (instance_exists(obj_note_rendering))
{
    for (var i = 0; i < 4; i++)
        obj_note_rendering.lane_sprites[i] = [sp_note_chip_normal, sp_note_chip_normal, sp_note_hold_normal, sp_note_chip_normal, sp_note_chip_mine_normal];
    for (var i = 4; i < 7; i++)
        obj_note_rendering.lane_sprites[i] = [sp_note_bumper_normal, sp_note_bumper_timing_normal, sp_note_bumper_mine_normal];
}
