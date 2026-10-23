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
if (!is_custom_chart(chart)) exit;

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

custom_mpfs=[]

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

addExtraMod = function(modName, weight = 1, callBack = undefined, endCallBack = undefined)
{
    variable_struct_set(global.mod_weight, modName, weight);
    if (!instance_exists(cc)) exit;
    var i = lastExtraModIndex;
    lastExtraModIndex++;
    variable_struct_set(extraMods, modName, i);
    extraModCallbacks[i] = callBack;
    extraModEndCallbacks[i] = endCallBack;
};
updateMods = function()
{
    if (mpfHasError())
    {
        var errs = mpfGetErrors();
        var logname=string("mpfruntime.{0}.{1}.log",global.ch_load,global.df_load)
        var fp=file_text_open_append(logname);
        for (var i = 0; i < array_length(errs); i++)
        {
            var err = errs[i]; 
            file_text_write_string(fp, string(err));
            file_text_writeln(fp);
            array_push(global.mpfMsgQueue, string("script {2}: [{0}] at line {1}.", err.type, err.line, err.name));
        }
        file_text_close(fp);
    }
    var liveMsgCnt = instance_number(o_small_gmk_msg_dialog);
    while (array_length(global.mpfMsgQueue) > 0 && liveMsgCnt < global.mpfMsgMax)
    {
        var msgContent = global.mpfMsgQueue[0];
        array_delete(global.mpfMsgQueue, 0, 1);
        var ins_msg = instance_create_depth(999, 40, -9999, o_small_gmk_msg_dialog);
        with (ins_msg)
        {
            content = msgContent;
            width=string_width_ext(content, line_sep, text_max_width);
            dest_x = room_width - width - padding * 2 - 8;
            start_anim();
        }
        liveMsgCnt += 1;
    }
    while (curmod < array_length(modlist) && cc.currentbeataccurate >= modlist[curmod].b)
    {
        var thismod = modlist[curmod];
        var start = 1000 * TimeFromBPMListAndBeat(cc.bpmlist, thismod.b, cc.chartoffset);
        var duration = thismod.d * (60000 / GetBPMAtBeat(cc.bpmlist, thismod.b));
        var modID=thismod.ig?struct_get(global.mods, thismod.m):struct_get(extraMods, thismod.m);
        if (modID == undefined)
        {
            curmod++;
            continue;
        }
        if (thismod.ig?(global.mod_callbacks[modID] == undefined) : (extraModCallbacks[modID] == undefined))
        {
            cc.CreateChartTween(start, duration, (thismod.p >= 0) ? proxies[thismod.p] : cc, ((thismod.p >= 0) ? "" : "mod_") + thismod.m, thismod.e, thismod.v1, thismod.v2);
        }
        else
        {
            cc.CreateChartCallback(start, thismod.ig ? global.mod_callbacks[modID] : extraModCallbacks[modID],duration, thismod.v1, thismod.v2, thismod.e);
            
            if (thismod.ig?(global.mod_end_callbacks[modID] != undefined) : (extraModEndCallbacks[modID] != undefined))
                cc.CreateChartCallback(start + duration, thismod.ig ? global.mod_end_callbacks[modID] : extraModEndCallbacks[modID],duration, thismod.v1, thismod.v2, thismod.e);
        }
        
        curmod++;
    }
    
    for (var i = 0; i < array_length(perframelist); i++)
    {
        var thisper = perframelist[i];
        var mpfActive = (cc.currentbeataccurate > thisper.b && cc.currentbeataccurate < thisper.e);
        var mpfSelf = is_method(thisper.f) ? method_get_self(thisper.f) : undefined;
        var mpfMine = is_struct(mpfSelf) && struct_exists(mpfSelf, "__mpf");
        var mpfWasIn = struct_exists(thisper, "in_range") && thisper.in_range;
        if (mpfMine) mpfSelf.last_seen = cc.currentbeataccurate;
        
        if (mpfActive)
        {
            if (mpfMine)
            {
                mpfRunEntry(thisper, mpfSelf, cc.currentbeataccurate, self);
            }
            else if (thisper.f != undefined)
            {
                var mpffunc = method(self, thisper.f);
                mpffunc(cc.currentbeataccurate);
            }
        }
        else if (mpfMine && mpfWasIn)
        {
            mpfFinishEntry(thisper, mpfSelf, cc.currentbeataccurate, self);
        }
        thisper.in_range = mpfActive;
    }
};
  