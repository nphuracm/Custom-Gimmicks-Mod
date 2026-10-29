# Custom Gimmick说明

## 文档约定

本文档内有较多说明格式的部分，因此把一些说明放在这里，如果没有特殊说明，以下面提到的为准。

- 方括号括起来代表一个部分的值是必填的，比如```[arg]```代表arg的值是必填的；使用花括号括起来的代表一个部分（的值）是可选的，如```{,{step}}```代表step的值和它前面的那个逗号都是可以省略不写的
- 在没标注全局gimmick的情况下，本文档提到的gimmick得在obj为```obj_custom_gimmick```时才能使用

## 回调型gimmick与补间型gimmick
一般的，补间型gimmick的val1代表起始值，val2是结束值，然后再dur期间内从val1按指定缓动过渡val2；但是对于回调型gimmick，缓动、dur、val1和val2各自的意思完全取决于gimmick内部的设计，这也是为什么部分gimmick会有dur为0也能看到很明显的效果，或是调v1没有任何效果的情况。本文档内，对于回调型gimmick会标记上*回调型gimmick*。

## cgmk配置文件
顾名思义，这个文件是用来管理要不要启用某一部分的gimmick的。

<br>

直接在谱面根目录下创建```[难度]_cgmk_config.json```即可，如FINALE难度的配置就写```FINALE_cgmk_config.json```，如果需要全局的配置文件，就直接创建```cgmk_config.json```。
- 注意，单独难度的配置的优先级是大于全局的。
- 如果目录没有配置文件，那么**下述所有配置都会被认为是true**

<br>

以下是可用的配置： 
|           配置名            |                         作用                         |  默认值  |
| :-------------------------: | :--------------------------------------------------: | :------: |
|     JACKET_MANAGE_MODE      | 调整换背景的模式，可填plaudite或custom，默认plaudite | plaudite |
|         ENABLE_TEXT         |                   是否启用字幕gmk                    |   true   |
|     ENABLE_NON_BASE_FX      |            是否启用不在base obj内的fx gmk            |   true   |
| ENABLE_DF_GRID_AND_SIDELINE |            是否启用df的两侧的线或网格gmk             |   true   |
|  ENABLE_ANGELSTAR_CHECKER   |            是否启用anglestar的背景棋盘gmk            |   true   |
|      ENABLE_DISTORT_BG      |                    是否启用扭曲BG                    |   true   |
|    ENABLE_MUSIC_CONTROL     |       是否启用控制音乐的gmk(jumpto和playspeed)       |   true   |
|     ENABLE_STARPARTICLE     |               是否启用星星粒子相关gmk                |  false   |
|     ENABLE_SKIN_CHANGE      |              是否启用改变皮肤相关的gmk               |  false   |
|    NEW_PRTRX_CALCULATION    |                是否使用prtr*的新算法                 |  false   |
|      ENABLE_DEBUG_INFO      |       是否在屏幕上绘制调试信息(于1.11暂时废弃)       |  false   |
|         JACKET_GLOW         |              是否沿用前面版本的背景发光              |  false   |

<br>

在json内，你只要像下面这样填入配置信息就好了，你可以从上述的配置种填一或多个，**不填的默认为true**

```json
{
    "ENABLE_TEXT":false,
    "ENABLE_NON_BASE_FX":false,
    "JACKET_MANAGE_MODE":"custom"
}
```

## 字幕效果

首先要在谱面的目录下创建一个文件： ``` [难度]_text.txt```，如ENCORE难度就创建一个```ENCORE_text.txt```

之后在文件里面按照以下格式打轴，一行一个语句：

``````
[拍数],[字幕的内容]
``````

之后就可以使用gimmick操作字幕了，以下是可以操作字幕的gimmick：

|   gmk名    |        作用        |                      其它描述                       |
| :--------: | :----------------: | :-------------------------------------------------: |
|   textX    |  调整字幕的横坐标  |                                                     |
|   textY    |  调整字幕的纵坐标  |                                                     |
|  textalp   |  调整字幕的透明度  |                      范围[0,1]                      |
|  textrot   | 调整字幕的旋转角度 |                       角度制                        |
| textcolhex |    调整字幕颜色    | 将hex颜色转为10进制后填入<br>*受col_convertion影响* |
| textscale  |    调整字幕大小    |                       默认为1                       |

