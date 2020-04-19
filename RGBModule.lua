ConfigRGBModule = {
  PWM_MAX = 512,
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
    local r = 0
    local n = 2^math.random(30) -- Any power of 2.
    local limit = math.ceil(53 / (math.log(n) / math.log(2)))
    for i = 1, limit do
      r = r + math.random(0, n - 1) / (n^i)
    end
    return math.floor(r * (to - from + 1)) + from
  end
}

RGBEffects = {
  effectTimer = tmr.create(),
  
  startRandomRainbow = function(self, duration)
    self.effectTimer:register(duration, tmr.ALARM_AUTO, randomRainbow)
  end,

  randomRainbow = function() 
    local randomRGB = {utils.getRandomNumber(0, ConfigRGBModule.PWM_MAX), utils.getRandomNumber(0, ConfigRGBModule.PWM_MAX),utils.getRandomNumber(0, ConfigRGBModule.PWM_MAX)}
    RGBModule.fadeTo(randomRGB)
  end,

  stopRandomRainbow = function(self)
    self.effectTimer:unregister()
  end

}


 RGBModule:initRGB()
 RGBModule:setRGB({10,10,10})

 RGBModule:RGBFadeTo({0, ConfigRGBModule.PWM_MAX, 0},500)
 RGBModule:RGBFadeTo({0, 0, ConfigRGBModule.PWM_MAX},500)
 RGBModule:RGBFadeTo({ConfigRGBModule.PWM_MAX, ConfigRGBModule.PWM_MAX, ConfigRGBModule.PWM_MAX},500)





