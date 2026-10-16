event_inherited();
// t++;
// if(t>=10){
//     var fp=file_text_open_append("log_mpf_runtime.log");
//     file_text_write_string(fp, string(mpfDebugState("ENCORE", "test")));
//     file_text_writeln(fp);
//     file_text_close(fp);
// }


if (!instance_exists(cc))
    exit;

if (cc.mod_slash_anycol > 0)
{
    var ins = instance_create_depth(0, 0, 255, o_anycol_slash);
    ins.color = col_convert(cc.mod_set_slash_col);
    cc.mod_slash_anycol = 0;
}

if(cc.plaudite_pburst_consist){
    spawn_particles_directional(irandom_range(0, 320), -10, 701, o_pt_diamonddust, 1, 0, 1.5 * cc.mod_pburstspeed, 240, 1);
}

if(cc.ENABLE_DISTORT_BG){
    fx_set_parameter(blurEff, "g_Radius", cc.mod_BG_blurRadius);
    fx_set_parameter(blurEff, "g_NoiseTexture ", noisetex);
    fx_set_parameter(distortEff, "g_Distort1Scale", cc.mod_BG_ditortScale);
    fx_set_parameter(distortEff, "g_Distort2Scale", cc.mod_BG_ditortScale);
    fx_set_parameter(distortEff, "g_Distort1Amount", cc.mod_BG_ditortAmount);
    fx_set_parameter(distortEff, "g_Distort2Amount", cc.mod_BG_ditortAmount);
}

if(cc.ENABLE_ANGELSTAR_CHECKER)
{
    if (cc.mod_angelstar_checker_mode==0)
        o_angelstar_checker.depth=721;
    else if (cc.mod_angelstar_checker_mode==1)
        o_angelstar_checker.depth=301;
    else if (cc.mod_angelstar_checker_mode==2)
        o_angelstar_checker.depth=-50;
    
}




//custom
if (cc.ENABLE_NON_BASE_FX)
{
    var colarray = [];
    colarray[0] = color_get_red(make_color_hsv(cc.mod_curcolor, 255, 255));
    colarray[1] = color_get_green(make_color_hsv(cc.mod_curcolor, 255, 255));
    colarray[2] = color_get_blue(make_color_hsv(cc.mod_curcolor, 255, 255));
    var tintarray = []
    tintarray[0] = color_get_blue(cc.mod_fx_colorise_col_rgb);
    tintarray[1] = color_get_green(cc.mod_fx_colorise_col_rgb);
    tintarray[2] = color_get_red(cc.mod_fx_colorise_col_rgb);
    tintarray[3] = cc.mod_fx_colorise_col_alpha;
    fx_set_parameter(layer_get_fx("tintLayer"), "g_TintCol", tintarray);
    fx_set_parameter(layer_get_fx("tintLayer"), "g_Intensity", cc.mod_fx_colorise_intensity);
    fx_set_parameter(layer_get_fx("FX_red"), "g_Intensity", cc.mod_fx_red_intensity);
    //
    //original
    fx_set_parameter(layer_get_fx("FX_red"), "g_TintCol", colarray);
    fx_set_parameter(layer_get_fx("FX_hue"), "g_HueShift", cc.mod_fx_hue_hue);
    fx_set_parameter(layer_get_fx("FX_hue"), "g_HueSaturation", cc.mod_fx_hue_saturation);
    layer_set_visible(layer_get_id("FX_edge"), cc.mod_fx_edge);
    layer_set_visible(layer_get_id("FX_posterize"), cc.mod_fx_posterize_vis);
    fx_set_parameter(layer_get_fx("FX_posterize"), "g_ColourLevels", cc.mod_fx_posterize);
    fx_set_parameter(layer_get_fx("FX_twirl"), "g_DistortAngle", cc.mod_fx_twirl);
    fx_set_parameter(layer_get_fx("FX_underwater"), "g_Distort1Amount", cc.mod_fx_underwater);
    fx_set_parameter(layer_get_fx("FX_underwater"), "g_Distort2Amount", cc.mod_fx_underwater);
    fx_set_parameter(layer_get_fx("FX_zoom"), "g_ZoomBlurIntensity ", cc.mod_fx_zoom);
    layer_set_visible(layer_get_id("FX_red"), cc.mod_fx_red);
}
