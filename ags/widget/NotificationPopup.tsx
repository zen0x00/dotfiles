import { timeout } from "astal"
import { App, Astal, Gdk, Gtk } from "astal/gtk4"
import Notifd from "gi://AstalNotifd?version=0.1"

const notifd = Notifd.get_default()

function NotifWidget({ notif, onDismiss }: {
  notif: Notifd.Notification
  onDismiss: () => void
}) {
  return (
    <box cssClasses={["notif-popup"]} spacing={10}>
      {notif.appIcon ? (
        <image iconName={notif.appIcon} pixelSize={28} valign={Gtk.Align.START} />
      ) : <box />}
      <box vertical={true} spacing={2} hexpand={true}>
        <box>
          <label
            cssClasses={["notif-summary"]}
            label={notif.summary}
            halign={Gtk.Align.START}
            ellipsize={3}
            maxWidthChars={40}
            hexpand={true}
          />
          <button cssClasses={["notif-close"]} onClicked={() => { notif.dismiss(); onDismiss() }}>
            <label label="✕" />
          </button>
        </box>
        {notif.body ? (
          <label
            cssClasses={["notif-body"]}
            label={notif.body}
            halign={Gtk.Align.START}
            ellipsize={3}
            maxWidthChars={48}
            wrap={true}
            useMarkup={true}
          />
        ) : <box />}
      </box>
    </box>
  )
}

export default function NotificationPopup(monitor: Gdk.Monitor) {
  const popups: Map<number, Gtk.Widget> = new Map()
  let list: Gtk.Box

  const win = (
    <window
      cssClasses={["notif-popup-window"]}
      name="zen0x-notif-popup"
      namespace="zen0x-notif-popup"
      gdkmonitor={monitor}
      application={App}
      visible={false}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.NONE}
      anchor={Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT}
      marginTop={42}
      marginRight={8}
    >
      <box cssClasses={["notif-popup-list"]} vertical={true} spacing={6} setup={(self) => { list = self }} />
    </window>
  ) as Astal.Window

  function addPopup(id: number) {
    const notif = notifd.get_notification(id)
    if (!notif || notifd.dontDisturb) return

    function remove() {
      const w = popups.get(id)
      if (w) { list.remove(w); popups.delete(id) }
      if (popups.size === 0) win.visible = false
    }

    const widget = (<NotifWidget notif={notif} onDismiss={remove} />) as Gtk.Widget
    popups.set(id, widget)
    list.append(widget)
    win.visible = true

    const ms = notif.expireTimeout > 0 ? notif.expireTimeout : 5000
    timeout(ms, remove)
  }

  notifd.connect("notified", (_self, id: number) => addPopup(id))

  return win
}
