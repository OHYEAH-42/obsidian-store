> 本文由 [简悦 SimpRead](http://ksria.com/simpread/) 转码， 原文地址 [zhuanlan.zhihu.com](https://zhuanlan.zhihu.com/p/5267908580)

### 引言

vim 很好用，但是还是有一定的学习成本的，如果大家想尝试熟练之后绝对不会让你失望的，vim 可以极大的提高 [obsidian](https://zhida.zhihu.com/search?content_id=250075925&content_type=Article&match_order=1&q=obsidian&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NzM5Mjg3OTgsInEiOiJvYnNpZGlhbiIsInpoaWRhX3NvdXJjZSI6ImVudGl0eSIsImNvbnRlbnRfaWQiOjI1MDA3NTkyNSwiY29udGVudF90eXBlIjoiQXJ0aWNsZSIsIm1hdGNoX29yZGVyIjoxLCJ6ZF90b2tlbiI6bnVsbH0.3lsy8ppoHnDDIbK24UwCCD6hn1h-CperBpx2yRRiwaM&zhida_source=entity) 使用起来的流畅感

这篇可能是网上很少的中文 obsidian 的 vim 详细设置和参考的文章了，因为当时我自己设置的时候主要参考的是国外的博客，当然还有一个我心心念念很久的问题本文没有解决，就是无法设置 h j k l 在不同的聚焦情况下完全替代上下左右键，如果大家用过 vscode 可能知道我是什么意思，后续如果大家感兴趣我也可以写一篇 vscode 中如何配置 vim 配置文件来实现极其舒服的编程体验

本文提供的功能并不是所有 obsidian vim 所支持的功能，如果大家有更好的想法可以在评论区沟通，当 [vimrc](https://zhida.zhihu.com/search?content_id=250075925&content_type=Article&match_order=1&q=vimrc&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NzM5Mjg3OTgsInEiOiJ2aW1yYyIsInpoaWRhX3NvdXJjZSI6ImVudGl0eSIsImNvbnRlbnRfaWQiOjI1MDA3NTkyNSwiY29udGVudF90eXBlIjoiQXJ0aWNsZSIsIm1hdGNoX29yZGVyIjoxLCJ6ZF90b2tlbiI6bnVsbH0.T5Eck5kShD9IfV3gL205w4ghN55gtrpa5nVaDQcHsdA&zhida_source=entity) 插件发生更新导致配置不能使用时我也会第一时间更新的，因为我自己每天也在高强度的使用

### 1. vim 及 vimrc 介绍

Vim 其实是 UNIX 系统上 Vi 的扩展版本，主要用于编辑程序和纯文本文件（Markdown），基本可以实现所有命令都用键盘操作，可以脱离鼠标专心内容，还可以根据自己需求自定义按键

由于 Vim 真的很好用，不同的软件都有相应的内置功能来实现类似 Vim 的操作，在 Obsidian 中就有内置的 [Vim key bindings](https://zhida.zhihu.com/search?content_id=250075925&content_type=Article&match_order=1&q=Vim+key+bindings&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NzM5Mjg3OTgsInEiOiJWaW0ga2V5IGJpbmRpbmdzIiwiemhpZGFfc291cmNlIjoiZW50aXR5IiwiY29udGVudF9pZCI6MjUwMDc1OTI1LCJjb250ZW50X3R5cGUiOiJBcnRpY2xlIiwibWF0Y2hfb3JkZXIiOjEsInpkX3Rva2VuIjpudWxsfQ.aDpxRqSyLdNpaa5v9cP1dUE1zcYPi7zcQgOl_9X0X3k&zhida_source=entity)，还有对应的插件 [Vimrc Support](https://zhida.zhihu.com/search?content_id=250075925&content_type=Article&match_order=1&q=Vimrc+Support&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NzM5Mjg3OTgsInEiOiJWaW1yYyBTdXBwb3J0IiwiemhpZGFfc291cmNlIjoiZW50aXR5IiwiY29udGVudF9pZCI6MjUwMDc1OTI1LCJjb250ZW50X3R5cGUiOiJBcnRpY2xlIiwibWF0Y2hfb3JkZXIiOjEsInpkX3Rva2VuIjpudWxsfQ.ExbeYZARmAonRFrDrHmHnwc5KkEeLU46riFH7A_rnv8&zhida_source=entity) 可以添加一些其它的功能

### 2. 开启 Obsidian 内置的 Vim

1.  使用 `cmd + ,` 或者 `ctrl + ,` 打开 obsidian 的设置，或者按照下图点击对应的设置

![](https://pic2.zhimg.com/v2-8be4e82533d141a1a0f3f1dd4bca9429_r.jpg)

2. 打开设置后点击 Editor 然后划到最下面打开 Vim key bindings 如下图

![](https://pic3.zhimg.com/v2-4c31bc19f36e0c9cf45344448240c392_r.jpg)

3. 打开后会出现提示框来保证你会用 Vim 这里要求输入退出并不保存的命令，对应 `:q` 如下图

![](https://pic1.zhimg.com/v2-5a1f78c6188cf04c7697eef07dc5445c_r.jpg)

4. 打开后需要掌握常见的 vim 操作命令，请参考 [vim 常见操作](https://link.zhihu.com/?target=https%3A//blog.csdn.net/zhang_yu_ling/article/details/103777714%3Ffromshare%3Dblogdetail%26sharetype%3Dblogdetail%26sharerId%3D103777714%26sharerefer%3DPC%26sharesource%3Dweixin_44370439%26sharefrom%3Dfrom_link)

### 3. vimrc 插件的获取和安装

为了让开启了 vim 的 obsidian 更好用，可以安装 Vimrc Support 插件，安装步骤参考 [Obsidian 插件安装教程](https://zhuanlan.zhihu.com/p/4948327074)，本文同样提供了对应的插件文件，搜索公众号 <文件夹的知识圈> 回复 < 插件下载 > 即可，需要下载文件中的 obsidian-vimrc-support 压缩包和对应的 .obsidian

### 4. vimrc 插件的设置

对 vimrc 进行配置，接下来的内容包括每一项的介绍和建议配置，

1.  vimrc 快捷键配置文件，在 4 小节进行进一步配置，后面框中内容填写的是快捷键配置文档的名称，默认在仓库文件夹下，如果有更改需要重启

![](https://pica.zhimg.com/v2-9a8bb3328c556dc1a198642ad0ba4596_r.jpg)

2. 显示没有完成的 vim 命令，建议开启。因为有一些命令比较复杂需要看到输入的按键是否正确

![](https://pic4.zhimg.com/v2-04d0b6a103f3887f9f36eb6a6f16c75f_r.jpg)

没有开启的时候，进行移动和其它命令右下角是没有任何显示的

![](https://pic1.zhimg.com/v2-12c24f8aecf9484f39c779f317bb43d2_1440w.jpg)

开启后在最左侧会有对应命令的提示

![](https://pica.zhimg.com/v2-8b6b6dad54f671c22657fc2ddf83dd5c_1440w.jpg)

3. 显示当前 vim 所处的模式（建议开启）

开启后会在最右侧显示当前 vim 当前所处的模式

![](https://picx.zhimg.com/v2-49868515ada55e140a6685fce17ddfed_1440w.jpg)

显示的样式可以在设置的最后面自定义设置，可以照抄我的设置

![](https://picx.zhimg.com/v2-6793537d1c277d0eda0f1af2aa7ad4bf_r.jpg)

4. 固定当前键盘布局，有的语言的键盘上没有对应 vim 的按键所以需要，大部分人不需要设置

![](https://pic2.zhimg.com/v2-56ff301b583f325049ae6efefbf7e313_r.jpg)

5. 支持 JS 命令，这个我没有用到过，帮助文档中提到这个是将 vim 命令映射到 JavaScript 代码片段的，如果有人了解可以在下面评论分享

![](https://pic3.zhimg.com/v2-ce149d10f5aa4890080e59ca6127b5a2_r.jpg)

### 5. vimrc 配置文件的设置

接下来对 vimrc 的自定义配置文件进行配置和说明，这里基本上是我用到的快捷键设置

1.  首先需要在仓库文件夹下创建一个名为 `.obsidian.vimrc` 的文件，详见下图，然后右键选中打开方式使用文本文档打开

![](https://pic1.zhimg.com/v2-62e6aad7ff5469389c9a85a8823cd176_1440w.jpg)

2. 将附件中的文本粘贴到文件中，保存然后重启 obsidian 即可。下面会依次介绍对应的效果以观察是否配置成功

```
" 将数字上的 j 和 k 改为视觉
nmap j gj
nmap k gk

```

如果配置成功，对应的效果为光标从 “文” 依次垂直到 " 是“和“示”，如果没配置成功

![](https://pic2.zhimg.com/v2-e5ba2a12f02c056a40735957b16e6c2f_r.jpg)

```
" HJKL 实现更大范围的 hjkl
nmap H ^
nmap L $
nmap J 6gj
nmap K 6gk

```

这个可以根据自己的喜好设置，这样设置的结果是当 normal 模式下按下大小的 L 、H 和 J、K 会有一个更大范围的光标跳转

```
" 访问系统剪切板
set clipboard=unnamed

```

这个**一定要设置**，如果不设置的话就无法通过 ob 中 vim 的 y 和 p 实现将文本复制到别的地方或者从别的地方复制到 ob

```
" 移动到下一段落
nmap [ {
nmap ] }

```

上面设置过视觉上的 j 和 k，这个可以通过 `[ {` 和 `] }` 来实现段落之间的上下跳转

```
" 复制整行
nmap Y y$

```

正常在 vim 中可以通过 `y$` 实现复制整行，这样可以直接通过大写的 Y 来实现同样的功能

```
" 打开文本编辑菜单 = 鼠标右键
exmap contextMenu obcommand editor:context-menu
nmap zl :contextMenu<CR>

```

这个命令模拟的是鼠标在文本区右键的功能，当直接在 normal 模式下接连按下 `z` 和 `l` 后就会出现下图

![](https://picx.zhimg.com/v2-334011b9d04e17c7901d0f4b2ada56d7_1440w.jpg)

```
" 实现括号的surrend功能 
exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_backticks surround ` `
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }
exmap surround_italic surround * *
exmap surround_bold surround ** **
exmap surround_delete surround ~~ ~~
exmap surround_mark surround == ==
exmap surround_math surround $ $

" 必须使用 'map'
map [[ :surround_wiki
nunmap s
vunmap s
map s" :surround_double_quotes<CR>
map s' :surround_single_quotes<CR>
map s` :surround_backticks<CR>
map sb :surround_brackets<CR>
map s( :surround_brackets<CR>
map s) :surround_brackets<CR>
map s[ :surround_square_brackets<CR>
map s] :surround_square_brackets<CR>
map s{ :surround_curly_brackets<CR>
map s} :surround_curly_brackets<CR>
map si :surround_italic<CR>
map sb :surround_bold<CR>
map sd :surround_delete<CR>
map sm :surround_mark<CR>
map s$ :surround_math<CR>

```

这个功能很好用，建议一定要设置，可以在 visual 模式下快速的给一段文字的两边加上符号，操作的方法为：按 ESC 进入 normal 模式 -> 按 V + hjkl 移动键选中想要圈起来的文本 -> 键入 s -> 键入对应的符号（比如上面的 `s"` 就是键入 `"`）步骤如下图

![](https://pic1.zhimg.com/v2-d6718475d251e1c47b3b25e83154b64e_1440w.jpg)

选中后连贯的依次按 `s"` 会变成

![](https://pica.zhimg.com/v2-620179cff761027c3d61a81b54c4961e_1440w.jpg)

成功的在文本的左右加上 `"` ，可以依次尝试其它的

```
" 使用th和tl实现tab的切换 
exmap tabnext obcommand cycle-through-panes:cycle-through-panes
nmap tl :tabnext<CR>
exmap tabprev obcommand cycle-through-panes:cycle-through-panes-reverse
nmap th :tabprev<CR>

```

这个可以实现 tab 页的切换，但是需要首先安装 [Tab Switcher](https://zhida.zhihu.com/search?content_id=250075925&content_type=Article&match_order=1&q=Tab+Switcher&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NzM5Mjg3OTgsInEiOiJUYWIgU3dpdGNoZXIiLCJ6aGlkYV9zb3VyY2UiOiJlbnRpdHkiLCJjb250ZW50X2lkIjoyNTAwNzU5MjUsImNvbnRlbnRfdHlwZSI6IkFydGljbGUiLCJtYXRjaF9vcmRlciI6MSwiemRfdG9rZW4iOm51bGx9.0Yvrf1nu4FlJBBgXqN-HL8jD1TLZ8pYHkA2eQLemrEU&zhida_source=entity) 插件原名为 cycle through panes，如果之前安装过 cycle through panes 不需要再进行额外的设置了，安装步骤参考 [[Obsidian 插件安装教程]]，本文同样提供了对应的插件下载，请搜索公众号 < 文件夹的知识圈 > 并回复 < 插件下载 > 在打开链接的文件夹中选择 `cycle-through-panes` 对，你没有看错这就是最新版的 Tab Switcher，通过官方社区下载的时候需要搜索 Tab Sitcher，下载完成后在 `.obsidian/plugins` 下的名字还是 `cycle-through-panes`

ps: 这里可能有同学会疑问，为什么 Tab Switcher 本身已经提供了标签页切换了还需要设置，其实就是为了在出现按键冲突的时候提供了一个选择，可以根据自己的习惯选择

Tab Switcher 的设置只需要将下图的设置关掉就可以使用 `tb` 和 `tl` 来进行 tab 的切换

![](https://pic1.zhimg.com/v2-cec24521f709969356c0b61eb3872e46_r.jpg)

```
" 实现工作区的分割
exmap vsp obcommand workspace:split-vertical
" 实现工作区的纵向分割
exmap ssp obcommand workspace:split-horizontal

```

实现的功能和直接拖动笔记分割屏幕的效果一样，注意这里的命令需要在 `Normal` 模式下通过依次键入 `:vsp` 然后回车实现

```
" 聚焦
exmap focusLeft obcommand editor:focus-left
exmap focusRight obcommand editor:focus-right
exmap focusBottom obcommand editor:focus-bottom
exmap focusTop obcommand editor:focus-top
nmap <C-w>h :focusLeft<CR>
nmap <C-w>l :focusRight<CR>
nmap <C-w>j :focusBottom<CR>
nmap <C-w>k :focusTop<CR>

```

当将编辑区分成下面的情况时，可以首先按下组合键 `ctrl + w`，然后松手再按下对应的 `h j k l` 来实现编辑区的左、下、右和上的无感切换，结合上 `ctrl + o` 快捷键和上面的垂直和水平划分编辑区，简直不要太好用

注意，如果这里出现了按下 `ctrl + w` 当前 tab 页直接关闭，可以在设置处将快捷键为 `ctrl + w` 的 `close current tab` 换成 `ctrl + d` 后续会出一个快捷键设置的文章来避免这种问题，也可以使用后面的 `:q` 关闭当前 tab 页把对应的快捷键删除

![](https://picx.zhimg.com/v2-2edb9054bb28bd03138178ea4b3eddeb_r.jpg)

```
" 关闭工作区
exmap q obcommand workspace:close

```

通过在 `Normal` 模式下键入 `:q` 来模拟 `close current tab` 功能

```
" 模拟折叠标题的功能
exmap unfoldall obcommand editor:unfold-all
exmap togglefold obcommand editor:toggle-fold
exmap foldall obcommand editor:fold-all
nmap zo :togglefold<CR>
nmap za :foldall<CR>
nmap zr :unfoldall<CR>

```

使用方法为依次键入 `zo` 其中 `zo` 是折叠当前标题下的内容，如果已经折叠则是取消折叠，`za` 是折叠所有的标题，`zr` 是展开所有的标题

### 附件

```
" 将数字上的 j 和 k 改为视觉
nmap j gj
nmap k gk

" HJKL 实现更大范围的 hjkl
nmap H ^
nmap L $
nmap J 6gj
nmap K 6gk

" 访问系统剪切板
set clipboard=unnamed

" 移动到下一段落
nmap [ {
nmap ] }

" 复制整行
nmap Y y$

" 打开文本编辑菜单 = 鼠标右键
exmap contextMenu obcommand editor:context-menu
nmap zl :contextMenu<CR>

" 实现括号的surrend功能 
exmap surround_wiki surround [[ ]]
exmap surround_double_quotes surround " "
exmap surround_single_quotes surround ' '
exmap surround_backticks surround ` `
exmap surround_brackets surround ( )
exmap surround_square_brackets surround [ ]
exmap surround_curly_brackets surround { }
exmap surround_italic surround * *
exmap surround_bold surround ** **
exmap surround_delete surround ~~ ~~
exmap surround_mark surround == ==
exmap surround_math surround $ $

- [ ] " 必须使用 'map'
map [[ :surround_wiki
nunmap s
vunmap s
map s" :surround_double_quotes<CR>
map s' :surround_single_quotes<CR>
map s` :surround_backticks<CR>
map sb :surround_brackets<CR>
map s( :surround_brackets<CR>
map s) :surround_brackets<CR>
map s[ :surround_square_brackets<CR>
map s] :surround_square_brackets<CR>
map s{ :surround_curly_brackets<CR>
map s} :surround_curly_brackets<CR>
map si :surround_italic<CR>
map sb :surround_bold<CR>
map sd :surround_delete<CR>
map sm :surround_mark<CR>
map s$ :surround_math<CR>


" 使用th和tl实现tab的切换 
exmap tabnext obcommand cycle-through-panes:cycle-through-panes
nmap tl :tabnext<CR>
exmap tabprev obcommand cycle-through-panes:cycle-through-panes-reverse
nmap th :tabprev<CR>

" 实现工作区的横向分割
exmap vsp obcommand workspace:split-vertical
" 实现工作区的纵向分割
exmap ssp obcommand workspace:split-horizontal

" 聚焦
exmap focusLeft obcommand editor:focus-left
exmap focusRight obcommand editor:focus-right
exmap focusBottom obcommand editor:focus-bottom
exmap focusTop obcommand editor:focus-top
nmap <C-w>h :focusLeft<CR>
nmap <C-w>l :focusRight<CR>
nmap <C-w>j :focusBottom<CR>
nmap <C-w>k :focusTop<CR>

" 关闭工作区
exmap q obcommand workspace:close

" 模拟折叠标题的功能
exmap unfoldall obcommand editor:unfold-all
exmap togglefold obcommand editor:toggle-fold
exmap foldall obcommand editor:fold-all
nmap zo :togglefold<CR>
nmap za :foldall<CR>
nmap zr :unfoldall<CR>

```