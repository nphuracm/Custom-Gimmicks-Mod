mod_uimode = 0;
mod_bgparticles200 = 0;
cgm_applied_uimode = false;
chartPath=get_chart_path_from_chartid(global.ch_load);
var settings=[
    ["JACKET_MANAGE_MODE", "plaudite"],
    ["ENABLE_DEBUG_INFO", false],
    ["ENABLE_TEXT", true],
    ["ENABLE_NON_BASE_FX", true],
    ["ENABLE_DF_GRID_AND_SIDELINE", true],
    ["ENABLE_ANGELSTAR_CHECKER", true],
    ["ENABLE_DISTORT_BG", true],
    ["ENABLE_MUSIC_CONTROL", true],
    ["ENABLE_STARPARTICLE",false],
    ["ENABLE_SKIN_CHANGE",false],
    ["NEW_PRTRX_CALCULATION",false],
    ["JACKET_GLOW",false]
];
array_foreach(settings, function(ele){
    variable_instance_set(cc, ele[0], ele[1]);
})
mod_drawstop=-infinity;
mod_freeze = 0;
mod_playspeed = 1;
mod_xoffset = 0;
mod_xoffsetb = 0;
mod_yoffsetb = 0;
for (var lane=0;lane<7;lane++){
    variable_instance_set(cc,string("mod_yoffsetind{0}", lane), 0);
    variable_instance_set(cc,string("mod_xoffsetind{0}", lane), 0);
    variable_instance_set(cc,string("mod_yoffsetindb{0}", lane), 0);
    variable_instance_set(cc,string("mod_xoffsetindb{0}", lane), 0);
    variable_instance_set(cc,string("mod_notealpind{0}", lane), 1);
    variable_instance_set(cc,string("mod_boost_timeind{0}", lane), 300);
    variable_instance_set(cc,string("mod_boost_distanceind{0}", lane), 0);
}


if(struct_exists(getSongEntry(global.ch_load), "is_custom"))
{
    var loadConfig=true;
    var configPath = chartPath + string("{0}_cgmk_config.json", global.df_load);
    if (!file_exists(configPath)){
        configPath = chartPath + "cgmk_config.json";
        if (!file_exists(configPath))
            loadConfig=false;
    }

    config={};
    configText="";
    if (loadConfig){
        var fp=file_text_open_read(configPath);
        while (!file_text_eof(fp))
        configText = configText + file_text_readln(fp);
        file_text_close(fp);
        config=json_parse(configText);
    }
    if (struct_names_count(config)>0)
    {
        var keys=struct_get_names(config);
        array_foreach(keys,
            function(_ele,_idx){
            variable_instance_set(cc, _ele, struct_get(config, _ele));
            }
        )
    }
    if(!ENABLE_NON_BASE_FX){
        layer_destroy(layer_get_id("FX_red"));
        layer_destroy(layer_get_id("FX_twirl"));
        layer_destroy(layer_get_id("FX_posterize"));
        layer_destroy(layer_get_id("FX_edge"));
        layer_destroy(layer_get_id("FX_hue"));
        layer_destroy(layer_get_id("FX_underwater"));
        layer_destroy(layer_get_id("FX_zoom"));
    }
}