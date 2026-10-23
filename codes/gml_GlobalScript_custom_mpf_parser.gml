#macro MPF_OP_PUSH_K 0
#macro MPF_OP_PUSH_V 1
#macro MPF_OP_PUSH_IDX 2
#macro MPF_OP_POP 3
#macro MPF_OP_STORE_V 4
#macro MPF_OP_SET_IDX 5
#macro MPF_OP_DUP2 6
#macro MPF_OP_ARR_NEW 7
#macro MPF_OP_ADD 8
#macro MPF_OP_SUB 9
#macro MPF_OP_MUL 10
#macro MPF_OP_DIV 11
#macro MPF_OP_IDIV 12
#macro MPF_OP_MOD 13
#macro MPF_OP_NEG 14
#macro MPF_OP_NOT 15
#macro MPF_OP_EQ 16
#macro MPF_OP_NEQ 17
#macro MPF_OP_LT 18
#macro MPF_OP_LE 19
#macro MPF_OP_GT 20
#macro MPF_OP_GE 21
#macro MPF_OP_CALL 22
#macro MPF_OP_JMP 23
#macro MPF_OP_JMPZ 24
#macro MPF_OP_JMPZ_PEEK 25
#macro MPF_OP_JMPNZ_PEEK 26
#macro MPF_OP_LOOP_TICK 27
#macro MPF_OP_LOOP_ENTER 28
#macro MPF_OP_LOOP_EXIT 29
#macro MPF_OP_HALT 30

#macro MPF_STACK_INIT 64
#macro MPF_BUILTIN_VARS 4

function mpfMetaDefaults()
{
    return { risk_level: "SAFE", max_loop_times: 65536, refresh_on_each_run: true };
}

function mpfRiskIsValid(_s)
{
    return array_contains(["SAFE", "RISK", "HIGH_RISK", "CRITICAL_RISK"], string_upper(_s));
}

function mpfIsPositiveInt(_s)
{
    if (string_length(_s) == 0) return false;
    for (var _i = 1; _i <= string_length(_s); _i++)
    {
        if (string_pos(string_char_at(_s, _i), "0123456789") == 0) return false;
    }
    return real(_s) > 0;
}

function mpfMetaReadEntries(_entries, ctx, _strict)
{
    var _meta = mpfMetaDefaults();
    for (var _i = 0; _i < array_length(_entries); _i++)
    {
        var _e = _entries[_i];
        var _body = string_trim(string_copy(_e.t, 2, string_length(_e.t) - 1));
        var _eq = string_pos("=", _body);
        if (_eq <= 1 || _eq >= string_length(_body))
        {
            if (_strict)
            {
                mpfPushError("SyntaxError", "malformed attribute", _e.n, "meta", ctx.diff, ctx.name);
                return undefined;
            }
        }
        else
        {
            var _key = string_upper(string_trim(string_copy(_body, 1, _eq - 1)));
            var _val = string_trim(string_copy(_body, _eq + 1, string_length(_body) - _eq));
            if (_key == "RISK_LEVEL")
            {
                if (mpfRiskIsValid(_val)) _meta.risk_level = string_upper(_val);
                else if (_strict)
                {
                    mpfPushError("ValueError", "invalid RISK_LEVEL '" + _val + "'", _e.n, "meta", ctx.diff, ctx.name);
                    return undefined;
                }
            }
            else if (_key == "MAX_LOOP_TIMES")
            {
                if (mpfIsPositiveInt(_val)) _meta.max_loop_times = real(_val);
                else if (_strict)
                {
                    mpfPushError("ValueError", "invalid MAX_LOOP_TIMES '" + _val + "'", _e.n, "meta", ctx.diff, ctx.name);
                    return undefined;
                }
            }
            else if (_key == "REFRESH_ON_EACH_RUN")
            {
                var _lower = string_lower(_val);
                if (_lower == "true") _meta.refresh_on_each_run = true;
                else if (_lower == "false") _meta.refresh_on_each_run = false;
                else if (_strict)
                {
                    mpfPushError("ValueError", "invalid REFRESH_ON_EACH_RUN '" + _val + "'", _e.n, "meta", ctx.diff, ctx.name);
                    return undefined;
                }
            }
        }
    }
    return _meta;
}

function mpfJoinLines(_lines)
{
    var _s = "";
    for (var _i = 0; _i < array_length(_lines); _i++)
    {
        if (_i > 0) _s += "\n";
        _s += _lines[_i];
    }
    return _s;
}

function mpfNewParserState(_toks, _ctx, _risk, _block)
{
    var _P = {
        toks: _toks,
        i: 0,
        ctx: _ctx,
        risk: _risk,
        block: _block,
        ops: [],
        consts: [],
        fns: [],
        fnIdx: {},
        vars: [],
        varIdx: {},
        loops: [],
        err: false
    };
    mpfDeclareVar(_P, "beat");
    mpfDeclareVar(_P, "beatStart");
    mpfDeclareVar(_P, "beatEnd");
    mpfDeclareVar(_P, "pi");
    return _P;
}

function mpfTok(_P) { return _P.toks[_P.i]; }
function mpfAdv(_P) { var _t = _P.toks[_P.i]; _P.i++; return _t; }
function mpfIsOp(_P, _v) { var _t = _P.toks[_P.i]; return (_t.k == "op" && _t.v == _v); }
function mpfIsKw(_P, _v) { var _t = _P.toks[_P.i]; return (_t.k == "kw" && _t.v == _v); }
function mpfAccept(_P, _v) { if (mpfIsOp(_P, _v)) { _P.i++; return true; } return false; }

function mpfFail(_P, _type, _msg, _line)
{
    mpfPushError(_type, _msg, _line, "parse", _P.ctx.diff, _P.ctx.name);
    _P.err = true;
    return undefined;
}

function mpfErrHere(_P, _type, _msg)
{
    return mpfFail(_P, _type, _msg, _P.toks[_P.i].line);
}

function mpfEmit(_P, _ins)
{
    array_push(_P.ops, _ins);
    return array_length(_P.ops) - 1;
}

function mpfPatch(_P, _idx, _target)
{
    _P.ops[_idx].a = _target;
}

