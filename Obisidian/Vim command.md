---
tags:
  - Vim
date: 2026-04-13
---
# 介绍
本篇笔记用来介绍Vim的常用指令，以及Obsidian中会用到的自定义指令，Vim指令和Obsidian指令会分开介绍



# Vim指令

" 上下左右移动
hjkl

" 将当前行移到页面中间
zz
“ 将当前行移动到屏幕顶部
zt
” 将当前行移动到屏幕底部
zb

# Obsidian指令

" 右键菜单
exmap contextMenu obcommand editor:context-menu
nmap zl :contextMenu<CR>

" 跳转链接命令
exmap followLink obommand editor:follow-link
nmap <C-q> :followink<CR>
kk
" 打开上一个标签页/
exmap back obcommand app:go-back
nmap <C-a> :back<CR>
" 打开下一个标签页/
exmap forward obcommand app:go-forward
nmap <C-d> :forward<CR>

" 搜索打开/创建笔记
exmap switchopen obcommand switcher:open
nmap go :switchopen<CR>

" 使用 Ctrl + w + 方向键导航
nmap <C-w>h :focusLeft<CR>
nmap <C-w>l :focusRight<CR>
nmap <C-w>j :focusBottom<CR>
nmap <C-w>k :focusTop<CR>

" 关闭工作区
exmap q obcommand workspace:close
nmap <leader>q :q<CR>        " 快速关闭
nmap <C-w>q :q<CR>           " 也支持传统关闭方式

" 标签页切换
exmap tabnext obcommand cycle-through-panes:cycle-through-panes
exmap tabprev obcommand cycle-through-panes:cycle-through-panes-reverse
nmap tl :tabnext<CR>         " 下一个标签页
nmap th :tabprev<CR>         " 上一个标签页