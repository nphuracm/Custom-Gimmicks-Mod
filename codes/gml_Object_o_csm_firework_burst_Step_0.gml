if (!instance_exists(cc))
{
    instance_destroy();
    exit;
}

if (cc.currentms >= retire_ms) instance_destroy();
