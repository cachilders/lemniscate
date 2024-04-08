-- lemniscate
-- 

local util = require('util')

local ASSET_PATH = '/home/we/dust/code/lemniscate/assets/bg_frames/'
local MAX_PROGRAM_LENGTH = 87
local MIN_PROGRAM_LENGTH = 1
local MAX_BG_FRAMES = 6
local position = 1
local program = 1
local program_length = 10
local tape_length = 40
local source_amp = 1.0
local play_amp = 1.0
local rec_amp = 1.0
local preserve_amp = 0.7
local shift = false
local playing = 0
local recording = 0
local bg_frame = 1
local frame_clock = nil
local program_cell_dimensions = {3, 14}
local program_cells = {
  {74, 26},
  {78, 26},
  {82, 26},
  {86, 26}
}

local function _animate_background()
  if playing == 1 or recording == 1 then
    bg_frame = util.wrap(bg_frame + 1, 1, MAX_BG_FRAMES)
  end
end

local function _refresh_position(i, pos)
  position = math.floor(pos)
end

local function _set_head_position()
  for i = 1, 2 do
    softcut.position(i, position)
  end

  softcut.voice_sync(2, 1, 0)
end

local function init_animation()
  frame_clock = metro.init(_animate_background, 1/12)
  frame_clock:start()
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

local function refresh_background()
  screen.display_png(ASSET_PATH..bg_frame..'.png', 0, 0)
end

local function refresh_foreground()
  local x, y = program_cells[program][1], program_cells[program][2]
  local width, height = program_cell_dimensions[1], program_cell_dimensions[2]
  screen.rect(x, y, width, height)
  -- screen.fill()
  screen.move(x + math.floor(width/2), y - 5)
  if playing == 1 then
    screen.text('▶')
  end
  screen.move(x + math.floor(width/2), y + height + 10)
  if recording == 1 then
    screen.text('°')
  end
end

local function refresh_program()
  softcut.query_position(1)
  program = math.ceil(position / program_length)
end

local function set_tape_length(d)
  program_length = util.clamp(program_length + d, MIN_PROGRAM_LENGTH, MAX_PROGRAM_LENGTH)
  tape_length = 4 * program_length
  
  for i = 1, 2 do
    -- Loop should be inclusive of final second
    softcut.loop_end(i, tape_length + 1)
  end

  position = util.clamp(position, 1, program_length)
  _set_head_position()  
end

local function temp_render_text()
  screen.move(64, 12)
  screen.text_center('PROGRAM LENGTH '..program_length..'s')
  screen.move(64, 22)
  screen.text_center('TAPE LENGTH '..tape_length..'s')
  screen.move(64, 32)
  screen.text_center('PROGRAM '..program)
  screen.move(64, 42)
  screen.text_center('POSITION '..position)
  screen.move(64, 52)
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
  init_animation()
  init_softcut()
  toggle_play()
  toggle_record()
  redraw()
end

function enc(e, d)
  if e == 3 then
    set_tape_length(d)
  end
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
  refresh_background()
  refresh_foreground()
  -- temp_render_text()
  screen.stroke()
  screen.update()
end

function refresh()
  redraw()
end
