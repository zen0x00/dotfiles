import { timeout, Variable, execAsync } from "astal"
import { App, Astal, Gdk } from "astal/gtk4"
import Wp from "gi://AstalWp?version=0.1"

const BRIGHTNESS_ICONS = ["󰃞", "󰃟", "󰃠"]
const VOLUME_ICONS = ["󰝟", "󰕿", "󰖀", "󰕾"]

function brightnessIcon(pct: number) {
  if (pct < 33) return BRIGHTNESS_ICONS[0]
  if (pct < 66) return BRIGHTNESS_ICONS[1]
  return BRIGHTNESS_ICONS[2]
}

function volumeIcon(pct: number, muted: boolean) {
  if (muted || pct === 0) return VOLUME_ICONS[0]
  if (pct < 33) return VOLUME_ICONS[1]
  if (pct < 66) return VOLUME_ICONS[2]
  return VOLUME_ICONS[3]
}

export default function Osd(monitor: Gdk.Monitor) {
  const icon = Variable("")
  const value = Variable(0)
  const visible = Variable(false)

  let hideTimer: ReturnType<typeof timeout> | null = null

  function show(ic: string, val: number) {
    icon.set(ic)
    value.set(Math.round(val))
    visible.set(true)
    if (hideTimer) hideTimer.cancel?.()
    hideTimer = timeout(1500, () => visible.set(false))
  }

  // Watch volume
  const speaker = Wp.get_default()?.audio?.defaultSpeaker
  if (speaker) {
    let lastVol = speaker.volume
    let lastMute = speaker.mute
    speaker.connect("notify::volume", () => {
      if (speaker.volume !== lastVol) {
        lastVol = speaker.volume
        show(volumeIcon(speaker.volume * 100, speaker.mute), speaker.volume * 100)
      }
    })
    speaker.connect("notify::mute", () => {
      if (speaker.mute !== lastMute) {
        lastMute = speaker.mute
        show(volumeIcon(speaker.volume * 100, speaker.mute), speaker.volume * 100)
      }
    })
  }

  // Watch brightness via polling
  async function getBrightness(): Promise<number> {
    try {
      const cur = parseFloat(await execAsync("brightnessctl get"))
      const max = parseFloat(await execAsync("brightnessctl max"))
      return (cur / max) * 100
    } catch { return -1 }
  }

  let lastBrightness = -1
  const brightnessPoller = Variable(0).poll(200, async () => {
    const pct = await getBrightness()
    if (pct >= 0 && Math.abs(pct - lastBrightness) > 0.5) {
      if (lastBrightness >= 0) show(brightnessIcon(pct), pct)
      lastBrightness = pct
    }
    return pct
  })

  return (
    <window
      cssClasses={["osd"]}
      name="zen0x-osd"
      namespace="zen0x-osd"
      gdkmonitor={monitor}
      application={App}
      visible={visible()}
      layer={Astal.Layer.OVERLAY}
      exclusivity={Astal.Exclusivity.IGNORE}
      keymode={Astal.Keymode.NONE}
      anchor={Astal.WindowAnchor.BOTTOM}
      marginBottom={48}
      onDestroy={() => brightnessPoller.drop()}
    >
      <box cssClasses={["osd-box"]} spacing={10}>
        <label cssClasses={["osd-icon"]} label={icon()} />
        <levelbar
          cssClasses={["osd-bar"]}
          value={value().as((v) => v / 100)}
          minValue={0}
          maxValue={1}
          widthRequest={160}
        />
        <label cssClasses={["osd-value"]} label={value().as((v) => `${v}%`)} />
      </box>
    </window>
  ) as Astal.Window
}
