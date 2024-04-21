local ControlSpec = require 'controlspec'
local Formatters = require 'formatters'

local Parameters = {}

local function quantize_and_format(value, step, unit)
  return util.round(value, step)..unit
end

local loop_parameters = {
  {id = 'play_amp', name = 'playback amplitude', type = 'control', min = 0, max = 1, warp = 'lin', default = 1.0, formatter = function(param) return quantize_and_format(param:get()*100, 1, '%') end},
  {id = 'preserve_amp', name = 'overdub amplitude', type = 'control', min = 0, max = 1, warp = 'lin', default = 0.8, formatter = function(param) return quantize_and_format(param:get()*100, 1, '%') end},
  {id = 'source_amp', name = 'source amplitude', type = 'control', min = 0, max = 1, warp = 'lin', default = 1.0, formatter = function(param) return quantize_and_format(param:get()*100, 1, '%') end}
}

function Parameters.init(set_param)
  params:add_group('lemniscate_loop', 'LEMNISCATE (loop)', #loop_parameters)
  for i = 1, #loop_parameters do
    parameter = loop_parameters[i]
    params:add_control(
      parameter.id,
      parameter.name,
      ControlSpec.new(parameter.min, parameter.max, parameter.warp, 0, parameter.default),
      parameter.formatter
    )
    params:set_action(parameter.id, function(val) set_param[parameter.id](val) end)
  end

  params:bang()
end

return Parameters