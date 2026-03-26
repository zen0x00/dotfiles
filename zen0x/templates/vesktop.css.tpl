@import url("https://refact0r.github.io/midnight-discord/build/midnight.css");

body {
  --font: "figtree";
  --code-font: "";
  font-weight: 400;
  --gap: 12px;
  --divider-thickness: 4px;
  --border-thickness: 1px;
  --animations: on;
  --list-item-transition: 0.2s ease;
  --dms-icon-svg-transition: 0.4s ease;
  --border-hover-transition: 0.2s ease;
  --top-bar-height: var(--gap);
  --top-bar-button-position: titlebar;
  --top-bar-title-position: off;
  --subtle-top-bar-title: off;
  --custom-window-controls: on;
  --window-control-size: 14px;
  --custom-dms-icon: custom;
  --dms-icon-svg-url: url("https://refact0r.github.io/midnight-discord/assets/Font_Awesome_5_solid_moon.svg");
  --dms-icon-svg-size: 90%;
  --dms-icon-color-before: var(--icon-subtle);
  --dms-icon-color-after: var(--white);
  --custom-dms-background: off;
  --dms-background-image-url: url("");
  --dms-background-image-size: cover;
  --dms-background-color: linear-gradient(
    70deg,
    var(--accent-2),
    var(--accent-5),
    var(--red)
  );
  --background-image: off;
  --background-image-url: url("");
  --transparency-tweaks: off;
  --remove-bg-layer: off;
  --panel-blur: off;
  --blur-amount: 12px;
  --bg-floating: var(--bg-3);
  --custom-chatbar: off;
  --chatbar-height: 47px;
  --small-user-panel: on;
}

:root {
  --colors: on;

  --text-0: {{ bg0 }};
  --text-1: {{ fg0 }};
  --text-2: {{ fg1 }};
  --text-3: {{ fg2 }};
  --text-4: {{ fg2 }};
  --text-5: {{ fg1 }};

  --bg-1: {{ bg0 }};
  --bg-2: {{ bg1 }};
  --bg-3: {{ bg2 }};
  --bg-4: {{ bg3 }};

  --hover: rgba({{ blue_rgb }}, 0.12);
  --active: rgba({{ blue_rgb }}, 0.25);
  --active-2: rgba({{ blue_rgb }}, 0.35);

  --message-hover: rgba({{ fg0_rgb }}, 0.03);

  --accent-1: {{ accent }};
  --accent-2: {{ blue }};
  --accent-3: {{ green }};
  --accent-4: {{ cyan }};
  --accent-5: {{ purple }};

  --accent-new: var(--accent-2);

  --mention: linear-gradient(
    to right,
    rgba({{ blue_rgb }}, 0.25) 40%,
    transparent
  );

  --mention-hover: linear-gradient(
    to right,
    rgba({{ blue_rgb }}, 0.35) 40%,
    transparent
  );

  --reply: linear-gradient(
    to right,
    rgba({{ fg0_rgb }}, 0.15) 40%,
    transparent
  );

  --reply-hover: linear-gradient(
    to right,
    rgba({{ fg0_rgb }}, 0.25) 40%,
    transparent
  );

  --online: {{ green }};
  --idle: {{ yellow }};
  --dnd: {{ red }};
  --streaming: {{ blue }};
  --offline: {{ fg2 }};

  --border-light: rgba({{ fg0_rgb }}, 0.05);
  --border: rgba({{ fg0_rgb }}, 0.08);
  --border-hover: rgba({{ fg0_rgb }}, 0.12);
  --button-border: rgba({{ fg0_rgb }}, 0.08);
}