function mpfAddConst(_P, _v)
{
    array_push(_P.consts, _v);
    return array_length(_P.consts) - 1;
}

function mpfDeclareVar(_P, _name, _line = 0)
{
    if (struct_exists(_P.varIdx, _name))
    {
        mpfFail(_P, "SyntaxError", "variable '" + _name + "' is already declared", _line);
        return false;
    }
    array_push(_P.vars, _name);
    variable_struct_set(_P.varIdx, _name, array_length(_P.vars) - 1);
    return true;
}

function mpfVarSlot(_P, _name, _line)
{
    if (!struct_exists(_P.varIdx, _name))
    {
        mpfFail(_P, "NameError", "undefined variable '" + _name + "' (declare it with var)", _line);
        return 0;
    }
    return variable_struct_get(_P.varIdx, _name);
}

function mpfIsAssignOp(_v)
{
    return array_contains(["=", "+=", "-=", "*=", "/=", "%=", "\\="], _v);
}

function mpfCompoundOp(_v)
{
    if (_v == "+=") return MPF_OP_ADD;
    if (_v == "-=") return MPF_OP_SUB;
    if (_v == "*=") return MPF_OP_MUL;
    if (_v == "/=") return MPF_OP_DIV;
    if (_v == "\\=") return MPF_OP_IDIV;
    if (_v == "%=") return MPF_OP_MOD;
    return -1;
}

function mpfAssignOpAhead(_P)
{
    var _depth = 0;
    var _j = _P.i;
    var _n = array_length(_P.toks);
    while (_j < _n)
    {
        var _t = _P.toks[_j];
        if (_t.k == "eof") return undefined;
        if (_t.k == "op")
        {
            if (_t.v == "[" || _t.v == "(") _depth++;
            else if (_t.v == "]" || _t.v == ")") _depth--;
            else if (_depth == 0)
            {
                if (mpfIsAssignOp(_t.v)) return _t.v;
                if (_t.v == ";" || _t.v == ",") return undefined;
            }
        }
        _j++;
    }
    return undefined;
}

function mpfFnIndex(_P, _entry, _name)
{
    if (!struct_exists(_P.fnIdx, _name))
    {
        var _f = struct_get(_entry, "f");
        array_push(_P.fns, { name: _name, m: is_method(_f) ? _f : method(undefined, _f) });
        variable_struct_set(_P.fnIdx, _name, array_length(_P.fns) - 1);
    }
    return variable_struct_get(_P.fnIdx, _name);
}

function mpfParseCall(_P, _nameTok)
{
    var _name = _nameTok.v;
    var _whitelist = global.mpfAllowedInternalFuncs;
    if (!variable_struct_exists(_whitelist, _name))
    {
        mpfFail(_P, "NameError", "unknown function '" + _name + "'", _nameTok.line);
        return;
    }
    var _entry = variable_struct_get(_whitelist, _name);
    var _fnRisk = struct_get(_entry, "rl");
    if (_fnRisk > _P.risk)
    {
        mpfFail(_P, "PermissionError", "function '" + _name + "' needs a higher RISK_LEVEL", _nameTok.line);
        return;
    }
    if (_P.block != "init" && mpfScopeInitOnly(struct_get(_entry, "scope")))
    {
        mpfFail(_P, "PermissionError", "function '" + _name + "' can only be used in the ::Init:: block", _nameTok.line);
        return;
    }
    var _fi = mpfFnIndex(_P, _entry, _name);
    _P.i++;
    var _argc = 0;
    if (!mpfIsOp(_P, ")"))
    {
        while (true)
        {
            mpfParseExpr(_P);
            if (_P.err) return;
            _argc++;
            if (!mpfAccept(_P, ",")) break;
        }
    }
    if (!mpfAccept(_P, ")"))
    {
        mpfErrHere(_P, "SyntaxError", "expected ')'");
        return;
    }
    mpfEmit(_P, { op: MPF_OP_CALL, a: _fi, b: _argc, line: _nameTok.line });
}

function mpfParsePrimary(_P)
{
    var _t = mpfTok(_P);
    if (_t.k == "num" || _t.k == "str")
    {
        _P.i++;
        mpfEmit(_P, { op: MPF_OP_PUSH_K, a: mpfAddConst(_P, _t.v), line: _t.line });
        return;
    }
    if (_t.k == "kw" && (_t.v == "true" || _t.v == "false"))
    {
        _P.i++;
        mpfEmit(_P, { op: MPF_OP_PUSH_K, a: mpfAddConst(_P, (_t.v == "true") ? 1 : 0), line: _t.line });
        return;
    }
    if (_t.k == "op" && _t.v == "(")
    {
        _P.i++;
        mpfParseExpr(_P);
        if (_P.err) return;
        if (!mpfAccept(_P, ")")) mpfErrHere(_P, "SyntaxError", "expected ')'");
        return;
    }
    if (_t.k == "op" && _t.v == "[")
    {
        _P.i++;
        var _count = 0;
        if (!mpfIsOp(_P, "]"))
        {
            while (true)
            {
                mpfParseExpr(_P);
                if (_P.err) return;
                _count++;
                if (!mpfAccept(_P, ",")) break;
            }
        }
        if (!mpfAccept(_P, "]"))
        {
            mpfErrHere(_P, "SyntaxError", "expected ']'");
            return;
        }
        mpfEmit(_P, { op: MPF_OP_ARR_NEW, a: _count, line: _t.line });
        return;
    }
    if (_t.k == "id")
    {
        _P.i++;
        if (mpfIsOp(_P, "("))
        {
            mpfParseCall(_P, _t);
            return;
        }
        var _slot = mpfVarSlot(_P, _t.v, _t.line);
        if (_P.err) return;
        mpfEmit(_P, { op: MPF_OP_PUSH_V, a: _slot, line: _t.line });
        return;
    }
    mpfFail(_P, "SyntaxError", "unexpected token '" + string(_t.v) + "'", _t.line);
}

