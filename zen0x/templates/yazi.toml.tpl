# vim:fileencoding=utf-8:foldmethod=marker

# : Manager {{{

[mgr]
cwd = { fg = "{{ cyan }}" }

find_keyword  = { fg = "{{ yellow }}", bold = true, italic = true, underline = true }
find_position = { fg = "{{ purple }}", bg = "reset", bold = true, italic = true }

marker_copied   = { fg = "{{ green }}", bg = "{{ green }}" }
marker_cut      = { fg = "{{ red }}", bg = "{{ red }}" }
marker_marked   = { fg = "{{ cyan }}", bg = "{{ cyan }}" }
marker_selected = { fg = "{{ yellow }}", bg = "{{ yellow }}" }

count_copied   = { fg = "{{ bg0 }}", bg = "{{ green }}" }
count_cut      = { fg = "{{ bg0 }}", bg = "{{ red }}" }
count_selected = { fg = "{{ bg0 }}", bg = "{{ yellow }}" }

border_symbol = "│"
border_style  = { fg = "{{ bg4 }}" }

# : }}}

# : Tabs {{{

[tabs]
active   = { fg = "{{ bg0 }}", bg = "{{ purple }}", bold = true }
inactive = { fg = "{{ purple }}", bg = "{{ bg2 }}" }

# : }}}

# : Mode {{{

[mode]
normal_main = { fg = "{{ bg0 }}", bg = "{{ purple }}", bold = true }
normal_alt  = { fg = "{{ purple }}", bg = "{{ bg2 }}" }

select_main = { fg = "{{ bg0 }}", bg = "{{ cyan }}", bold = true }
select_alt  = { fg = "{{ cyan }}", bg = "{{ bg2 }}" }

unset_main = { fg = "{{ bg0 }}", bg = "{{ yellow }}", bold = true }
unset_alt  = { fg = "{{ yellow }}", bg = "{{ bg2 }}" }

# : }}}

# : Status bar {{{

[status]
perm_sep   = { fg = "{{ bg4 }}" }
perm_type  = { fg = "{{ purple }}" }
perm_read  = { fg = "{{ yellow }}" }
perm_write = { fg = "{{ red }}" }
perm_exec  = { fg = "{{ green }}" }

progress_label  = { fg = "{{ fg0 }}", bold = true }
progress_normal = { fg = "{{ green }}", bg = "{{ bg3 }}" }
progress_error  = { fg = "{{ yellow }}", bg = "{{ red }}" }

# : }}}

# : Pick {{{

[pick]
border   = { fg = "{{ purple }}" }
active   = { fg = "{{ accent }}", bold = true }
inactive = {}

# : }}}

# : Input {{{

[input]
border   = { fg = "{{ purple }}" }
title    = {}
value    = {}
selected = { reversed = true }

# : }}}

# : Completion {{{

[cmp]
border = { fg = "{{ purple }}" }

# : }}}

# : Tasks {{{

[tasks]
border  = { fg = "{{ purple }}" }
title   = {}
hovered = { fg = "{{ accent }}", bold = true }

# : }}}

# : Which {{{

[which]
mask            = { bg = "{{ bg2 }}" }
cand            = { fg = "{{ cyan }}" }
rest            = { fg = "{{ fg2 }}" }
desc            = { fg = "{{ accent }}" }
separator       = "  "
separator_style = { fg = "{{ fg2 }}" }

# : }}}

# : Help {{{

[help]
on      = { fg = "{{ cyan }}" }
run     = { fg = "{{ accent }}" }
hovered = { reversed = true, bold = true }
footer  = { fg = "{{ bg2 }}", bg = "{{ fg0 }}" }

# : }}}

# : Spotter {{{

[spot]
border   = { fg = "{{ purple }}" }
title    = { fg = "{{ purple }}" }
tbl_col  = { fg = "{{ cyan }}" }
tbl_cell = { fg = "{{ accent }}", bg = "{{ bg3 }}" }

# : }}}

# : Notification {{{

[notify]
title_info  = { fg = "{{ green }}" }
title_warn  = { fg = "{{ yellow }}" }
title_error = { fg = "{{ red }}" }

# : }}}

# : File-specific styles {{{

[filetype]
rules = [
	{ mime = "image/*", fg = "{{ cyan }}" },
	{ mime = "{audio,video}/*", fg = "{{ yellow }}" },
	{ mime = "application/{zip,rar,7z*,tar,gzip,xz,zstd,bzip*,lzma,compress,archive,cpio,arj,xar,ms-cab*}", fg = "{{ accent }}" },
	{ mime = "application/{pdf,doc,rtf}", fg = "{{ green }}" },
	{ mime = "vfs/{absent,stale}", fg = "{{ fg2 }}" },
	{ url = "*", fg = "{{ fg0 }}" },
	{ url = "*/", fg = "{{ purple }}" },
]

# : }}}

[icon]
dirs = [
	{ name = ".config", text = "", fg = "{{ accent }}" },
	{ name = ".git", text = "", fg = "{{ cyan }}" },
	{ name = "Desktop", text = "", fg = "{{ cyan }}" },
	{ name = "Documents", text = "", fg = "{{ cyan }}" },
	{ name = "Downloads", text = "", fg = "{{ cyan }}" },
	{ name = "Music", text = "", fg = "{{ cyan }}" },
	{ name = "Pictures", text = "", fg = "{{ cyan }}" },
]

conds = [
	{ if = "orphan", text = "", fg = "{{ fg0 }}" },
	{ if = "link", text = "", fg = "{{ bg4 }}" },
	{ if = "block", text = "", fg = "{{ yellow }}" },
	{ if = "char", text = "", fg = "{{ yellow }}" },
	{ if = "fifo", text = "", fg = "{{ yellow }}" },
	{ if = "sock", text = "", fg = "{{ yellow }}" },

	{ if = "dir", text = "", fg = "{{ purple }}" },
	{ if = "exec", text = "", fg = "{{ green }}" },
	{ if = "!dir", text = "", fg = "{{ fg0 }}" },
]
