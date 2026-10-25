global.mpfErrors = [];
global.mpfErrorPushes = 0;
global.mpfMsgQueue = [];
global.mpfMsgMax = 4;
global.mpfRegistry = {};
global.mpfRegistryKey = "";

function mpfPushError(_type, _msg, _line, _phase, _diff, _name)
{
    global.mpfErrorPushes++;
    array_push(global.mpfErrors, { type: _type, msg: _msg, line: _line, phase: _phase, diff: _diff, name: _name });
}

function mpfGetErrors()
{
    var _out = global.mpfErrors;
    global.mpfErrors = [];
    return _out;
}

function mpfHasError()
{
    return array_length(global.mpfErrors) > 0;
}

function mpfClearErrors()
{
    global.mpfErrors = [];
}

function mpfRaise(_type, _msg)
{
    throw { __mpf_error: true, type: _type, msg: _msg };
}

function mpfReadText(_path)
{
    if (!file_exists(_path)) return undefined;
    var _fp = file_text_open_read(_path);
    var _out = "";
    while (!file_text_eof(_fp))
    {
        var _line = file_text_readln(_fp);
        _out += _line;
        var _last = string_char_at(_line, string_length(_line));
        if (_last != "\n" && _last != "\r") _out += "\n";
    }
    file_text_close(_fp);
    return _out;
}

function mpfNormalizeDir(_dir)
{
    if (!is_string(_dir) || _dir == "") return "";
    if (string_char_at(_dir, string_length(_dir)) == "/" || string_char_at(_dir, string_length(_dir)) == "\\") return _dir;
    return _dir + "/";
}

function mpfCurrentChartPath()
{
    if (!variable_global_exists("ch_load")) return "";
    var _p = get_chart_path_from_chartid(global.ch_load);
    if (!is_string(_p)) return "";
    return mpfNormalizeDir(_p);
}

function mpfSplitScriptFileName(_fname)
{
    var _suffix = ".vsmpf";
    var _len = string_length(_fname);
    if (_len <= string_length(_suffix)) return undefined;
    if (string_lower(string_copy(_fname, _len - string_length(_suffix) + 1, string_length(_suffix))) != _suffix) return undefined;
    var _base = string_copy(_fname, 1, _len - string_length(_suffix));
    var _dot = string_pos(".", _base);
    if (_dot <= 1 || _dot >= string_length(_base)) return undefined;
    return {
        diff: string_copy(_base, 1, _dot - 1),
        name: string_copy(_base, _dot + 1, string_length(_base) - _dot)
    };
}

function mpfScanScriptFiles(_chartPath)
{
    var _dir = mpfNormalizeDir(_chartPath);
    if (_dir == "") return [];
    _dir += "cmpf/";
    var _out = [];
    var _f = file_find_first(_dir + "*.vsmpf", 16);
    while (is_string(_f) && _f != "")
    {
        var _split = mpfSplitScriptFileName(_f);
        if (_split != undefined)
        {
            _split.path = _dir + _f;
            array_push(_out, _split);
        }
        _f = file_find_next();
    }
    file_find_close();
    return _out;
}

function mpfFindScriptFile(_chartPath, _diff, _name)
{
    var _files = mpfScanScriptFiles(_chartPath);
    var _globalHit = undefined;
    for (var _i = 0; _i < array_length(_files); _i++)
    {
        var _f = _files[_i];
        if (string_lower(_f.name) != string_lower(string(_name))) continue;
        if (string_upper(_f.diff) == "GLOBAL")
        {
            if (_globalHit == undefined) _globalHit = _f.path;
            continue;
        }
        if (string_upper(_f.diff) == string_upper(string(_diff))) return _f.path;
    }
    return _globalHit;
}

function mpfMetaEntriesOfFile(_path)
{
    var _text = mpfReadText(_path);
    if (_text == undefined) return undefined;
    var _lines = mpfSplitLines(_text);
    var _entries = [];
    for (var _i = 0; _i < array_length(_lines); _i++)
    {
        var _l = string_trim(_lines[_i]);
        if (_l == "::Init::" || _l == "::Main::" || _l == "::Finish::" || _l == "::MetaData::") break;
        if (string_char_at(_l, 1) != "#") continue;
        array_push(_entries, { n: _i + 1, t: _l });
    }
    return _entries;
}

function mpfGetMeta(_diff, _name)
{
    var _path = mpfFindScriptFile(mpfCurrentChartPath(), _diff, _name);
    if (_path == undefined) return undefined;
    var _entries = mpfMetaEntriesOfFile(_path);
    if (_entries == undefined) return undefined;
    var _meta = mpfMetaReadEntries(_entries, { diff: _diff, name: _name }, false);
    if (_meta == undefined) return undefined;
    _meta.exists = true;
    _meta.path = _path;
    _meta.diff = _diff;
    _meta.name = _name;
    return _meta;
}

function mpfListScripts(_diff)
{
    var _files = mpfScanScriptFiles(mpfCurrentChartPath());
    var _want = string_upper(string(_diff));
    var _names = [];
    for (var _i = 0; _i < array_length(_files); _i++)
    {
        var _f = _files[_i];
        if (string_upper(_f.diff) != "GLOBAL" && string_upper(_f.diff) != _want) continue;
        if (!array_contains(_names, _f.name)) array_push(_names, _f.name);
    }
    return _names;
}