function mpfParsePostfix(_P)
{
    mpfParsePrimary(_P);
    while (!_P.err && mpfIsOp(_P, "["))
    {
        var _t = mpfAdv(_P);
        mpfParseExpr(_P);
        if (_P.err) return;
        if (!mpfAccept(_P, "]"))
        {
            mpfErrHere(_P, "SyntaxError", "expected ']'");
            return;
        }
        mpfEmit(_P, { op: MPF_OP_PUSH_IDX, line: _t.line });
    }
}

function mpfParseUnary(_P)
{
    if (mpfIsOp(_P, "!") || mpfIsOp(_P, "-"))
    {
        var _t = mpfAdv(_P);
        mpfParseUnary(_P);
        if (_P.err) return;
        mpfEmit(_P, { op: (_t.v == "!") ? MPF_OP_NOT : MPF_OP_NEG, line: _t.line });
        return;
    }
    mpfParsePostfix(_P);
}

function mpfParseMul(_P)
{
    mpfParseUnary(_P);
    while (!_P.err && (mpfIsOp(_P, "*") || mpfIsOp(_P, "/") || mpfIsOp(_P, "%") || mpfIsOp(_P, "\\")))
    {
        var _t = mpfAdv(_P);
        mpfParseUnary(_P);
        if (_P.err) return;
        var _op = MPF_OP_MUL;
        if (_t.v == "/") _op = MPF_OP_DIV;
        else if (_t.v == "\\") _op = MPF_OP_IDIV;
        else if (_t.v == "%") _op = MPF_OP_MOD;
        mpfEmit(_P, { op: _op, line: _t.line });
    }
}

function mpfParseAdd(_P)
{
    mpfParseMul(_P);
    while (!_P.err && (mpfIsOp(_P, "+") || mpfIsOp(_P, "-")))
    {
        var _t = mpfAdv(_P);
        mpfParseMul(_P);
        if (_P.err) return;
        mpfEmit(_P, { op: (_t.v == "+") ? MPF_OP_ADD : MPF_OP_SUB, line: _t.line });
    }
}

function mpfParseRel(_P)
{
    mpfParseAdd(_P);
    while (!_P.err && (mpfIsOp(_P, "<") || mpfIsOp(_P, "<=") || mpfIsOp(_P, ">") || mpfIsOp(_P, ">=")))
    {
        var _t = mpfAdv(_P);
        mpfParseAdd(_P);
        if (_P.err) return;
        var _op = MPF_OP_LT;
        if (_t.v == "<=") _op = MPF_OP_LE;
        else if (_t.v == ">") _op = MPF_OP_GT;
        else if (_t.v == ">=") _op = MPF_OP_GE;
        mpfEmit(_P, { op: _op, line: _t.line });
    }
}

function mpfParseEq(_P)
{
    mpfParseRel(_P);
    while (!_P.err && (mpfIsOp(_P, "==") || mpfIsOp(_P, "!=")))
    {
        var _t = mpfAdv(_P);
        mpfParseRel(_P);
        if (_P.err) return;
        mpfEmit(_P, { op: (_t.v == "==") ? MPF_OP_EQ : MPF_OP_NEQ, line: _t.line });
    }
}

function mpfParseAnd(_P)
{
    mpfParseEq(_P);
    var _jumps = [];
    while (!_P.err && mpfIsOp(_P, "&&"))
    {
        _P.i++;
        array_push(_jumps, mpfEmit(_P, { op: MPF_OP_JMPZ_PEEK, a: 0, line: mpfTok(_P).line }));
        mpfParseEq(_P);
    }
    for (var _k = 0; _k < array_length(_jumps); _k++) mpfPatch(_P, _jumps[_k], array_length(_P.ops));
}

function mpfParseOr(_P)
{
    mpfParseAnd(_P);
    var _jumps = [];
    while (!_P.err && mpfIsOp(_P, "||"))
    {
        _P.i++;
        array_push(_jumps, mpfEmit(_P, { op: MPF_OP_JMPNZ_PEEK, a: 0, line: mpfTok(_P).line }));
        mpfParseAnd(_P);
    }
    for (var _k = 0; _k < array_length(_jumps); _k++) mpfPatch(_P, _jumps[_k], array_length(_P.ops));
}

function mpfParseExpr(_P)
{
    mpfParseOr(_P);
}

function mpfParseBlock(_P)
{
    if (!mpfAccept(_P, "{"))
    {
        mpfErrHere(_P, "SyntaxError", "expected '{'");
        return;
    }
    while (!mpfIsOp(_P, "}"))
    {
        if (_P.err) return;
        if (mpfTok(_P).k == "eof")
        {
            mpfErrHere(_P, "SyntaxError", "unexpected end of block, expected '}'");
            return;
        }
        mpfParseStatement(_P);
    }
    _P.i++;
}

function mpfParseBody(_P)
{
    if (mpfIsOp(_P, "{")) mpfParseBlock(_P);
    else mpfParseStatement(_P);
}

function mpfParseVarDecl(_P, _needSemi = true)
{
    var _kw = mpfAdv(_P);
    
    while (true)
    {
        var _t = mpfTok(_P);
        if (_t.k != "id")
        {
            mpfErrHere(_P, "SyntaxError", "expected a variable name");
            return;
        }
        _P.i++;
        if (!mpfDeclareVar(_P, _t.v, _t.line)) return;
        var _slot = variable_struct_get(_P.varIdx, _t.v);
        if (mpfAccept(_P, "="))
        {
            mpfParseExpr(_P);
            if (_P.err) return;
        }
        else
        {
            mpfEmit(_P, { op: MPF_OP_PUSH_K, a: mpfAddConst(_P, 0), line: _t.line });
        }
        mpfEmit(_P, { op: MPF_OP_STORE_V, a: _slot, line: _t.line });
        if (!mpfAccept(_P, ",")) break;
    }
    if (_needSemi && !mpfAccept(_P, ";")) mpfErrHere(_P, "SyntaxError", "expected ';'");
}

