#!/usr/bin/env bash
#
# Display Sway window ids, workspaces and titles, switch to selection.

set -euo pipefail

swaymsg -t get_tree | jq -r '
# descend to workspace or scratchpad
.nodes[].nodes[]
# save workspace name as .w
| {"w": .name} + (
if .nodes then # workspace
    [recurse(.nodes[])]
else # scratchpad
    []
end
+ .floating_nodes
| .[]
# select nodes with no children (windows)
| select(.nodes==[])
)
| ((.id | tostring) + "\t "
# remove markup and index from workspace name, replace scratch with "[S]"
+ (.w | gsub("^[^:]*:|<[^>]*>"; "") | sub("__i3_scratch"; "[S]"))
+ "\t " +  .name)' | wofi -k /dev/null -i -d -p "Focus a window" | {
  read -r id _
  swaymsg -q "[con_id=$id]" focus
}
