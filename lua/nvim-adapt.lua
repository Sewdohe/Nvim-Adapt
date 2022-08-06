local M = {}
local loop = vim.loop
Working = true
Process_pid = 0

M.init = function()
	GetDesktopValue()
end

GetDesktopValue = function()
	-- Create a message for the method call we want to make.
	local ldbus = require "ldbus"
	local conn = assert ( ldbus.bus.get ( "session" ) )
	assert ( ldbus.bus.request_name ( conn , "org.freedesktop.portal.Settings" , { replace_existing = true } ) )

	local clock = os.clock

	local function sleep(s)
		local ntime = os.time() + s
		repeat until os.time() > ntime
	end

	local msg = assert ( ldbus.message.new_method_call (
		"org.freedesktop.portal.Desktop",
		"/org/freedesktop/portal/desktop",
		"org.freedesktop.portal.Settings" ,
		"Read" ) , "Message Null" )
	local iter = ldbus.message.iter.new ( )
	msg:iter_init_append ( iter )

	-- assert ( iter:append_basic ( {"org.freedesktop.appearance", "color-scheme"} ) , "Out of Memory" )
	iter:append_basic("org.freedesktop.appearance")
	iter:append_basic("color-scheme")

	local reply = assert ( conn:send_with_reply_and_block ( msg ) )

	-- here we have gotten the response from dbus.
	-- the message is of type v (value) and idk what to do with it.
	-- *fuck.*
	assert ( reply:iter_init ( iter ) , "Message has no arguments" )
	local subiter = ldbus.message.iter.new ( )
	assert(iter:recurse(subiter), "No recursable")
	local sub_sub_iter = ldbus.message.iter.new ( )
	assert(subiter:recurse(sub_sub_iter), "sub-iter not recursable")
	local theme_value = sub_sub_iter:get_basic()

	if theme_value == 0 then
		vim.o.background = "light"
	elseif theme_value == 1 then
		vim.o.background = "dark"
	end
end

M.ctx = loop.new_work(function(v)
	-- Create a message for the method call we want to make.
	local ldbus = require "ldbus"
	local conn = assert ( ldbus.bus.get ( "session" ) )
	assert ( ldbus.bus.request_name ( conn , "org.freedesktop.portal.Settings" , { replace_existing = true } ) )

	local msg = assert ( ldbus.message.new_method_call (
		"org.freedesktop.portal.Desktop",
		"/org/freedesktop/portal/desktop",
		"org.freedesktop.portal.Settings" ,
		"Read" ) , "Message Null" )
	local iter = ldbus.message.iter.new ( )
	msg:iter_init_append ( iter )

	-- assert ( iter:append_basic ( {"org.freedesktop.appearance", "color-scheme"} ) , "Out of Memory" )
	iter:append_basic("org.freedesktop.appearance")
	iter:append_basic("color-scheme")

	local reply = assert ( conn:send_with_reply_and_block ( msg ) )

	-- here we have gotten the response from dbus.
	-- the message is of type v (value) and idk what to do with it.
	-- *fuck.*
	assert ( reply:iter_init ( iter ) , "Message has no arguments" )
	local subiter = ldbus.message.iter.new ( )
	assert(iter:recurse(subiter), "No recursable")
	local sub_sub_iter = ldbus.message.iter.new ( )
	assert(subiter:recurse(sub_sub_iter), "sub-iter not recursable")
	local theme_value = sub_sub_iter:get_basic()

	if theme_value == 0 then
		-- vim.o.background = "light"
		print('light')
	elseif theme_value == 1 then
		-- vim.o.background = "dark"
		print('dark')
	end
	
	-- local ldbus = require "ldbus"
	-- local conn = assert ( ldbus.bus.get ( "session" ) )

	-- local clock = os.clock

	-- local function sleep(s)
	-- 	local ntime = os.time() + s
	-- 	repeat until os.time() > ntime
	-- end

	-- -- I don't know why, but this assertion causes restarting the work thread to error saying
	-- -- it isn't the primary owner...not sure of the damages of disabling it as I don't understand it.
	-- assert ( ldbus.bus.request_name ( conn , "org.freedesktop.portal.Settings" , { replace_existing = true } ) )
	-- assert ( ldbus.bus.add_match ( conn , "type='signal',interface='org.freedesktop.portal.Settings'" ) )

	-- conn:flush ( )

	-- while conn:read_write ( 0 ) do
	-- 	local msg = conn:pop_message ( )
	-- 	if not msg then
	-- 		sleep(0.2)
	-- 	elseif msg:get_type ( ) == "signal" then
	-- 		local iter = ldbus.message.iter.new ( )
	-- 		assert ( msg:iter_init ( iter ) , "Message has no parameters" )
	-- 		assert ( iter:get_arg_type ( ) == ldbus.types.string , "Argument is not a string" )

	-- 		local val = iter:get_basic()
	-- 		if iter:next() then
	-- 			local secondVal = iter:get_basic()
	-- 		end
	-- 		if iter:next() then
	-- 			local subiter = ldbus.message.iter.new ( )
	-- 			iter:recurse(subiter)
	-- 			local theme_value = subiter:get_basic()
	-- 			if(theme_value == 0) then
	-- 				print("Light Mode Selected.")
	-- 				return 0
	-- 			elseif(theme_value == 1) then
	-- 				print("Dark Mode Selected")
	-- 				return 1
	-- 			end
	-- 		end
	-- 	end
	-- end
end, 	-- Using vim.schedule_wrap as per the docs:
			-- https://neovim.io/doc/user/lua.html
vim.schedule_wrap(function(v)
	if v == 1 then
		vim.o.background = "dark"
	elseif v == 0 then
		vim.o.background = "light"
	else
		print"error"
	end
	-- restart the work queue to wait for the next signal
	local handle = loop.queue_work(M.ctx)
end))

M.start_listen = function()
	-- queue the first listener instance. More instances will be made in the callback
	-- function of the worker thread
	loop.queue_work(M.ctx)
	loop.run('default')
	Process_pid = vim.loop.os_getpid()
end

M.init()
M.start_listen()

-- vim.api.nvim_create_autocmd("VimLeavePre", {
-- 	callback = function()
-- 		Working = false
-- 		print("closing")
-- 		-- vim.loop.close(Process_pid)
-- 		os.exit()
-- 	end
-- })