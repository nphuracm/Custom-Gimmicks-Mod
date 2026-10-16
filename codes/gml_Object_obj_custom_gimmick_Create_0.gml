event_inherited();
/*
addExtraMod = function(modName, weight = 1, callBack = undefined, endCallBack = undefined)
{
    var i = lastExtraModIndex;
    lastExtraModIndex++;
    variable_struct_set(extraMods, modName, i);
    extraModCallbacks[i] = callBack;
    extraModEndCallbacks[i] = endCallBack;
    variable_struct_set(global.mod_weight, modName, weight);
};
args of callbacks:
[start, duration, thismod.v1, thismod.v2, thismod.e]
*/
t=0
custom_mpfs=[]

funcs={
    quake: function(arg0)
    {
        random_set_seed(floor(arg0 * 32));
        
        for (var i = 0; i < 8; i++)
        {
            with (proxies[i])
            {
                prxd = (random(1) * prvib * 2) - prvib;
                prxd = (random(1) * prvib * 2) - prvib;
            }
        }
        
        randomize();
    },
    
    spin3D: function(arg0)
    {
        var spinradiusx = cc.mod_spinradiusx;
        var spinradiusz = cc.mod_spinradiusz;
        var fakezy = cc.mod_fakezy;
        var fakezyb = cc.mod_fakezyb;
        var float = cc.mod_float;
        
        for (var i = 0; i < 4; i++)
        {
            with (proxies[i])
            {
                var ang = 50.26548245743669 + (((arg0 - 180) * pi) / 12);
                var quadrant = (1.5707963267948966 * i) + pi;
                var finalang = ((ang - quadrant) % 1.5707963267948966) + quadrant;
                var xp = cos(finalang);
                var zp = sin(finalang);
                prx = (xp * spinradiusx) + (20 * float * sin(finalang * 2));
                pry = 20 * float * cos(finalang * 2);
                przm = 1 - (zp * spinradiusz);
                var fzy = 1;
                
                if (((i % 2) == 0 && (arg0 % 12) < 6) || ((i % 2) == 1 && (arg0 % 12) >= 6))
                    fzy = fakezy;
                
                przy = fzy * fakezyb;
                prrz = 10 * float * sin(finalang * 2);
            }
        }
    },
    
    wiggle: function(arg0)
    {
        var spinradiusx = cc.mod_spinradiusx;
        var float = cc.mod_float;
        var wiggly = cc.mod_wiggly * (0.55 + (0.45 * cos(arg0 * pi * 0.5)));
        var wigspeed = (arg0 > 380) ? 4 : 3;
        
        for (var i = 0; i < 4; i++)
        {
            with (proxies[i])
            {
                var ang = ((arg0 - 324) * pi * wigspeed) + (1.5707963267948966 * i);
                var xr = cos(ang);
                var yr = sin(ang);
                prxc = (spinradiusx * (-1.5 + (1 * i)) * (0.5 + (0.5 * cos(arg0 * pi * 0.5)))) + (float * (-1.5 + i));
                prrx = xr * wiggly;
                prry = yr * wiggly;
                prrzb = xr * wiggly * 0.25;
            }
        }
    },
    
    swirl: function(arg0)
    {
        var spinradiusx = cc.mod_spinradiusx;
        var float = cc.mod_float;
        
        for (var i = 0; i < 4; i++)
        {
            var ang = 2.0734511513692637 * i;
            var floatx = float * ((0.8 * sin(ang + (arg0 * pi * 0.25))) + (0.4 * sin(ang + (arg0 * pi * 0.8 * 0.2))));
            var floaty = float * ((0.6 * cos(ang + (arg0 * pi * 0.18))) + (0.47 * cos(ang + (arg0 * pi * 0.8 * 0.23))));
            var floatz = float * ((0.4 * sin(ang + (arg0 * pi * 0.13))) + (0.2 * cos(ang + (arg0 * pi * 0.8 * 0.16))));
            ang = 1.0367255756846319 * (i / 4);
            var ang2 = 1.0367255756846319 * ((i + 0.5) / 4);
            var swirlx = spinradiusx * (0.8 * sin(ang + (arg0 * pi * 0.125)));
            var swirly = spinradiusx * (0.6 * cos(ang + (arg0 * pi * 0.25)));
            var swirlx2 = spinradiusx * (0.8 * sin(ang2 + (arg0 * pi * 0.125)));
            var swirly2 = spinradiusx * (0.6 * cos(ang2 + (arg0 * pi * 0.25)));
            
            with (proxies[i])
            {
                prxc = floatx + swirlx;
                pryc = floaty + swirly;
                prrzb = floatz;
            }
            
            with (proxies[i + 4])
            {
                prxc = floatx + swirlx2;
                pryc = floaty + swirly2;
                prrzb = floatz;
            }
        }
    },
    spinProxyZero: function(arg0)
    {
        with (proxies[0])
        {
            var spinradius = cc.mod_spinradius;
            var xp = 90 * sin((arg0 * pi) / 16);
            var yp = 60 * cos((arg0 * pi) / 8);
            prx = xp * spinradius;
            pry = yp * spinradius;
            prrz = (yp * spinradius) / 3;
        }
    },
    
    spinProxyOne: function(arg0)
    {
        with (proxies[1])
        {
            var spinradius = cc.mod_spinradius;
            var xp = 90 * sin((arg0 * pi) / 16);
            var yp = 30 * cos((arg0 * pi) / 8);
            prxb = xp * spinradius;
            pryb = yp * spinradius;
            prrzb = (yp * spinradius) / 3;
        }
    },
    spinProxies: function(arg0)
    {
        for (var i = 0; i < 4; i++)
        {
            with (proxies[i])
            {
                var spinradius = cc.mod_spinradius;
                var spiny = cc.mod_spiny;
                var xp = 90 * sin(((arg0 * pi) / 16) + (i * pi * 0.5));
                var yp = (-90 * spiny) + (90 * cos(((arg0 * pi) / 16) + (i * pi * 0.5)));
                prx = xp * spinradius;
                pry = yp * spinradius;
            }
        }
    }
}

