# 自定义 mpf 脚本说明

> 这篇文档是写给**谱师**的，不需要任何编程基础：所有东西都是"照抄上面这段、改几个数字"。
> 遇到看不懂的名词，先看后面的例子，例子比解释重要。

## 一、mpf 是什么

在 `.vsm` 里你已经可以写 gimmick：某一段时间内，把一个值从 A 渐变到 B。

**mpf 是"更进一步"的版本**：在指定的拍数区间内，**每一帧**都运行一次你写的小脚本。
渐变做不到的事情——按拍数振荡、每 4 拍跳一次、随机抖动、几个变量互相联动、进场铺好/退场还原——都可以用 mpf 做。

一句话：**gimmick 是"从 A 到 B"，mpf 是"你自己写怎么变"。**

## 二、5 分钟上手

### 1. 建两个东西

**① 脚本文件**：在谱面目录下新建 `cmpf` 文件夹，在里面放一个 `.vsmpf` 文件，文件名格式是：

```
[难度名].[脚本名].vsmpf
```

例如 `ENCORE.wave.vsmpf`（ENCORE 难度、脚本名 `wave`）。
难度名写 `GLOBAL` 表示所有难度都能用，例如 `GLOBAL.wave.vsmpf`。

**② 在 `.vsm` 里指定生效区间**：在 `.vsm` **最后**加一段（`mpf` 之后不能再写 gimmick 语句）：

```
mpf
32,64,wave
```

意思是：**从 32 拍到 64 拍之间，每帧运行 `wave` 这个脚本。**

> 注意：mpf 名字必须和文件名里的中段**完全一致**（区分大小写）。
> 另外谱面需要在 `.vsm` 里用 `!obj:obj_custom_gimmick`（本 mod 的谱面都是这样）。

### 2. 最小的脚本

`ENCORE.wave.vsmpf` 的内容：

```
::Main::
set_mod_val("cover1", 0.5);
```

效果：32 拍到 64 拍之间，屏幕上等于一直开着 `cover1 = 0.5`。
（`set_mod_val("名字", 值)` 等于写 `.vsm` 里的 `名字` 这个 gimmick 的值。）

### 3. 让它动起来

```
::Main::
set_mod_val("cover1", (beat - beatStart) / (beatEnd - beatStart));
```

`beat` 是当前拍数，`beatStart`/`beatEnd` 是你写的区间起止拍。
于是 `cover1` 会从 0 慢慢涨到 1 —— 效果和用 gimmick 写渐变一样，但你现在可以随便改算式了。

## 三、脚本的三个部分

一个 vsmpf 文件最多分三块，**顺序必须是这样**：

| 块 | 什么时候运行 |
| :--- | :--- |
| `::Init::` | 每次**进入**区间时运行一次（用来准备变量、设置初始值） |
| `::Main::` | 在区间内**每帧**运行一次（主要逻辑写这里） |
| `::Finish::` | 离开区间时运行一次（用来还原、收尾） |

- `::Init::` / `::Finish::` 可以省略，`::Main::` 必须有。
- 三个标记**必须单独占一行**，且大小写必须写对（`::Main::` 不能写成 `::main::`）。
- 不写 `::Init::` 时，文件开头也可以直接以 `::Main::` 开头。

```
::Init::
var timer = 0;

::Main::
timer = timer + 1;

::Finish::
set_mod_val("cover1", 0);
```

## 四、变量

### 要用 var 声明

```
var a = 3;        // 声明一个叫 a 的变量，初始值 3
var b;            // 声明 b，初始值 0
```

- **每条语句结尾必须写 `;`**。
- 变量必须先声明再用，否则会报 `NameError`。
- **变量只需要声明一次**：在 `::Init::` 里 `var` 过的，`::Main::` 和 `::Finish::` 里直接用，**不要再写 var**（重复声明会报错）。
- 名字区分大小写（`A` 和 `a` 是两个变量），也不能用 `var`、`if`、`while` 这些关键字当名字。

### 自带的变量（不用自己声明）

| 名字 | 含义 |
| :--- | :--- |
| `beat` | 当前拍数（和 `.vsm` 里的拍数一致） |
| `beatStart` | 本区间的起始拍（`.vsm` 里写的第一个数） |
| `beatEnd` | 本区间的结束拍（第二个数） |
| `pi` | 圆周率 3.14159…（写周期算式时要用） |

这四个**不要自己声明**，直接用就行。

### 值的种类

