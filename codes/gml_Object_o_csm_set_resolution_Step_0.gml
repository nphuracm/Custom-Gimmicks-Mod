if (!instance_exists(cc))
{
    instance_destroy();
    exit;
}

if (want == applied) exit;

if (want <= 1)
{
    if (instance_exists(obj_resolution_handler)) reset_resolution();
    if (instance_exists(o_bg)) o_bg.highres = false;
}
else if (instance_exists(obj_resolution_handler))
{
    set_resolution_multiplier(want);
    if (instance_exists(o_bg)) o_bg.highres = true;
}
applied = want;
