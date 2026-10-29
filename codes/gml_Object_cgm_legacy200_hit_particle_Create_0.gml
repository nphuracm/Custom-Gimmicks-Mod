visible = true;
image_speed = 0;
image_blend = c_white;
if (legacy_diamond)
{
    sprite_index = sp_lg_diamonddust;
    image_index = legacy_frame;
    image_alpha = 0.6;
    legacy_lifetime = 75;
}
else
{
    sprite_index = sp_lg_noteparticle;
    image_index = legacy_judgement;
    image_angle = 45;
    image_alpha = 1;
    image_xscale = 2;
    image_yscale = 2;
    legacy_lifetime = 50;
}