| 种类 | 怎么写 | 例子 |
| :--- | :--- | :--- |
| 数字 | 直接写 | `3`、`0.5`、`-2` |
| 字符串 | 用双引号括起来 | `"cover1"` |
| 真/假 | `true` / `false`（其实就是 1 和 0） | `true` |
| 数组 | 用方括号，下标从 0 开始 | `var a = [10, 20, 30];` 用 `a[0]` 取值 |

数组例子：

```
::Init::
var colors = [16777215, 16711680, 255];

::Main::
set_mod_val("set_slash_col", colors[0]);
```

> 数组下标不能越界（`a[3]` 在只有 3 个元素的数组上会报 `IndexError`）。

## 五、运算符

| 写法 | 含义 |
| :--- | :--- |
| `+` `-` `*` `/` | 加、减、乘、除 |
| `\` | 整除（只要整数部分）：`7 \ 2` 是 `3` |
| `%` | 取余数：`7 % 3` 是 `1`（常用来做"每 N 拍循环"） |
| `==` `!=` | 等于、不等于 |
| `<` `<=` `>` `>=` | 小于、小于等于、大于、大于等于 |
| `&&` | 并且（两边都成立） |
| `\|\|` | 或者（任一边成立） |
| `!` | 取反：`!true` 是 `false` |

赋值写法（简写）：

| 写法 | 等价于 |
| :--- | :--- |
| `a = 1;` | 把 1 存进 a |
| `a += 1;` | `a = a + 1;` |
| `a -= 1;` | `a = a - 1;` |
| `a *= 2;` | `a = a * 2;` |
| `a /= 2;` | `a = a / 2;` |
| `a \= 2;` | `a = a \ 2;` |
| `a %= 2;` | `a = a % 2;` |

> - 字符串不能做加减乘除（会报 `TypeError`）。想把数字和文字拼起来要用 `str_cat` 和 `to_str`，见下面的函数表。
> - 除以 0 会报 `ZeroDivisionError`。

## 六、条件判断

```
::Main::
if (beat - beatStart < 8) {
    set_mod_val("cover1", 0.2);
}
else if (beat - beatStart < 16) {
    set_mod_val("cover1", 0.6);
}
else {
    set_mod_val("cover1", 1);
}
```

- 条件成立就执行 `{ }` 里的内容。
- `else if` 可以连很多个；`else` 表示"以上都不成立"。
- `else` 也可以不写。

> 判定"真假"的规则：大于 0 就是真、小于等于 0 就是假。所以数字可以直接当条件用（`if (timer)` 表示 timer 不为 0 时成立）。

## 七、循环

大部分情况下你用不到循环（因为 Main 本身每帧都在跑）。需要"在一帧里重复算几次"时才用：

```
// 让 4 条轨道的横向偏移各自做不同的摆动
::Main::
for (var i = 0; i < 4; i = i + 1) {
    set_mod_val(str_cat("xoffsetind", to_str(i)), sin(beat + i) * 5);
}

// while：条件成立就一直重复
var k = 0;
while (k < 3) {
    k = k + 1;
}
```

- `break;` 立刻跳出循环；`continue;` 直接进入下一轮。
- 为了防止写错成死循环把游戏卡死，每个循环最多执行 **65536** 次（可用属性调整），超了会报 `MaxLoopReached` 并停用这个脚本。

## 八、可以调用的函数

脚本**只能**调用下表里的函数；写别的名字（或者拼错）会报 `NameError`。

- 参数按顺序写，用英文逗号 `,` 分隔；标了"可省略"的才能省，其余必须给全。
- "危险等级"和脚本属性 `#RISK_LEVEL` 配套：**脚本只能调用等级不高于自己的函数**（`SAFE` < `RISK` < `HIGH_RISK` < `CRITICAL_RISK`），超了会报 `PermissionError`。脚本默认等级是 `SAFE`。
- 表按等级从低到高排列（目前还没有 `RISK` / `CRITICAL_RISK` 级的函数，级别留着以后用）。
- 涉及时间、时长的参数**单位一律是拍**。
- `轨道号` 的含义和 `.vsm` 里 proxy 那一列一致：`-1` = 全局（操控 `cc.mod_xxx`，也就是普通 gimmick 的用法），`0~6` = 只作用于对应轨道。

