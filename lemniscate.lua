-- lemniscate
--

local util = require('util')

local MAX_PROGRAM_LENGTH = 87
local position = 1
local program = 1
local program_length = 10
local tape_length = program_length * 4
local source_amp = 0.5
local play_amp = 0.9
local rec_amp = 0.9
local preserve_amp = 0.7

local function _refresh_position(i, pos)
  position = math.floor(pos)
end

local function init_softcut()
  audio.level_adc_cut(1)
  softcut.buffer_clear()
  softcut.event_position(_refresh_position)
  for i = 1, 2 do
    softcut.enable(i, 1)
    softcut.buffer(i, i)
    softcut.level(i, play_amp)
    softcut.loop(i, 1)
    softcut.loop_start(i, 1)
    softcut.loop_end(i, tape_length)
    softcut.pre_level(i, preserve_amp)
    softcut.rec_level(i, rec_amp)
    softcut.position(i, position)
    softcut.level_input_cut(i, i, source_amp)
  end
end

local function get_program_offset()
  return (program - 1) * program_length
end

local function play()
  for i = 1, 2 do
    softcut.play(i, 1)
  end

  softcut.voice_sync(2, 1, 0)
end

local function record()
  for i = 1, 2 do
    softcut.rec(i, 1)
  end

  softcut.voice_sync(2, 1, 0)
end

local function program_select(n)
  local segment_position = position - get_program_offset()

  if n then
    program = n
  else
    program = util.wrap(program + 1, 1, 4)
  end

  position = segment_position + get_program_offset()
  set_head_position()
end

local function refresh_program()
  softcut.query_position(1)
  if position > program_length then
    program = math.floor(position // program_length) + 1
  else
    program = 1
  end
end

local function set_head_position()
  for i = 1, 2 do
    softcut.loop_position(i, position)
  end

  softcut.voice_sync(2, 1, 0)
end

local function set_tape_length(d)
  program_length = util.clamp(program_length + d, 1, MAX_PROGRAM_LENGTH)
  for i = 1, 2 do
    softcut.loop_end(i, tape_length)
  end

  position = util.clamp(position, 1, program_length)
  set_head_position()  
end

local function temp_render_text()
  screen.move(64, 12)
  screen.text_center('PROGRAM '..program)
  screen.move(64, 22)
  screen.text_center('PLAY POSITION '..position)
end
  

function init()
  init_softcut()
  play()
  record()
  redraw()
end

function enc(e, d)
  -- set program length
end

function key(k, z)
  -- change program
  -- play/pause/rec/stop
end

function redraw()
  screen.clear()
  refresh_program()
  temp_render_text()
  screen.update()
end

function refresh()
  redraw()
end
