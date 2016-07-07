// Zenburn theme for chrome hterm / ssh
//
// Instructions:
// 1. open the options screen by clicking [Options] in a new window
// 2. Inspect Element to get a Javascript console
// 3. paste the whole script into the Inspect Element window.

var bad_windows_colors = {
  "0": "#3f3f3f",
  "1": "#af6464",
  "2": "#008000",
  "3": "#808000",
  "4": "#232333",
  "5": "#aa50aa",
  "6": "#00dcdc",
  "7": "#ccdcdc",
  "8": "#8080c0",
  "9": "#ffafaf",
  "10": "#7f9f7f",
  "11": "#d3d08c",
  "12": "#7071e3",
  "13": "#c880c8",
  "14": "#afdff0",
  "15": "#ffffff",
}

var urxvt_colors = {
  0: "#3f3f3f",
  1: "#cc9393",
  2: "#7f9f7f",
  3: "#d0bf8f",
  4: "#6ca0a3",
  5: "#dc8cc3",
  6: "#93e0e3",
  7: "#dcdccc",
  8: "#8A9D91",
  9: "#dca3a3",
  10: "#bfebbf",
  11: "#f0dfaf",
  12: "#8cd0d3",
  13: "#dc8cc3",
  14: "#93e0e3",
  15: "#ffffff",
}

var prefs = {
  "color-palette-overrides": urxvt_colors,
  "background-color": "#3a3a3a",
  "cursor-color": "#8faf9f",
  "foreground-color": "#dcdccc",
}

Object.keys(prefs).forEach(k => term_.prefs_.set(k, prefs[k]))
