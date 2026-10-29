// Legacy 2.0.0 gameplay presentation adapter.
//
// This deliberately changes drawing only. Modern note timing, input handling,
// scoring, gimmicks, and native note-mod math continue to run unchanged.

// VSML-created sprites start at (0, 0). The 2.0 atlas used origin (13, 0),
// which is what lets the same frame position every lane and bumper correctly.
if (sprite_exists(sp_lg_notetypes))
{
    sprite_set_offset(sp_lg_notetypes, 13, 0);
}
if (sprite_exists(sp_lg_holdFill))
{
    sprite_set_offset(sp_lg_holdFill, 0, 0);
}
sprite_set_offset(sp_lg_chip, 11, 3);
sprite_set_offset(sp_lg_holdbody, 12, 0);
// Match the stock 107x7 bumper canvas and pivot. Keeping the vertical pivot
// in the sprite (rather than subtracting 3 from py) also preserves rotation.
sprite_set_offset(sp_lg_bumper, 53, 3);
sprite_set_offset(sp_lg_bumper_timing, 53, 3);
sprite_set_offset(sp_lg_chip_mine, 11, 3);
sprite_set_offset(sp_lg_bumper_mine, 22, 3);
sprite_set_offset(sp_lg_press, 11, 144);
sprite_set_offset(sp_lg_noteparticle, 2, 2);
sprite_set_offset(sp_lg_diamonddust, 4, 4);

function cgm_legacy200_ui_enabled()
{
    return instance_exists(cc) && variable_instance_exists(cc, "mod_uimode") && cc.mod_uimode >= 0.5;
}

function cgm_legacy200_background_enabled()
{
    return instance_exists(cc) && variable_instance_exists(cc, "mod_bgparticles200") && cc.mod_bgparticles200 >= 0.5;
}

function cgm_set_ui_mode(mode)
{
    if (!instance_exists(cc)) return;
    if (is_string(mode))
    {
        if (mode == "legacy200") mode = 1;
        else if (mode == "modern") mode = 0;
        else return;
    }
    cc.mod_uimode = mode >= 0.5 ? 1 : 0;
    cgm_apply_ui_mode();
}

function cgm_apply_ui_mode()
{
    if (instance_exists(o_cgm_legacy200_ui)) o_cgm_legacy200_ui.apply();
}
