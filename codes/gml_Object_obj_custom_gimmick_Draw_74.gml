if(proxyCount<=0){
    if (aftsprite != undefined && sprite_exists(aftsprite))
    {
        sprite_delete(aftsprite);
        aftsprite = undefined;
    }
    shader_set(shader_custom_main);
    shader_set_uniform_f(uTime, cc.currentms / 1000);
    shader_set_uniform_f(uGrayAmp, cc.mod_gray);
    shader_set_uniform_f(uBarrelAmp, cc.mod_barrel + cc.mod_barrel2);
    shader_set_uniform_f(uHDistortAmp, cc.mod_hdistort);
    shader_set_uniform_f(uVDistortAmp, cc.mod_vdistort);
    shader_set_uniform_f(uFishAmp, cc.mod_fish);
    shader_set_uniform_f(uVigAmp, cc.mod_vig);
    shader_set_uniform_f(bloom, cc.mod_bloom);
    shader_set_uniform_f(uAbX, cc.mod_abx);
    shader_set_uniform_f(uAbY, cc.mod_aby);
    shader_set_uniform_f(uAbberationX, cc.mod_barrelabx);
    shader_set_uniform_f(uAbberationY, cc.mod_barrelaby);
    shader_set_uniform_f(uSTime, cc.mod_glitchoffset);
    shader_set_uniform_f(uGlitchAmp, cc.mod_glitchamp);
    shader_set_uniform_f(uHNoise, cc.mod_uhnoise);
    for (var i = 1; i < 5; i++)
    {
        var twx = variable_instance_get(cc, string("mod_twx{0}", i));
        var twy = variable_instance_get(cc, string("mod_twy{0}", i));
        var twa = variable_instance_get(cc, string("mod_twa{0}", i));
        var twr = variable_instance_get(cc, string("mod_twr{0}", i));
        shader_set_uniform_f(variable_instance_get(cc,string("uTwist{0}",i)), twx, twy, twa * 0.6, twr);
    }
    shader_set_uniform_f(uSinm, cc.mod_sina,cc.mod_sinp,cc.mod_sino);
    shader_set_uniform_f(uCosm, cc.mod_cosa,cc.mod_sinp,cc.mod_coso);
    shader_set_uniform_f(uTanm, cc.mod_tana,cc.mod_tanp,cc.mod_tano);
    shader_set_uniform_f(uMove, cc.mod_posx,cc.mod_posy);
    texture_set_stage(uNoiseSampler, noisetex);
    draw_surface_stretched(application_surface, 0, 0, 320, 180);
    shader_reset();
}
else{
    var beat = cc.currentbeataccurate;
    draw_set_alpha(1);
    draw_clear_alpha(c_black, 1);

    if (!surface_exists(aft))
        aft = surface_create(320, 180);

    var pixelate = shouldPixelate;

    if (pixelate && !surface_exists(pixelated_topscreen))
        pixelated_topscreen = surface_create(320, 180);

    var _alp = 1 - cc.mod_hom;
    surface_target(aft);
    draw_rectangle_colour(0, 0, display_get_gui_width(), display_get_gui_height(), c_black, c_black, c_black, c_black, 0);
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_surface_stretched(application_surface, 0, 0, 320, 180);
    surface_untarget();
    draw_set_alpha(_alp);

    if (pixelate && surface_exists(pixelated_topscreen))
        surface_target(pixelated_topscreen);

    draw_rectangle_colour(0, 0, display_get_gui_width(), display_get_gui_height(), c_black, c_black, c_black, c_black, 0);
    draw_surface_general(aft, 0, 0, 81, 180, 0, 0, 1, 1, 0, 16777215, 16777215, 16777215, 16777215, _alp);
    draw_surface_general(aft, 239, 0, 81, 180, 239, 0, 1, 1, 0, 16777215, 16777215, 16777215, 16777215, _alp);
    draw_surface_general(aft, 81, 165, 158, 15, 81, 165, 1, 1, 0, 16777215, 16777215, 16777215, 16777215, _alp);


    draw_set_alpha(1 - cc.mod_uialpha);
    draw_rectangle_colour(0, 165, display_get_gui_width(), display_get_gui_height(), c_black, c_black, c_black, c_black, 0);

    draw_set_alpha(1);
    var i = proxyCount;

    while (i-- > 0)
    {
        with (proxies[i])
        {
            var _xsc = przm * przmb * przmc * przx * cos(degtorad(prrx));
            var _ysc = przm * przmb * przmc * przy * cos(degtorad(prry));
            var _ang = prrz + prrzb;
            var _x = 160 + prx + prxb + prxc + prxd;
            var _y = 82 + pry + pryb + pryc + pryd;
            var _alpha = pra;
            var _skewx = prsx;
            var _skewy = prsy;
            var _prtrX = prtrX;
            var _prtrY = prtrY;
            var _prtrD = prtrD;
            var top = 0;
            var bottom = 165;
            var left = 113 - shxa;
            var right = left + 95 + (2 * shxa);
            var oleft = 113 - shxa;
            
            if (prct != 0.08 || prcb != 0)
            {
                top = (180 * prcb) - 1;
                bottom = 180 - ceil(180 * prct);
            }
            
            if (prcl != 0.35 || prcr != 0.35)
            {
                left = prcl;
                right = prcr;
            }
            
            var _wreal = right - left;
            var _hreal = bottom - top;
            var rotdir = 1;
            
            if (variable_instance_exists(cc, "mod_rotdir"))
                rotdir = cc.mod_rotdir;
            
            var MSkew = MatrixSkew(-_skewx, -_skewy);
            var MTrans = MatrixTranslate(_x, _y);
            var MScale = MatrixScale(_xsc, _ysc);
            var MRot = MatrixRotateZ(_ang * rotdir);
            //角度制分支：物距先写死 320px（按"缩放后/屏幕px"计，越大透视越弱），之后要调再改成设置项/gmk
            var MTrape=cc.NEW_PRTRX_CALCULATION?MatrixTrapezoidalNew(_prtrX,_prtrY,_prtrD):MatrixTrapezoidal(_prtrX,_prtrY);
            var M = other.i_matrix;
            M = matrix_multiply(M, other.MToOrigin);
            M = matrix_multiply(M, MScale);
            M = matrix_multiply(M, MRot);
            M = matrix_multiply(M,MTrape);
            M = matrix_multiply(M, MSkew);
            M = matrix_multiply(M, MTrans);
            M = matrix_multiply(M, other.MFromOrigin);
            matrix_set(2, M);
            
            if (_alpha > 0.001 && abs(_xsc) > 0.001 && abs(_ysc) > 0.001)
            {
                shader_set(shader_00_sine);
                shader_set_uniform_f(other.uTime, cc.currentbeataccurate);
                var tex = surface_get_texture(other.aft);
                shader_set_uniform_f(other.uTexel, texture_get_texel_width(tex), texture_get_texel_height(tex));
                shader_set_uniform_f(other.uXSpd, shxs);
                shader_set_uniform_f(other.uXPer, shxp);
                shader_set_uniform_f(other.uXAmp, shxa);
                shader_set_uniform_f(other.uYSpd, shys);
                shader_set_uniform_f(other.uYPer, shyp);
                shader_set_uniform_f(other.uYAmp, shya);
                shader_set_uniform_f(other.uCt, shct);
                shader_set_uniform_f(other.uFt, shft);
                shader_set_uniform_f(other.uCb, shcb);
                shader_set_uniform_f(other.uFb, shfb);
                shader_set_uniform_f(other.uCl, shcl);
                shader_set_uniform_f(other.uFl, shfl);
                shader_set_uniform_f(other.uCr, shcr);
                shader_set_uniform_f(other.uFr, shfr);
                draw_surface_general(other.aft, left, top, _wreal, _hreal, left - oleft, top, 1, 1, 0, 16777215, 16777215, 16777215, 16777215, _alpha);
                shader_reset();
            }
            
            matrix_set(2, other.i_matrix);
        }
    }

    var hom = cc.mod_hom != 0;

    if (hom && surface_exists(pixelated_topscreen))
    {
        aftsprite = sprite_create_from_surface(pixelated_topscreen, 0, 0, 320, 180, false, false, 160, 90);
        var _xsc = 1.03;
        var _ysc = 1.03;
        var _ang = 2 * sin((beat * pi) / 16);
        var _x = 160;
        var _y = 90;
        var _alpha = cc.mod_hom * 0.96;
        draw_sprite_ext(aftsprite, 0, _x, _y, _xsc, _ysc, _ang, c_white, _alpha);
    }


    if (pixelate)
        surface_untarget();

    if (pixelate)
    {
        draw_rectangle_colour(0, 0, display_get_gui_width(), display_get_gui_height(), c_black, c_black, c_black, c_black, 0);
        
        if (main_shader != -1)
            main_shader();
        
        draw_surface_ext(pixelated_topscreen, 0, 0, 1, 1, 0, c_white, 1);
        
        if (main_shader != -1)
            shader_reset();
    }
}
