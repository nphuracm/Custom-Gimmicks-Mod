if (!instance_exists(cc))
{
    instance_destroy();
    exit;
}
// Original gameplay targeted 120 steps/s. Match that speed in real time even
// when the modern FPS target differs, and pause with the UI clock.
var frames = cc.delta_s * 120;
var velocity_scale = legacy_diamond ? image_alpha : 1;
x += legacy_vx * velocity_scale * frames;
y += legacy_vy * velocity_scale * frames;
image_alpha -= frames / legacy_lifetime;
if (!legacy_diamond)
{
    image_xscale = max(0, image_alpha * 2);
    image_yscale = image_xscale;
}
if (image_alpha <= 0) instance_destroy();