// _difficulty 传难度名（ENCORE 之类）；传成曲目 id 也能跑（会把当前难度一并接受）
function mpfRegisterAll(_difficulty, _chartPath)
{
    var _path = mpfNormalizeDir(_chartPath);
    if (_path == "") return global.mpfRegistry;
    var _currentDiff = variable_global_exists("df_load") ? global.df_load : "";
    var _runId = instance_exists(cc) ? cc.id : -1;
    var _key = _path + "|" + string(_currentDiff) + "|" + string(_runId);
    if (global.mpfRegistryKey == _key) return global.mpfRegistry;
    global.mpfRegistryKey = _key;
    global.mpfRegistry = {};
    var _files = mpfScanScriptFiles(_path);
    var _want = string_upper(string(_difficulty));
    var _wantAlt = string_upper(string(_currentDiff));
    for (var _pass = 0; _pass < 2; _pass++)
    {
        for (var _i = 0; _i < array_length(_files); _i++)
        {
            var _f = _files[_i];
            var _isGlobal = (string_upper(_f.diff) == "GLOBAL");
            if (_pass == 0 && !_isGlobal) continue;
            if (_pass == 1 && (_isGlobal || (string_upper(_f.diff) != _want && string_upper(_f.diff) != _wantAlt))) continue;
            var _entries = mpfMetaEntriesOfFile(_f.path);
            if (_entries == undefined) continue;
            var _meta = mpfMetaReadEntries(_entries, { diff: _f.diff, name: _f.name }, false);
            if (_meta == undefined) continue;
            _meta.exists = true;
            _meta.path = _f.path;
            _meta.diff = _f.diff;
            _meta.name = _f.name;
            var _env = mpfMakeEnv(_f.diff, _f.name, _f.path, _meta);
            variable_struct_set(global.mpfRegistry, _f.name, method(_env, mpfRunner));
        }
    }
    return global.mpfRegistry;
}

function mpfDebugState(_diff, _name)
{
    var _out = {
        diff: _diff,
        name: _name,
        chart: mpfCurrentChartPath(),
        exists: false,
        path: "",
        lines: 0,
        parsed: false,
        has_init: false,
        has_main: false,
        has_finish: false,
        init_ops: 0,
        main_ops: 0,
        finish_ops: 0,
        var_names: [],
        registered: false,
        loaded: false,
        inited: false,
        dead: false,
        resets: 0,
        init_runs: 0,
        main_runs: 0,
        finish_runs: 0,
        last_beat: -1,
        vars_len: -1,
        vars: [],
        alias_works: false
    };
    var _path = mpfFindScriptFile(mpfCurrentChartPath(), _diff, _name);
    if (_path == undefined) return _out;
    _out.exists = true;
    _out.path = _path;
    var _text = mpfReadText(_path);
    if (_text == undefined) return _out;
    _out.lines = array_length(mpfSplitLines(_text));
    var _res = mpfParser(_text, { diff: _diff, name: _name });
    if (_res != undefined)
    {
        _out.parsed = true;
        _out.has_init = (_res.init != undefined);
        _out.has_main = (_res.main != undefined);
        _out.has_finish = (_res.finish != undefined);
        if (_out.has_init) _out.init_ops = array_length(_res.init.ops);
        if (_out.has_main) _out.main_ops = array_length(_res.main.ops);
        if (_out.has_finish) _out.finish_ops = array_length(_res.finish.ops);
        _out.var_names = _res.vars;
    }
    if (variable_struct_exists(global.mpfRegistry, _name))
    {
        var _closure = variable_struct_get(global.mpfRegistry, _name);
        var _env = is_method(_closure) ? method_get_self(_closure) : undefined;
        if (is_struct(_env) && variable_struct_exists(_env, "__mpf"))
        {
            _out.registered = true;
            _out.loaded = _env.loaded;
            _out.inited = _env.inited;
            _out.dead = _env.dead;
            _out.resets = _env.resets;
            _out.init_runs = _env.init_runs;
            _out.main_runs = _env.main_runs;
            _out.finish_runs = _env.finish_runs;
            _out.last_beat = _env.last_beat;
            _out.last_seen = _env.last_seen;
            _out.errors_total = _env.errors_total;
            _out.last_err_type = _env.last_err_type;
            _out.last_err_msg = _env.last_err_msg;
            _out.last_err_line = _env.last_err_line;
            _out.last_err_phase = _env.last_err_phase;
            _out.vars_len = array_length(_env.variables);
            _out.vars = _env.variables;
        }
    }
    var _probeArr = [0, 0, 0, 0];
    var _probeHolder = { arr: _probeArr };
    var _probeAlias = _probeHolder.arr;
    _probeAlias[3] = 7;
    _out.alias_works = (_probeHolder.arr[3] == 7);
    return _out;
}

function mpfLookupClosure(_name)
{
    var _diff = variable_global_exists("df_load") ? global.df_load : "";
    var _table = mpfRegisterAll(_diff, mpfCurrentChartPath());
    if (_table == undefined) return undefined;
    if (!variable_struct_exists(_table, _name)) return undefined;
    return variable_struct_get(_table, _name);
}
