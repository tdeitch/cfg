set -Ux CODE_HOME $CODE_HOME
set -Ux EDITOR vim
set -Ux HOMEBREW_NO_AUTO_UPDATE 1

set -U fish_greeting
set -U fish_user_paths $BIN_HOME /usr/local/opt/node@8/bin

# Solarized dark
set -U fish_color_autosuggestion 586e75
set -U fish_color_cancel -r
set -U fish_color_command 93a1a1
set -U fish_color_comment 586e75
set -U fish_color_cwd green
set -U fish_color_cwd_root red
set -U fish_color_end 268bd2
set -U fish_color_error dc322f
set -U fish_color_escape 'bryellow'  '--bold'
set -U fish_color_history_current --bold
set -U fish_color_host normal
set -U fish_color_match --background=brblue
set -U fish_color_normal normal
set -U fish_color_operator bryellow
set -U fish_color_param 839496
set -U fish_color_quote 657b83
set -U fish_color_redirection 6c71c4
set -U fish_color_search_match 'bryellow'  '--background=brblack'
set -U fish_color_selection 'white'  '--bold'  '--background=brblack'
set -U fish_color_status red
set -U fish_color_user brgreen
set -U fish_color_valid_path --underline
set -U fish_pager_color_completion
set -U fish_pager_color_description 'B3A06D'  'yellow'
set -U fish_pager_color_prefix 'white'  '--bold'  '--underline'
set -U fish_pager_color_progress 'brwhite'  '--background=cyan'