function mpfParseAssign(_P, _needSemi = true)
{
    var _t = mpfTok(_P);
    var _opStr = mpfAssignOpAhead(_P);
    _P.i++;
    var _isIndex = false;
    var _slot = 0;
    if (mpfIsOp(_P, "["))
    {
        _isIndex = true;
        _slot = mpfVarSlot(_P, _t.v, _t.line);
        if (_P.err) return;
        mpfEmit(_P, { op: MPF_OP_PUSH_V, a: _slot, line: _t.line });
        _P.i++;
        mpfParseExpr(_P);
        if (_P.err) return;
        if (!mpfAccept(_P, "]"))
        {
            mpfErrHere(_P, "SyntaxError", "expected ']'");
            return;
        }
    }
    else
    {
        _slot = mpfVarSlot(_P, _t.v, _t.line);
        if (_P.err) return;
    }
    var _opTok = mpfAdv(_P);
    var _bin = mpfCompoundOp(_opStr);
    if (_bin != -1)
    {
        if (_isIndex)
        {
            mpfEmit(_P, { op: MPF_OP_DUP2, line: _t.line });
            mpfEmit(_P, { op: MPF_OP_PUSH_IDX, line: _t.line });
        }
        else
        {
            mpfEmit(_P, { op: MPF_OP_PUSH_V, a: _slot, line: _t.line });
        }
    }
    mpfParseExpr(_P);
    if (_P.err) return;
    if (_bin != -1) mpfEmit(_P, { op: _bin, line: _opTok.line });
    if (_isIndex) mpfEmit(_P, { op: MPF_OP_SET_IDX, line: _t.line });
    else mpfEmit(_P, { op: MPF_OP_STORE_V, a: _slot, line: _t.line });
    if (_needSemi && !mpfAccept(_P, ";")) mpfErrHere(_P, "SyntaxError", "expected ';'");
}

function mpfParseSimple(_P, _needSemi)
{
    var _t = mpfTok(_P);
    if (_t.k == "kw" && _t.v == "var")
    {
        mpfParseVarDecl(_P, _needSemi);
        return;
    }
    if (_t.k == "id" && mpfAssignOpAhead(_P) != undefined)
    {
        mpfParseAssign(_P, _needSemi);
        return;
    }
    mpfParseExpr(_P);
    if (_P.err) return;
    mpfEmit(_P, { op: MPF_OP_POP, line: _t.line });
    if (_needSemi && !mpfAccept(_P, ";")) mpfErrHere(_P, "SyntaxError", "expected ';'");
}

function mpfParseIf(_P)
{
    var _kw = mpfAdv(_P);
    if (!mpfAccept(_P, "("))
    {
        mpfErrHere(_P, "SyntaxError", "expected '('");
        return;
    }
    mpfParseExpr(_P);
    if (_P.err) return;
    if (!mpfAccept(_P, ")"))
    {
        mpfErrHere(_P, "SyntaxError", "expected ')'");
        return;
    }
    var _jFalse = mpfEmit(_P, { op: MPF_OP_JMPZ, a: 0, line: _kw.line });
    mpfParseBody(_P);
    if (_P.err) return;
    var _jEnd = [];
    if (mpfIsKw(_P, "else"))
    {
        array_push(_jEnd, mpfEmit(_P, { op: MPF_OP_JMP, a: 0, line: _kw.line }));
        mpfPatch(_P, _jFalse, array_length(_P.ops));
        _P.i++;
        if (mpfIsKw(_P, "if")) mpfParseIf(_P);
        else mpfParseBody(_P);
    }
    else
    {
        mpfPatch(_P, _jFalse, array_length(_P.ops));
    }
    for (var _k = 0; _k < array_length(_jEnd); _k++) mpfPatch(_P, _jEnd[_k], array_length(_P.ops));
}

function mpfParseWhile(_P)
{
    var _kw = mpfAdv(_P);
    mpfEmit(_P, { op: MPF_OP_LOOP_ENTER, a: 0, line: _kw.line });
    var _tick = mpfEmit(_P, { op: MPF_OP_LOOP_TICK, a: 0, line: _kw.line });
    if (!mpfAccept(_P, "("))
    {
        mpfErrHere(_P, "SyntaxError", "expected '('");
        return;
    }
    mpfParseExpr(_P);
    if (_P.err) return;
    if (!mpfAccept(_P, ")"))
    {
        mpfErrHere(_P, "SyntaxError", "expected ')'");
        return;
    }
    var _jEnd = mpfEmit(_P, { op: MPF_OP_JMPZ, a: 0, line: _kw.line });
    array_push(_P.loops, { breaks: [], continues: [], cont: _tick });
    mpfParseBody(_P);
    if (_P.err) return;
    var _loop = array_pop(_P.loops);
    mpfEmit(_P, { op: MPF_OP_JMP, a: _tick, line: _kw.line });
    var _exit = mpfEmit(_P, { op: MPF_OP_LOOP_EXIT, a: 0, line: _kw.line });
    mpfPatch(_P, _jEnd, _exit);
    for (var _k = 0; _k < array_length(_loop.breaks); _k++) mpfPatch(_P, _loop.breaks[_k], _exit);
    for (var _k = 0; _k < array_length(_loop.continues); _k++) mpfPatch(_P, _loop.continues[_k], _loop.cont);
}

