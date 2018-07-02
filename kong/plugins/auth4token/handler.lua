-- If you're not sure your plugin is executing, uncomment the line below and restart Kong
-- then it will throw an error which indicates the plugin is being loaded at least.

--assert(ngx.get_phase() == "timer", "The world is coming to an end!")


-- Grab pluginname from module name
local plugin_name = ({...})[1]:match("^kong%.plugins%.([^%.]+)")

-- load the base plugin object and create a subclass
local plugin = require("kong.plugins.base_plugin"):extend()

local responses = require "kong.tools.responses"

-- http client
local http = require("resty.http")

-- json
local json = require("json")

local function center_auth(config, token)

  local httpc = http.new()  
  local url = config.url
  local res, err = httpc:request_uri(url, {  
	  method = "GET",  
	  --args = str,  
	  --body = str,  
	  headers = {  
		  ["Content-Type"] = "application/json",  
		  ["Authorization"] = token,  
	  }  
  })

  if err then
	  ngx.log(ngx.ERR, "the center is not visit: ", err)
  else
	  if res.status == 200 then
		  body_struct = json.decode(res.body)

		  if body_struct.code == "200" then
			  return nil
		  end
	  else
		  ngx.log(ngx.ERR, "the center is error: ", res.status)
	  end
  end

  return "err"
end

-- constructor
function plugin:new()
  plugin.super.new(self, plugin_name)
  
  -- do initialization here, runs in the 'init_by_lua_block', before worker processes are forked

end

---------------------------------------------------------------------------------------------
-- In the code below, just remove the opening brackets; `[[` to enable a specific handler
--
-- The handlers are based on the OpenResty handlers, see the OpenResty docs for details
-- on when exactly they are invoked and what limitations each handler has.
--
-- The call to `.super.xxx(self)` is a call to the base_plugin, which does nothing, except logging
-- that the specific handler was executed.
---------------------------------------------------------------------------------------------


--[[ handles more initialization, but AFTER the worker process has been forked/created.
-- It runs in the 'init_worker_by_lua_block'
function plugin:init_worker()
  plugin.super.access(self)

  -- your custom code here
  
end --]]

--[[ runs in the ssl_certificate_by_lua_block handler
function plugin:certificate(plugin_conf)
  plugin.super.access(self)

  -- your custom code here
  
end --]]

--[[ runs in the 'rewrite_by_lua_block' (from version 0.10.2+)
-- IMPORTANT: during the `rewrite` phase neither the `api` nor the `consumer` will have
-- been identified, hence this handler will only be executed if the plugin is 
-- configured as a global plugin!
function plugin:rewrite(plugin_conf)
  plugin.super.rewrite(self)

  -- your custom code here
  
end --]]

---[[ runs in the 'access_by_lua_block'
function plugin:access(plugin_conf)
  plugin.super.access(self)

  -- your custom code here
  -- ngx.req.set_header("Hello-World", "this is on a request")

  local token = ngx.req.get_headers()["authorization"]
  if not token then
	  return responses.send(400, "Token has must.")
  else
	  local err = center_auth(plugin_conf, token)
	  if err then
		  return responses.send(401, "Authorization failure.")
	  end
  end

  
end --]]

---[[ runs in the 'header_filter_by_lua_block'
function plugin:header_filter(plugin_conf)
  plugin.super.access(self)

  -- your custom code here, for example;
  -- ngx.header["Bye-World"] = "this is on the response iioooiii"

end --]]

--[[ runs in the 'body_filter_by_lua_block'
function plugin:body_filter(plugin_conf)
  plugin.super.access(self)

  -- your custom code here
  
end --]]

--[[ runs in the 'log_by_lua_block'
function plugin:log(plugin_conf)
  plugin.super.access(self)

  -- your custom code here
  
end --]]


-- set the plugin priority, which determines plugin execution order
plugin.PRIORITY = 1000

-- return our plugin object
return plugin
