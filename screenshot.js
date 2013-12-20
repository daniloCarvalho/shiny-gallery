// Simple screenshot utility. Usage:
// phantomjs screenshot.js {url} {path-to-png}

var page = require('webpage').create();
var system = require('system');
page.viewportSize = { width: 910, height: 660 };
page.onLoadFinished = function(status) {
  page.clipRect = { left: 0, top: 0, width: 910, height: 660 };
  page.render(system.args[2]);
  phantom.exit();
};
page.open(system.args[1]);