在v1.5及以后，可以使用多文件字幕，要使用要创建文件：```[难度]_text_[编号].txt```，如ENCORE难度的2号字幕就创建一个```ENCORE_text_2.txt```；<br>
内部格式同单文件字幕，但是使用的gmk不太一样，下面记指定的字幕文件的编号为```[tid]```


|       gmk名        |                 作用                  |                 其它描述                  |
| :----------------: | :-----------------------------------: | :---------------------------------------: |
|    textX_[tid]     |         调整字幕[tid]的横坐标         |  实际横坐标为textX\_[tid]+textX\_[tid]b   |
|    textX_[tid]b    |         调整字幕[tid]的横坐标         |                                           |
|    textY_[tid]     |         调整字幕[tid]的纵坐标         |  实际纵坐标为textY\_[tid]+textY\_[tid]b   |
|    textY_[tid]b    |          调整字幕tid的纵坐标          |                                           |
|   textalp_[tid]    |         调整字幕[tid]的透明度         |                 范围[0,1]                 |
|   textrot_[tid]    |        调整字幕[tid]的旋转角度        |                  角度制                   |
|  textcolrgb_[tid]  |           调整字幕[tid]颜色           |         将hex颜色转为10进制后填入         |
|  textscale_[tid]   |           调整字幕[tid]大小           |                  默认为1                  |
|   textsep_[tid]    |         调整字幕[tid]的行间距         |                  默认为1                  |
| textmaxwidth_[tid] | 调整字幕[tid]的行最大宽度（单位字符） |                 默认为20                  |
|  textalignv_[tid]  |      调整字幕[tid]的中心垂直位置      | 默认为顶部<br>0,1,2分别为顶部，中部，底部 |
|  textalignh_[tid]  |      调整字幕[tid]的中心水平位置      | 默认为居中<br>0,1,2分别为左侧，居中，右侧 |

> 从1.10.0开始,tid可以是任意字符串了，之前只能是0~49的数字

## 背景
对于自定义背景模式(custom)，你只要往谱面目录下放入数个图片(jpg或png)并在gmk内使用```custom_jacket```切换即可，命名格式是```jacket[id```，比如id为的1图片就叫```jacket[1.png```或```jacket[1.jpg```
<br>
**注意：使用这功能时，确保在配置文件里JACKET_MANAGE_MODE的值为"custom"!**
<br>

对于plaudite背景(plaudite),范围0~11，从0到10分别对应以下曲目的jacket:
- transparent（透明背景）
- pyromania
- valor
- unraveling
- supernova
- libertia
- stopmotion
- convergence
- red（纯红色背景）
- plaudite
- astellion

|       gmk名        |           作用           |                      其它描述                      |
| :----------------: | :----------------------: | :------------------------------------------------: |
|   ditortedBG_alp   |  调整扭曲背景的不透明度  |                     范围[0,1]                      |
| ditortedBG_col_rgb |    调整扭曲背景的颜色    |             将hex颜色转为10进制后填入              |
|  plaudite_jacket   |      切换粒子的背景      | 虽然不是新的gmk，但是多了新的参数:11，代表默认背景 |
|   custom_jacket    |      切换粒子的背景      |         填入要切换的图片id，0代表默认背景          |
|   BG_ditortScale   | 调整扭曲背景的扭曲块大小 |                       默认0                        |
|  BG_ditortAmount   |  调整扭曲背景的扭曲程度  |                       默认0                        |

## 图片插入
你需要先在谱面目录下创建```[难度名].vsp```，如果需要全难度可用难度名处填```GLOBAL```，**特定难度的vsp会覆盖全局vsp**。

一个vsp内可以分成两个部分，像这样：
```
//第一部分
#Layer
[layer1声明]
[layer2声明]
...
[layerN声明]

//第二部分
#Image
[layer1名称]:
[image1声明]
[image2声明]
...
[imageN声明]

[layer2名称]:
[image1声明]
[image2声明]
...
[imageN声明]
```
<br>
第一部分是用来说明你要使用哪些图层的，一个图层声明语句是这样的：