function mpfParseFor(_P)
{
    var _kw = mpfAdv(_P);
    if (!mpfAccept(_P, "("))
    {
        mpfErrHere(_P, "SyntaxError", "expected '('");
        return;
    }
    if (!mpfIsOp(_P, ";")) mpfParseSimple(_P, false);
    if (_P.err) return;
    if (!mpfAccept(_P, ";"))
    {
        mpfErrHere(_P, "SyntaxError", "expected ';'");
        return;
    }
    mpfEmit(_P, { op: MPF_OP_LOOP_ENTER, a: 0, line: _kw.line });
    var _tick = mpfEmit(_P, { op: MPF_OP_LOOP_TICK, a: 0, line: _kw.line });
    var _hasCond = !mpfIsOp(_P, ";");
    if (_hasCond)
    {
        mpfParseExpr(_P);
        if (_P.err) return;
    }
    if (!mpfAccept(_P, ";"))
    {
        mpfErrHere(_P, "SyntaxError", "expected ';'");
        return;
    }
    var _jEnd = -1;
    if (_hasCond) _jEnd = mpfEmit(_P, { op: MPF_OP_JMPZ, a: 0, line: _kw.line });
    var _mainOps = _P.ops;
    _P.ops = [];
    if (!mpfIsOp(_P, ")")) mpfParseSimple(_P, false);
    var _incOps = _P.ops;
    _P.ops = _mainOps;
    if (_P.err) return;
    if (!mpfAccept(_P, ")"))
    {
        mpfErrHere(_P, "SyntaxError", "expected ')'");
        return;
    }
    array_push(_P.loops, { breaks: [], continues: [], cont: -1 });
    mpfParseBody(_P);
    if (_P.err) return;
    var _loop = array_pop(_P.loops);
    var _cont = array_length(_P.ops);
    for (var _k = 0; _k < array_length(_incOps); _k++) array_push(_P.ops, _incOps[_k]);
    mpfEmit(_P, { op: MPF_OP_JMP, a: _tick, line: _kw.line });
    var _exit = mpfEmit(_P, { op: MPF_OP_LOOP_EXIT, a: 0, line: _kw.line });
    if (_jEnd != -1) mpfPatch(_P, _jEnd, _exit);
    for (var _k = 0; _k < array_length(_loop.breaks); _k++) mpfPatch(_P, _loop.breaks[_k], _exit);
    for (var _k = 0; _k < array_length(_loop.continues); _k++) mpfPatch(_P, _loop.continues[_k], _cont);
}

function mpfParseLoopJump(_P, _kind)
{
    var _t = mpfAdv(_P);
    if (array_length(_P.loops) == 0)
    {
        mpfFail(_P, "SyntaxError", "'" + _kind + "' outside of a loop", _t.line);
        return;
    }
    var _at = mpfEmit(_P, { op: MPF_OP_JMP, a: 0, line: _t.line });
    var _loop = _P.loops[array_length(_P.loops) - 1];
    if (_kind == "break") array_push(_loop.breaks, _at);
    else array_push(_loop.continues, _at);
    if (!mpfAccept(_P, ";")) mpfErrHere(_P, "SyntaxError", "expected ';'");
}

function mpfParseStatement(_P)
{
    var _t = mpfTok(_P);
    if (_t.k == "kw")
    {
        if (_t.v == "var") { mpfParseVarDecl(_P, true); return; }
        if (_t.v == "if") { mpfParseIf(_P); return; }
        if (_t.v == "while") { mpfParseWhile(_P); return; }
        if (_t.v == "for") { mpfParseFor(_P); return; }
        if (_t.v == "break" || _t.v == "continue") { mpfParseLoopJump(_P, _t.v); return; }
    }
    if (_t.k == "op" && _t.v == "{")
    {
        mpfParseBlock(_P);
        return;
    }
    if (_t.k == "op" && _t.v == ";")
    {
        _P.i++;
        return;
    }
    mpfParseSimple(_P, true);
}

function mpfParseSection(_P)
{
    while (mpfTok(_P).k != "eof")
    {
        mpfParseStatement(_P);
        if (_P.err) return undefined;
    }
    return { ops: _P.ops, consts: _P.consts, fns: _P.fns };
}

function mpfParser(t, ctx = undefined)
{
    if (ctx == undefined) ctx = { diff: "", name: "" };
    var _lines = mpfSplitLines(t);
    var _count = array_length(_lines);
    var _preLines = [];
    var _metaEntries = [];
    var _initLines = [];
    var _mainLines = [];
    var _finishLines = [];
    var _initStart = 0;
    var _mainStart = 0;
    var _finishStart = 0;
    var _cur = "pre";
    var _seenMeta = false;
    var _seenInit = false;
    var _seenMain = false;
    var _seenFinish = false;
    var _lastRank = -1;
    for (var _i = 0; _i < _count; _i++)
    {
        var _raw = _lines[_i];
        var _l = string_trim(_raw);
        var _no = _i + 1;
        if (_l == "::MetaData::" || _l == "::Init::" || _l == "::Main::" || _l == "::Finish::")
        {
            var _name = string_lower(string_copy(_l, 3, string_length(_l) - 4));
            var _rank = 0;
            if (_name == "init") _rank = 1;
            else if (_name == "main") _rank = 2;
            else if (_name == "finish") _rank = 3;
            if ((_name == "metadata" && _seenMeta) || (_name == "init" && _seenInit) || (_name == "main" && _seenMain) || (_name == "finish" && _seenFinish))
            {
                mpfPushError("SyntaxError", "duplicated " + _l + " block", _no, "parse", ctx.diff, ctx.name);
                return undefined;
            }
            if (_rank <= _lastRank)
            {
                mpfPushError("SyntaxError", _l + " is out of order", _no, "parse", ctx.diff, ctx.name);
                return undefined;
            }
            _lastRank = _rank;
            if (_name == "metadata") _seenMeta = true;
            else if (_name == "init") { _seenInit = true; _initStart = _no; }
            else if (_name == "main") { _seenMain = true; _mainStart = _no; }
            else { _seenFinish = true; _finishStart = _no; }
            _cur = _name;
            continue;
        }
        if (string_starts_with(_l, "::"))
        {
            mpfPushError("SyntaxError", "unknown block marker '" + _l + "'", _no, "parse", ctx.diff, ctx.name);
            return undefined;
        }
        if (_cur == "pre")
        {
            if (_l == "") continue;
            if (string_char_at(_l, 1) != "#")
            {
                mpfPushError("SyntaxError", "code must be inside ::Init:: or ::Main::", _no, "parse", ctx.diff, ctx.name);
                return undefined;
            }
            array_push(_metaEntries, { n: _no, t: _l });
            continue;
        }
        if (_cur == "metadata")
        {
            if (_l == "") continue;
            if (string_char_at(_l, 1) != "#")
            {
                mpfPushError("SyntaxError", "expected an attribute line (starting with '#')", _no, "parse", ctx.diff, ctx.name);
                return undefined;
            }
            array_push(_metaEntries, { n: _no, t: _l });
            continue;
        }
        if (_cur == "init") array_push(_initLines, _raw);
        else if (_cur == "main") array_push(_mainLines, _raw);
        else array_push(_finishLines, _raw);
    }
    var _meta = mpfMetaReadEntries(_metaEntries, ctx, true);
    if (_meta == undefined) return undefined;
    var _risk = mpfRiskToLevel(_meta.risk_level);
    var _result = { meta: _meta, init: undefined, main: undefined, finish: undefined, vars: [] };
    var _P = mpfNewParserState([], ctx, _risk, "init");
    if (_seenInit)
    {
        var _toks = mpfTokenize(mpfJoinLines(_initLines), ctx, _initStart);
        if (_toks == undefined) return undefined;
        _P.toks = _toks;
        _P.i = 0;
        _P.block = "init";
        _P.ops = [];
        var _progInit = mpfParseSection(_P);
        if (_progInit == undefined) return undefined;
        _result.init = _progInit;
    }
    if (_seenMain)
    {
        var _toks2 = mpfTokenize(mpfJoinLines(_mainLines), ctx, _mainStart);
        if (_toks2 == undefined) return undefined;
        _P.toks = _toks2;
        _P.i = 0;
        _P.block = "main";
        _P.ops = [];
        var _progMain = mpfParseSection(_P);
        if (_progMain == undefined) return undefined;
        _result.main = _progMain;
    }
    if (_seenFinish)
    {
        var _toks3 = mpfTokenize(mpfJoinLines(_finishLines), ctx, _finishStart);
        if (_toks3 == undefined) return undefined;
        _P.toks = _toks3;
        _P.i = 0;
        _P.block = "finish";
        _P.ops = [];
        var _progFinish = mpfParseSection(_P);
        if (_progFinish == undefined) return undefined;
        _result.finish = _progFinish;
    }
    _result.vars = _P.vars;
    return _result;
}

