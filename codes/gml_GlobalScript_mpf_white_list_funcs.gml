enum MPF_SCOPE {
    ANY,
    INIT
}
enum RISK_LEVEL {
    SAFE,
    RISK,
    HIGH_RISK,
    CRITICAL_RISK
}

function mpfRiskToLevel(_s)
{
    var _v = string_upper(string(_s));
    if (_v == "RISK") return RISK_LEVEL.RISK;
    if (_v == "HIGH_RISK") return RISK_LEVEL.HIGH_RISK;
    if (_v == "CRITICAL_RISK") return RISK_LEVEL.CRITICAL_RISK;
    return RISK_LEVEL.SAFE;
}

function mpfScopeInitOnly(_scope)
{
    return (_scope == MPF_SCOPE.INIT);
}

global.mpfAllowedInternalFuncs={}

function RegisterWLFuncs(_name,_rl,_scope,_func){
    var struct_func={
        rl:_rl,
        scope:_scope,
        f:_func
    };
    struct_set(global.mpfAllowedInternalFuncs,_name,struct_func);
}

//math
RegisterWLFuncs("sin", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(x, env=undefined) {
    return sin(x);
});

RegisterWLFuncs("cos", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(x, env=undefined) {
    return cos(x);
});

RegisterWLFuncs("tan", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(x, env=undefined) {
    return tan(x);
});

RegisterWLFuncs("abs", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(x, env=undefined) {
    return abs(x);
});

RegisterWLFuncs("floor", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(x, env=undefined) {
    return floor(x);
});

RegisterWLFuncs("ceil", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(x, env=undefined) {
    return ceil(x);
});

RegisterWLFuncs("min", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(a, b, env=undefined) {
    return min(a, b);
});

RegisterWLFuncs("max", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(a, b, env=undefined) {
    return max(a, b);
});

RegisterWLFuncs("clamp", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(v, lo, hi, env=undefined) {
    return clamp(v, lo, hi);
});

//string handling
RegisterWLFuncs("to_str", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(v, env=undefined) {
    return string(v);
});

RegisterWLFuncs("str_cat", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(a, b, env=undefined) {
    return string(a) + string(b);
});

//array handling
RegisterWLFuncs("array_create", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(size, env=undefined) {
    return array_create(size);
});

RegisterWLFuncs("array_sort", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(a,sorttype, env=undefined) {
    if (!is_array(a)) mpfRaise("TypeError", "this function expects an array");
    array_sort(a,sorttype);
    return a;
});

RegisterWLFuncs("array_length", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(a, env=undefined) {
    if (!is_array(a)) mpfRaise("TypeError", "this function expects an array");
    return array_length(a);
});

RegisterWLFuncs("array_push", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(a,e, env=undefined) {
    if (!is_array(a)) mpfRaise("TypeError", "this function expects an array");
    array_push(a, e);
    return a;
});

RegisterWLFuncs("array_pop", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(a, env=undefined) {
    if (!is_array(a)) mpfRaise("TypeError", "this function expects an array");
    return array_pop(a);
});

RegisterWLFuncs("array_insert", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(a,e,i, env=undefined) {
    if (!is_array(a)) mpfRaise("TypeError", "this function expects an array");
    if (i < 0 || i > array_length(a)) mpfRaise("IndexError", "cannot insert out of array");
    array_insert(a, i, e);
    return a;
});

RegisterWLFuncs("array_contains", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(a, e, env=undefined) {
    if (!is_array(a)) mpfRaise("TypeError", "this function expects an array");
    return array_contains(a, e);
});

//random
RegisterWLFuncs("random", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(x, env=undefined) {
    return random(x);
});

RegisterWLFuncs("irandom", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(x, env=undefined) {
    return irandom(x);
});

RegisterWLFuncs("random_set_seed", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(x, env=undefined) {
    return random_set_seed(x);
});

//input relative
RegisterWLFuncs("input_lane_check_pressed",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(lane,env=undefined){
    return input_lane_check_pressed(lane);
})

RegisterWLFuncs("input_lane_check_released",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(lane,env=undefined){
    return input_lane_check_released(lane);
})

RegisterWLFuncs("input_lane_check",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(lane,env=undefined){
    return input_lane_check(lane);
})

RegisterWLFuncs("input_keyboard_check_key",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(itype,kcode,env=undefined){
    return input_keyboard_check_key(itype,kcode);
})

