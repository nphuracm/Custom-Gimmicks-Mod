draw_set_font(fnt_phosphor);

var pad = padding;
var bw = border_width;
var text_h = string_height_ext(content, line_sep, text_max_width);
var box_w = width + pad * 2;
var box_h = text_h + pad * 2;
var x2 = x + box_w;
var y2 = y + box_h;

draw_set_color(col_convert(bg_color));
draw_rectangle(x, y, x2, y2, false);

if (bw > 0)
{
    draw_set_color(col_convert(border_color));
    draw_rectangle(x, y, x2, y + bw, false);
    draw_rectangle(x, y2 - bw, x2, y2, false);
    draw_rectangle(x, y, x + bw, y2, false);
    draw_rectangle(x2 - bw, y, x2, y2, false);
}

draw_set_color(col_convert(text_color));
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_text_ext(x + pad, y + pad, content, line_sep, text_max_width);
