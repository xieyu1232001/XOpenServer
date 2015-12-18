
require("oo")

-- testA类
testA = oo.class();

-- Init 在构造新对象时调用
function testA:Init(name)
	print("testA:Init")
	self.name = name
end

function testA:SayHello()
	print("Hello" .. self.name)
end

function testA:print()
	print("I am testA!")
end

-- testB类
testB = oo.class(testA);
function testB:Init(name)
	print("testB:Init")
	testA.Init(self, name)
end
function testB:print()
	print("I am testB!")
end


-- 实例化 testC, testD
testC = testA(" testC")
testD = testB(" testD")


testC:SayHello()
testC:print()

testD:SayHello()
testD:print()

-- 类关系
print(testC:IsInherit(testA))
print(testC:IsInherit(testB))
print(testD:IsInherit(testA))

--以下两个用法是一样的, 使用oo.IsInstance更安全一些. oo.IsInstance会先检测对象是否存在IsInherit方法
print(testD:IsInherit(testB))
print(oo.IsInstance(testD, testB))