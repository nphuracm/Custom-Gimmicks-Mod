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
  