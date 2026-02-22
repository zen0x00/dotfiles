"$schema" = 'https://starship.rs/config-schema.json'

format = """
[](zen0x_red)\
$os\
$username\
[](bg:zen0x_orange fg:zen0x_red)\
$directory\
[](bg:zen0x_yellow fg:zen0x_orange)\
$git_branch\
$git_status\
[](fg:zen0x_yellow bg:zen0x_teal)\
$c\
$rust\
$golang\
$nodejs\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:zen0x_teal bg:zen0x_blue)\
$conda\
[](fg:zen0x_blue bg:zen0x_lavender)\
$time\
[ ](fg:zen0x_lavender)\
$cmd_duration\
$line_break\
$character"""

palette = 'zen0x'

[os]
disabled = false
style = "bg:zen0x_red fg:zen0x_bg_dark"

[username]
show_always = true
style_user = "bg:zen0x_red fg:zen0x_bg_dark"
style_root = "bg:zen0x_red fg:zen0x_bg_dark"
format = '[ $user]($style)'

[directory]
style = "bg:zen0x_orange fg:zen0x_bg_dark"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = ""
style = "bg:zen0x_yellow"
format = '[[ $symbol $branch ](fg:zen0x_bg_dark bg:zen0x_yellow)]($style)'

[git_status]
style = "bg:zen0x_yellow"
format = '[[($all_status$ahead_behind )](fg:zen0x_bg_dark bg:zen0x_yellow)]($style)'

[nodejs]
symbol = ""
style = "bg:zen0x_teal"
format = '[[ $symbol( $version) ](fg:zen0x_bg_dark bg:zen0x_teal)]($style)'

[c]
symbol = " "
style = "bg:zen0x_teal"
format = '[[ $symbol( $version) ](fg:zen0x_bg_dark bg:zen0x_teal)]($style)'

[rust]
symbol = ""
style = "bg:zen0x_teal"
format = '[[ $symbol( $version) ](fg:zen0x_bg_dark bg:zen0x_teal)]($style)'

[golang]
symbol = ""
style = "bg:zen0x_teal"
format = '[[ $symbol( $version) ](fg:zen0x_bg_dark bg:zen0x_teal)]($style)'

[python]
symbol = ""
style = "bg:zen0x_teal"
format = '[[ $symbol( $version)(\(#$virtualenv\)) ](fg:zen0x_bg_dark bg:zen0x_teal)]($style)'

[conda]
symbol = "  "
style = "fg:zen0x_bg_dark bg:zen0x_blue"
format = '[$symbol$environment ]($style)'
ignore_base = false

[time]
disabled = false
time_format = "%R"
style = "bg:zen0x_lavender"
format = '[[  $time ](fg:zen0x_bg_dark bg:zen0x_lavender)]($style)'

[character]
success_symbol = '[❯](bold fg:zen0x_teal)'
error_symbol = '[❯](bold fg:zen0x_red)'
vimcmd_symbol = '[❮](bold fg:zen0x_teal)'

[cmd_duration]
show_milliseconds = true
format = " in $duration "
style = "bg:zen0x_lavender"
disabled = false

[palettes.zen0x]

zen_red        = "{{ red }}"
zen_orange     = "{{ yellow }}"
zen_yellow     = "{{ yellow }}"
zen_teal       = "{{ cyan }}"
zen_blue       = "{{ blue }}"
zen_lavender   = "{{ purple }}"

zen_text       = "{{ fg0 }}"
zen_subtext    = "{{ fg2 }}"
zen_surface    = "{{ bg2 }}"
zen_bg         = "{{ bg1 }}"
zen_bg_dark    = "{{ bg0 }}"
