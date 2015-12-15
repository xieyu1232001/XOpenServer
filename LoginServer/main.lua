print("main star")

GameApp = ServerEngine()

--------------------------------------------------------------------------------
--引擎事件处理
function GameApp:OnServerStart()
	print("GameApp:OnServerStart")
end

function GameApp:MainLoop()
	print("Hello XOpenServer, GameApp Is Running!!")
end

function GameApp:ServerStop()
	print("GameApp:ServerStop")
end

--引擎开跑
GameApp:Loop()