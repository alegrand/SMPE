--
-- This is file `lua-ul.lua',
-- generated with the docstrip utility.
--
-- The original source files were:
--
-- lua-ul.dtx  (with options: `luacode')
-- 
-- Copyright (C) 2020 by Marcel Krueger
--
-- This file may be distributed and/or modified under the
-- conditions of the LaTeX Project Public License, either
-- version 1.3c of this license or (at your option) any later
-- version. The latest version of this license is in:
--
-- http://www.latex-project.org/lppl.txt
--
-- and version 1.3 or later is part of all distributions of
-- LaTeX version 2005/12/01 or later.
local unset_t = node.id'unset'
local hlist_t = node.id'hlist'
local vlist_t = node.id'vlist'
local kern_t = node.id'kern'
local glue_t = node.id'glue'

local properties = node.direct.get_properties_table()

local has_attribute = node.direct.has_attribute
local set_attribute = node.direct.set_attribute
local dimensions = node.direct.dimensions
local flush_node = node.direct.flush_node
local getboth = node.direct.getboth
local getfield = node.direct.getfield
local getglue = node.direct.getglue
local getleader = node.direct.getleader
local getlist = node.direct.getlist
local setheight = node.direct.setheight
local setdepth = node.direct.setdepth
local getheight = node.direct.getheight
local getdepth = node.direct.getdepth
local getnext = node.direct.getnext
local getshift = node.direct.getshift
local insert_after = node.direct.insert_after
local insert_before = node.direct.insert_before
local nodecopy = node.direct.copy
local nodenew = node.direct.new
local setboth = node.direct.setboth
local setlink = node.direct.setlink
local hpack = node.direct.hpack
local setfield = node.direct.setfield
local slide = node.direct.slide
local setglue = node.direct.setglue
local setnext = node.direct.setnext
local setshift = node.direct.setshift
local todirect = node.direct.todirect
local tonode = node.direct.tonode
local traverse = node.direct.traverse
local traverse_id = node.direct.traverse_id
local traverse_list = node.direct.traverse_list
local getList = function(n) return getfield(n, 'list') end
local setList = function(n, h) return setfield(n, 'list', h) end

local tokennew = token.new
local set_lua = token.set_lua
local scan_keyword = token.scan_keyword
local scan_list = token.scan_list
local scan_int = token.scan_int
local put_next = token.put_next
local texerror = tex.error

local char_given = token.command_id'char_given'

local underlineattrs = {}
local underline_types = {}
local underline_strict_flag = {}
local underline_over_flag = {}

vmode = 1
local texnest = tex.nest