|函数|作用|参数说明|危险等级|
|:-:|:-:|:-:|:-:|
|`set_mod_val(名字, 值, 轨道号)`|设置某个 gimmick 的值，立刻生效|名字：gimmick 名，**不要带 `mod_` 前缀**，如 `"cover1"`；值：要设置成的数值；轨道号：可省略，省略等于 `-1`|SAFE|
|`set_mod_val_at(名字, 拍数, 值, 轨道号)`|到指定拍数时再设置该 gimmick 的值|名字、值、轨道号：同上；拍数：什么时候生效（单位拍）|SAFE|
|`get_mod_val(名字, 轨道号)`|读取某个 gimmick 当前的值|名字、轨道号：同上；该 gimmick 变量必须已经存在，否则会报错|SAFE|
|`tween_mod_val(名字, 时长, 缓动, 起始值, 结束值, 轨道号)`|让该 gimmick 在"时长"内从起始值渐变到结束值（等于用脚本写一条补间 gimmick）|名字、轨道号：同上；时长：单位拍；缓动：写法同 `.vsm` 里的 easing，如 `"outCubic"`；起始值/结束值：渐变的两端|SAFE|
|`tween_mod_val_at(名字, 起始拍, 时长, 缓动, 起始值, 结束值, 轨道号)`|同上，但从指定的拍数开始渐变|起始拍：从第几拍开始（单位拍）；其余同上|SAFE|
|`call_callback_mod(名字, 时长, 值1, 值2)`|触发一个**回调型** gimmick（不是所有 gimmick 都有回调）|名字：gimmick 名；时长：单位拍；值1/值2：传给回调的两个参数|SAFE|
|`call_callback_mod_at(名字, 起始拍, 时长, 值1, 值2)`|同上，但从指定的拍数开始|起始拍：从第几拍开始（单位拍）；其余同上|SAFE|
|`register_mod(名字, 初始值)`|注册一个新的 gimmick 名，之后就能用 `set_mod_val` / `tween_mod_val` 或 `.vsm` 控制它|名字：新 gimmick 名（建议加前缀避免撞名）；初始值：它的初始数值。**只能在 `::Init::` 里调用**|SAFE|
|`ease(缓动, 起始值, 结束值, 进度)`|自己算缓动值（想手动做渐变曲线时用）|缓动：写法同 `.vsm`；进度：0~1 的小数；返回缓动后的数值|SAFE|
|`sin(弧度)`|正弦|弧度：参数是弧度制；想要"每 N 拍一个周期"就写 `sin(beat * 2 * pi / N)`|SAFE|
|`cos(弧度)`|余弦|弧度：同 `sin`|SAFE|
|`tan(弧度)`|正切|弧度：同 `sin`|SAFE|
|`abs(数值)`|绝对值|数值：任意数字|SAFE|
|`floor(数值)`|向下取整|数值：任意数字，`floor(2.7)` 得到 `2`|SAFE|
|`ceil(数值)`|向上取整|数值：任意数字，`ceil(2.1)` 得到 `3`|SAFE|
|`min(a, b)`|取较小的那个|a、b：两个数字|SAFE|
|`max(a, b)`|取较大的那个|a、b：两个数字|SAFE|
|`clamp(值, 最小值, 最大值)`|把值限制在范围内|值：要限制的数字；最小值：范围下限；最大值：范围上限|SAFE|
|`to_str(值)`|把值变成文字|值：数字或文字，用于和 `str_cat` 拼接，`to_str(3)` 得到 `"3"`|SAFE|
|`str_cat(文字1, 文字2)`|把两段文字接起来|文字1：前半段；文字2：后半段，如 `str_cat("cover", "1")` 得到 `"cover1"`|SAFE|
|`array_create(长度)`|造一个全是 0 的数组|长度：要造几个元素|SAFE|
|`array_length(数组)`|数组里有多少个元素|数组：用 `[ ]` 定义的数组|SAFE|
|`array_contains(数组, 元素)`|数组里有没有这个元素（返回 `true`/`false`）|数组：要查找的数组；元素：要找的值|SAFE|
|`array_push(数组, 元素)`|把元素追加到数组末尾|数组：要追加的数组；元素：要加的值。**要把返回值赋回变量**：`a = array_push(a, 1);`|SAFE|
|`array_insert(数组, 元素, 位置)`|把元素插到指定位置|数组：要插入的数组；元素：要插入的值；位置：插到第几个（0 开始）。同样要 `a = array_insert(a, 1, 0);`|SAFE|
|`array_sort(数组, 升序)`|给数组排序|数组：要排序的数组；升序：`true` 从小到大、`false` 从大到小。同样要 `a = array_sort(a, true);`|SAFE|
|`array_pop(数组)`|取出并移除最后一个元素（返回被移除的那个值）|数组：要操作的数组|SAFE|
|`random(上限)`|0 到上限之间的随机小数|上限：任意数字，`random(1)` 得到 0~1 之间的小数|SAFE|
|`irandom(上限)`|0 到上限之间的随机整数|上限：任意整数，`irandom(3)` 得到 0/1/2/3 之一|SAFE|
|`random_set_seed(种子)`|固定随机结果（同一个种子每次结果一样）|种子：任意数字|SAFE|
|`get_judge_cnt(判定类型)`|读取统计里的判定数|判定类型：0~4 依次是 acrit、crit、great、good、miss|SAFE|
|`get_combo()`|读取当前连击|无参数|SAFE|
|`get_max_combo()`|读取最大连击|无参数|SAFE|
|`write_log(文字)`|往游戏根目录的 `log_mpf.[chartid].[难度名].log` 追加一行，用来调试|文字：要记录的内容|SAFE|
|`short_msg(文字)`|在游玩界面发送一条短消息，用来调试|文字：要发送的内容|SAFE|
|`add_judge_cnt(判定类型, 数量)`|改动统计里的判定数（会影响成绩显示）|判定类型：0~4 依次是 acrit、crit、great、good、miss；数量：要增加的数量|HIGH_RISK|
|`set_judge_timing(判定档位, 数值)`|修改判定窗口（会影响判定结果）|判定档位：0~4；数值：窗口大小，单位毫秒|HIGH_RISK|
|`reset_judge_timing()`|把判定窗口恢复成默认值|无参数|HIGH_RISK|

