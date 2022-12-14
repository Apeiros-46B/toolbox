# scripts
collection of shell scripts  
should be all posix-compliant

coreutils used are not listed under requirements

## ee
**e**dit **e**ncrypted  
edit an encrypted (`gpg` symmetric aes256) file with `$EDITOR`

### requirements
- `gpg`
- `file`
- `grep`
- `diff`
- `$EDITOR` environment variable set in your shell

### usage examples
- `ee file.norg` (unencrypted) - starts `$EDITOR` on `file.norg`
- `ee file.norg` (nonexistent) - starts `$EDITOR` on a temp file and encrypts it to `file.norg` after editor exit
- `ee file.norg` (encrypted) - decrypts to a temp file, opens temp file with `$EDITOR`, and re-encrypts to `file.norg` after editor exit

## fp
**f**ile **p**icker  
pick files with `fzf` (descending modification date) and open `dragon-drop` with them

### requirements
- `find`
- `sed`
- `grep`
- `fzf`
- `awk`
- `dragon-drop`
- an executable (previewer) in `$PATH` run on Ctrl+O, or provide a previewer through command-line arguments

### usage examples
- `fp` - opens fzf on the current directory and opens `dragon-drop` on selected files
- `fp dir/subdir '\.png$'` - opens fzf on the directory `dir/subdir` (excluding files matching the pattern `\.png$`) and opens `dragon-drop` on selected files
- `fp . '^$' previewer.sh` - opens fzf on the directory `.` (excluding nothing) with the previewer `previewer.sh` and opens `dragon-drop` on selected files

## ne
**n**eorg **e**xport  
export `.norg` files to other formats (most notably pdf) using `pandoc`

### requirements
*see `ne -h` for more info*

- `ps`
- `grep`
- `kill`
- `nvim` (with Neorg plugin)
- `sed`
- `pandoc`
- `lualatex`

### usage examples
*see `ne -h` for more info*

- `ne file.norg` - export `file.norg` as a pdf (default format)
- `ne file.norg -t pdf -f` - export `file.norg` as a pdf with formal mode on
- `ne file.norg -t latex -p ~/org/.util/preamble.tex` - export `file.norg` as a latex file with the preamble `~/org/.util/preamble.tex`

## qr
**qr** code  
scan qr codes with `flameshot` and `zbarimg` or create qr codes with `qrencode`

### requirements
- `qrencode`
- `flameshot`
- `zbarimg`
- `grep`

### usage examples
- `qr d` - use `flameshot` to select an area and decode qr with `zbarimg`
- `qr e -o test.png https://github.com/Apeiros-46B/scripts` - create a qr code in `test.png` with a link to this repository

## sm
**s**ed **m**ap  
use a `sed` expression and map a command to it with the original input as 1st argument and the result of the expression as 2nd argument

### requirements
- `sed`

### usage examples
- `sm 's/ /_/g' mv *` - replace ` ` with `_` in the names of the files matching the glob `*` (`test 1.txt` would be moved (`mv`) to `test_1.txt`)
- `sm 's/test// echo test1 test2 test3` - echo original filenames of `test1`, `test2`, and `test3` alongside with `1`, `2`, and `3` (filenames with `test` removed)

## tx
**t**oggle e**x**ecutable  
toggle executable status of a file, using `sudo` if necessary

### requirements
- `sudo`
- `chmod`

### usage examples
- `tx file.sh` - toggle executable bit on the file `file.sh`
- `tx file.sh` (not writable by current user) - toggle executable bit on the (not writable) file `file.sh`, with `sudo`

## xc
**xc**lip  
simplify pasting from x clipboard using `xclip`

### requirements
- `xclip`

### usage examples
- `xc test.txt` - paste the clipboard contents to `test.txt`
- `xc test.png image/png` - paste the clipboard contents as png image data to `test.png`

## yt
**y**ou**t**ube
simplify downloading videos from youtube using `yt-dlp`

### requirements
- `yt-dlp`

### usage examples
- `yt a mp3 <a youtube link>` - downloads youtube video as mp3 audio with best-available quality
- `yt v mov <a youtube link>` - downloads youtube video as mov video with best-available quality
