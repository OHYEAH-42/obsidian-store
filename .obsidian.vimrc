" ========================================
" Obsidian 专用 Vim 配置
" ========================================


" 基础导航优化
" 将 j/k 改为视觉行移动（处理自动换行）
nmap j gj
nmap k gk

" HJKL 增强导航
nmap H ^                    " 行首
nmap L $                    " 行尾
nmap J 5gj                  " 向下5行（视觉行）
nmap K 5gk                  " 向上5行（视觉行）

" 段落导航
nmap [ {                    " 上一段落
nmap ] }                    " 下一段落

" 复制粘贴优化
set clipboard=unnamed        " 使用系统剪贴板
nmap Y y$                    " 复制到行尾
nmap <leader>p "+p          " 从系统剪贴板粘贴
vmap <leader>y "+y          " 复制选中到剪贴板

" ========================================
" Obsidian 特定命令映射
" ========================================

" 右键菜单
exmap contextMenu obcommand editor:context-menu
nmap zl :contextMenu<CR>

" 标签页切换
exmap tabnext obcommand cycle-through-panes:cycle-through-panes
exmap tabprev obcommand cycle-through-panes:cycle-through-panes-reverse
nmap tl :tabnext<CR>         " 下一个标签页
nmap th :tabprev<CR>         " 上一个标签页
nmap tn :tabnew<CR>          " 新建标签页（需要添加）

" 工作区分割
exmap vsp obcommand workspace:split-vertical
exmap ssp obcommand workspace:split-horizontal
nmap <leader>v :vsp<CR>      " 垂直分割
nmap <leader>s :ssp<CR>      " 水平分割

" 工作区导航
exmap focusLeft obcommand editor:focus-left
exmap focusRight obcommand editor:focus-right
exmap focusBottom obcommand editor:focus-bottom
exmap focusTop obcommand editor:focus-top

" 使用 Ctrl + w + 方向键导航
nmap <C-w>h :focusLeft<CR>
nmap <C-w>l :focusRight<CR>
nmap <C-w>j :focusBottom<CR>
nmap <C-w>k :focusTop<CR>

" 使用 leader + 方向键导航（备选方案）
nmap <leader>h :focusLeft<CR>
nmap <leader>l :focusRight<CR>
nmap <leader>j :focusBottom<CR>
nmap <leader>k :focusTop<CR>

" 关闭工作区
exmap q obcommand workspace:close
nmap <leader>q :q<CR>        " 快速关闭
nmap <C-w>q :q<CR>           " 也支持传统关闭方式

" ========================================
" 折叠功能（Obsidian 标题折叠）
" ========================================
exmap unfoldall obcommand editor:unfold-all
exmap togglefold obcommand editor:toggle-fold
exmap foldall obcommand editor:fold-all

" 折叠快捷键
nmap zo :togglefold<CR>      " 切换折叠/展开
nmap zc :togglefold<CR>      " 兼容传统折叠键
nmap za :foldall<CR>         " 全部折叠
nmap zA :foldall<CR>         " 全部折叠（大写版本）
nmap zr :unfoldall<CR>       " 全部展开
nmap zR :unfoldall<CR>       " 全部展开（大写版本）

" 使用空格键切换折叠（可选）
nmap <space> :togglefold<CR>

" ========================================
" Surround 功能（文本包围）
" ========================================

" 定义包围命令
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
exmap surround_code surround ` `      " 行内代码
exmap surround_codeblock surround ``` ```  " 代码块

"在v模式下框选后，[[再输入回车即可实现wiki链接"
map [[ :surround_wiki
" 必须先解除 s 的默认映射
nunmap s
vunmap s

" 视觉模式下的包围命令
vmap s" :surround_double_quotes<CR>
vmap s' :surround_single_quotes<CR>
vmap s` :surround_backticks<CR>
vmap s( :surround_brackets<CR>
vmap s) :surround_brackets<CR>
vmap s[ :surround_square_brackets<CR>
vmap s] :surround_square_brackets<CR>
vmap s{ :surround_curly_brackets<CR>
vmap s} :surround_curly_brackets<CR>
vmap si :surround_italic<CR>
vmap sb :surround_bold<CR>
vmap sd :surround_delete<CR>
vmap sm :surround_mark<CR>
vmap s$ :surround_math<CR>
vmap sc :surround_code<CR>              " 行内代码
vmap sC :surround_codeblock<CR>         " 代码块

" ========================================
" 实用 Obsidian 命令
" ========================================


" 跳转链接命令
exmap followLink obcommand editor:follow-link
nmap <C-q> :followLink<CR>

" 打开上一个标签页/
exmap back obcommand app:go-back
nmap <C-a> :back<CR>
" 打开下一个标签页/
exmap forward obcommand app:go-forward
nmap <C-d> :forward<CR>

" 搜索打开/创建笔记
exmap switchopen obcommand switcher:open
nmap go :switchopen<CR>
