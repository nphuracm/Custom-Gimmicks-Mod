ps = -1;
ps_live = false;
birth_ms = cc.currentms;
retire_ms = birth_ms + 2000;
burst_col = (variable_instance_exists(self, "burst_col") && !is_undefined(burst_col)) ? burst_col : 16777215;
samples = [];

for (var i = 0; i < 30; i++)
    array_push(samples, [random(360), random_range(2.8, 4.8), irandom(3)]);

rebuild = function()
{
    if (ps_live) particle_system_destroy(ps);
    ps = particle_system_create(5);
    ps_live = true;
    for (var i = 0; i < array_length(samples); i++)
    {
        var s = samples[i];
        particle_system_add_particle(ps, x, y, 0, 0, s[0], s[1], 1, 1, 0, s[2], c_white);
    }
    simulated_ms = max(birth_ms, cc.currentms);
    var age = (simulated_ms - birth_ms) / 1000;
    if (age > 0) particle_system_add_alpha(ps, age);
};

sync = function()
{
    var now = max(birth_ms, cc.currentms);
    if (now < simulated_ms) rebuild();
    else if (now > simulated_ms)
    {
        particle_system_add_alpha(ps, (now - simulated_ms) / 1000);
        simulated_ms = now;
    }
};

rebuild();
