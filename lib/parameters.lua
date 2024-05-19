local ControlSpec = require 'controlspec'
local Formatters = require 'formatters'

local Parameters = {}

local function quantize_and_format(value, step, unit)
  return util.round(value, step)..unit
end

local loop_parameters = {
  {id = 'play_amp', name = 'playback amplitude', type = 'control', min = 0, max = 1, warp = 'lin', default = 1.0, formatter = function(param) return quantize_and_format(param:get()*100, 1, '%') end},
  {id = 'preserve_amp', name = 'overdub amplitude', type = 'control', min = 0, max = 1, warp = 'lin', default = 0.8, formatter = function(param) return quantize_and_format(param:get()*100, 1, '%') end},
  {id = 'source_amp', name = 'source amplitude', type = 'control', min = 0, max = 1, warp = 'lin', default = 1.0, formatter = function(param) return quantize_and_format(param:get()*100, 1, '%') end},
  {id = 'filter_cutoff', name = 'low pass cutoff', type = 'number', min = 120, max = 42000, default = 1200, formatter = function(param) return quantize_and_format(param:get(), 10, ' hz') end}
}

function Parameters.init(set_param)
  params:add_group('lemniscate_loop', 'LEMNISCATE', #loop_parameters)
  for i = 1, #loop_parameters do
    local parameter = loop_parameters[i]

    if parameter.type == 'control'then
      params:add_control(
        parameter.id,
        parameter.name,
        ControlSpec.new(parameter.min, parameter.max, parameter.warp, 0, parameter.default),
        parameter.formatter
      )
    elseif parameter.type == 'number' then
      params:add_number(
        parameter.id,
        parameter.name,
        parameter.min,
        parameter.max,
        parameter.default,
        parameter.formatter
      )
    end
    params:set_action(parameter.id, function(val) set_param[parameter.id](val) end)
  end
  params:add_group('lemniscate_ux', 'LEMNISCATE (ux)', 1)
  params:add_control(
    'lem_skeuo_amp',
    'Skeuomorph Amp',
    ControlSpec.new(0, 1, 'lin', 0, 0),
    function(param) return quantize_and_format(param:get()*100, 1, '%') end
  )
  params:bang()
end

return Parameters