RegisterWLFuncs("input_check_mouse",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(itype,mcode,env=undefined){
    switch (mcode) {
        case 0:
            mcode=mb_left;
            break;
        case 1:
            mcode=mb_middle;
            break;
        case 2:
            mcode=mb_right;
            break;
        case 3:
            mcode=mb_any
            break;
    }
    switch (itype) {
        case 0:
            return mouse_check_button_pressed(mcode)
            break;
        case 1:
            return mouse_check_button_released(mcode)
            break;
        case 2:
            return mouse_check_button(mcode);
            break;
    }
})

RegisterWLFuncs("mouse_wheel_up",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(env=undefined){
    return mouse_wheel_up();
})

RegisterWLFuncs("mouse_wheel_down",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(env=undefined){
    return mouse_wheel_down();
})

RegisterWLFuncs("get_mouse_pos",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(env=undefined){
    return [mouse_x,mouse_y];
})

//gameplay relative
RegisterWLFuncs("add_judge_cnt", RISK_LEVEL.HIGH_RISK, MPF_SCOPE.ANY, function(judgeType, cnt, side, env=undefined) {
    if (is_struct(side)) { env = side; side = 0; }
    if (!is_real(judgeType) || judgeType != floor(judgeType) || judgeType < 0 || judgeType > 4) mpfRaise("ValueError", "judge type must be an integer 0~4");
    if (!is_real(cnt) || cnt != floor(cnt)) mpfRaise("ValueError", "judge count must be an integer");
    if (!is_real(side)) mpfRaise("ValueError", "judge side must be 0 (late) or 1 (early)");
    if (cnt == 0) return;
    if (!variable_global_exists("count_acrit")) return;

    var _early = (side != 0);
    var _accval = 0;
    var _xaccval = 0;
    switch (judgeType) {
        case 0:
            global.count_acrit += cnt;
            _accval = 100;
            _xaccval = 101 / 1.01;
            break;
        case 1:
            if (_early) global.count_early_crit += cnt;
            else global.count_late_crit += cnt;
            _accval = 100;
            _xaccval = 100 / 1.01;
            break;
        case 2:
            if (_early) global.count_early_great += cnt;
            else global.count_late_great += cnt;
            _accval = 75;
            _xaccval = 75 / 1.01;
            break;
        case 3:
            if (_early) global.count_early_good += cnt;
            else global.count_late_good += cnt;
            _accval = 50;
            _xaccval = 50 / 1.01;
            break;
        case 4:
            if (_early) global.count_early_miss += cnt;
            else global.count_late_miss += cnt;
            break;
    }

    global.count_crit = global.count_early_crit + global.count_late_crit;
    global.count_great = global.count_early_great + global.count_late_great;
    global.count_good = global.count_early_good + global.count_late_good;
    global.count_miss = global.count_early_miss + global.count_late_miss;
    global.earlynotes = global.count_early_crit + global.count_early_great + global.count_early_good;
    global.latenotes = global.count_late_crit + global.count_late_great + global.count_late_good;

    if (judgeType == 4) {
        global.currentcombo = (cnt > 0) ? 0 : max(0, global.currentcombo - cnt);
    }
    else if (judgeType != 3) {
        global.currentcombo = max(0, global.currentcombo + cnt);
    }
    global.maxcombo = max(global.maxcombo, global.currentcombo);

    var _acc = global.accuracy;
    _acc.sum += _accval * cnt;
    _acc.count += cnt;
    _acc.value = (_acc.count > 0) ? (_acc.sum / _acc.count) : 100;
    var _xacc = global.x_accuracy;
    _xacc.sum += _xaccval * cnt;
    _xacc.count += cnt;
    _xacc.value = (_xacc.count > 0) ? (_xacc.sum / _xacc.count) : 100;

    if (!variable_global_exists("notevalue")) return;
    global.currentscore = ((global.count_acrit * 1.01) + global.count_crit + (global.count_great * 0.75) + (global.count_good * 0.5)) * global.notevalue;
    global.minusscore = 1010000 - (((global.count_crit * 0.01) + (global.count_great * 0.26) + (global.count_good * 0.51) + (global.count_miss * 1.01)) * global.notevalue);
    global.gamescore = (3 * global.count_acrit) + (2 * global.count_crit) + global.count_great;

    if (!instance_exists(cc)) return;
    if (cc.sdisp_accscore > global.currentscore) cc.sdisp_accscore = global.currentscore;
    if (cc.sdisp_exscore > global.gamescore) cc.sdisp_exscore = global.gamescore;
    cc.pace_total += _accval * cnt;
    cc.pace_amount += cnt;
    if (cc.pace_amount > 0) cc.pace_update();
});

