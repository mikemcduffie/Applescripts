-- Does not work from Alfred NSAppleScript (possible sandbox issue)
-- Have Alfred run embedded scpt file

-- test site:    http://jsbin.com/reni/2

-- Alternate JS method failed on modal dialog
-- tell application "Safari" to do JavaScript "window.close()" in front document

tell application "Safari" to close front document