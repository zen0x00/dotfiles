{
  "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json",

  "logo": {
    "source": "~/.config/fastfetch/arch.txt",
    "height": 5,
    "width": 10,
    "color": {
      "1": "{{ accent }}",
      "2": "{{ cyan }}",
      "3": "{{ green }}",
      "4": "{{ purple }}"
    }
  },

  "display": {
    "separator": " ›  "
  },

  "modules": [
    { "type": "custom", "format": "" },

    {
      "type": "title",
      "key": "   Host",
      "keyColor": "{{ fg0 }}"
    },

    { "type": "custom", "format": "" },

    {
      "type": "os",
      "key": "   OS         ",
      "keyColor": "{{ accent }}"
    },
    {
      "type": "kernel",
      "key": "   Kernel     ",
      "keyColor": "{{ accent }}"
    },
    {
      "type": "cpu",
      "format": "{1}",
      "key": "   CPU        ",
      "keyColor": "{{ green }}"
    },
    {
      "type": "gpu",
      "format": "{2}",
      "key": "   GPU        ",
      "keyColor": "{{ cyan }}"
    },
    {
      "type": "memory",
      "key": "   Memory     ",
      "keyColor": "{{ purple }}"
    },
    {
      "type": "packages",
      "key": "  󰏗 Packages   ",
      "keyColor": "{{ blue }}"
    },
    {
      "type": "wm",
      "key": "   WM         ",
      "keyColor": "{{ accent }}"
    },
    {
      "type": "terminal",
      "key": "   Terminal   ",
      "keyColor": "{{ fg1 }}"
    },
    {
      "type": "uptime",
      "key": "   Uptime     ",
      "keyColor": "{{ yellow }}"
    },
    {
      "type": "battery",
      "key": "   Battery    ",
      "keyColor": "{{ red }}"
    },
    {
      "type": "command",
      "key": "  󰔟 OS Age     ",
      "keyColor": "{{ red }}",
      "text": "birth_install=$(stat -c %W /); current=$(date +%s); days_difference=$(( (current - birth_install) / 86400 )); echo $days_difference days"
    },

    "break"
  ]
}
