-- lemniscate
-- 

local util = require('util')

local MAX_PROGRAM_LENGTH = 87
local position = 1
local program = 1
local program_length = 10
local tape_length = program_length * 4
local source_amp = 1.0
local play_amp = 1.0
local rec_amp = 1.0
local preserve_amp = 0.7
local shift = false
local playing = 0
local recording = 0

local function _refresh_position(i, pos)
  position = math.floor(pos)
end

local function _set_head_position()
  for i = 1, 2 do
    softcut.position(i, position)
  end

  softcut.voice_sync(2, 1, 0)
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

local function toggle_play()
  playing = util.wrap(playing + 1, 0, 1)

  for i = 1, 2 do
    softcut.play(i, playing)
  end

  softcut.voice_sync(2, 1, 0)
end

local function toggle_record()
  recording = util.wrap(recording + 1, 0, 1)

  for i = 1, 2 do
    softcut.rec(i, recording)
  end

  softcut.voice_sync(2, 1, 0)
end

local function stop_all()
  for i = 1, 2 do
    softcut.play(i, 0)
    softcut.rec(i, 0)
  end

  position = 1
  program = 1
  _set_head_position()
end


local function program_select(n)
  local segment_position = position - get_program_offset()

  if n then
    program = n
  else
    program = util.wrap(program + 1, 1, 4)
  end

  position = segment_position + get_program_offset()
  _set_head_position()
end

local function refresh_program()
  softcut.query_position(1)
  if position > program_length then
    program = math.floor(position // program_length) + 1
  else
    program = 1
  end
end

local function set_tape_length(d)
  program_length = util.clamp(program_length + d, 1, MAX_PROGRAM_LENGTH)
  for i = 1, 2 do
    softcut.loop_end(i, tape_length)
  end

  position = util.clamp(position, 1, program_length)
  _set_head_position()  
end

local function temp_render_text()
  screen.move(64, 12)
  screen.text_center('PROGRAM '..program)
  screen.move(64, 22)
  screen.text_center('POSITION '..position)
  screen.move(64, 32)
  if playing == 0 and recording == 0 then
    screen.text_center('PAUSED')
  elseif playing == 0 then
    screen.text_center('PLAY PAUSED / REC ACTIVE')
  elseif recording == 0 then
    screen.text_center('PLAY ACTIVE / REC PAUSED')
  else
    screen.text_center('PLAY ACTIVE / REC ACTIVE')
  end
end
  

function init()
  init_softcut()
  toggle_play()
  toggle_record()
  redraw()
end

function enc(e, d)
  -- set program length
end

function key(k, z)
  if k == 1 and z == 1 then
    shift = true
  elseif k == 1 and z == 0 then
    shift = false
  elseif k == 2 and z == 0 and not shift then
    toggle_play()
  elseif k== 2 and z == 0 and shift then
    toggle_record()
  elseif k == 3 and z == 0 and not shift then
    program_select()
  elseif k == 3 and z == 0 and shift then
    stop_all()
  end
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