var chart=undefined

if (instance_exists(o_songselect_main)){
    chart=o_songselect_main.selected_song;
}
else if (instance_exists(o_songselect_shatter)){
    chart=o_songselect_shatter.selected_song;
}
else{
    chart=global.ch_load;
}

var _mpfPath = get_chart_path_from_chartid(chart);
var _mpfTable = mpfRegisterAll(variable_global_exists("df_load") ? global.df_load : "", _mpfPath);
if (_mpfTable != undefined)
{
    var _mpfNames = variable_struct_get_names(_mpfTable);
    for (var _mpfI = 0; _mpfI < array_length(_mpfNames); _mpfI++)
    {
        var _mpfKey = _mpfNames[_mpfI];
        var _mpfFn = variable_struct_get(_mpfTable, _mpfKey);
        if (!struct_exists(funcs, _mpfKey)) variable_struct_set(funcs, _mpfKey, _mpfFn);
        array_push(custom_mpfs, _mpfFn);
    }
}

if (!instance_exists(cc))
    exit;

depth=50;
//Initilizers
function InitSkinChange(){
    if (!cc.ENABLE_SKIN_CHANGE)
        exit;
    singleSkins=[
        [sp_note_chip_normal, sp_note_chip_normal, sp_note_hold_normal, sp_note_chip_normal, sp_note_chip_mine_normal],
        [sp_note_chip_stopmotion, sp_note_hold_start_stopmotion, sp_note_hold_stopmotion, sp_note_hold_end_stopmotion, sp_empty],
        [sp_note_chip_extendnova, sp_note_chip_extendnova, sp_note_hold_extendnova, sp_note_chip_extendnova, sp_note_chip_mine_normal],
        [sp_note_chip_stargazers, sp_note_hold_start_stargazers, sp_note_hold_stargazers, sp_note_hold_end_stargazers, sp_empty]
    ]
    bumperSkins=[
        [sp_note_bumper_normal, sp_note_bumper_timing_normal, sp_note_bumper_mine_normal],
        [sp_note_bumper_stopmotion, sp_empty, sp_empty],
        [sp_note_bumper_extendnova, sp_note_bumper_timing_normal, sp_note_bumper_mine_normal],
        [sp_note_bumper_stargazers, sp_note_bumper_timing_stargazers, sp_empty]

    ]
    addExtraMod("changeskin", 0, function(start,dur,v1,skinID){
        for (var lane=0;lane<7;lane++)
        {
            if (lane<4)
                obj_note_rendering.lane_sprites[lane]=obj_custom_gimmick.singleSkins[skinID]
            else
                obj_note_rendering.lane_sprites[lane]=obj_custom_gimmick.bumperSkins[skinID]
        }
    })
}