RegisterWLFuncs("get_judge_cnt", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(judgeType, env=undefined) {
    switch (judgeType) {
        case 0:
            return global.count_acrit;
            break;
        case 1:
            return global.count_crit;
            break;
        case 2:
            return global.count_great;
            break;
        case 3:
            return global.count_good;
            break;
        case 4:
            return global.count_miss;
            break;
    }
    return 0;
});

RegisterWLFuncs("get_combo",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(env=undefined){
    return global.currentcombo;
})

RegisterWLFuncs("get_max_combo",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(env=undefined){
    return global.maxcombo;
})

RegisterWLFuncs("get_score",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(minus,env=undefined){
    return minus?global.minusscore:global.currentscore;
})

RegisterWLFuncs("get_score_ex",RISK_LEVEL.SAFE,MPF_SCOPE.ANY,function(env=undefined){
    return global.gamescore;
})

RegisterWLFuncs("set_judge_timing",RISK_LEVEL.HIGH_RISK,MPF_SCOPE.ANY,function(judge,timing){
    cc.timings[judge]=timing;
})

RegisterWLFuncs("reset_judge_timing",RISK_LEVEL.HIGH_RISK,MPF_SCOPE.ANY,function(){
    cc.timings=[35, 70, 110, 150, 200];
})

//gimmick control
RegisterWLFuncs("register_mod", RISK_LEVEL.SAFE, MPF_SCOPE.INIT, function(mod_name,_default_val, env=undefined) {
    if (env == undefined || !is_struct(env) || env.inst == undefined) return;
    var _gmk = env.inst;
    var _nid = _gmk.lastExtraModIndex;
    _gmk.lastExtraModIndex = _nid + 1;
    variable_struct_set(_gmk.extraMods, mod_name, _nid);
    _gmk.extraModCallbacks[_nid] = undefined;
    _gmk.extraModEndCallbacks[_nid] = undefined;
    variable_struct_set(global.mod_weight, mod_name, 0);
    if (instance_exists(cc)) variable_instance_set(cc, "mod_" + mod_name, _default_val);
});

RegisterWLFuncs("set_mod_val", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(modname, val, proxy, env=undefined) {
    if (is_struct(proxy)) { env = proxy; proxy = -1; }
    if (!instance_exists(cc)) return;
    if (proxy==-1){
        variable_instance_set(cc, "mod_" + modname, val);
    }
    else{
        variable_instance_set(env.inst.proxies[proxy], modname, val);
    }
});

RegisterWLFuncs("set_mod_val_at", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(modname,time, val, proxy, env=undefined) {
    if (!instance_exists(cc)) return;
    if (is_struct(proxy)) { env = proxy; proxy = -1; }
    var argenv={
        _modname: modname,
        _val: val,
        _proxy: proxy,
        _env: env
    }
    var set_val=function(){
        if (_proxy==-1){
            variable_instance_set(cc, "mod_" + _modname, _val);
        }
        else{
            variable_instance_set(_env.inst.proxies[_proxy], _modname, _val);
        }
    }
    var _startms = 1000 * TimeFromBPMListAndBeat(cc.bpmlist, time, cc.chartoffset);
    cc.CreateChartCallback(_startms, method(argenv,set_val), 0, 0, 0, EaseLinear);
});

RegisterWLFuncs("get_mod_val", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(modname, proxy, env=undefined) {
    if (is_struct(proxy)) { env = proxy; proxy = -1; }
    if (!instance_exists(cc)) return 0;
    return (proxy==-1) ? variable_instance_get(cc, "mod_" + modname) : variable_instance_get(env.inst.proxies[proxy], modname);
});

RegisterWLFuncs("tween_mod_val", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(modname,duration,easing,startval,endval,proxy, env=undefined) {
    if (!variable_struct_exists(global.eases, easing)) mpfRaise("NameError", "unknown easing '" + string(easing) + "'");
    var tween_inst=(proxy >= 0) ? env.inst.proxies[proxy] : cc;
    var excatmod=((proxy>= 0) ? "" : "mod_")+modname;
    var easeFunc=struct_get(global.eases, easing);
    var curbeat=env.last_beat;
    var _startms = 1000 * TimeFromBPMListAndBeat(cc.bpmlist, curbeat, cc.chartoffset);
    var _durms = duration * (60000 / GetBPMAtBeat(cc.bpmlist, curbeat));
    cc.CreateChartTween(_startms, _durms, tween_inst, excatmod, easeFunc, startval, endval);
});

