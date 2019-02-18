// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.

import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"
import $ from "jquery"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"
import game_init from "./reversi"
import socket from "./socket"


$(() => {
  let root = document.getElementById('root');
  if(root) {
    console.log(window.name);
    let channel = socket.channel("games: " + window.name, {});
    console.log("reached");
    game_init(root, channel, window.user);
  }
});
