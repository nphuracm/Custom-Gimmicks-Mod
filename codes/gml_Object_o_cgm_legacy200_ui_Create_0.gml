apply = function()
{
    if (!instance_exists(cc)) return;
    var mode = cgm_legacy200_ui_enabled();
    if (variable_instance_exists(cc, "cgm_applied_uimode") && cc.cgm_applied_uimode == mode) return;
    cc.cgm_applied_uimode = mode;
    // Change only our own stock replacements; retain graphic IDs, layer state,
    // alpha, transforms, alternate frames and any chart-owned replacement.
    var layers = layer_get_all();
    for (var i = 0; i < array_length(layers); i++)
    {
        var elements = layer_get_all_elements(layers[i]);
        for (var j = 0; j < array_length(elements); j++)
        {
            var element = elements[j];
            if (layer_get_element_type(element) != layerelementtype_sprite) continue;
            var sprite = layer_sprite_get_sprite(element);
            if (mode && sprite == sp_overlaynew) layer_sprite_change(element, sp_lg_asset_frame);
            else if (mode && sprite == sp_holdnote_overlay) layer_sprite_change(element, sp_lg_asset_receptors);
            else if (!mode && sprite == sp_lg_asset_frame) layer_sprite_change(element, sp_overlaynew);
            else if (!mode && sprite == sp_lg_asset_receptors) layer_sprite_change(element, sp_holdnote_overlay);
        }
    }
    with (o_pressindicator) cgm_legacy200_beam_sync();
    with (obj_noteIndicatorNew) cgm_legacy200_hit_update(false);
    with (obj_noteIndicatorWideNew) cgm_legacy200_hit_update(false);
};
apply();