function InitCSMJacket(){
    layer_destroy_instances(layer_get_id("Instances_2"))
    layer_destroy_instances(layer_get_id("Instances_1")) 
    var Lparticle=layer_create(800,"Lparticle")  
    var LBG=layer_create(700,"LBG")
    instance_create_layer(0, 32, Lparticle, o_csm_particle_system)
    instance_create_layer(0, 32, LBG, o_csm_jacket)
    addExtraMod("particle_alpha");
    cc.mod_particle_alpha = 1;
    if (cc.JACKET_MANAGE_MODE=="plaudite"){
        addExtraMod("plaudite_jacket");
        cc.mod_plaudite_jacket = 11;
    }
    else{
        addExtraMod("custom_jacket");
        cc.mod_custom_jacket = 0;
    }
}

function InitText(){
    if (!cc.ENABLE_TEXT)
        exit;
    var tpathOld = cc.chartPath + string("{0}_text.txt", global.df_load);
    var tpath = "";
    if (file_exists(tpathOld)){
        addExtraMod("textX",0);
        addExtraMod("textY",0);
        addExtraMod("textalp",0);
        addExtraMod("textrot",0);
        addExtraMod("textcolhex",0);
        addExtraMod("textscale",0);
        cc.mod_textX = room_width*0.5;
        cc.mod_textY = room_height*0.5;
        cc.mod_textalp = 1;
        cc.mod_textrot = 0;
        cc.mod_textcolhex = 16777215;
        cc.mod_textscale = 1.0;
        var displayerSetting={};
        struct_set(displayerSetting,"text_path",tpathOld);
        if (!instance_exists(o_text_displayer)){
            instance_create_depth(0,0,-10,o_text_displayer,displayerSetting);
        }
    }
    else if (!instance_exists(o_text_displayer_ext)){
        var displayerSetting={};
        struct_set(displayerSetting,"caller",id);
        instance_create_depth(0,0,-10,o_text_displayer_ext,displayerSetting);
    }
}

function InitDistortBG(){
    if (!cc.ENABLE_DISTORT_BG)
        exit;
    instance_create_depth(0,0,801,o_csm_distortbg_handler);
    bgLayer = layer_get_id("LBG");
    blurLayer = layer_create(698);
    distortEff = fx_create("_filter_heathaze");
    blurEff = fx_create("_filter_large_blur");
    layer_set_fx(bgLayer, distortEff);
    layer_set_fx(blurLayer, blurEff);
    addExtraMod("ditortedBG_alp");
    addExtraMod("ditortedBG_col");
    addExtraMod("BG_ditortScale");
    addExtraMod("BG_ditortAmount");
    addExtraMod("BG_blurRadius");
    cc.mod_ditortedBG_alp = 0;
    cc.mod_ditortedBG_col_rgb = 16777215;
    cc.mod_BG_ditortScale = 0;
    cc.mod_BG_ditortAmount = 0;
    cc.mod_BG_blurRadius = 0;
}

