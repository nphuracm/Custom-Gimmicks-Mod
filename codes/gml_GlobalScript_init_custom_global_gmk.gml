function UnlimitedAddGlobalMod(modName,modWeight,callBack=undefined,endCallBack=undefined){
    static lastIdx = 129;
    variable_struct_set(global.mods, modName, lastIdx);
    global.mod_callbacks[lastIdx] = callBack;
    global.mod_end_callbacks[lastIdx] = endCallBack;
    variable_struct_set(global.mod_weight, modName, modWeight);
    lastIdx++;
}
UnlimitedAddGlobalMod("prsy", 2);
UnlimitedAddGlobalMod("prtrX", 2);
UnlimitedAddGlobalMod("prtrY", 2);
UnlimitedAddGlobalMod("prtrD", 2);
UnlimitedAddGlobalMod("xoffset", 1.5);
UnlimitedAddGlobalMod("xoffsetb", 1.5);
UnlimitedAddGlobalMod("yoffsetb", 1.5);
UnlimitedAddGlobalMod("drawstop", 2);
for (var lane=0;lane<7;lane++){
    UnlimitedAddGlobalMod(string("yoffsetind{0}", lane), 1.5);
    UnlimitedAddGlobalMod(string("xoffsetind{0}", lane), 1.5);
    UnlimitedAddGlobalMod(string("yoffsetindb{0}", lane), 1.5);
    UnlimitedAddGlobalMod(string("xoffsetindb{0}", lane), 1.5);
    UnlimitedAddGlobalMod(string("notealpind{0}", lane), 1.5);
    UnlimitedAddGlobalMod(string("boost_timeind{0}", lane), 2.5);
    UnlimitedAddGlobalMod(string("boost_distanceind{0}", lane), 2.5);
}
UnlimitedAddGlobalMod("jumpto_beat",0,function(start,dur, v1, toBeat){
    if (cc.playback != undefined && cc.ENABLE_MUSIC_CONTROL)
    {
        var pos = TimeFromBPMListAndBeat(cc.bpmlist, toBeat, cc.chartoffset);
        if (global.op_use_gamemaker_audio)
            audio_sound_set_track_position(cc.playback, pos);
        else
            precise_audio_set_time(pos);
    }
});
UnlimitedAddGlobalMod("jumpto_s",0,function(start,dur, isSec, v2){
    if (cc.playback != undefined && cc.ENABLE_MUSIC_CONTROL)
    {
        if (global.op_use_gamemaker_audio)
            audio_sound_set_track_position(cc.playback, v2/(isSec?1:1000));
        else
            precise_audio_set_time(v2/(isSec?1:1000));
    }
});
UnlimitedAddGlobalMod("playspeed", 0,function(start,dur, v1, playspeed){
    if (cc.playback != undefined && cc.ENABLE_MUSIC_CONTROL)
    {
        var val = round(playspeed * 100) / 100;
        cc.song_speed*=val
    }
});
UnlimitedAddGlobalMod("reset_scrollspeed",0,function(){
    cc.mod_scrollspeed=(global.op_note_speed / 5) + 1;
});

// Discrete presentation controls: set the destination at the event start.
UnlimitedAddGlobalMod("uimode", 0, function(start, dur, v1, v2)
{
    cgm_set_ui_mode(v2 == cc.ORIGINAL_FROM ? v1 : v2);
});
UnlimitedAddGlobalMod("bgparticles200", 0, function(start, dur, v1, v2)
{
    cc.mod_bgparticles200 = (v2 == cc.ORIGINAL_FROM ? v1 : v2) >= 0.5 ? 1 : 0;
});
