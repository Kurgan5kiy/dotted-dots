# Bar IPC contract

`bar_v1.reveal(output)` returns `{"version":1,"status":"accepted"}`. An empty output string reveals all selected bars; an exact output name reveals that bar when connected and selected. Bind a key in Niri to `dot-shell ipc call bar_v1 reveal ""` if keyboard reveal is wanted. The action does not alter configuration or focus.
