
require ("Script.Refactory.Header")

-- local g_test = nil
-- local function Test()
-- 	local test = LuaVector3.New()
-- 	test:Destroy()
-- 	g_test = test
-- end


-- Debug.Log("test begin")
-- TablePool.monitor = TablePoolMonitor.Me()
-- Test()
-- TablePool.DebugCheck(Time.time, Time.deltaTime)
-- TablePool.monitor = nil
-- Debug.Log("test end")

if nil == g_Game then
	g_Game = Game.Me()
	Debug_LuaMemotry.Start()
end

return Game