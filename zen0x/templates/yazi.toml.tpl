"$schema" = "https://yazi-rs.github.io/schemas/theme.json"

[flavor]
dark = ""
light = ""

[app]
overall = { bg = "{{ bg0 }}", fg = "{{ fg0 }}" }

[mgr]
cwd = { fg = "{{ accent }}" }

find_keyword  = { fg = "{{ yellow }}", bold = true, italic = true, underline = true }
find_position = { fg = "{{ red }}", bold = true }

symlink_target = { fg = "{{ fg1 }}", italic = true }

marker_copied   = { fg = "{{ bg0 }}", bg = "{{ cyan }}" }
marker_cut      = { fg = "{{ bg0 }}", bg = "{{ red }}" }
marker_marked   = { fg = "{{ bg0 }}", bg = "{{ blue }}" }
marker_selected = { fg = "{{ bg0 }}", bg = "{{ yellow }}" }

count_copied   = { fg = "{{ bg0 }}", bg = "{{ cyan }}" }
count_cut      = { fg = "{{ bg0 }}", bg = "{{ red }}" }
count_selected = { fg = "{{ bg0 }}", bg = "{{ yellow }}" }

border_symbol = "│"
border_style  = { fg = "{{ bg3 }}" }

[tabs]
active   = { fg = "{{ bg0 }}", bg = "{{ accent }}", bold = true }
inactive = { fg = "{{ fg1 }}", bg = "{{ bg1 }}" }

sep_inner = { open = "", close = "" }
sep_outer = { open = "", close = "" }

[mode]
normal_main = { fg = "{{ bg0 }}", bg = "{{ accent }}", bold = true }
normal_alt  = { fg = "{{ accent }}", bg = "{{ bg1 }}" }

select_main = { fg = "{{ bg0 }}", bg = "{{ red }}", bold = true }
select_alt  = { fg = "{{ red }}", bg = "{{ bg1 }}" }

unset_main = { fg = "{{ bg0 }}", bg = "{{ red }}", bold = true }
unset_alt  = { fg = "{{ red }}", bg = "{{ bg1 }}" }

[indicator]
parent  = { reversed = true }
current = { reversed = true }
preview = { underline = true }
padding = { open = "", close = "" }

[status]
overall = {}
sep_left  = { open = "", close = "" }
sep_right = { open = "", close = "" }

perm_sep   = { fg = "{{ fg2 }}" }
perm_type  = { fg = "{{ cyan }}" }
perm_read  = { fg = "{{ yellow }}" }
perm_write = { fg = "{{ red }}" }
perm_exec  = { fg = "{{ blue }}" }

progress_label  = { bold = true }
progress_normal = { fg = "{{ green }}", bg = "{{ bg0 }}" }
progress_error  = { fg = "{{ yellow }}", bg = "{{ red }}" }

[which]
cols      = 3
mask      = { bg = "{{ bg0 }}" }
cand      = { fg = "{{ accent }}" }
rest      = { fg = "{{ fg2 }}" }
desc      = { fg = "{{ yellow }}" }
separator = "  "
separator_style = { fg = "{{ fg2 }}" }

[confirm]
border  = { fg = "{{ accent }}" }
title   = { fg = "{{ accent }}" }
btn_yes = { reversed = true }
btn_no  = {}
btn_labels = ["  [Y]es  ", "  (N)o  "]

[notify]
title_info  = { fg = "{{ green }}" }
title_warn  = { fg = "{{ yellow }}" }
title_error = { fg = "{{ red }}" }

icon_info  = ""
icon_warn  = ""
icon_error = ""
