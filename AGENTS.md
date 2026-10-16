## 项目概述
- 这是一个GMS2音游vivid/stasis的mod，主要用于收集/拓展游戏内的特效(下文将称为gimmick)；
- 这个游戏的路径（下文将简记为%GAME_PATH%）在```D:\Program Files\steam\steamapps\common\vividstasis```，未经过MOD补丁的data.win在%GAME_PATH%\backup内，MOD补丁总是会打到%GAME_PATH%\data.win；
- 本地有游戏相应版本的GameMaker文档，位于```D:\Documents\Gamemaker_Docs```
- 本项目的核心object是obj_custom_gimmick；
- gimmick分为补间型和回调型；补间型的gimmick会控制相应变量```cc.mod_gimmick名```的值，而回调型则是会执行一次函数，通常没有对应的变量，具体机制可见项目里的```codepatches/updateMod.gml```和```gml_GlobalScript_init_custom_global_gmk.gml```

## 构建&验证方式
mod加载器位于%GAME_PATH%\BVOClient_1.0.7\VML\vividstasisModLoader.exe
运行成功后会有```修补完成，按 Enter 退出。 (Patching completed, press Enter to exit.)```这样一句话，这时就算安装成功，你可以直接关闭modloader窗口进行下一步

## 安全注意事项
- 在没有我允许的情况下不能使用修改/添加类型的git命令，也不能动.gitgignore这样的配置文件。

## 代码风格
- 不要把大量功能代码都堆到一个GlobalScript，记住你可以创建Object！在Object内使用的代码优先选择在这个Object的事件gml内写。只有需要全局使用的函数才放到 GlobalScript的gml内。
- 保持代码中的注释数量在最低限度。你几乎不应该写注释，除非代码实现方式不常规，函数定义时的参数不自解释，或者类定义及其成员上；此外不要去修改已有的注释。
## MOD编写指南

### 总体介绍
你能操作的mod目录有以下这些：
```
ExampleMod
├─ codepatches
├─ codes
├─ objects
├─ shaders
├─ raw
└─ codepatches.json
```

### 目录介绍

#### /raw
对于其中的文件：会用同名文件替换游戏目录中的对应文件。

#### /objects：
通常用于创建新的obj，内部存放数个object的json配置，文件名不与object名相关
一个json有如下字段：
- Name:Object名
- Awake:Object是否处于唤醒状态
- Parent:该Object的父对象，可以没有这个字段

#### /shaders
用于存放要插入的shader文件，里面包含数个文件夹，文件夹名即为shader名，文件夹内必须放**UTMT导出形式的shader代码文件**

#### /codes
对于其中的文件，会带文件名原样把整个gml放进data.win，如果已有相应名字的代码，则会用新的gml内容替代旧的内容；一般情况下只会放GlobalScript和Object的事件代码。
- GlobalScript（全局脚本）的命名规则是：```gml_GlobalScript_脚本名.gml```
- Object事件代码的命名规则是：```gml_Object_Object名_事件类型_子类型ID.gml```；事件类型表和相应子类型我会在附录一栏给出

#### codepatches.json
用于指定patch方式，patch点和要patch的代码。
有如下字段：
- Entry：代码条目名称。
- Find：仅在 Type 为 0 或 1 时使用。
- Value：当 Type 为 0 或 1 时，表示替换后的代码；当 Type 为 2 或 3 时，表示将要插入的代码。
- Type：
        0：将找到的所有字符串都替换为 Value。
        1：将找到的第一个字符串替换为 Value。
        2：在 Function 前插入 Value；当 Function 为空时，Value 会插入到该 Entry 开头。
        3：在 Function 后插入 Value；当 Function 为空时，Value 会插入到该 Entry 末尾。
-  Function：目标函数名称，仅在 Type 为 2 或 3 时使用。
- ExternalFile：/codepatches 中文件的相对路径；若指定该项，则会忽略 Value。

#### /codepatches
codepatches.json中ExternalFile的搜索目录

> 注：
> 1. /codes的加载先于codepatches相关的加载；
> 2. /raw内的文件每次加载mod都会覆盖一遍；
> 3. GlobalScript内的函数能够被注册为全局函数；

## 附录
### 事件类型表及子事件类型ID
*[W.I.P]*

### 这个音游gameplay相关的主要object/代码
#### 游玩相关Object:
- cc:播放谱面时的控制器
- obj_note_rendering，obj_pressed_holds：note判定和渲染
- obj_base_gimmick：gimmick控制器的基类