function InitNonBaseFX(){
    if (!cc.ENABLE_NON_BASE_FX) {
        exit;
    }
    //CUSTOM FX
    if (!layer_exists("tintLayer")){
    var tintLayer = layer_create(-2400,"tintLayer")
    var tintFX=fx_create("_filter_colourise")
    layer_set_fx(tintLayer,tintFX)
    addExtraMod("fx_red_intensity")
    addExtraMod("fx_colorise_col_rgb");//col_rgb
    addExtraMod("fx_colorise_col_alpha");//col_a
    addExtraMod("fx_colorise_intensity");//strength
    cc.mod_fx_red_intensity = 1;
    cc.mod_fx_colorise_col_rgb = 16777215;
    cc.mod_fx_colorise_col_alpha = 1;
    cc.mod_fx_colorise_intensity = 0;

    //NON CUSTOM FX
    cc.mod_curcolor = 0;
    addExtraMod("recolor",0,function(s,d,v1,v2){
        if(!cc.ENABLE_NON_BASE_FX && v2<=0) exit;
        cc.mod_curcolor = irandom(255);
    });
    addExtraMod("fx_hue_hue");
    addExtraMod("fx_hue_saturation");
    addExtraMod("fx_edge");
    addExtraMod("fx_posterize");
    addExtraMod("fx_twirl");
    addExtraMod("fx_posterize_vis");
    addExtraMod("fx_underwater");
    addExtraMod("fx_zoom");
    addExtraMod("fx_red");
    cc.mod_fx_hue_hue = 0;
    cc.mod_fx_hue_saturation = 1;
    cc.mod_fx_edge = 0;
    cc.mod_fx_posterize = 32;
    cc.mod_fx_posterize_vis = 0;
    cc.mod_fx_twirl = 0;
    cc.mod_fx_underwater = 0.01;
    cc.mod_fx_zoom = 0;
    cc.mod_fx_red = 0;
    cc.mod_recolor = 0;
    }
}

function InitDFGridAndLine(){
    if (!cc.ENABLE_DF_GRID_AND_SIDELINE)
        exit;
    //df
    instance_create_depth(0, 0,250, o_csm_df_handler)
    addExtraMod("df_sideline2",0,function(){
        if (!cc.ENABLE_DF_GRID_AND_SIDELINE && v2<=0) exit;
        with (instance_create_depth(0, 0, depth, obj_distortedfate_sideline))
        {
            TweenFire(self, EaseOutCirc, 0, true, 0, 0.75, "x", 0, 90);
            TweenFire(self, EaseOutCirc, 0, true, 0, 0.75, "image_alpha", 1, 0);
        }
        with (instance_create_depth(319, 0, depth, obj_distortedfate_sideline))
        {
            TweenFire(self, EaseOutCirc, 0, true, 0, 0.75, "x", 319, 229);
            TweenFire(self, EaseOutCirc, 0, true, 0, 0.75, "image_alpha", 1, 0);
        }
    });
    addExtraMod("df_sideline");
    addExtraMod("df_sideline_alpha");
    addExtraMod("df_whitebg");
    addExtraMod("df_grid_alpha");
    addExtraMod("df_grid_top");
    addExtraMod("df_grid_bottom");
    cc.mod_df_sideline = 0;
    cc.mod_df_sideline_alpha = 1;
    cc.mod_df_whitebg = 0;
    cc.mod_df_grid_alpha = 0;
    cc.mod_df_grid_top = 0;
    cc.mod_df_grid_bottom = 0;
}

function InitSides(){
    addExtraMod("sides",0, function()
    {
        instance_create_depth(150, 90, 260, o_unravel_sidething, 
        {
            dir: 1
        });
        instance_create_depth(170, 90, 260, o_unravel_sidething, 
        {
            dir: -1
        });
    });
    addExtraMod("unraveling_sidething",0, function()
    {
        instance_create_depth(150, 90, 260, o_unravel_sidething, 
        {
            dir: 1
        });
        instance_create_depth(170, 90, 260, o_unravel_sidething, 
        {
            dir: -1
        });
    });
    addExtraMod("astellion_sidething",0, function()
    {
        instance_create_depth(150, 90, 260, o_astellion_sidething, 
        {
            dir: 1
        });
        instance_create_depth(170, 90, 260, o_astellion_sidething, 
        {
            dir: -1
        });
        if (!instance_exists(o_ast_particle_particlesystem))
            instance_create_depth(0, 0, 259, o_ast_particle_particlesystem);
        
        particle_system_add_particle(o_ast_particle_particlesystem.particles, irandom_range(0, 120), irandom_range(0, 180), 0, 0, 0, 0, 0, 0, 2, 0, make_color_hsv(random_range(0, 255), 255, 255));
        particle_system_add_particle(o_ast_particle_particlesystem.particles, irandom_range(200, 320), irandom_range(0, 180), 0, 0, 0, 0, 0, 0, 2, 0, make_color_hsv(random_range(0, 255), 255, 255));
    });
    addExtraMod("apocalypse_sidething",0, function()
    {
        instance_create_depth(150, 90, 260, o_apocalypse_sidething, 
        {
            dir: 1
        });
        instance_create_depth(170, 90, 260, o_apocalypse_sidething, 
        {
            dir: -1
        });
    });
}

