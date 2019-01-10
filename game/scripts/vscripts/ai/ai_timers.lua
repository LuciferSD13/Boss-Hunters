TIMERS_VERSION = "1.05"

--[[
  -- A timer running every second that starts immediately on the next frame, respects pauses
  AITimers:CreateTimer(function()
      print ("Hello. I'm running immediately and then every second thereafter.")
      return 1.0
    end
  )
  -- The same timer as above with a shorthand call 
  AITimers(function()
    print ("Hello. I'm running immediately and then every second thereafter.")
    return 1.0
  end)
  
  -- A timer which calls a function with a table context
  AITimers:CreateTimer(GameMode.someFunction, GameMode)
  -- A timer running every second that starts 5 seconds in the future, respects pauses
  AITimers:CreateTimer(5, function()
      print ("Hello. I'm running 5 seconds after you called me and then every second thereafter.")
      return 1.0
    end
  )
  -- 10 second delayed, run once using gametime (respect pauses)
  AITimers:CreateTimer({
    endTime = 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      print ("Hello. I'm running 10 seconds after when I was started.")
    end
  })
  -- 10 second delayed, run once regardless of pauses
  AITimers:CreateTimer({
    useGameTime = false,
    endTime = 10, -- when this timer should first execute, you can omit this if you want it to run first on the next frame
    callback = function()
      print ("Hello. I'm running 10 seconds after I was started even if someone paused the game.")
    end
  })
  -- A timer running every second that starts after 2 minutes regardless of pauses
  AITimers:CreateTimer("uniqueTimerString3", {
    useGameTime = false,
    endTime = 120,
    callback = function()
      print ("Hello. I'm running after 2 minutes and then every second thereafter.")
      return 1
    end
  })
  -- A timer using the old style to repeat every second starting 5 seconds ahead
  AITimers:CreateTimer("uniqueTimerString3", {
    useOldStyle = true,
    endTime = GameRules:GetGameTime() + 5,
    callback = function()
      print ("Hello. I'm running after 5 seconds and then every second thereafter.")
      return GameRules:GetGameTime() + 1
    end
  })
]]



TIMERS_THINK = 0.01

if AITimers == nil then
  print ( '[AITimers] creating AITimers' )
  AITimers = {}
  setmetatable(AITimers, {
    __call = function(t, ...)
      return t:CreateTimer(...)
    end
  })
  --AITimers.__index = AITimers
end

function AITimers:start()
  AITimers = self
  self.timers = {}
  
  --local ent = Entities:CreateByClassname("info_target") -- Entities:FindByClassname(nil, 'CWorld')
  local ent = SpawnEntityFromTableSynchronous("info_target", {targetname="ai_thinker"})
  ent:SetThink("Think", self, "timers", TIMERS_THINK)
end

function AITimers:Think()
	--if GameRules:State_Get() >= DOTA_GAMERULES_STATE_POST_GAME then
	--return
	--end
	local AIThink = function(self)
		-- Track game time, since the dt passed in to think is actually wall-clock time not simulation time.
		local now = GameRules:GetGameTime()

		-- Process timers
		for k,v in pairs(AITimers.timers) do
			local bUseGameTime = true
			if v.useGameTime ~= nil and v.useGameTime == false then
			  bUseGameTime = false
			end
			local bOldStyle = false
			if v.useOldStyle ~= nil and v.useOldStyle == true then
			  bOldStyle = true
			end

			local now = GameRules:GetGameTime()
			if not bUseGameTime then
			  now = Time()
			end

			if v.endTime == nil then
			  v.endTime = now
			end
			-- Check if the timer has finished
			if now >= v.endTime then
			  -- Remove from timers list
			  AITimers.timers[k] = nil

			  AITimers.runningTimer = k
			  AITimers.removeSelf = false
			  
			  -- Run the callback
			  local status = true
			  local nextCall
			  if v.context then
				nextCall = v.callback(v.context, v)
			  else
				nextCall = v.callback(v)
			  end

			  AITimers.runningTimer = nil

			  -- Make sure it worked
			  if status then
				-- Check if it needs to loop
				if nextCall and not AITimers.removeSelf then
				  -- Change its end time

				  if bOldStyle then
					v.endTime = v.endTime + nextCall - now
				  else
					v.endTime = v.endTime + nextCall
				  end

				  AITimers.timers[k] = v
				end

				-- Update timer data
				--self:UpdateTimerData()
			  else
				-- Nope, handle the error
				AITimers:HandleEventError('Timer', k, nextCall)
			  end
			end
		end
	end
	status, err, ret = xpcall(AIThink, debug.traceback, self, fPrep )
	if not status then
		print(err)
	end
	return TIMERS_THINK
end

function AITimers:HandleEventError(name, event, err)
  print(err)

  -- Ensure we have data
  name = tostring(name or 'unknown')
  event = tostring(event or 'unknown')
  err = tostring(err or 'unknown')

  -- Tell everyone there was an error
  --Say(nil, name .. ' threw an error on event '..event, false)
  --Say(nil, err, false)

  -- Prevent loop arounds
  if not self.errorHandled then
    -- Store that we handled an error
    self.errorHandled = true
  end
end

function AITimers:CreateTimer(name, args, context)
  if type(name) == "function" then
    if args ~= nil then
      context = args
    end
    args = {callback = name}
    name = DoUniqueString("timer")
  elseif type(name) == "table" then
    args = name
    name = DoUniqueString("timer")
  elseif type(name) == "number" then
    args = {endTime = name, callback = args}
    name = DoUniqueString("timer")
  end
  if not args.callback then
    print("Invalid timer created: "..name)
    return
  end


  local now = GameRules:GetGameTime()
  if args.useGameTime ~= nil and args.useGameTime == false then
    now = Time()
  end

  if args.endTime == nil then
    args.endTime = now
  elseif args.useOldStyle == nil or args.useOldStyle == false then
    args.endTime = now + args.endTime
  end

  args.context = context

  AITimers.timers[name] = args 

  return name
end

function AITimers:RemoveTimer(name)
  AITimers.timers[name] = nil
  if AITimers.runningTimer == name then
    AITimers.removeSelf = true
  end
end

function AITimers:RemoveTimers(killAll)
  local timers = {}
  AITimers.removeSelf = true

  if not killAll then
    for k,v in pairs(AITimers.timers) do
      if v.persist then
        timers[k] = v
      end
    end
  end

  AITimers.timers = timers
end

if not AITimers.timers then AITimers:start() end

GameRules.AITimers = AITimers