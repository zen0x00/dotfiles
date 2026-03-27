"$schema" = "https://starship.rs/config-schema.json"

palette = "zen"

format = """
[](red)\
$os\
$username\
[](fg:red bg:bg1)\
$directory\
[](fg:bg1 bg:accent)\
$git_branch\
$git_status\
[](fg:accent bg:bg2)\
$c\
$rust\
$golang\
$nodejs\
$php\
$java\
$kotlin\
$haskell\
$python\
[](fg:bg2 bg:cyan)\
$conda\
[](fg:cyan bg:bg3)\
$time\
[](fg:bg3)\
$cmd_duration\
$line_break\
$character
"""

[os]
disabled = false
style = "bg:red fg:fg0"

[username]
show_always = true
style_user = "bg:red fg:fg0"
style_root = "bg:red fg:fg0"
format = "[ $user ]($style)"

[directory]
style = "bg:bg1 fg:fg0"
format = "[ $path ]($style)"
truncation_length = 3
truncation_symbol = "…/"

[git_branch]
symbol = ""
style = "bg:accent fg:bg0"
format = "[ $symbol $branch ]($style)"

[git_status]
style = "bg:accent fg:bg0"
format = "[($all_status$ahead_behind)]($style)"

[nodejs]
symbol = ""
style = "bg:bg2 fg:fg0"
format = "[ $symbol( $version) ]($style)"

[c]
symbol = ""
style = "bg:bg2 fg:fg0"
format = "[ $symbol( $version) ]($style)"

[rust]
symbol = ""
style = "bg:bg2 fg:fg0"
format = "[ $symbol( $version) ]($style)"

[golang]
symbol = ""
style = "bg:bg2 fg:fg0"
format = "[ $symbol( $version) ]($style)"

[python]
symbol = ""
style = "bg:bg2 fg:fg0"
format = "[ $symbol( $version)(\\(#$virtualenv\\)) ]($style)"

[conda]
symbol = ""
style = "bg:cyan fg:bg0"
format = "[ $symbol $environment ]($style)"
ignore_base = false

[time]
disabled = false
time_format = "%R"
style = "bg:bg3 fg:fg0"
format = "[  $time ]($style)"

[line_break]
disabled = true

[character]
success_symbol = "[❯](bold fg:green)"
error_symbol = "[❯](bold fg:red)"

[cmd_duration]
show_milliseconds = true
format = " $duration "
style = "fg:fg2"

[palettes.zen]
bg0 = "{{ bg0 }}"
bg1 = "{{ bg1 }}"
bg2 = "{{ bg2 }}"
bg3 = "{{ bg3 }}"
bg4 = "{{ bg4 }}"

fg0 = "{{ fg0 }}"
fg1 = "{{ fg1 }}"
fg2 = "{{ fg2 }}"

accent = "{{ accent }}"

red = "{{ red }}"
green = "{{ green }}"
yellow = "{{ yellow }}"
blue = "{{ blue }}"
cyan = "{{ cyan }}"
purple = "{{ purple }}"