```
[图层名],[图层优先级]
```

图层优先级的值越大，图层越靠顶部。

<br>

第二部分用于声明要使用哪些图片(image)，及所属图层；其中，<u>layer名称</u>处填写你在第一部分声明的图层名，并且不必按照第一部分的声明顺序填写；<br>
插入的图片分为静态图(static)和动态图(animated)，两种分别是这样声明的：
<br><br>
*方括号代表必填参数，大括号代表可选参数*

#### 静态

```
static,[图像名],[源图像路径],[图像层级]{,{图像初始宽度},{图像初始宽度},{所属lane}}
```

#### 动态

```
animated,[图像名],[源图像路径],[图像层级],[图像帧个数]{,{图像初始宽度},{图像初始高度},{所属lane}}
```
同样的，图像层级高的图片会盖住图像层级低的图片。

> 注：<br>
> I.动态图像必须采用条带格式，且满足 单帧图像宽度=条带宽度/图像帧个数<br>
> II.源图像路径指相对谱面目录的路径，比如在谱面文件夹内有```iv.png```，那么源图像路径就为```iv.png```；如果在aaa文件夹内有```bbb.png```，那么应该写```aaa/bbb.png```<br>
> III.同一个图片文件可以被多个的不同的image使用<br>
> IV.vsp文件内在行头加上//，代表这整行为注释 ~~（虽然我也不知道加注释功能有啥用）~~<br>
> V.如果Layer的层级更高，那么其中的所有image会盖住Layer更低的image

在写完vsp文件后，你就可以用下列gimmick控制你在#Image内声明的图像了
|       gimmick名        |                        作用                         |                           其它描述                           |
| :--------------------: | :-------------------------------------------------: | :----------------------------------------------------------: |
|     imgx_[图像名]      |                  调整图像的横坐标                   |                      默认为160，单位px                       |
|     imgy_[图像名]      |                  调整图像的纵坐标                   |                       默认为90，单位px                       |
|     imgxb_[图像名]     |                  调整图像的横坐标                   |                      默认为160，单位px                       |
|     imgyb_[图像名]     |                  调整图像的纵坐标                   |                       默认为90，单位px                       |
|   imgxtime_[图像名]    |    在当前imgx上加上(N ms时所属lane的横坐标偏移)     |                   默认为_(573613)，单位ms                    |
|   imgytime_[图像名]    |    在当前imgy上加上(离判定还有N ms时note的位置)     |   默认为_(573613)，单位msx<br>当值为_时，这个gimmick不生效   |
|    imgrot_[图像名]     |                 调整图像的旋转角度                  |                       默认为0，角度制                        |
|   imgscalex_[图像名]   |                 调整图像的横向缩放                  |                           默认为1                            |
|   imgscaley_[图像名]   |                 调整图像的纵向缩放                  |                           默认为1                            |
| imgscaleytime_[图像名] | 在当前imgscaley上乘上(N msx对应的px数/图像初始高度) |   默认为_(573613)，单位msx<br>当值为_时，这个gimmick不生效   |
|   imgskewx_[图像名]    |                 调整图像的横向斜切                  |                           默认为0                            |
|   imgskewy_[图像名]    |                 调整图像的纵向斜切                  |                           默认为0                            |
|   imgcolrgb_[图像名]   |                   调整图像的颜色                    |          将rgb的hex转为10进制后填入，默认为16777215          |
|    imgalp_[图像名]     |                 调整图像的不透明度                  |                           默认为1                            |
|    imgidx_[图像名]     |       调整当前所绘制的帧（只对动态图片生效）        | 默认为0；0代表第一帧<br>小于0会直接取0，大于总帧数会自动取余 |
>注:<br>
> 变换时参考的中心为图片的中心点
> 最终的imgx=imgx+imgxb+imgxtime；最终的imgy=imgy+imgyb+imgytime

