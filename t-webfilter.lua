thirddata           = thirddata           or {}
thirddata.webfilter = thirddata.webfilter or {}

local webfilter = thirddata.webfilter

local trace_webfilter = false
trackers.register("thirddata.webfilter", function(v) trace_webfilter = v end)
local report_webfilter = logs.new("thirddata.webfilter") 

local match = string.match
local gsub  = string.gsub

local tinsert = table.insert
local tconcat = table.concat


function webfilter.processwebfilter(name, prefix, suffix, figuresetup, transform)
  local content = transform(name)
  local url = prefix .. content .. suffix

  if trace_webfilter then
    report_webfilter("downloading url %s", url)
  end
  
  local specification = resolvers.splitmethod(url) 

  local file       = resolvers.finders['http'](specification) or ""

  if trace_webfilter then
    if file and file ~= "" then
      report_webfilter("saving file %s", file)
    else
      report_webfilter("download failed")
    end
  end

  context.externalfigure({file}, {figuresetup})
end

-- Useful data transformation

webfilter.transform = {}

-- The default transformation:
-- Dedent the buffer and remove empty lines
function webfilter.transform.default(name, sep)
        sep      = sep or ","
  local content  = buffers.getcontent(name)
  local lines    = string.splitlines(content)
  local indent   = match(lines[1], '^ +') or ''
  local result   = {}
  local pattern  = '^' .. indent
  for i=1,#lines do
    lines[i] = gsub(lines[i],pattern,"")
    -- remove empty lines
    if gsub(lines[i], '^%s*$', '') ~= "" then
      tinsert(result,lines[i])
    end
  end
  content = tconcat(result,sep)
  return content
end