function mpfMakeEnv(_diff, _name, _path, _meta)
{
    var _env = {
        __mpf: true,
        diff: _diff,
        name: _name,
        path: _path,
        meta: _meta,
        loaded: false,
        inited: false,
        dead: false,
        phase: "main",
        prog_init: undefined,
        prog_main: undefined,
        prog_finish: undefined,
        variables: [],
        var_names: [],
        stack: array_create(MPF_STACK_INIT, 0),
        args: [],
        loop_depth: 0,
        loop_counts: array_create(8, 0),
        init_runs: 0,
        main_runs: 0,
        finish_runs: 0,
        resets: 0,
        last_beat: -1,
        last_seen: -1,
        errors_total: 0,
        last_err_type: "",
        last_err_msg: "",
        last_err_line: 0,
        last_err_phase: "",
        inst: undefined,
        log_fp: undefined
    };
    mpfInitBuiltinVars(_env);
    return _env;
}

function mpfRecordError(_env, _type, _msg, _line, _phase)
{
    _env.errors_total++;
    _env.last_err_type = string(_type);
    _env.last_err_msg = string(_msg);
    _env.last_err_line = _line;
    _env.last_err_phase = string(_phase);
}

function mpfInitBuiltinVars(_env)
{
    _env.i_beat = 0;
    _env.i_beatStart = 1;
    _env.i_beatEnd = 2;
    _env.i_pi = 3;
    if (array_length(_env.variables) < MPF_BUILTIN_VARS) _env.variables = array_create(MPF_BUILTIN_VARS, 0);
    _env.variables[_env.i_beat] = 0;
    _env.variables[_env.i_beatStart] = 0;
    _env.variables[_env.i_beatEnd] = 0;
    _env.variables[_env.i_pi] = pi;
}

function mpfResetEnv(_env)
{
    _env.resets++;
    _env.loaded = false;
    _env.inited = false;
    _env.prog_init = undefined;
    _env.prog_main = undefined;
    _env.prog_finish = undefined;
    _env.variables = [];
    _env.var_names = [];
    _env.stack = array_create(MPF_STACK_INIT, 0);
    _env.loop_depth = 0;
    _env.loop_counts = array_create(8, 0);
    if (_env.log_fp != undefined)
    {
        file_text_close(_env.log_fp);
        _env.log_fp = undefined;
    }
    mpfInitBuiltinVars(_env);
}

function mpfVMError(_env, _ins, _type, _msg)
{
    mpfPushError(_type, _msg, _ins.line, _env.phase, _env.diff, _env.name);
    mpfRecordError(_env, _type, _msg, _ins.line, _env.phase);
    _env.dead = true;
}

function mpfCatchFuncError(_env, _ins, _err)
{
    var _type = "FuncExecError";
    var _msg = string(_err);
    if (is_struct(_err))
    {
        if (variable_struct_exists(_err, "__mpf_error"))
        {
            _type = string(variable_struct_get(_err, "type"));
            _msg = string(variable_struct_get(_err, "msg"));
        }
        else if (variable_struct_exists(_err, "message"))
        {
            _msg = string(variable_struct_get(_err, "message"));
        }
    }
    mpfPushError(_type, _msg, _ins.line, _env.phase, _env.diff, _env.name);
    mpfRecordError(_env, _type, _msg, _ins.line, _env.phase);
    _env.dead = true;
}

function mpfIsNum(_v)
{
    return (is_real(_v) || is_bool(_v));
}

function mpfTruthy(_v)
{
    if (mpfIsNum(_v)) return (_v > 0);
    return undefined;
}

function mpfArith(_env, _ins, _op, _a, _b)
{
    if (!mpfIsNum(_a) || !mpfIsNum(_b))
    {
        mpfVMError(_env, _ins, "TypeError", "arithmetic requires numbers");
        return undefined;
    }
    if (_op == MPF_OP_ADD) return _a + _b;
    if (_op == MPF_OP_SUB) return _a - _b;
    if (_op == MPF_OP_MUL) return _a * _b;
    if (_op == MPF_OP_DIV)
    {
        if (_b == 0)
        {
            mpfVMError(_env, _ins, "ZeroDivisionError", "division by zero");
            return undefined;
        }
        return _a / _b;
    }
    if (_op == MPF_OP_IDIV)
    {
        if (_b == 0)
        {
            mpfVMError(_env, _ins, "ZeroDivisionError", "division by zero");
            return undefined;
        }
        return _a div _b;
    }
    if (_op == MPF_OP_MOD)
    {
        if (_b == 0)
        {
            mpfVMError(_env, _ins, "ZeroDivisionError", "modulo by zero");
            return undefined;
        }
        return _a mod _b;
    }
    return undefined;
}