function InitAngelstarChecker(){
    if(!cc.ENABLE_ANGELSTAR_CHECKER)
        exit;
    if (instance_exists(cc))
        instance_create_depth(0, 0, 721, o_angelstar_checker);
    addExtraMod("angelstar_checker_mode")
    addExtraMod("angelstar_checker_alpha");
    addExtraMod("angelstar_checker_set");
    cc.mod_angelstar_checker_mode=0;
    cc.mod_angelstar_checker_alpha = 0;
    cc.mod_angelstar_checker_set = 0;
}

function InitCustomShader(){
    //Shader Init
    uTime = shader_get_uniform(shader_custom_main, "time");
    uGrayAmp = shader_get_uniform(shader_custom_main, "uGrayAmp");
    uBarrelAmp = shader_get_uniform(shader_custom_main, "uBarrelAmp");
    uHDistortAmp = shader_get_uniform(shader_custom_main, "uHDistortAmp");
    uVDistortAmp = shader_get_uniform(shader_custom_main, "uVDistortAmp");
    uFishAmp = shader_get_uniform(shader_custom_main, "uFishAmp");
    uVigAmp = shader_get_uniform(shader_custom_main, "uVigAmp");
    bloom = shader_get_uniform(shader_custom_main, "bloom");
    uAbberationX = shader_get_uniform(shader_custom_main, "abberationx");
    uAbberationY = shader_get_uniform(shader_custom_main, "abberationy");
    uAbX = shader_get_uniform(shader_custom_main, "abX");
    uAbY = shader_get_uniform(shader_custom_main, "abY");
    uMove = shader_get_uniform(shader_custom_main, "move");
    uSinm = shader_get_uniform(shader_custom_main, "sinm");
    uCosm = shader_get_uniform(shader_custom_main, "cosm");
    uTanm = shader_get_uniform(shader_custom_main, "tanm");
    uHNoise=shader_get_uniform(shader_custom_main, "uHnoise");
    uGlitchAmp=shader_get_uniform(shader_custom_main, "glitchAmp");
    uSTime=shader_get_uniform(shader_custom_main, "stime");
    for (var i=1; i<=4; i++)
        variable_instance_set(cc,string("uTwist{0}",i),shader_get_uniform(shader_custom_main, string("twist{i}",i)));
    uNoiseSampler = shader_get_sampler_index(shader_supernova_main, "samplerRandom");
    noisetex = sprite_get_texture(sp_noise2, 0);
    //shaderRelative
    addExtraMod("gray");
    addExtraMod("barrel");
    addExtraMod("barrel2");
    addExtraMod("hdistort");
    addExtraMod("vdistort");
    addExtraMod("vig");
    addExtraMod("abx");
    addExtraMod("aby");
    addExtraMod("barrelabx")
    addExtraMod("barrelaby")
    addExtraMod("fish");
    addExtraMod("bloom");
    addExtraMod("glitchamp");
    addExtraMod("glitchoffset");
    addExtraMod("uhnoise");
    addExtraMod("posx");
    addExtraMod("posy");
    for (var i = 1; i <= 4; i++)
    {
        addExtraMod(string("twx{0}", i));
        addExtraMod(string("twy{0}", i));
        addExtraMod(string("twa{0}", i));
        addExtraMod(string("twr{0}", i));
    }

    cc.mod_gray = 0;
    cc.mod_barrel = 0;
    cc.mod_barrel2 = 0;
    cc.mod_hdistort = 0;
    cc.mod_vdistort = 0;
    cc.mod_fish = 0;
    cc.mod_vig = 0;
    cc.mod_abx = 0;
    cc.mod_aby = 0;
    cc.mod_barrelabx=0;
    cc.mod_barrelaby=0;
    cc.mod_bloom = 0;
    cc.mod_uhnoise = 0;
    cc.mod_glitchamp = 0;
    cc.mod_glitchoffset = 0;
    //uCurvem
    cc.mod_sino = 0;
    cc.mod_sina = 0;
    cc.mod_sinp = 1;
    cc.mod_cosa = 0;
    cc.mod_cosp = 1;
    cc.mod_coso = 0;
    cc.mod_tana = 0;
    cc.mod_tanp = 1;
    cc.mod_tano = 0;
    //umove
    cc.mod_posx=0;
    cc.mod_posy=0;
    //utwist
    for (var i = 1; i <= 4; i++)
        {
            variable_instance_set(cc, string("mod_twx{0}", i), 0);
            variable_instance_set(cc, string("mod_twy{0}", i), 0);
            variable_instance_set(cc, string("mod_twa{0}", i), 0);
            variable_instance_set(cc, string("mod_twr{0}", i), 0.4);
        }

}

