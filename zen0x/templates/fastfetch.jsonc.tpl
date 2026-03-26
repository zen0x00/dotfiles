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
      "keyWidth": 10,
      "keyColor": "{{ fg0 }}"
    },

    { "type": "custom", "format": "" },

    {
      "type": "os",
      "key": "os  ",
      "keyColor": "{{ accent }}",
      "format": "{name}"
    },
    {
      "type": "kernel",
      "key": "ker ",
      "keyColor": "{{ accent }}"
    },
    {
      "type": "cpu",
      "format": "{1}",
      "key": "cpu ",
      "keyColor": "{{ green }}"
    },
    {
      "type": "gpu",
      "format": "{2}",
      "key": "gpu ",
      "keyColor": "{{ cyan }}"
    },
    {
      "type": "memory",
      "key": "ram ",
      "keyColor": "{{ purple }}"
    },
    {
      "type": "packages",
      "key": "pkgs",
      "keyColor": "{{ blue }}"
    },
    {
      "type": "wm",
      "key": "wm  ",
      "keyColor": "{{ accent }}"
    },
    {
      "type": "terminal",
      "key": "term",
      "keyColor": "{{ fg1 }}"
    },
    {
      "type": "uptime",
      "key": "up  ",
      "keyColor": "{{ yellow }}"
    },
    {
      "type": "battery",
      "key": "bat",
      "keyColor": "{{ red }}"
    },
    {
      "type": "command",
      "key": "age ",
      "keyColor": "{{ red }}",
      "text": "birth_install=$(stat -c %W /); current=$(date +%s); days_difference=$(( (current - birth_install) / 86400 )); echo $days_difference days"
    },

    "break",
    {
      "type": "custom",
      "format": "\u001b[33m󰮯 \u001b[32m󰊠 \u001b[34m󰊠 \u001b[31m󰊠 \u001b[36m󰊠 \u001b[35m󰊠 \u001b[37m󰊠 \u001b[97m󰊠"
    }
  ]
}
