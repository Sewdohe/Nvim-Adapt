local ldbus = require "ldbus"
-- Create a message for the method call we want to make.
local ldbus = require "ldbus"
local conn = assert(ldbus.bus.get("session"))
assert(ldbus.bus.request_name(conn, "org.freedesktop.portal.Settings",
                              {replace_existing = true}))

local msg = assert(ldbus.message.new_method_call(
                       "org.freedesktop.portal.Desktop",
                       "/org/freedesktop/portal/desktop",
                       "org.freedesktop.portal.Settings", "Read"),
                   "Message Null")
local iter = ldbus.message.iter.new()
msg:iter_init_append(iter)

-- assert ( iter:append_basic ( {"org.freedesktop.appearance", "color-scheme"} ) , "Out of Memory" )
iter:append_basic("org.freedesktop.appearance")
iter:append_basic("color-scheme")

local reply = assert(conn:send_with_reply_and_block(msg))

-- here we have gotten the response from dbus.
-- the message is of type v (value) and idk what to do with it.
-- *fuck.*
assert(reply:iter_init(iter), "Message has no arguments")
local subiter = ldbus.message.iter.new()
assert(iter:recurse(subiter), "No recursable")
local sub_sub_iter = ldbus.message.iter.new()
assert(subiter:recurse(sub_sub_iter), "sub-iter not recursable")
local theme_value = sub_sub_iter:get_basic()
if theme_value == 0 then
    --   vim.o.background = "light"
    print("light")
elseif theme_value == 1 then
    --   vim.o.background = "dark"
    print("dark")
end