RegisterWLFuncs("tween_mod_val_at", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(modname,start,duration,easing,startval,endval,proxy, env=undefined) {
    if (!variable_struct_exists(global.eases, easing)) mpfRaise("NameError", "unknown easing '" + string(easing) + "'");
    var tween_inst=(proxy >= 0) ? env.inst.proxies[proxy] : cc;
    var excatmod=((proxy>= 0) ? "" : "mod_")+modname;
    var easeFunc=struct_get(global.eases, easing);
    var _startms = 1000 * TimeFromBPMListAndBeat(cc.bpmlist, start, cc.chartoffset);
    var _durms = duration * (60000 / GetBPMAtBeat(cc.bpmlist, start));
    cc.CreateChartTween(_startms, _durms, tween_inst, excatmod, easeFunc, startval, endval);
});

RegisterWLFuncs("call_callback_mod", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(modname,duration,val1,val2, env=undefined) {
    var curbeat=env.last_beat;
    var isExtra=struct_exists(env.inst.extraMods, modname);
    if (!isExtra && !variable_struct_exists(global.mods, modname)) mpfRaise("NameError", "unknown mod '" + string(modname) + "'");
    var modID=(isExtra)?struct_get(env.inst.extraMods, modname):struct_get(global.mods, modname);
    var callback=(isExtra)?env.inst.extraModCallbacks[modID]:global.mod_callbacks[modID];
    var endcallback=(isExtra)?env.inst.extraModEndCallbacks[modID]:global.mod_end_callbacks[modID];
    var _startms = 1000 * TimeFromBPMListAndBeat(cc.bpmlist, curbeat, cc.chartoffset);
    var _durms = duration * (60000 / GetBPMAtBeat(cc.bpmlist, curbeat));
    if (callback != undefined) cc.CreateChartCallback(_startms, callback, _durms, val1, val2, EaseLinear);
    if (endcallback != undefined) cc.CreateChartCallback(_startms + _durms, endcallback, _durms, val1, val2, EaseLinear);
});

RegisterWLFuncs("call_callback_mod_at", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(modname,time,duration,val1,val2, env=undefined) {
    var isExtra=struct_exists(env.inst.extraMods, modname);
    if (!isExtra && !variable_struct_exists(global.mods, modname)) mpfRaise("NameError", "unknown mod '" + string(modname) + "'");
    var modID=(isExtra)?struct_get(env.inst.extraMods, modname):struct_get(global.mods, modname);
    var callback=(isExtra)?env.inst.extraModCallbacks[modID]:global.mod_callbacks[modID];
    var endcallback=(isExtra)?env.inst.extraModEndCallbacks[modID]:global.mod_end_callbacks[modID];
    var _startms = 1000 * TimeFromBPMListAndBeat(cc.bpmlist, time, cc.chartoffset);
    var _durms = duration * (60000 / GetBPMAtBeat(cc.bpmlist, time));
    if (callback != undefined) cc.CreateChartCallback(_startms, callback, _durms, val1, val2, EaseLinear);
    if (endcallback != undefined) cc.CreateChartCallback(_startms + _durms, endcallback, _durms, val1, val2, EaseLinear);
});

//debug
RegisterWLFuncs("write_log", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(str, env=undefined) {
    var logname=string("log_mpf.{0}.{1}.log",global.ch_load,global.df_load)
    var fp = file_text_open_append(logname);
    if (fp == -1) return;
    file_text_write_string(fp, str);
    file_text_writeln(fp, "");
    file_text_close(fp);
});
RegisterWLFuncs("short_msg", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(str, env=undefined) {
    array_push(global.mpfMsgQueue, str);
});

//easings
RegisterWLFuncs("ease", RISK_LEVEL.SAFE, MPF_SCOPE.ANY, function(easing,start_val,end_val,t, env=undefined) {
    var easeFunc=struct_get(global.eases,easing)
    var changed=end_val-start_val;
    return easeFunc(t,start_val,changed,1);
});

//special
RegisterWLFuncs("get_game_var_global", RISK_LEVEL.RISK, MPF_SCOPE.ANY, function(var_name, env=undefined) {
    if (!variable_global_exists(var_name))
        mpfRaise("ValueError","variable "+string(var_name)+"doesn't exists");
    return variable_global_get(var_name);
});

RegisterWLFuncs("get_game_var_instance", RISK_LEVEL.RISK, MPF_SCOPE.ANY, function(ins_name, var_name,ins_id=0, env=undefined) {
    var aid=asset_get_index(ins_name)
    if (aid<=-1)
        mpfRaise("ValueError","instance "+string(ins_name)+"doesn't exists");
    var ins=instance_find(aid,ins_id);
    if (!variable_instance_exists(ins,var_name))
        mpfRaise("ValueError","variable "+string(var_name)+"doesn't exists");

    return variable_instance_get(ins, var_name);
});