## 滤镜/shader
|         gmk名         |                            作用                            |                             其它描述                              |
| :-------------------: | :--------------------------------------------------------: | :---------------------------------------------------------------: |
|        fx_red         | 效果与fx_colorise相同，默认为红色，且只能由recolor改变颜色 |                    默认为0，大于等于1代表启用                     |
|        recolor        |                    随机调整fx_red的颜色                    |             大于等于1代表触发一次<br>*回调型gimmick*              |
|   fx_red_intensity    |                    调整fx_red的滤镜强度                    |                              默认为1                              |
|  fx_colorise_col_rgb  |                   调整colorise滤镜的颜色                   |                     将hex颜色转为10进制后填入                     |
| fx_colorise_col_alpha |             调整colorise滤镜的颜色中的alpha值              |                                                                   |
| fx_colorise_intensity |                   调整colorise滤镜的强度                   |                                                                   |
|       vdistort        |                          纵向模糊                          |                              默认为0                              |
|       hdistort        |                          横向模糊                          |                              默认为0                              |
|       barrelabx       |                    调整barrel的横向色散                    |                              默认为0                              |
|       barrelaby       |                    调整barrel的竖向色散                    |                              默认为0                              |
|         sina          |                     将ui扭曲为正弦波形                     |          这类gmk的a指振幅，o指周期的倒数，p指相位，下同           |
|         sino          |                                                            |                    默认为0（0代表禁用），下同                     |
|         sinp          |                                                            |                          p默认为1，下同                           |
|         cosa          |                  将ui扭曲为纵向的正弦波形                  |                                                                   |
|         cosp          |                                                            |                                                                   |
|         coso          |                                                            |                                                                   |
|         tana          |                  将ui扭曲为纵向的正切波形                  |                                                                   |
|         tano          |                                                            |                                                                   |
|         tanp          |                                                            |                                                                   |
|         posx          |                       横向移动ui界面                       |                              默认为0                              |
|         posy          |                       纵向移动ui界面                       |                              默认为0                              |
|        twx[id]        |                   在屏幕产生一个螺旋扭曲                   | x，y指扭曲中心位置，a指扭曲程度，r指扭曲半径<br>[id]范围1~4，下同 |
|        twy[id]        |                                                            |                                                                   |
|        twa[id]        |                                                            |                                                                   |
|        twr[id]        |                                                            |                                                                   |
|         gray          |                          灰色滤镜                          |                                                                   |
|        barrel         |                                                            |                     最后效果是barrel+barrel2                      |
|        barrel2        |                                                            |                                                                   |
|         fish          |                        鱼眼效果幅度                        |                                                                   |
|          vig          |                                                            |                                                                   |
|          abx          |                     调整横向色散的幅度                     |                                                                   |
|          aby          |                     调整纵向色散的幅度                     |                                                                   |
|         bloom         |                          光晕幅度                          |                                                                   |
|       glitchamp       |                      控制glitch的强度                      |             默认为0，效果可见aleph-0官谱那种的glitch              |
|     glitchoffset      |                  控制glitchamp的播放速度                   |                                                                   |
|        uhnoise        |                      控制glitch的强度                      |  默认为0，这种glitch效果可见supernova/extendnova官谱那种的glitch  |
|      fx_hue_hue       |                        调整整体色相                        |                              默认为0                              |
|   fx_hue_saturation   |                       调整整体饱和度                       |                              默认为1                              |
|        fx_edge        |                        启用边缘检测                        |                    默认为0，大于等于1代表启用                     |
|     fx_posterize      |         控制颜色层次(或者叫位深)，值越高层次越丰富         |                             默认为32                              |
|   fx_posterize_vis    |                    是否启用fx_posterize                    |                    默认为0，大于等于1代表启用                     |
|       fx_twirl        |   在屏幕中心产生螺旋扭曲，这个gmk控制这个扭曲的扭曲程度    |                              默认为0                              |
|     fx_underwater     |                          水下效果                          |                            默认为0.01                             |
|        fx_zoom        |                     缩放的动态模糊效果                     |                              默认为0                              |

