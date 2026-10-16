//arg0:lane,arg1:time
function gmlNoteModsX_scale (arg0, arg1, arg2, arg3, arg4)
    {
        return (((arg0 - arg1) * (arg4 - arg3)) / (arg2 - arg1)) + arg3;
    };

function gmlNoteModsX(lane, time, arg2)
{
    
    
    var xpos = 0;
    if (cc.mod_beat != 0)
    {
        var fAccelTime = 0.3;
        var fTotalTime = 0.7;
        var fBeat = cc.currentbeataccurate + fAccelTime;
        var bEvenBeat = (fBeat % 2) < 1;
        fBeat %= 1;
        
        if (fBeat < fTotalTime)
        {
            var fAmount = 0;
            
            if (fBeat < fAccelTime)
            {
                fAmount = gmlNoteModsX_scale(fBeat, 0, fAccelTime, 0, 1);
                fAmount = fAmount * fAmount;
            }
            else
            {
                fAmount = gmlNoteModsX_scale(fBeat, fAccelTime, fTotalTime, 1, 0);
                fAmount = 1 - ((1 - fAmount) * (1 - fAmount));
            }
            
            fAmount *= (bEvenBeat ? 1 : -1);
            var fShift = 11 * fAmount * sin((time / 60) + 1.5707963267948966);
            xpos += ((cc.mod_beat / 100) * fShift);
        }
    }
    xpos += cc.mod_xoffset+variable_instance_get(cc, string("mod_xoffsetind{0}", lane));
    xpos += cc.mod_xoffsetb+variable_instance_get(cc, string("mod_xoffsetindb{0}", lane));
    return xpos;
}

function gmlNoteExcatDist(dist, lane)
{
    var curms=(cc.mod_freeze==0)?cc.currentms:cc.mod_freeze;
    var yoff=cc.mod_yoffset+variable_instance_get(cc, string("mod_yoffsetind{0}", lane))
    yoff+=cc.mod_yoffsetb+variable_instance_get(cc, string("mod_yoffsetindb{0}", lane))
    return (dist+curms)-global.vsvHandler.warpedTime(curms + yoff);
}
//arg0:dist, arg1:lane
function gmlNoteModsY(notems, lane,arg2)
{
    var downscroll=NoteModsIsLaneDownscroll(lane)
    var scrollind=variable_instance_get(cc, string("mod_scrollind{0}",lane));
    var excatDist=gmlNoteExcatDist(notems, lane);
    if (excatDist>cc.mod_drawuntil)
        return downscroll ? -2147483647 : 2147483647;
    var yoff = 144 - ((excatDist / 10) * cc.mod_scrollspeed * cc.mod_velocity * scrollind);
    
    if (cc.mod_driven != 0)
        yoff -= (cc.mod_driven * cc.bps * cc.mod_scrollspeed * cc.mod_velocity * 22 * scrollind);
    
    if (cc.mod_wave != 0)
        yoff -= ((cc.mod_wave / 100) * 20 * sin(excatDist / 152));
    
    if (cc.mod_boost_distance != 0)
    {
        var arghenaTimeDistance = cc.mod_boost_time+variable_instance_get(cc, string("mod_boost_timeind{0}", lane));
        var arghenaMoveDistance = cc.mod_boost_distance+variable_instance_get(cc, string("mod_boost_distanceind{0}", lane));
        var arghenaModded = -arghenaMoveDistance;
        
        if (excatDist < arghenaTimeDistance && arghenaTimeDistance > 0)
            arghenaModded = EaseInCubic(arghenaTimeDistance - excatDist, -arghenaMoveDistance, arghenaMoveDistance, arghenaTimeDistance);
        
        yoff += arghenaModded;
    }
    return yoff;
}
