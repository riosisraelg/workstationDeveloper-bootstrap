" ============================================================
" ~/.vimrc - Configuración personal de Vim
" Autor: Israel
" Descripción: Configuración básica, visual, de indentación y productividad
" ============================================================

" ------------------------------------------------------------
" SECCIÓN 1: Apariencia y resaltado
" ------------------------------------------------------------

" Habilita el resaltado de sintaxis
syntax enable
syntax on

" Tema de color
colorscheme desert

" Muestra el número de línea
set number

" Muestra la posición del cursor (línea y columna)
set ruler

" Resalta la línea y columna donde está el cursor
set cursorline
set cursorcolumn

" Resalta resultados de búsqueda
set hlsearch

" Rompe las líneas largas (wrap)
set wrap

" ------------------------------------------------------------
" SECCIÓN 2: Identación y formato
" ------------------------------------------------------------

" Tamaño de tabulación (número de espacios por tab)
set tabstop=4

" Ancho de indentación automática
set shiftwidth=4

" Usa espacios en lugar de tabs
set expandtab

" Habilita auto-indentación básica e inteligente
set autoindent
set smartindent
set ai         " Auto indent
set si         " Smart indent

" Longitud máxima de línea antes de romper (linebreak)
set lbr
set tw=500

" Tipos de formato de archivo compatibles
set ffs=unix,dos,mac

" ------------------------------------------------------------
" SECCIÓN 3: Codificación y compatibilidad
" ------------------------------------------------------------

" Usa codificación UTF-8 por defecto
set encoding=utf8

" Detecta automáticamente el tipo de archivo y su indentación
filetype plugin indent on

" ------------------------------------------------------------
" SECCIÓN 4: Autocompletado y edición eficiente
" ------------------------------------------------------------

" Configuración del menú de autocompletado
set completeopt=menuone,noinsert,noselect
set omnifunc=syntaxcomplete#Complete

" Habilita menú de autocompletado al usar TAB
set wildmenu

" Modo de inserción rápido: 'jk' sale a modo normal
inoremap jk <Esc>

" ------------------------------------------------------------
" SECCIÓN 5: Personalización y detalles finales
" ------------------------------------------------------------

" Muestra el modo actual en la última línea
set showmode

" Desactiva copias de seguridad y archivos swap
set nobackup
set nowritebackup
set noswapfile

" ------------------------------------------------------------
" SECCIÓN: Plegado de código (folding) manual
" ------------------------------------------------------------

" Habilita folding manual
set foldmethod=indent

" Activa folding al abrir Vim
set foldenable

" Fin del archivo .vimrc
" ============================================================
```