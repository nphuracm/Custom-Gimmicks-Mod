function get_chart_path_from_chartid(chart)
{
    if (is_struct(chart))
        return struct_get_fallback(chart, "chart_path", "Charts/" + string(struct_get_fallback(chart, "chart_id", "")) + "/");
    
    for (var i = 0; i < array_length(global.song_list); i++)
    {
        if (global.song_list[i].chart_id == chart)
            return struct_get_fallback(global.song_list[i], "chart_path", "Charts/" + chart + "/");
    }
    
    for (var i = 0; i < array_length(global.shatter_list); i++)
    {
        if (global.shatter_list[i].chart_id == chart)
            return struct_get_fallback(global.shatter_list[i], "chart_path", "Charts/" + chart + "/");
    }
    
    return "";
}

function is_custom_chart(chart)
{
    if (is_struct(chart))
        return struct_get_fallback(chart, "is_custom", false);
    
    for (var i = 0; i < array_length(global.song_list); i++)
    {
        if (global.song_list[i].chart_id == chart)
            return struct_get_fallback(global.song_list[i], "is_custom", false);
    }
    
    for (var i = 0; i < array_length(global.shatter_list); i++)
    {
        if (global.shatter_list[i].chart_id == chart)
            return struct_get_fallback(global.shatter_list[i], "is_custom", false);
    }
    
    return false;
}