function mpfCompare(_env, _ins, _op, _a, _b)
{
    var _num = mpfIsNum(_a) && mpfIsNum(_b);
    var _str = is_string(_a) && is_string(_b);
    if (_op == MPF_OP_EQ || _op == MPF_OP_NEQ)
    {
        if (!_num && !_str)
        {
            mpfVMError(_env, _ins, "TypeError", "cannot compare values of different types");
            return undefined;
        }
        var _same = (_a == _b);
        if (_op == MPF_OP_EQ) return _same;
        return !_same;
    }
    if (!_num)
    {
        mpfVMError(_env, _ins, "TypeError", "cannot order strings or mixed types");
        return undefined;
    }
    if (_op == MPF_OP_LT) return (_a < _b);
    if (_op == MPF_OP_LE) return (_a <= _b);
    if (_op == MPF_OP_GT) return (_a > _b);
    return (_a >= _b);
}

function mpfExec(_env, _prog, _phase)
{
    if (_prog == undefined) return;
    var _ops = _prog.ops;
    var _consts = _prog.consts;
    var _fns = _prog.fns;
    var _stack = array_create(MPF_STACK_INIT, 0);
    var _sp = 0;
    var _pc = 0;
    var _len = array_length(_ops);
    var _maxLoop = _env.meta.max_loop_times;
    _env.phase = _phase;
    _env.loop_depth = 0;
    if (_phase == "init") _env.init_runs++;
    else if (_phase == "main") _env.main_runs++;
    else _env.finish_runs++;
    while (_pc < _len)
    {
        if (_sp + 16 >= array_length(_stack)) array_resize(_stack, array_length(_stack) + MPF_STACK_INIT);
        var _ins = _ops[_pc];
        switch (_ins.op)
        {
            case MPF_OP_PUSH_K:
                _stack[_sp] = _consts[_ins.a];
                _sp++;
                break;
            case MPF_OP_PUSH_V:
                _stack[_sp] = _env.variables[_ins.a];
                _sp++;
                break;
            case MPF_OP_PUSH_IDX:
            {
                _sp--;
                var _idx = _stack[_sp];
                _sp--;
                var _arr = _stack[_sp];
                if (!is_array(_arr))
                {
                    mpfVMError(_env, _ins, "TypeError", "cannot index a non-array value");
                    return;
                }
                if (!mpfIsNum(_idx))
                {
                    mpfVMError(_env, _ins, "TypeError", "array index must be a number");
                    return;
                }
                _idx = floor(_idx);
                if (_idx < 0 || _idx >= array_length(_arr))
                {
                    mpfVMError(_env, _ins, "IndexError", "array index " + string(_idx) + " is out of range");
                    return;
                }
                _stack[_sp] = _arr[_idx];
                _sp++;
                break;
            }
            case MPF_OP_POP:
                if (_sp > 0) _sp--;
                break;
            case MPF_OP_STORE_V:
                _sp--;
                _env.variables[_ins.a] = _stack[_sp];
                break;
            case MPF_OP_SET_IDX:
            {
                _sp--;
                var _val = _stack[_sp];
                _sp--;
                var _idx2 = _stack[_sp];
                _sp--;
                var _arr2 = _stack[_sp];
                if (!is_array(_arr2))
                {
                    mpfVMError(_env, _ins, "TypeError", "cannot index a non-array value");
                    return;
                }
                if (!mpfIsNum(_idx2))
                {
                    mpfVMError(_env, _ins, "TypeError", "array index must be a number");
                    return;
                }
                _idx2 = floor(_idx2);
                if (_idx2 < 0 || _idx2 >= array_length(_arr2))
                {
                    mpfVMError(_env, _ins, "IndexError", "array index " + string(_idx2) + " is out of range");
                    return;
                }
                _arr2[_idx2] = _val;
                break;
            }
            case MPF_OP_DUP2:
            {
                var _d0 = _stack[_sp - 2];
                var _d1 = _stack[_sp - 1];
                _stack[_sp] = _d0;
                _sp++;
                _stack[_sp] = _d1;
                _sp++;
                break;
            }
            case MPF_OP_ARR_NEW:
            {
                var _cnt = _ins.a;
                var _new = array_create(_cnt, undefined);
                for (var _k = _cnt - 1; _k >= 0; _k--)
                {
                    _sp--;
                    _new[_k] = _stack[_sp];
                }
                _stack[_sp] = _new;
                _sp++;
                break;
            }
            case MPF_OP_ADD:
            case MPF_OP_SUB:
            case MPF_OP_MUL:
            case MPF_OP_DIV:
            case MPF_OP_IDIV:
            case MPF_OP_MOD:
            {
                _sp -= 2;
                var _res = mpfArith(_env, _ins, _ins.op, _stack[_sp], _stack[_sp + 1]);
                if (_env.dead) return;
                _stack[_sp] = _res;
                _sp++;
                break;
            }
            case MPF_OP_EQ:
            case MPF_OP_NEQ:
            case MPF_OP_LT:
            case MPF_OP_LE:
            case MPF_OP_GT:
            case MPF_OP_GE:
            {
                _sp -= 2;
                var _cmp = mpfCompare(_env, _ins, _ins.op, _stack[_sp], _stack[_sp + 1]);
                if (_env.dead) return;
                _stack[_sp] = _cmp;
                _sp++;
                break;
            }
            case MPF_OP_NEG:
                if (!mpfIsNum(_stack[_sp - 1]))
                {
                    mpfVMError(_env, _ins, "TypeError", "unary '-' requires a number");
                    return;
                }
                _stack[_sp - 1] = -_stack[_sp - 1];
                break;
            case MPF_OP_NOT:
            {
                var _tv0 = mpfTruthy(_stack[_sp - 1]);
                if (_tv0 == undefined)
                {
                    mpfVMError(_env, _ins, "TypeError", "'!' requires a number");
                    return;
                }
                _stack[_sp - 1] = !_tv0;
                break;
            }
            case MPF_OP_JMP:
                _pc = _ins.a - 1;
                break;
            case MPF_OP_JMPZ:
            {
                _sp--;
                var _tv1 = mpfTruthy(_stack[_sp]);
                if (_tv1 == undefined)
                {
                    mpfVMError(_env, _ins, "TypeError", "condition must be a number");
                    return;
                }
                if (!_tv1) _pc = _ins.a - 1;
                break;
            }
            case MPF_OP_JMPZ_PEEK:
            {
                var _tv2 = mpfTruthy(_stack[_sp - 1]);
                if (_tv2 == undefined)
                {
                    mpfVMError(_env, _ins, "TypeError", "condition must be a number");
                    return;
                }
                if (!_tv2) _pc = _ins.a - 1;
                else _sp--;
                break;
            }
            case MPF_OP_JMPNZ_PEEK:
            {
                var _tv3 = mpfTruthy(_stack[_sp - 1]);
                if (_tv3 == undefined)
                {
                    mpfVMError(_env, _ins, "TypeError", "condition must be a number");
                    return;
                }
                if (_tv3) _pc = _ins.a - 1;
                else _sp--;
                break;
            }
            case MPF_OP_LOOP_ENTER:
                if (_env.loop_depth >= array_length(_env.loop_counts)) array_resize(_env.loop_counts, _env.loop_depth + 8);
                _env.loop_counts[_env.loop_depth] = 0;
                _env.loop_depth++;
                break;
            case MPF_OP_LOOP_TICK:
                _env.loop_counts[_env.loop_depth - 1]++;
                if (_env.loop_counts[_env.loop_depth - 1] > _maxLoop)
                {
                    mpfVMError(_env, _ins, "MaxLoopReached", "loop limit of " + string(_maxLoop) + " reached");
                    return;
                }
                break;
            case MPF_OP_LOOP_EXIT:
                if (_env.loop_depth > 0) _env.loop_depth--;
                break;
            case MPF_OP_CALL:
            {
                var _argc = _ins.b;
                var _base = _sp - _argc;
                var _fn = _fns[_ins.a].m;
                if (array_length(_env.args) < _argc + 1) array_resize(_env.args, _argc + 1);
                for (var _k = 0; _k < _argc; _k++) _env.args[_k] = _stack[_base + _k];
                _env.args[_argc] = _env;
                var _ret = undefined;
                try
                {
                    _ret = method_call(_fn, _env.args);
                }
                catch (_err)
                {
                    mpfCatchFuncError(_env, _ins, _err);
                    return;
                }
                _sp = _base;
                _stack[_sp] = _ret;
                _sp++;
                break;
            }
            case MPF_OP_HALT:
                return;
            default:
                mpfVMError(_env, _ins, "UnknownError", "unknown opcode " + string(_ins.op));
                return;
        }
        _pc++;
    }
}

