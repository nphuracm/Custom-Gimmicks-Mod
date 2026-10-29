## legacy200 contribution

- Independent `uimode` and `bgparticles200` chart controls; regular `changeskin` skin 4.
- Instant reversible UI/feedback switching without a System Options entry.
- Selected-base-skin Allison transitions. See `documents/legacy200.md`.

# 更新日志
---
### v1.6.2
- 新增prtrX与prtrY，分别对应仿射变换下的绕x轴旋转和绕y轴旋转
- 修复了字幕播放顺序可能出错的问题

### v1.6.3
- 添加了控制行最大宽度的gmk: textmaxwidth
- 修复了行最大宽度的逻辑，现在是以字符为单位
  
### v1.7.0 -pre1
- 支持了shader：abx,aby,barrelabx,barrelaby,vdistort,bloom ，具体见文档
- 支持了angelstar_checker系列

### v1.7.0
- pre1的内容
- 支持了aop,glitch,tw,pos系列等shader，具体参见文档
- 新增cgmk配置，具体也请见文档

### v1.7.1
- 修复了游玩官谱会崩溃的bug

### v1.8.0
- 支持了中途更换自定义的bg，具体可见文档
- distortedBG系列的扭曲滤镜现在可以被部分控制（BG_ditortScale BG_ditortAmount）了，具体见文档
- 再度修复了游玩官谱会崩溃的bug(???)

### v1.8.1
- 修复了游玩切出窗口时因surface不存在导致的崩溃
- 修复了cover盖不住note的问题
- 再度优化粒子系统（？

### v1.8.2
- 加了一些gmk的ind变种
- 新增xoffset

### v1.9.0
- 适配新版本体

### v1.10.0
- 优化了字幕gmk，并新增了调整对齐方式gmk，具体见文档
- 修复了部分gmk无法使用的问题（plaudite_pburst,playspeed）
- 将jumpto细化为jumpto_beat和jumpto_s，具体见文档
- 新增reset_scrollspeed

### v1.10.1
- 修复了谱面路径相关问题
- 修复了cosX滤镜的问题
- 现在jacket系列如果id值超过现有jacket数量/小于0 会 自动取余/取id最大的jacket

### v1.11.0
- 现在支持皮肤更换

- 支持图片插入

- sides被细化成了unraveling_sidething, astellion_sidething和apocalypse_sidething

- 常规SV（om的那种）支持

- 暂时废弃ENABLE_DEBUG_INFO

- 星星相关gmk支持

- 修复了df相关特效图层错误问题

- 改变了轨道变换的顺序

### v1.12
- 部分跟进了游戏更新

### v1.12.1

- 修复了NoteModsX导致的崩溃

### v1.12.2

- 修复了beat失效的问题

### v1.12.3
- 修复了部分shader失效的问题（如fish和barrel）
- 部分更新了粒子系统（也是用上新粒子系统了喵喵喵）
- 修复了scrollind失效的问题
- 修复了字幕时间顺序出错的的问题
- 修复了部分gmk v1和v2作用错位的问题

### v1.12.4

- 修复了plaudite_pburst的持续时间模式

### v1.12.5

- 修复了图片gmk的ytime/scaleytime的计算错误问题
- 修复了图层失效的问题
- vsp的图片声明新增参数：所属轨道，用于指定按哪个轨道进行位置计算
- 新增图片gmk:imgxtime

### v1.12.6
- 修复了文字透明度失效的问题
- 修复了particle_alpha失效的问题
- 修复了prtr系列失效的问题
- 修复了使用xoffset这类gimmick时，打击特效和note实际位置错位的问题

### v1.12.7
- 修复了astellion_sidething崩溃问题
- 修复了changeskin参数的错位问题
- 修复了vsv读取错误的问题
- 修复了游玩房间内，背景曲绘被错误缩放的问题(我才发现og在新版把背景曲绘大小调成420x268了XDD)
- 彻底移除了字幕的debug模式
- 移除了Herobrine

### v1.13
- 修复了vsv读取文件后未关闭导致的崩溃bug
- 修复了使用vsv变速时boost系列和wave失效的bug
- 添加了lr_slash,o_anycol_slash_new
- 图片gimmick新增imgxb_\*和imgyb_\*
- 新增yoffsetb，xoffsetb，yoffsetindb，xoffsetindb
- 新增了NEW_PRTRX_CALCULATION配置项，代表是否使用prtr系列的新算法，为新算法增加了```prtrD``` gimmick @deepseek
- 修复了imgscaleytime的运算优先级错误 @deepseek
- 修复了同一Layer内图层优先级错误的问题 @deepseek
- 修复了imgytime/imgxtime/imgscaleytime会串用到上一张图的数值的问题（现在每张图独立计算）@deepseek
- 优化了图片绘制性能 @deepseek

### v1.13.1
- 修复了xoffsetind失效的问题
- 修复了drawuntil生效条件错误的问题
- 添加了drawstop，代表距离判定线n msx时隐藏
- 给两种slash新增了控制收束时间的gimmick：*_close_time

### v1.14
- 修复了beat崩溃问题
- 新增自定义mpf功能 @deepseek

### v1.14.1
- 添加了lr_sides_blue/lr_sides_red/lr_sides_rev_blue/lr_sides_rev_red   @Frollsy
- 添加了sc_firework和sc_firework_color  @Frollsy
- 添加了chorus_greenleft_overlay    @Frollsy
- 添加了set_resolution，倍率上限8，开销为倍率平方，谱面结束时自动恢复   @Frollsy
- 重写了mpf的add_judge_cnt，现在能给任意判定加减任意整数，并可指定记在early还是late，同时同步分数、准度、连击和pace（原来crit及以下会失效  
- 新增了JACKET_GLOW，代表要不要修复旧版背景发光的bug
- 新增输入相关和获取分数的mpf白名单函数
- 现在自定义mpf是全局的了（任意obj可用）

### v1.14.2
- 修复了mpf重开一局后，变量不重置的问题
- 现在新增vsmpf支持热加载了
- 修复了旧版字幕颜色相关的崩溃
- 完善cgmk文档
- mpf函数get_game_var_instance的ins_id参数改为必须项
- mpf现在支持struct处理（暂时没有相关运算符）
- 取消了mpf函数array_push的返回值