## 粒子相关
|        gmk名        |               作用               |                                                                        其它描述                                                                         |
| :-----------------: | :------------------------------: | :-----------------------------------------------------------------------------------------------------------------------------------------------------: |
|  starspawner_timer  |           控制星星数量           |                                                                                                                                                         |
| starspd_multiplier  |         星星下落速度倍率         |                                                                                                                                                         |
|     starspd_low     |         星星最慢下落速度         |                                                                                                                                                         |
|    starspd_high     |         星星最快下落速度         |                                                                                                                                                         |
|  active_starchgcol  |         启用渐变色型星星         |                                              按hsv进行渐变，方式是对h，s和v各自单独补间<br>*回调型gimmick*                                              |
|  active_startrans   |          启用蒙版型星星          |                                                     星星所在区域黑色底板是透明的<br>*回调型gimmick*                                                     |
|   startrans_alpha   |        蒙版型星星不透明度        |                                                                                                                                                         |
|  starchgcol_alpha   |       渐变色型星星不透明度       |                                                                                                                                                         |
|  starchgcol_up_rgb  | 渐变色型星星在屏幕上半部分的颜色 |                                                             将hex颜色转为十进制后填入，下同                                                             |
| starchgcol_down_rgb | 渐变色型星星在屏幕下半部分的颜色 |                                                                                                                                                         |
|   particle_alpha    |      控制菱形粒子的不透明度      |                                                                                                                                                         |
|       rainbow       |        让菱形粒子变为彩色        |                                                                                                                                                         |
|   plaudite_pburst   |          从顶部喷射粒子          | value1控制喷射方式，大于0代表按持续时间，持续时间内每帧喷射一次；否则是喷射一次，但可控制密度；<br>value2代表持续时间（ms）/喷射密度<br>*回调型gimmick* |

## 轨道Gimmick
| gmk名 |                作用                |                                    其它描述                                    |
| :---: | :--------------------------------: | :----------------------------------------------------------------------------: |
| prtrX |            绕x轴3D旋转             | 默认为0<br>新算法中单位为角度制，旧算法应写相应角度的正弦值<br>*是全局gimmick* |
| prtrY |            绕y轴3D旋转             | 默认为0<br>新算法中单位为角度制，旧算法应写相应角度的正弦值<br>*是全局gimmick* |
| prtrD | 3D旋转使用的物距，只在新算法内生效 |                        默认为320<br>*是全局gimmick*<br>                        |
| prsy  |              纵向斜切              |                           默认为0<br>*是全局gimmick*                           |

## Note效果
此处[lane]指代第n条轨道，0~3为4k的1~4轨，456为左中右bumper
|          gmk名          |                    作用                    |                   其它描述                    |
| :---------------------: | :----------------------------------------: | :-------------------------------------------: |
|         xoffset         |                谱面横向偏移                |           单位px<br>*是全局gimmick*           |
|        xoffsetb         |                谱面横向偏移                |           单位px<br>*是全局gimmick*           |
|        yoffsetb         |               效果同yoffset                |           单位px<br>*是全局gimmick*           |
|    yoffsetind[lane]     |    效果同yoffset，但只对[lane]轨道生效     |    与yoffset是累加关系<br>*是全局gimmick*     |
|    xoffsetind[lane]     |    效果同xoffset，但只对[lane]轨道生效     |    与xoffset是累加关系<br>*是全局gimmick*     |
|    yoffsetindb[lane]    |    效果同yoffset，但只对[lane]轨道生效     |    与yoffset是累加关系<br>*是全局gimmick*     |
|    xoffsetindb[lane]    |    效果同xoffset，但只对[lane]轨道生效     |    与xoffset是累加关系<br>*是全局gimmick*     |
|    notealpind[lane]     |    效果同notealp，但只对[lane]轨道生效     |    与notealp是累乘关系<br>*是全局gimmick*     |
|   boost_timeind[lane]   |   效果同boost_time，但只对[lane]轨道生效   |   与boost_time是累加关系<br>*是全局gimmick*   |
| boost_distanceind[lane] | 效果同boost_distance，但只对[lane]轨道生效 | 与boost_distance是累加关系<br>*是全局gimmick* |
|    reset_scrollspeed    |              重置scrollspeed               |                *是全局gimmick*                |