local saved_values = {}
local function new_underline_type()
  for i=1,#underlineattrs do
    local attr = underlineattrs[i]
    saved_values[i] = tex.attribute[attr]
    tex.attribute[attr] = -0x7FFFFFFF
  end
  local strict_flag = scan_keyword'strict'
  local over_flag = scan_keyword'over'
  local b = todirect(scan_list())
  for i=1,#underlineattrs do
    tex.attribute[underlineattrs[i]] = saved_values[i]
  end
  local lead = getlist(b)
  if not getleader(lead) then
    texerror("Leader required", {"An underline type has to \z
      be defined by leader. You should use one of the", "commands \z
      \\leaders, \\cleaders, or \\xleader, or \\gleaders here."})
  else
    local after = getnext(lead)
    if after then
      texerror("Too many nodes", {"An underline type can only be \z
          defined by a single leaders specification,", "not by \z
          multiple nodes. Maybe you supplied an additional glue?",
          "Anyway, the additional nodes will be ignored"})
      setnext(lead, nil)
    end
    table.insert(underline_types, lead)
    setList(b, after)
    flush_node(b)
  end
  put_next(tokennew(#underline_types, char_given))
  underline_strict_flag[#underline_types] = strict_flag
  underline_over_flag[#underline_types] = over_flag
end
local function set_underline()
  local j, props
  for i=texnest.ptr,0,-1 do
    local mode = texnest[i].mode
    if mode == vmode or mode == -vmode then
      local head = todirect(texnest[i].head)
      local head_props = properties[head]
      if not head_props then
        head_props = {}
        properties[head] = head_props
      end
      props = head_props.luaul_attributes
      if not props then
        props = {}
        head_props.luaul_attributes = props
        break
      end
    end
  end
  for i=1,#underlineattrs do
    local attr = underlineattrs[i]
    if tex.attribute[attr] == -0x7FFFFFFF then
      j = attr
      break
    end
  end
  if not j then
    j = luatexbase.new_attribute(
        "luaul" .. tostring(#underlineattrs+1))
    underlineattrs[#underlineattrs+1] = j
  end
  props[j] = props[j] or -0x7FFFFFFF
  tex.attribute[j] = scan_int()
end
local function reset_underline()
  local reset_all = scan_keyword'*'
  local j
  for i=1,#underlineattrs do
    local attr = underlineattrs[i]
    if tex.attribute[attr] ~= -0x7FFFFFFF then
      if reset_all then
        tex.attribute[attr] = -0x7FFFFFFF
      else
        j = attr
      end
    end
  end
  if not j then
    if not reset_all then
      texerror("No underline active", {"You tried to disable \z
            underlining but underlining was not active in the first",
            "place. Maybe you wanted to ensure that \z
            no underling can be active anymore?", "Then you should \z
            append a *."})
    end
    return
  end
  tex.attribute[j] = -0x7FFFFFFF
end
local functions = lua.get_functions_table()
local new_underline_type_func =
    luatexbase.new_luafunction"luaul.new_underline_type"
local set_underline_func =
    luatexbase.new_luafunction"luaul.set_underline_func"
local reset_underline_func =
    luatexbase.new_luafunction"luaul.reset_underline_func"
set_lua("LuaULNewUnderlineType", new_underline_type_func)
set_lua("LuaULSetUnderline", set_underline_func, "protected")
set_lua("LuaULResetUnderline", reset_underline_func, "protected")
functions[new_underline_type_func] = new_underline_type
functions[set_underline_func] = set_underline
functions[reset_underline_func] = reset_underline

local stretch_fi = {}
local shrink_fi = {}
local function fil_levels(n)
  for i=0,4 do
    stretch_fi[i], shrink_fi[i] = 0, 0
  end
  for n in traverse_id(glue_t, n) do
    local w, st, sh, sto, sho = getglue(n)
    stretch_fi[sto] = stretch_fi[sto] + st
    shrink_fi[sho] = shrink_fi[sho] + sh
  end
  local stretch, shrink = 0, 0
  for i=0,4 do
    if stretch_fi[i] ~= 0 then
      stretch = i
    end
    if shrink_fi[i] ~= 0 then
      shrink = i
    end
  end
  return stretch, shrink
end
local function new_glue_neg_dimensions(n, t,
                                       stretch_order, shrink_order)
  local g = nodenew(glue_t)
  local w = -dimensions(n, t)
  setglue(g, w)
  setnext(g, n)
  setglue(g, w, -dimensions(1, 1, stretch_order, g, t),
                   dimensions(1, 2, shrink_order, g, t),
                   stretch_order, shrink_order)
  setnext(g, nil)
  return g
end

local add_underline_hlist, add_underline_hbox, add_underline_vbox
local function add_underline_vlist(head, attr, outervalue)
  local iter, state, n = traverse_list(head) -- FIXME: unset nodes
  local t
  n, t = iter(state, n)
  while n ~= nil do
    local real_new_value = has_attribute(n, attr)
    local new_value = real_new_value ~= outervalue
                        and real_new_value or nil
    if underline_strict_flag[new_value] or not new_value then
      if t == hlist_t then
        add_underline_hbox(n, attr, real_new_value)
      elseif t == vlist_t then
        add_underline_vbox(n, attr, real_new_value)
      end
      n, t = iter(state, n)
    elseif real_new_value <= 0 then
      n, t = iter(state, n)
    else
      local nn
      nn, t = iter(state, n)
      local prev, next = getboth(n)
      setboth(n, nil, nil)
      local shift = getshift(n)
      setshift(n, 0)
      local new_list = hpack((add_underline_hlist(n, attr)))
      setheight(new_list, getheight(n))
      setdepth(new_list, getdepth(n))
      setshift(new_list, shift)
      setlink(prev, new_list, next)
      set_attribute(new_list, attr, 0)
      if n == head then
        head = new_list
      end
      n = nn
    end
  end
  return head
end
function add_underline_vbox(head, attr, outervalue)
  if outervalue and outervalue <= 0 then return end
  setList(head, add_underline_vlist(getList(head), attr, outervalue))
  set_attribute(head, attr, outervalue and -outervalue or 0)
end
function add_underline_hlist(head, attr, outervalue)
  local max_height, max_depth
  slide(head)
  local last_value
  local first
  local shrink_order, stretch_order
  for n, id, subtype in traverse(head) do
    local real_new_value = has_attribute(n, attr)
    local new_value
    if real_new_value then
      if real_new_value > 0 then
        set_attribute(n, attr, -real_new_value)
        new_value = real_new_value ~= outervalue
                      and real_new_value or nil
      end
    else
      set_attribute(n, attr, 0)
    end
    if id == hlist_t then
      if underline_strict_flag[new_value]
          or subtype == 3 or not new_value then
        add_underline_hbox(n, attr, real_new_value)
        new_value = nil
      end
    elseif id == vlist_t then
      if underline_strict_flag[new_value] or not new_value then
        add_underline_vbox(n, attr, real_new_value)
        new_value = nil
      end
    elseif id == kern_t and subtype == 0 then
      local after = getnext(n)
      if after then
        local next_value = has_attribute(after, attr)
        if next_value == outervalue or not next_value then
          new_value = nil
        else
          new_value = last_value
        end
      else
        new_value = last_value
      end
    elseif id == glue_t and (
        subtype == 8 or
        subtype == 9 or
        subtype == 15 or
    false) then
      new_value = nil
    end
    if last_value ~= new_value then
      if not stretch_order then
        stretch_order, shrink_order = fil_levels(head)
      end
      if last_value then
        local glue = new_glue_neg_dimensions(first, n,
            stretch_order, shrink_order)
        local w, st, sh = getglue(glue)
        local lead = nodecopy(underline_types[last_value])
        setglue(lead, -w, -st, -sh, stretch_order, shrink_order)
        if underline_over_flag[last_value] then
          head = insert_before(head, n, glue)
          insert_after(head, glue, lead)
        else
          head = insert_before(head, first, lead)
          insert_after(head, lead, glue)
        end
      end
      if new_value then
        first = n
        local box = getleader(underline_types[new_value])
        if not max_height or getheight(box) > max_height then
          max_height = getheight(box)
        end
        if not max_depth or getdepth(box) > max_depth then
          max_depth = getdepth(box)
        end
      end
      last_value = new_value
    end
  end
  if last_value then
    local glue = new_glue_neg_dimensions(first, nil,
        stretch_order, shrink_order)
    local w, st, sh = getglue(glue)
    local lead = nodecopy(underline_types[last_value])
    setglue(lead, -w, -st, -sh, stretch_order, shrink_order)
    if underline_over_flag[last_value] then
      insert_before(head, nil, glue)
      insert_after(head, glue, lead)
    else
      head = insert_before(head, first, lead)
      insert_after(head, lead, glue)
    end
  end
  return head, max_height, max_depth
end
function add_underline_hbox(head, attr, outervalue, set_height_depth)
  if outervalue and outervalue <= 0 then return end
  local new_head, new_height, new_depth
      = add_underline_hlist(getList(head), attr, outervalue)
  setList(head, new_head)
  if set_height_depth then
    if new_height and getheight(head) < new_height then
      setheight(head, new_height)
    end
    if new_depth and getdepth(head) < new_depth then
      setdepth(head, new_depth)
    end
  end
  set_attribute(head, attr, outervalue and -outervalue or 0)
end
require'pre_append_to_vlist_filter'
luatexbase.add_to_callback('pre_append_to_vlist_filter',
    function(b, loc, prev, mirror)
      local props = properties[todirect(texnest.top.head)]
      props = props and props.luaul_attributes
      b = todirect(b)
      if loc == "post_linebreak" then
        for i = 1, #underlineattrs do
          local attr = underlineattrs[i]
          local current = props and props[attr] or tex.attribute[attr]
          if current == -0x7FFFFFFF then
            current = nil
          end
          add_underline_hbox(b, underlineattrs[i], current, true)
        end
      else
        for i = 1, #underlineattrs do
          local attr = underlineattrs[i]
          local current = props and props[attr] or tex.attribute[attr]
          local b_attr = has_attribute(b, attr)
          if b_attr and b_attr ~= current then
            local shift = getshift(b)
            setshift(b, 0)
            b = hpack((add_underline_hlist(b, attr)))
            setshift(b, shift)
            set_attribute(b, attr, 0)
          end
        end
      end
      return tonode(b)
    end, 'add underlines to list')
luatexbase.add_to_callback('hpack_filter',
    function(head, group, size, pack, dir, attr)
      head = todirect(head)
      for i = 1, #underlineattrs do
        local ulattr = underlineattrs[i]
        local current
        for n in node.traverse(attr) do
          if n.number == ulattr then
            current = n.value
          end
        end
        head = add_underline_hlist(head, ulattr, current)
      end
      return tonode(head)
    end, 'add underlines to list')
luatexbase.add_to_callback('vpack_filter',
    function(head, group, size, pack, maxdepth, dir, attr)
      head = todirect(head)
      for i = 1, #underlineattrs do
        local ulattr = underlineattrs[i]
        local current
        for n in node.traverse(attr) do
          if n.number == ulattr then
            current = n.value
          end
        end
        head = add_underline_vlist(head, ulattr, current)
      end
      return tonode(head)
    end, 'add underlines to list')
-- 
--
-- End of file `lua-ul.lua'.
