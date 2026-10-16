function mpfTokenize(t, ctx, lineOffset = 0)
{
    var _n = string_length(t);
    var _i = 1;
    var _line = 1 + lineOffset;
    var _tokens = [];
    var _digits = "0123456789";
    var _identStart = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
    var _identChars = "_abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    var _keywords = ["var", "if", "else", "while", "for", "break", "continue", "true", "false"];
    var _twoOps = ["==", "!=", "<=", ">=", "&&", "||", "+=", "-=", "*=", "/=", "%=", "\\="];
    var _oneOps = "+-*/%\\=<>!(){}[],;";
    while (_i <= _n)
    {
        var _c = string_char_at(t, _i);
        if (_c == "\n") { _line++; _i++; continue; }
        if (_c == " " || _c == "\t" || _c == "\r") { _i++; continue; }
        if (_c == "/" && string_char_at(t, _i + 1) == "/")
        {
            while (_i <= _n && string_char_at(t, _i) != "\n") _i++;
            continue;
        }
        var _startLine = _line;
        if (string_pos(_c, _digits) > 0 || (_c == "." && string_pos(string_char_at(t, _i + 1), _digits) > 0))
        {
            var _j = _i;
            var _seenDot = false;
            while (_j <= _n)
            {
                var _d = string_char_at(t, _j);
                if (_d == "." && !_seenDot) { _seenDot = true; _j++; continue; }
                if (string_pos(_d, _digits) > 0) { _j++; continue; }
                break;
            }
            array_push(_tokens, { k: "num", v: real(string_copy(t, _i, _j - _i)), line: _startLine });
            _i = _j;
            continue;
        }
        if (_c == "\"")
        {
            var _j = _i + 1;
            var _s = "";
            var _closed = false;
            while (_j <= _n)
            {
                var _d = string_char_at(t, _j);
                if (_d == "\n") break;
                if (_d == "\\")
                {
                    var _e = string_char_at(t, _j + 1);
                    switch (_e)
                    {
                        case "n": _s += chr(10); break;
                        case "t": _s += chr(9); break;
                        case "r": _s += chr(13); break;
                        case "\"": _s += "\""; break;
                        case "\\": _s += "\\"; break;
                        default: _s += _e; break;
                    }
                    _j += 2;
                    continue;
                }
                if (_d == "\"") { _closed = true; _j++; break; }
                _s += _d;
                _j++;
            }
            if (!_closed)
            {
                mpfPushError("SyntaxError", "unterminated string literal", _startLine, "parse", ctx.diff, ctx.name);
                return undefined;
            }
            array_push(_tokens, { k: "str", v: _s, line: _startLine });
            _i = _j;
            continue;
        }
        if (string_pos(_c, _identStart) > 0)
        {
            var _j = _i;
            while (_j <= _n && string_pos(string_char_at(t, _j), _identChars) > 0) _j++;
            var _word = string_copy(t, _i, _j - _i);
            if (array_contains(_keywords, _word)) array_push(_tokens, { k: "kw", v: _word, line: _startLine });
            else array_push(_tokens, { k: "id", v: _word, line: _startLine });
            _i = _j;
            continue;
        }
        var _two = string_copy(t, _i, 2);
        if (array_contains(_twoOps, _two))
        {
            array_push(_tokens, { k: "op", v: _two, line: _startLine });
            _i += 2;
            continue;
        }
        if (string_pos(_c, _oneOps) > 0)
        {
            array_push(_tokens, { k: "op", v: _c, line: _startLine });
            _i++;
            continue;
        }
        mpfPushError("SyntaxError", "unexpected character '" + _c + "'", _startLine, "parse", ctx.diff, ctx.name);
        return undefined;
    }
    array_push(_tokens, { k: "eof", v: "", line: _line });
    return _tokens;
}

function mpfSplitLines(t)
{
    var _raw = string_split(t, "\n");
    var _out = [];
    for (var _i = 0; _i < array_length(_raw); _i++)
        array_push(_out, string_replace_all(_raw[_i], chr(13), ""));
    return _out;
}
