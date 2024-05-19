-- Nothing here. Boilerplate just in case.

local Lemnisc8 = {}
local ControlSpec = require 'controlspec'
local Formatters = require 'formatters'

local function quantize_and_format(value, step, unit)
  return util.round(value, step)..unit
end

local parameters = {
  -- {id = 'amp', name = 'amplitude', type = 'control', min = 0, max = 1, warp = 'lin', default = 0.0, formatter = function(param) return quantize_and_format(param:get()*100, 1, '%') end},
}

function Lemnisc8:add_params()
  params:add_group('lemnisc8', 'LEMNISC8', 1)
  for i = 1, #parameters do
    local parameter = parameters[i]
    if parameter.type == 'control' then
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

    params:set_action(parameter.id, function(val)
      engine[parameter.id](val)
    end)
  end

  params:bang()
end

return Lemnisc8