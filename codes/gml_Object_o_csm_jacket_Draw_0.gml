if (cgm_legacy200_background_enabled()) exit;
gpu_set_blendmode_ext(bm_dest_color, bm_zero);
draw_sprite_stretched_ext(jacket, 0, 0, 0, 320, 180, jacketBlend, jacketAlpha)
gpu_set_blendmode(bm_normal);