function InitStarParticle(){
    if (!cc.ENABLE_STARPARTICLE)
        exit;
    addExtraMod("starspawner_timer")
    cc.mod_starspawner_timer = 0;
    addExtraMod("starspd_multiplier")
    cc.mod_starspd_multiplier = 1;
    addExtraMod("starspd_low")
    cc.mod_starspd_low = 0;
    addExtraMod("starspd_high")
    cc.mod_starspd_high = 0;
    addExtraMod("startrans_alpha")
    cc.mod_startrans_alpha = 1;
    addExtraMod("starchgcol_alpha")
    cc.mod_starchgcol_alpha = 1;
    addExtraMod("active_starchgcol", 0,function(start,dur,v1,stat)
        {
            cc.mod_activate_starchgcol = stat;
        });
    addExtraMod("active_startrans", 0,function(start,dur,v1,stat)
        {
            cc.mod_activate_startrans = stat;
        });
    cc.mod_activate_starchgcol = 0;
    cc.mod_activate_startrans = 0;
    addExtraMod("starchgcol_up_rgb");
    cc.mod_starchgcol_up_rgb=c_white;
    addExtraMod("starchgcol_down_rgb");
    cc.mod_starchgcol_down_rgb=c_white;
    instance_create_depth(0, 0, 750, o_csm_startransparent_spawner);
    instance_create_depth(0, 0, 101, o_csm_starchangecol_spawner);
}

function InitImage(){
    var insEx={
        caller:id
    };
    instance_create_depth(0,0,0,o_sprite_drawer_manager,insEx);
}

function InitMisc(){
    addExtraMod("cover1");
    addExtraMod("cover2");
    addExtraMod("cover3");

    addExtraMod("rainbow");
    addExtraMod("sides");
    addExtraMod("scorealph");
    addExtraMod("bgalph");
    addExtraMod("static");
    addExtraMod("holdoverlayalpha");
    addExtraMod("hide_combo");

    addExtraMod("slash_anycol_new",1,function(start,dur, slash_cnt, slash_col){
        var col=(slash_col==cc.ORIGINAL_FROM) ? cc.mod_set_slash_col : slash_col;
        var repeatTime=(slash_cnt==cc.ORIGINAL_FROM) ? 1 : slash_cnt;

        repeat(repeatTime)
        {
            instance_create_depth(0, 0, 255, o_anycol_slash, {
                color:col_convert(col)
            })
        }
        
    })
    addExtraMod("set_slash_col",1)
    addExtraMod("slash_anycol")
    addExtraMod("slash_anycol_close_time")
    cc.mod_slash_anycol_close_time=1
    addExtraMod("lr_slash",1,function(start,dur, slash_cnt, slash_col){
        var col=(slash_col==cc.ORIGINAL_FROM) ? cc.mod_lr_slash_col : slash_col;
        var repeatTime=(slash_cnt==cc.ORIGINAL_FROM) ? 1 : slash_cnt;

        repeat(repeatTime)
        {
            instance_create_depth(0, 0, 255, o_csm_side_slash, {
                color:col_convert(col)
            })
        }
    })
    addExtraMod("lr_slash_col",1)
    addExtraMod("lr_slash_close_time",1)
    cc.mod_lr_slash_close_time=1

    addExtraMod("wflash");
    cc.plaudite_pburst_consist=-0.01
    addExtraMod("plaudite_pburst",0,function(start,dur, msRepeat, repeatTime)
    {
        if (msRepeat){
            cc.CreateChartTween(start,repeatTime,cc,"plaudite_pburst_consist",EaseLinear,repeatTime,-0.01);
        }
        else{
        for (var i = 0; i < repeatTime; i++)
            spawn_particles_directional(irandom_range(0, 320), -10, 701, o_pt_diamonddust, 1, 0, 1.5 * cc.mod_pburstspeed, 240, 1);
        }
    });
    addExtraMod("sg_endblip",0 ,function(){
        instance_create_depth(160, 90, -9000, o_sg_endblip);
    });
    addExtraMod("sg_endblip_destroy",0 ,function(){
        instance_destroy(o_sg_endblip);
    });
    cc.mod_static=0;
    cc.mod_cover1 = 0;
    cc.mod_cover2 = 0;
    cc.mod_cover3 = 0;
    cc.mod_wflash = 0;
    cc.mod_rainbow = 0;
    cc.mod_scorealph = 1;
    cc.mod_bgalph = 1;
    cc.mod_sg_endblip = 0;
    cc.mod_sg_endblip_destroy = 0;
    cc.mod_plaudite_pburst = 0;
    cc.mod_hide_combo = 0;
    cc.mod_slash_anycol=0
    cc.mod_set_slash_col=16777215;
    cc.mod_lr_slash_col=16777215;

    instance_create_depth(0,0,-400,o_csm_screen_cover_handler)
}