> 某一轨的最终yoffset=yoffset+yoffsetb+yoffsetind[lane]；最终xoffset=xoffset+xoffsetb+xoffsetind[lane]

## 其它
|          gmk名           |                                   作用                                   |                                                         其它描述                                                          |
| :----------------------: | :----------------------------------------------------------------------: | :-----------------------------------------------------------------------------------------------------------------------: |
|       jumpto_beat        |                             跳转谱面指定位置                             |                                    在value2处填具体的值，单位为拍数<br>*是全局gimmick*                                    |
|         jumpto_s         |                             跳转谱面指定位置                             |                          当value1>0时单位为秒否则为毫秒，在value2处填具体的值<br>*是全局gimmick*                          |
|        playspeed         |                             设置谱面播放速度                             |                                               默认值为1<br>*是全局gimmick*                                                |
|      col_convertion      |                  将自定义gmk内部分调整颜色的gmk逻辑转换                  |         *已于1.12.8移除*<br>不为0时会将输入的颜色以rgb的形式使用，否则以bgr的形式<br>受该gmk影响的将在描述中标出          |
|          cover1          |                           调整屏幕遮盖不透明度                           |                                   虽然不是新的gmk，但是作用变了：控制的是整个屏幕的遮盖                                   |
|          cover2          |                          轨道外侧遮盖的不透明度                          |                                                                                                                           |
|          cover3          |                            轨道遮盖的不透明度                            |                                                                                                                           |
|  angelstar_checker_mode  | 调整angelstar_checker的状态，0为受曲绘影响，1是不受影响，2是大于轨道图层 |                                                          默认为0                                                          |
| angelstar_checker_alpha  |                          调整棋盘效果的不透明度                          |                                                                                                                           |
|  angelstar_checker_set   |                               刷新棋盘效果                               |                                                                                                                           |
|          wflash          |                            白色闪屏的不透明度                            |                                                                                                                           |
|          static          |                         调整雪花屏效果的不透明度                         |                                                                                                                           |
|       df_sideline2       |                生成一对向外移动的黑色竖线，缓动为outCirc                 |                                                      *回调型gimmick*                                                      |
|       df_sideline        |                      绘制一对可以控制移动的白色竖线                      |                                         范围[0,1]，1代表抵达屏幕边缘，0为轨道边缘                                         |
|    df_sideline_alpha     |                         控制df_sideline的透明度                          |                                                                                                                           |
|        df_whitebg        |                                 白色背景                                 |                                                                                                                           |
|      df_grid_alpha       |                          df中的网格效果不透明度                          |                                                                                                                           |
|       df_grid_top        |                        控制网格可视部分的顶部位置                        |                                                                                                                           |
|      df_grid_bottom      |                        控制网格可视部分的底部位置                        |                                                                                                                           |
|       df_grid_col        |                              控制网格的颜色                              |                                                                                                                           |
|          bgalph          |                        控制轨道非灰色部分的透明度                        |                                                                                                                           |
|     holdoverlayalpha     |                           轨道灰色部分的透明度                           |                                                                                                                           |
|        hide_combo        |                              隐藏combo显示                               |                                                                                                                           |
|        changeskin        |                             修改当前显示皮肤                             |         取值范围为整数[0,3]<br>0~3分别代表正常，stopmotion，纯黑(entendnova)以及stargazer皮肤<br>*回调型gimmick*          |
|   unraveling_sidething   |                      生成unraveling stasis的冲击波                       |                                                      *回调型gimmick*                                                      |
|   astellion_sidething    |                          生成astellion的冲击波                           |                                                      *回调型gimmick*                                                      |
|   apocalypse_sidething   |                       生成apocalypse call的冲击波                        |                                                      *回调型gimmick*                                                      |
|      set_slash_col       |                          调整slash_anycol的颜色                          |                                               将hex颜色转为10进制后填入<br>                                               |
|       slash_anycol       |                 生成横向的slash，颜色由set_slash_col定义                 |                                                                                                                           |
|     slash_anycol_new     |            生成数个横向的slash，颜色由set_slash_col或val2定义            | val1不为\_时指定一次生成几个slash，填\_则按1记；<br> val2指定生成slash的颜色，为\_时使用set_slash_col<br>*回调型gimmick*  |
| slash_anycol_close_time  |                    控制slash_anycol的收束时间，单位秒                    |                                                          默认为1                                                          |
|       lr_slash_col       |                            调整lr_slash的颜色                            |                                               将hex颜色转为10进制后填入<br>                                               |
|         lr_slash         |          生成数个位于两侧的slash，颜色由lr_slash_col或val2定义           |      val1指定一次生成几个slash，为\_则按1记；<br> val2指定生成slash的颜色，为\_则使用lr_slash_col<br>*回调型gimmick*      |
|   lr_slash_close_time    |                      控制lr_slash的收束时间，单位秒                      |                                                          默认为1                                                          |
|      lr_sides_blue       |                  从两侧生成蓝色的类astellion的sidething                  |                                                      *回调型gimmick*                                                      |
|       lr_sides_red       |                  从两侧生成红色的类astellion的sidething                  |                                                      *回调型gimmick*                                                      |
|    lr_sides_rev_blue     |              从画面外侧向内生成蓝色的类astellion的sidething              |                                                      *回调型gimmick*                                                      |
|     lr_sides_rev_red     |              从画面外侧向内生成红色的类astellion的sidething              |                                                      *回调型gimmick*                                                      |
|       sc_firework        |                      生成一个烟花，从底部升空后爆开                      | val1指定上升持续拍数，填\_则按1拍记，0或负数立即爆开；<br> val2指定爆开的Y坐标，为\_时随机取整数20~90<br>*回调型gimmick*  |
|    sc_firework_color     |                         调整之后升空的烟花的颜色                         |    val1调整升空星星的颜色，val2调整爆开碎片的颜色，为\_则保持当前值；<br> 将hex颜色转为10进制后填入<br>*回调型gimmick*    |
| chorus_greenleft_overlay |                  将轨道覆盖层与note皮肤变为allison风格                   |       val1为起始强度，val2为终止强度，取值范围0~1；<br> 终止值填\_则直接切换为val1；<br> 渐变的时长由duration列控制       |
|      set_resolution      |                          调整房间渲染分辨率倍率                          | val2为倍率，取整后限制在1~8，填\_按1记；<br> 性能开销为倍率的平方（8倍即64倍像素），谱面结束时自动恢复<br>*回调型gimmick* |
|        sg_endblip        |                       生成stargazer结尾的闭幕特效                        |                                                      *回调型gimmick*                                                      |
|    sg_endblip_destroy    |                       销毁stargazer结尾的闭幕特效                        |                                                      *回调型gimmick*                                                      |


