dest_x=-999
bg_color = c_black;
border_color = c_white;
text_color = c_white;
border_width = 1;
text_max_width = room_width;
padding = 4;
line_sep = -1;
content = "";
fade_in_sec=0.3;
waiting_sec=3;
fade_out_sec=0.5;
width=0
slot=-1;
var _used = [];
with (o_small_gmk_msg_dialog) { if (slot > -1) array_push(_used, slot); }
while (array_contains(_used, slot + 1)) slot += 1;
slot += 1;
y = 40 + slot * 30;
start_anim=function(){
    TweenFire(self,EaseOutCubic,0,true,0,fade_in_sec,"x",room_width+20,dest_x)
    TweenFire(self,EaseInCubic,0,true,fade_in_sec + waiting_sec,fade_out_sec,"x",dest_x,room_width+20)
    call_later(fade_in_sec + waiting_sec + fade_out_sec, time_source_units_seconds, function(){
            instance_destroy(self)
        }
    )
}