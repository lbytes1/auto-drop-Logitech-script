-- ✅最终完整版脚本
-- 触发：G5（arg==5）
-- 停止：CapsLock 亮（立刻退出，释放左键+Alt）
-- 暂停：ScrollLock 亮（暂停时松开Alt；灭时如果之前按住Alt则自动按回去）
--
-- 丢弃动作计数规则（只统计“拖到0”）：
-- 从第250次丢弃动作开始：每10次丢弃 => POST_DELAY +2；PRE_DELAY +1；DRAG_TRAVEL +1
--
-- 装卸总次数：17次（a~p 每轮前装卸1次共16次 + p 完成后再装卸1次）
-- wait 规则：前3轮固定100ms，从第4轮开始 100 + (i-3)*50

EnablePrimaryMouseButtonEvents(true)

local START_BTN  = 5
local DROP_TIMES = 3

-- ===== 数字坐标 =====
local pos = {
  [0]={12772,32433},
  [1]={35448,45249},
  [2]={39273,45613},
  [3]={42654,45978},
  [4]={46308,45856},
  [5]={35892,51687},
  [6]={39410,51930},
  [7]={42927,52173},
  [8]={46274,51930},
}

-- ===== a~p =====
local letters = {
  {46137,39479},{42757,39661},{39239,39479},{35687,39297},
  {46206,33041},{42654,33284},{39376,33284},{35722,33405},
  {46240,26967},{42757,26967},{39239,27149},{35790,27149},
  {46342,20590},{42791,20772},{39273,20772},{35858,20590},
}

-- ===== 延迟参数（会被“丢弃计数规则”动态增加）=====
local PRE_DELAY   = 20
local DRAG_HOLD   = 0
local DRAG_TRAVEL = 30
local POST_DELAY  = 20

-- ✅丢弃动作计数（只统计 toIdx==0 的拖动）
local discardCount = 0

-- ✅Alt按住状态（用于暂停恢复）
local altHeld = false

local function mm(x,y) MoveMouseTo(x,y) end
local function shouldStop() return IsKeyLockOn("capslock") end

local function pressAlt()
  PressKey("lalt")
  altHeld = true
end

local function releaseAlt()
  ReleaseKey("lalt")
  altHeld = false
end

local function safeAbort()
  ReleaseMouseButton(1)
  releaseAlt()
end

-- ✅暂停：ScrollLock亮=暂停；灭=继续
-- 暂停时：如果之前Alt按住 -> 临时松开
-- 继续时：如果之前Alt按住 -> 自动按回去
local function checkPause()
  if IsKeyLockOn("scrolllock") then
    -- 进入暂停：临时松Alt（不改变altHeld标记）
    if altHeld then
      ReleaseKey("lalt")
    end
    ReleaseMouseButton(1)

    while IsKeyLockOn("scrolllock") do
      Sleep(50)
      if shouldStop() then safeAbort(); return true end
    end

    -- 恢复：如果暂停前Alt应该按住，就按回去
    if altHeld then
      PressKey("lalt")
    end
  end
  return false
end

local function SleepBreak(ms)
  local t = 0
  while t < ms do
    if shouldStop() then return true end
    if checkPause() then return true end
    Sleep(10)
    t = t + 10
  end
  return false
end

-- ✅根据丢弃次数更新延迟（从第250次丢弃开始，每10次丢弃增加一次）
local function updateDelayByDiscard()
  if discardCount >= 250 and ((discardCount - 250) % 5 == 0) then
    PRE_DELAY   = PRE_DELAY + 1
    DRAG_TRAVEL = DRAG_TRAVEL + 1
    POST_DELAY  = POST_DELAY + 2
  end
end

local function dragAbs(fx,fy,tx,ty)
  if SleepBreak(PRE_DELAY) then safeAbort(); return true end
  mm(fx,fy)

  if SleepBreak(PRE_DELAY) then safeAbort(); return true end
  PressMouseButton(1)

  -- DRAG_HOLD = 0（不等待）
  mm(tx,ty)

  if SleepBreak(DRAG_TRAVEL) then safeAbort(); return true end
  ReleaseMouseButton(1)

  if SleepBreak(POST_DELAY) then safeAbort(); return true end
  return false
end