function mpfLoadEnv(_env)
{
    var _text = mpfReadText(_env.path);
    if (_text == undefined)
    {
        mpfPushError("NameError", "mpf script not found: " + string(_env.path), 0, "parse", _env.diff, _env.name);
        mpfRecordError(_env, "NameError", "mpf script not found: " + string(_env.path), 0, "parse");
        _env.dead 
        = true;
        return false;
    }
    var _res = mpfParser(_text, { diff: _env.diff, name: _env.name });
    if (_res == undefined)
    {
        _env.dead = true;
        return false;
    }
    _env.meta = _res.meta;
    _env.prog_init = _res.init;
    _env.prog_main = _res.main;
    _env.prog_finish = _res.finish;
    if (_res.main == undefined)
    {
        mpfPushError("SyntaxError", "the ::Main:: block is missing", 0, "parse", _env.diff, _env.name);
        mpfRecordError(_env, "SyntaxError", "the ::Main:: block is missing", 0, "parse");
    }
    _env.var_names = _res.vars;
    array_resize(_env.variables, array_length(_res.vars));
    for (var _i = MPF_BUILTIN_VARS; _i < array_length(_res.vars); _i++)
        _env.variables[_i] = 0;
    mpfInitBuiltinVars(_env);
    _env.loaded = true;
    return true;
}

function mpfRun(_env, _currentbeat, _obj_ins, _entry)
{
    if (!is_struct(_env) || !variable_struct_exists(_env, "__mpf")) return;
    if (_env.dead) return;
    _env.inst = _obj_ins;
    if (!_env.loaded)
    {
        if (!mpfLoadEnv(_env)) return;
        if (_env.dead) return;
    }
    _env.last_beat = _currentbeat;
    _env.variables[_env.i_beat] = _currentbeat;
    if (_entry != undefined)
    {
        _env.variables[_env.i_beatStart] = _entry.b;
        _env.variables[_env.i_beatEnd] = _entry.e;
    }
    if (!_env.inited)
    {
        _env.inited = true;
        if (_env.prog_init != undefined)
        {
            mpfExec(_env, _env.prog_init, "init");
            if (_env.dead) return;
        }
    }
    mpfExec(_env, _env.prog_main, "main");
}

function mpfRunner(currentbeat,obj_ins,entry = undefined){
    mpfRun(self, currentbeat, obj_ins, entry);
}

function mpfRunEntry(_entry, _env, _currentbeat, _obj_ins)
{
    if (!variable_struct_exists(_entry, "in_range") || !_entry.in_range)
    {
        _entry.in_range = true;
        _env.dead = false;
        var _refresh = true;
        if (variable_struct_exists(_env, "meta") && is_struct(_env.meta)) _refresh = _env.meta.refresh_on_each_run;
        if (_refresh) mpfResetEnv(_env);
    }
    mpfRun(_env, _currentbeat, _obj_ins, _entry);
}

function mpfFinishEntry(_entry, _env, _currentbeat, _obj_ins)
{
    if (!is_struct(_env) || !variable_struct_exists(_env, "__mpf")) return;
    if (_env.dead || !_env.loaded) return;
    if (_env.prog_finish == undefined) return;
    _env.inst = _obj_ins;
    _env.variables[_env.i_beat] = _currentbeat;
    _env.variables[_env.i_beatStart] = _entry.b;
    _env.variables[_env.i_beatEnd] = _entry.e;
    mpfExec(_env, _env.prog_finish, "finish");
}

function testHighRisk(){
    
}