> 脚本不支持自定义函数：想要表里没有的功能（新的数学函数、新的控制接口等），找 mod 作者加白名单。
> 表里 `push` / `insert` / `sort` 这类"改数组"的函数记得写 `a = 函数(a, ...);`（直接写 `array_push(a, 1);` 可能不生效）。

## 九、脚本属性

文件**最开头**（在 `::Init::` 之前）可以写属性，每行一条：

```
#RISK_LEVEL = SAFE
#MAX_LOOP_TIMES = 1024
#REFRESH_ON_EACH_RUN = false
```

| 属性 | 含义 | 默认值 |
| :--- | :--- | :--- |
| `RISK_LEVEL` | 脚本的权限等级，可填 `SAFE` / `RISK` / `HIGH_RISK` / `CRITICAL_RISK`。等级低于要调用的函数时会报 `PermissionError` | `SAFE` |
| `MAX_LOOP_TIMES` | 每个循环最多执行多少次 | `65536` |
| `REFRESH_ON_EACH_RUN` | `true`：每次**进入**区间都重置变量并重跑 `::Init::`；`false`：整首曲子只初始化一次，变量一直保留 | `true` |

- 写错的属性名会被忽略；属性值写错（比如 `RISK_LEVEL = 你好`）会报 `ValueError`。
- 也可以把属性放在 `::MetaData::` 块里（写在 `::Init::` 之前就行）。

## 十、用途示例（直接抄）

### 1）匀速变化 + 收尾还原

```
::Init::
set_mod_val("df_grid_alpha", 0);

::Main::
set_mod_val("df_grid_alpha", (beat - beatStart) / (beatEnd - beatStart));

::Finish::
set_mod_val("df_grid_alpha", 0);
```

### 2）按拍振荡（4 拍一个周期）

```
::Main::
set_mod_val("bgalph", 0.5 + 0.5 * sin(beat * 2 * pi / 4));
```

### 3）每 4 拍切一次背景图（在 0/1/2 之间循环）

```
::Main::
set_mod_val("custom_jacket", floor((beat - beatStart) / 4) % 3);
```

### 4）只在区间的后半段生效

```
::Main::
if (beat > (beatStart + beatEnd) / 2) {
    set_mod_val("wflash", 0.8);
}
else {
    set_mod_val("wflash", 0);
}
```

### 5）四条轨道分别摆动

```
::Main::
for (var i = 0; i < 4; i = i + 1) {
    set_mod_val(str_cat("xoffsetind", to_str(i)), sin(beat + i * 0.5) * 6);
}
```

### 6）每 2 拍才做一次（不要用帧数计时！）

```
::Init::
var lastBeat = -999;

::Main::
if (beat - lastBeat >= 2) {
    lastBeat = beat;
    set_mod_val("custom_jacket", irandom(3));
}
```

### 7）接一个"渐变 + 抖动"的效果

```
::Main::
var base = (beat - beatStart) / (beatEnd - beatStart);
set_mod_val("vig", 0.5 * base + 0.05 * sin(beat * 2 * pi / 0.5));
```

## 十一、一定要知道的几个坑

1. **不要用"每帧加一"来计时。**
   玩家的帧率设置可以是 30/60/120…，同一份谱在不同机器上表现会不一样。
   时间判断一律用 `beat`（第 6 号示例）。

