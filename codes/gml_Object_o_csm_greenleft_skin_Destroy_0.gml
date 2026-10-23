for (var i = 0; i < array_length(sprites); i++)
    if (sprite_exists(sprites[i])) sprite_delete(sprites[i]);
if (surface_exists(surf)) surface_free(surf);
if (instance_exists(obj_note_rendering))
{
    for (var i = 0; i < 4; i++)
        obj_note_rendering.lane_sprites[i] = cc.current_sg_skin;
    for (var i = 4; i < 7; i++)
        obj_note_rendering.lane_sprites[i] = cc.current_bp_skin;
}
