import GLib from "gi://GLib"
import { Variable } from "astal"

export default function Clock() {
  const time = Variable("").poll(
    1000,
    () => GLib.DateTime.new_now_local().format("%I:%M %p") ?? "",
  )

  const date = Variable("").poll(
    60000,
    () => GLib.DateTime.new_now_local().format("%A, %B %d") ?? "",
  )

  return (
    <label
      cssClasses={["clock"]}
      label={time()}
      tooltipText={date()}
      onDestroy={() => {
        time.drop()
        date.drop()
      }}
    />
  )
}
