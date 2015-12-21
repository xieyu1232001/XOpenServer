-- 计算下一天时间
local function CalcNextDay()

	local t = os.date("*t", CURRENT_TIME)
	t.hour = 0
	t.min = 0
	t.sec = 0
	return os.time(t) + 3600*24
end

------------------------------------------------------------------
local LogFileList = {}

-- 初始化log文件
function CreateLogFile(keyname, path, filename, maxcount)

	if not keyname or not filename then return end
	if LogFileList[keyname] then return end
	
	local logFile = {}
	logFile.keyname = keyname
	logFile.path = path
	logFile.filename = filename
	logFile.maxcount = maxcount
	logFile.count = 0
	logFile.refreshTime = CalcNextDay()
	logFile.currFullName = path .. filename .. "_" .. os.date("%Y%m%d%H%M%S") .. ".log"


	LogFileList[keyname] = logFile
	OpenLogFile(keyname)
	return true
end

-- 打开log文件
function OpenLogFile(keyname)

	local logFile = LogFileList[keyname]
	if not logFile then return end
	if logFile.file then logFile.file:close() end

	logFile.refreshTime = CalcNextDay()
	logFile.currFullName = logFile.path .. logFile.filename .. "_" .. os.date("%Y%m%d%H%M%S") .. ".log"

	local errMsg
	logFile.file, errMsg = io.open(logFile.currFullName, "w+")
	if not logFile.file then print("Open log file fail", errMsg) end
	return logFile.file
end

-- 关闭
function CloseLogFile(keyname)

	local logFile = LogFileList[keyname]
	if not logFile then return end
	if logFile.file then logFile.file:close() end
end

-- 检查是否要新建文件
function CheckLogFile(keyname)

	local logFile = LogFileList[keyname]
	if not logFile then return end

	-- 一天刷新一次
	if logFile.refreshTime <= CURRENT_TIME then OpenLogFile(keyname) end
	-- 数据超过最大行数
	if logFile.maxcount and logFile.count >= logFile.maxcount then OpenLogFile(keyname) end
end

-- 写文件
function WriteLog(keyname, msg)

	local logFile = LogFileList[keyname]
	if not logFile then return print("file is not init ", msg) end
	CheckLogFile(keyname)

	local result, errMsg, errNo
	result, errMsg, errNo = logFile.file:write(msg)
	if not result then 
		print("Write log error!", errMsg, errNo)
		return 
	end

	logFile.count = logFile.count + 1
	result, errMsg, errNo = logFile.file:flush()
	if not result then print("flush log error!", errMsg, errNo) end
end

-- log 屏幕输出+文件输出
function LogAndPrint(keyname, level, f, ...)

	--if not DEBUG then return end
	if not keyname or not f then return end

	local msg1 = string.format(f, ...)
	print(msg1)

	local msg = "[" .. os.date("%X", os.time()) .. "]["..level.."] " .. msg1 .. "\n"
	WriteLog(keyname, msg)
end

------------------------------------------------------------------
-- 程序日志
CreateLogFile("programlog", PROGRAM_LOG_PATH , SERVER_NAME .. ServerID, LOGS_COUNT_MAX)

-- 打印堆栈
function Trace()
	--if not DEBUG then return end
	LogAndPrint("programlog", "TRACE", debug.traceback())
end

function LogDebug(f, ...)
	if not DEBUG then return end
	LogAndPrint("programlog", "DEBUG", f, ...)
end

function LogInfo(f, ...)
	LogAndPrint("programlog", "INFO", f, ...)
end

function LogWarning(f, ...)
	LogAndPrint("programlog", "WARNING", f, ...)
	Trace()
end

function LogError(f, ...)
	LogAndPrint("programlog", "ERROR", f, ...)
	Trace()
end

-- 输出堆栈
function LogTrace(f, ...)

	if not DEBUG then return end
	LogAndPrint("programlog", "TRACE", f, ...)
	Trace()
end

-- LogDebug的拓展, 支持输出不定参数
function LogDebugEx(s, ...)

	if not DEBUG then return end
	if not ISSTR(s) and not ... then return end

	local t = {...}
	if table.empty(t) then
		if s then LogDebug(s) end
		return
	end

	local n = #t
	if n < 1 then return end

	s = s .. "\t%s"
	for i=2,n,1 do
		s = s .. "\t%s"
	end

	LogDebug(s, ...)
end