InitStarParticle();
InitSkinChange()
InitCSMJacket()
InitText();
InitDistortBG();
InitNonBaseFX();
InitSides()
InitDFGridAndLine();
InitAngelstarChecker();
InitCustomShader();
InitMisc();
InitImage();



for (var i = 0; i < proxyCount; i++)
    proxies[i].pra = 1;
//OTHERS
aft = -1;
pixelated_topscreen = -1;
aftsprite = -1;
sidespawner = 0;


//special
shouldPixelate = true;
main_shader = function(){
    
    if (aftsprite != undefined && sprite_exists(aftsprite))
    {
        sprite_delete(aftsprite);
        aftsprite = undefined;
    }
    //ANGELSTAR
    shader_set(shader_custom_main);
    shader_set_uniform_f(uTime, cc.currentms / 1000);
    shader_set_uniform_f(uGrayAmp, cc.mod_gray);
    shader_set_uniform_f(uBarrelAmp, cc.mod_barrel + cc.mod_barrel2);
    shader_set_uniform_f(uHDistortAmp, cc.mod_hdistort);
    shader_set_uniform_f(uVDistortAmp, cc.mod_vdistort);
    shader_set_uniform_f(uFishAmp, cc.mod_fish);
    shader_set_uniform_f(uVigAmp, cc.mod_vig);
    shader_set_uniform_f(bloom, cc.mod_bloom);
    shader_set_uniform_f(uAbX, cc.mod_abx);
    shader_set_uniform_f(uAbY, cc.mod_aby);
    shader_set_uniform_f(uAbberationX, cc.mod_barrelabx);
    shader_set_uniform_f(uAbberationY, cc.mod_barrelaby);
    shader_set_uniform_f(uSTime, cc.mod_glitchoffset);
    shader_set_uniform_f(uGlitchAmp, cc.mod_glitchamp);
    shader_set_uniform_f(uHNoise, cc.mod_uhnoise);
    for (var i = 1; i < 5; i++)
    {
        var twx = variable_instance_get(cc, string("mod_twx{0}", i));
        var twy = variable_instance_get(cc, string("mod_twy{0}", i));
        var twa = variable_instance_get(cc, string("mod_twa{0}", i));
        var twr = variable_instance_get(cc, string("mod_twr{0}", i));
        shader_set_uniform_f(variable_instance_get(cc,string("uTwist{0}",i)), twx, twy, twa * 0.6, twr);
    }
    shader_set_uniform_f(uSinm, cc.mod_sina,cc.mod_sinp,cc.mod_sino);
    shader_set_uniform_f(uCosm, cc.mod_cosa,cc.mod_cosp,cc.mod_coso);
    shader_set_uniform_f(uTanm, cc.mod_tana,cc.mod_tanp,cc.mod_tano);
    shader_set_uniform_f(uMove, cc.mod_posx,cc.mod_posy);
    texture_set_stage(uNoiseSampler, noisetex);
}