local function dragOnce(a,b)
  -- ✅丢弃动作统计：凡是拖到0都计数，并按规则动态加延迟
  if b == 0 then
    discardCount = discardCount + 1
    updateDelayByDiscard()
  end
  return dragAbs(pos[a][1],pos[a][2],pos[b][1],pos[b][2])
end

-- ✅交替丢弃：a->0,b->0,a->0,b->0...（每个各 n 次）
local function dropAlternate(a,b,n)
  for i=1,n do
    if dragOnce(a,0) or dragOnce(b,0) then return true end
  end
  return false
end

-- ===== 装卸 =====
local function ZhuangXie()
  pressAlt()
  if SleepBreak(40) then safeAbort(); return true end

  -- 普通移动
  if dragOnce(1,2) then return true end
  if dragOnce(2,3) then return true end
  if dragOnce(3,4) then return true end
  if dragOnce(4,5) then return true end
  if dragOnce(5,6) then return true end

  -- 交替丢弃（所有类似情况都交替）
  if dropAlternate(5,6,DROP_TIMES) then return true end

  if dragOnce(4,5) then return true end
  if dropAlternate(5,4,DROP_TIMES) then return true end

  if dragOnce(3,4) then return true end
  if dragOnce(4,5) then return true end
  if dropAlternate(5,4,DROP_TIMES) then return true end

  if dragOnce(3,4) then return true end
  if dropAlternate(4,3,DROP_TIMES) then return true end

  if dragOnce(2,3) then return true end
  if dragOnce(3,4) then return true end
  if dragOnce(4,5) then return true end
  if dropAlternate(5,4,DROP_TIMES) then return true end

  if dragOnce(3,4) then return true end
  if dropAlternate(4,3,DROP_TIMES) then return true end

  if dragOnce(2,3) then return true end
  if dragOnce(3,4) then return true end
  if dropAlternate(4,3,DROP_TIMES) then return true end

  if dragOnce(2,3) then return true end
  if dropAlternate(3,2,DROP_TIMES) then return true end

  if dragOnce(1,2) then return true end
  if dragOnce(2,3) then return true end
  if dragOnce(3,4) then return true end
  if dragOnce(4,5) then return true end
  if dropAlternate(5,4,DROP_TIMES) then return true end

  if dragOnce(3,4) then return true end
  if dropAlternate(4,3,DROP_TIMES) then return true end

  if dragOnce(2,3) then return true end
  if dragOnce(3,4) then return true end
  if dropAlternate(4,3,DROP_TIMES) then return true end

  if dragOnce(2,3) then return true end
  if dropAlternate(3,2,DROP_TIMES) then return true end

  if dragOnce(1,2) then return true end
  if dragOnce(2,3) then return true end
  if dragOnce(3,4) then return true end
  if dropAlternate(4,3,DROP_TIMES) then return true end

  if dragOnce(2,3) then return true end
  if dropAlternate(3,2,DROP_TIMES) then return true end

  if dragOnce(1,2) then return true end
  if dragOnce(2,3) then return true end
  if dropAlternate(3,2,DROP_TIMES) then return true end

  if dragOnce(1,2) then return true end
  if dropAlternate(2,1,DROP_TIMES) then return true end

  releaseAlt()
  return false
end

-- ===== 主流程 =====
local function RunAll()
  -- 每次启动重置基础延迟 & 丢弃计数 & Alt状态
  PRE_DELAY, DRAG_TRAVEL, POST_DELAY = 20,30,20
  discardCount = 0
  altHeld = false

  for i=1,16 do
    if ZhuangXie() then return end

    -- wait：前3轮固定100ms，从第4轮开始递增
    local wait
    if i <= 3 then
      wait = 100
    else
      wait = 100 + (i - 3) * 50
    end
    if SleepBreak(wait) then safeAbort(); return end

    -- 字母拖到1：不按Alt（并确保Alt状态记录为未按）
    releaseAlt()
    local lx, ly = letters[i][1], letters[i][2]
    if dragAbs(lx, ly, pos[1][1], pos[1][2]) then return end
  end

  -- p 后补第17次装卸
  ZhuangXie()
end

function OnEvent(e,a)
  if e=="MOUSE_BUTTON_PRESSED" and a==START_BTN then
    RunAll()
  end
end


