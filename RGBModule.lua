ConfigRGBModule = {
  PWM_MAX = 1023,
  PWM_OFF = 0,
  INITIAL_RGB = {255,0,0},
  PIN_R = 1,
  PIN_G = 2,
  PIN_B = 3
}

RGBModule = {
  currentRGB = ConfigRGBModule.INITIAL_RGB,
  
  initRGB = function()
    pwm.setup(ConfigRGBModule.PIN_R, 500, ConfigRGBModule.PWM_OFF)
    pwm.setup(ConfigRGBModule.PIN_G, 500, ConfigRGBModule.PWM_OFF)
    pwm.setup(ConfigRGBModule.PIN_B, 500, ConfigRGBModule.PWM_OFF)
    
    pwm.start(ConfigRGBModule.PIN_R)
    pwm.start(ConfigRGBModule.PIN_G)
    pwm.start(ConfigRGBModule.PIN_B)
  end,

  setRGB = function(self, rgb)
    self.currentRGB = {rgb[1], rgb[2], rgb[3]}
    pwm.setduty(ConfigRGBModule.PIN_R, self.currentRGB[1])
    pwm.setduty(ConfigRGBModule.PIN_G, self.currentRGB[2])
    pwm.setduty(ConfigRGBModule.PIN_B, self.currentRGB[3])
  end,

  RGBFadeTo = function(self, newRGB, duration)
    local fadeTimer = tmr.create()

    local currentR = self.currentRGB[1]
    local currentG = self.currentRGB[2]
    local currentB = self.currentRGB[3]

    local newR = newRGB[1]
    local newG = newRGB[2]
    local newB = newRGB[3]

    local deltaR = newR - currentR
    local deltaG = newG - currentG
    local deltaB = newB - currentB

    local deltaMax = 0

    if math.abs(deltaR) > deltaMax then
      deltaMax = math.abs(deltaR)
    end

    if math.abs(deltaG) > deltaMax then
      deltaMax = math.abs(deltaG)
    end

    if math.abs(deltaB) > deltaMax then
      deltaMax = math.abs(deltaB)
    end

    
    if deltaMax == 0 then 
      return
    end

    local stepR = deltaR / deltaMax
    local stepG = deltaG / deltaMax
    local stepB = deltaB / deltaMax

    local stepDelay = 1000 * duration / deltaMax;

    for i=0,deltaMax-1,2 do
      currentR = math.floor(currentR + stepR)
      currentG = math.floor(currentG + stepG)
      currentB = math.floor(currentB + stepB)
      if currentR < 0 then currentR = 0 end
      if currentG < 0 then currentG = 0 end
      if currentB < 0 then currentB = 0 end
      self.setRGB(self,{currentR,currentG,currentB})
      tmr.delay(stepDelay)
    end   
  end
}

utils = {
  getRandomNumber = function (from, to)

  local function log(x)
    assert(x > 0)
    local a, b, c, d, e, f = x < 1 and x or 1/x, 0, 0, 1, 1
    repeat
       repeat
          c, d, e, f = c + d, b * d / e, e + 1, c
       until c == f
       b, c, d, e, f = b + 1 - a * c, 0, 1, 1, b
       until b <= f
       return a == x and -f or f
    end
    
    local r = 0
    local n = 2^math.random(30) -- Any power of 2.
    local limit = math.ceil(53 / (log(n) / log(2)))
    
    for i = 1, limit do
      r = r + math.random(0, n - 1) / (n^i)
    end
    return math.floor(r * (to - from + 1)) + from
  end
}

RGBEffects = {
  effectTimer = tmr.create(),
  
  startRandomRainbow = function(self, duration)
    self.effectTimer:register(duration, tmr.ALARM_AUTO, function (t)
--        print("run") 
        self.randomRainbow(duration)
    end)
    self.effectTimer:start()
  end,

  randomRainbow = function(duration) 
    local randomRGB = {utils.getRandomNumber(0, ConfigRGBModule.PWM_MAX), utils.getRandomNumber(0, ConfigRGBModule.PWM_MAX),utils.getRandomNumber(0, ConfigRGBModule.PWM_MAX)}
    print(randomRGB[1], randomRGB[2], randomRGB[3])
    RGBModule:RGBFadeTo(randomRGB, duration)
  end,

  stopRandomRainbow = function(self)
    
    self.effectTimer:unregister()
    print(self.effectTimer:state())
  end

}


 RGBModule:initRGB()
 RGBModule:setRGB({255,10,10})

-- RGBModule:RGBFadeTo({0, ConfigRGBModule.PWM_MAX, 0},500)
-- RGBModule:RGBFadeTo({0, 0, ConfigRGBModule.PWM_MAX},500)
-- RGBModule:RGBFadeTo({ConfigRGBModule.PWM_MAX, ConfigRGBModule.PWM_MAX, ConfigRGBModule.PWM_MAX},500)

RGBEffects:startRandomRainbow(3000)
--
removeTimer = tmr.create()

removeTimer:register(12000, tmr.ALARM_SINGLE, function(t)
    RGBEffects:stopRandomRainbow()
    RGBModule:setRGB(RGBModule.currentRGB)
    t:unregister()
end)
removeTimer:start()



