import { bind } from "astal"
import { App, Astal, Gdk, Gtk } from "astal/gtk4"
import Notifd from "gi://AstalNotifd?version=0.1"

const notifd = Notifd.get_default()

function NotifItem({ notif }: { notif: Notifd.Notification }) {
  const time = new Date(notif.time * 1000)
  const hhmm = time.toLocaleTimeString([], { hour: "2-digit", minute: "2-digit" })

  return (
    <box cssClasses={["nc-item"]} spacing={10}>
      {notif.appIcon ? (
        <image iconName={notif.appIcon} pixelSize={18} valign={Gtk.Align.START} />
      ) : <box />}
      <box vertical={true} spacing={2} hexpand={true}>
        <box>
          <label
            cssClasses={["nc-summary"]}
            label={notif.summary}
            halign={Gtk.Align.START}
            ellipsize={3}
            maxWidthChars={32}
            hexpand={true}
          />
          <label cssClasses={["nc-time"]} label={hhmm} halign={Gtk.Align.END} />
        </box>
        {notif.body ? (
          <label
            cssClasses={["nc-body"]}
            label={notif.body}
            halign={Gtk.Align.START}
            ellipsize={3}
            maxWidthChars={40}
            wrap={true}
            useMarkup={true}
          />
        ) : <box />}
      </box>
      <button cssClasses={["nc-dismiss"]} onClicked={() => notif.dismiss()} valign={Gtk.Align.START}>
        <label label="✕" />
      </button>
    </box>
  )
}

export default function NotificationCenter(monitor: Gdk.Monitor) {
  const win = (
    <window
      cssClasses={["nc"]}
      name="zen0x-nc"
      namespace="zen0x-nc"
      gdkmonitor={monitor}
      application={App}
      visible={false}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.ON_DEMAND}
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT | Astal.WindowAnchor.BOTTOM}
      marginTop={41}
      marginRight={8}
      marginBottom={8}
    >
      <box cssClasses={["nc-box"]} vertical={true} vexpand={true}>
        <box cssClasses={["nc-header"]}>
          <label cssClasses={["nc-title"]} label="Notifications" halign={Gtk.Align.START} hexpand={true} />
          <button
            cssClasses={bind(notifd, "dontDisturb").as((dnd) =>
              dnd ? ["nc-dnd", "active"] : ["nc-dnd"]
            )}
            tooltipText="Do Not Disturb"
            onClicked={() => { notifd.dontDisturb = !notifd.dontDisturb }}
          >
            <label label={bind(notifd, "dontDisturb").as((dnd) => dnd ? "󰂛" : "󰂚")} />
          </button>
          <button
            cssClasses={["nc-clear"]}
            onClicked={() => notifd.notifications.forEach((n) => n.dismiss())}
          >
            <label label="Clear all" />
          </button>
        </box>
        <Gtk.ScrolledWindow cssClasses={["nc-scroll"]} vexpand={true} hscrollbarPolicy={2} vscrollbarPolicy={1}>
          <box vertical={true} spacing={4} cssClasses={["nc-list"]}>
            {bind(notifd, "notifications").as((notifs) =>
              notifs.length === 0
                ? [<label cssClasses={["nc-empty"]} label="No notifications" />]
                : [...notifs].reverse().map((n) => <NotifItem notif={n} />)
            )}
          </box>
        </Gtk.ScrolledWindow>
      </box>
    </window>
  ) as Astal.Window

  return win
}
