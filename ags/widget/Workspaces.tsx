import { bind, Variable } from "astal"
import Hyprland from "gi://AstalHyprland?version=0.1"

const hypr = Hyprland.get_default()

function WorkspaceButton({ id }: { id: number }) {
  const classes = Variable.derive(
    [bind(hypr, "workspaces"), bind(hypr, "focusedWorkspace")],
    (ws, fw) => {
      const cls = ["workspace"]
      if (fw?.id === id) cls.push("active")
      else if (ws.some((w) => w.id === id)) cls.push("occupied")
      return cls
    },
  )

  return (
    <button
      cssClasses={classes()}
      onClicked={() => hypr.dispatch("workspace", String(id))}
      onDestroy={() => classes.drop()}
    >
      <label label={String(id)} />
    </button>
  )
}

export default function Workspaces() {
  return (
    <box cssClasses={["workspaces"]} spacing={0}>
      {[1, 2, 3, 4, 5, 6].map((id) => (
        <WorkspaceButton id={id} />
      ))}
    </box>
  )
}