2. **mpf 每帧都会覆盖它设置的值。**
   同一个 gimmick 变量如果既用补间 gimmick 又用 mpf 控制，补间会被 mpf 盖掉。二选一。

3. **每次进入区间都会重置（默认）。**
   `REFRESH_ON_EACH_RUN = true` 时，重打谱面、或者从区间前方跳回来，`::Init::` 都会再跑一次、变量清零。这是通常想要的行为，不想这样就把属性写成 `false`。

4. **区间的起止是开区间。**
   `32,64` 表示从 32 拍之后开始、到 64 拍之前结束；`::Finish::` 在离开的那一帧执行一次。

5. **同一名字的脚本被多条区间引用时，共用同一份变量。**
   想要独立的两份状态，就写两个不同的脚本名（两个文件）。

6. **脚本出错会停用自己。**
   一旦报错，这个 mpf 在本次游玩内不再运行，并弹出错误窗口。修好脚本重进谱面即可。

7. **别写太重的循环。**
   区间内每帧都在跑，循环次数过大（几千次以上）会掉帧。

8. **字符串不能直接相加。**
   `"a" + "b"` 会报错，要用 `str_cat("a", "b")`；数字要拼进文字里要先 `to_str`。

## 十二、出错怎么办

报错窗口里的一条信息长这样：

```
script mpf脚本名:[TypeError] at line 12.
```

- 方括号里是错误类型，`line 12` 是 **vsmpf 文件里的第几行**，具体原因会打在```%LOCALAPPDATA%/VIVIDSTASIS/mpfruntime.[chart_id].[难度名].log```。

| 错误类型 | 常见原因 |
| :--- | :--- |
| `SyntaxError` | 打错字、少了分号 `;`、`::Main::` 写错/顺序不对/没写、少了 `}` |
| `NameError` | 用了没有 `var` 声明的变量；调用了不在函数表里的函数名（拼错） |
| `TypeError` | 拿字符串去做加减乘除、拿两个不同类型的东西比大小、条件不是数字 |
| `ZeroDivisionError` | 除以 0 或对 0 取余（常见于 `/(beatEnd - beatStart)` 这类写错） |
| `IndexError` | 数组下标越界，或对不是数组的东西用 `[ ]` |
| `MaxLoopReached` | 循环次数超过 `MAX_LOOP_TIMES` |
| `PermissionError` | 调用了高于 `#RISK_LEVEL` 的函数 |
| `FuncExecError` | 函数内部报错（比如 `get_mod_val` 读了一个不存在的 gimmick） |
| `ValueError` | 属性值写错 |

**排查建议**：在可疑的位置插 `write_log(...)`，例如

```
::Main::
write_log(str_cat("beat=", to_str(beat)));
```

然后看游戏根目录的 `log_mpf.log`，确认脚本真的在跑、`beat` 的值对不对。

## 十三、语法速查

```
// 这是注释，这一行不会被运行

#属性名 = 值            ← 只能写在最前面

::Init::                ← 进入区间时一次
::Main::                ← 区间内每帧
::Finish::              ← 离开区间时一次

var a = 3;              ← 声明变量（只声明一次！）
a = a + 1;              ← 赋值
a += 1;                 ← 赋值简写

if (条件) { ... } else if (条件) { ... } else { ... }

while (条件) { ... }
for (var i = 0; i < 4; i = i + 1) { ... }
break;  continue;

set_mod_val("名字", 值, 轨道号);        ← 立刻设置
set_mod_val_at("名字", 拍数, 值, 轨道号);  ← 到某一拍再设置
get_mod_val("名字", 轨道号);
tween_mod_val("名字", 时长, "outCubic", 起始值, 结束值, 轨道号);
tween_mod_val_at("名字", 起始拍, 时长, "outCubic", 起始值, 结束值, 轨道号);
call_callback_mod("名字", 时长, 值1, 值2);
call_callback_mod_at("名字", 起始拍, 时长, 值1, 值2);
register_mod("名字", 初始值);           ← 只能在 ::Init::

ease("outCubic", 0, 1, 0.5);
sin() cos() tan() abs() floor() ceil() min() max() clamp()
to_str() str_cat() write_log()
array_create() array_length() array_contains() array_pop()
a = array_push(a, 元素);  a = array_insert(a, 元素, 位置);  a = array_sort(a, true);
random() irandom() random_set_seed()
get_judge_cnt() get_combo() get_max_combo()

beat  beatStart  beatEnd  pi
```