## 变速(SV)
这里的变速指om或其它音游内传统的允许不等距的变速。<br>
你需要做的是在谱面目录下创建```[难度].vsv```，如ENCORE难度就是```ENCORE.vsv```
之后每个变速语句之间用换行分开即可。现在支持的变速有这些：<br>
<br>
<br>

```
addVelo(time,velo)
```

这个语句作用是在指定位置添加一个速度。<br>
**time**：该速度所在的时间，单位ms<br>
**velo**：该速度的值<br>
<br>

```
addVeloTween(time,timeEnd,stVelo,edVelo{,easing,step})
```

这个语句作用是在指定位置添加一个速度补间。<br>
**time**：补间起始位置，单位ms<br>
**timeEnd**：补间结束位置，单位ms<br>
**stVelo**：起始速度<br>
**edVelo**：结束速度<br>
**easing**：补间使用的缓动，缓动格式同vsm的，可以不写，默认为linear<br>
**step**：补间的步长，可以不写，默认为32<br>



## legacy200 presentation extension

See `legacy200.md`: `uimode` (0 modern / 1 legacy200), `changeskin` skin 4, and independent `bgparticles200` (0 jacket mask / 1 plain particles). These controls are independent; skin 4 needs ENABLE_SKIN_CHANGE=true. No System Options entry is added.
