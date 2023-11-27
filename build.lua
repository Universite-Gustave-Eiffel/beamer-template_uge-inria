#!/usr/bin/env texlua

--[[
  ** Build config for demopkg using l3build **
--]]

-- Identification
module     = "demopkg"
pkgversion = "0.1"
pkgdate    = "2023-02-19"

-- 
-- CONFIGURATION of files for build and installation
-- 
maindir       = "." -- Top level directory for the module/bundle
sourcefiledir = "./src" -- Directory containing source files
-- sourcefiles   = {"*.dtx", "*.ins"} -- Files to copy for unpacking
installfiles  = {"*.sty", "*.cls", "*.pdf",} -- Files to install to the tex area of the texmf tree
-- tdslocations  = {
--   "source/latex/"..module.."/"..module..".dtx",
--   "source/latex/"..module.."/"..module..".ins",
--   "doc/latex/"..module.."/example/"..module.."-example.tex",
--   "doc/latex/"..module.."/example/"..module.."-example.pdf",
--   "doc/latex/"..module.."/"..module.."-doc.pdf",
--   "doc/latex/"..module.."/"..module..".pdf",
--   "doc/latex/"..module.."/"..module.."-dev-implementation.pdf",
--   "doc/latex/"..module.."/"..module.."-user-cmds.pdf",
--   "tex/latex/"..module.."/"..module..".sty"
-- }
-- local fake_tds = "build/distrib" -- Define the fake TDS directory


-- 
-- UNPACKING
-- 

-- Unpacking files from .dtx file
unpackfiles = {""..module..".ins"} -- Files to run to perform unpacking
unpackopts  = "--interaction=batchmode" -- Options passed to engine when unpacking
-- unpackexe   = "luatex" -- Executable for running unpack


-- 
-- DOCUMENTATION + EXAMPLES
-- 

-- Generating documentation
textfiledir   = "./src" -- Directory containing plain text files
textfiles     = {"ctan/CTANREADME.md"} -- Plain text files to send to CTAN as-is
-- docfiledir = "./doc" -- Directory containing documentation files
docfiles = {"examples/*.tex", "doc/"..module.."-doc.tex", } --Files which are part of the documentation but should not be typeset
-- demofiles = {"examples/*.tex"} -- Files which show how to use a module
-- typesetdemofiles = {"examples/"..module.."-example.tex"} -- Files to typeset before the documentation for inclusion in main documentation files

typesetfiles  = { ""..module.."-example.tex", ""..module..".dtx", ""..module.."-doc.tex", } --,    ""..module.."-user-cmds.tex", ""..module.."-dev-implementation.tex" -- Files to typeset for documentation
-- typesetexe    = "pdflatex" -- Executable for compiling doc(s)
typesetopts   = "-interaction=batchmode --shell-escape" --Options passed to engine when typesetting
-- typesetruns   = 3 --Number of cycles of typesetting to carry out
-- typesetcmds = "" -- Instructions to be passed to TEX when doing typesetting


-- 
-- UNIT TESTS
-- 

-- testfiledir = "./testfiles" -- Directory containing test files
-- testsuppdir = testfiledir .. "/support" -- Directory containing test-specific support files
checksearch = true -- Enable command printing during check phase



-- 
-- PACKAGING FOR CTAN
-- 

-- Update package date and version
tagfiles = {sourcefiledir.."/"..module..".dtx", "ctan/CTANREADME.md"}
local mydate = os.date("!%Y-%m-%d")

function update_tag(file, content, tagname, tagdate)
  if not tagname and tagdate == mydate then
    tagname = pkgversion
    tagdate = pkgdate
    print("** "..file.." have been tagged with the version and date of build.lua")
  else
    local v_maj, v_min = string.match(tagname, "^v?(%d+)(%S*)$")
    if v_maj == "" or not v_min then
      print("Error!!: Invalid tag '"..tagname.."', none of the files have been tagged")
      os.exit(0)
    else
      tagname = string.format("%i%s", v_maj, v_min)
      tagdate = mydate
    end
    print("** "..file.." have been tagged with the version "..tagname.." and date "..mydate)
  end

  if string.match(file, ""..module..".dtx") then
    local tagdate = string.gsub(tagdate, "-", "/")
    content = string.gsub(content,
                          "%[%d%d%d%d%/%d%d%/%d%d%s+v%S+",
                          "["..tagdate.." v"..tagname)
  end

  if string.match(file, "ctan/CTANREADME.md") then
    local tagdate = string.gsub(tagdate, "/", "-")
    content = string.gsub(content,
                          "Version: (%d+)(%S+)",
                          "Version: "..tagname)
    content = string.gsub(content,
                          "Date: %d%d%d%d%-%d%d%-%d%d",
                          "Date: "..tagdate)
  end
  return content
end

-- Configuration for ctan
ctanreadme = "ctan/CTANREADME.md"
ctanpkg    = module
ctanzip    = ctanpkg.."-"..pkgversion
packtdszip = false


uploadconfig = {
  author      = "Your name",
  uploader    = "Your name too",
  email       = "Your.name@domain.com",
  pkg         = ctanpkg,
  version     = pkgversion,
  license     = "lppl1.3c",
  summary     = "A demo package",
  description = [[An example of the use of l3build]],
  topic       = { "Some topic A", "Some topic B" },
  ctanPath    = "/macros/latex/contrib/" .. ctanpkg,
  repository  = "https://github.com/yourrepo/"..module,
  bugtracker  = "https://github.com/yourrepo/"..module.."/issues",
  support     = "https://github.com/yourrepo/"..module.."/issues",
  announcement_file="ctan/ctan.ann",
  note_file   = "ctan/ctan.note",
  update      = true,
}

-- Clean files
cleanfiles = {
  ctanzip..".curlopt",
  ctanzip..".zip",
  ""..module.."-example.log",
  ""..module.."-example.pdf",
  ""..module..".pdf",
}

-- Line length in 80 characters
local function os_message(text)
  local mymax = 77 - string.len(text) - string.len("done")
  local msg = text.." "..string.rep(".", mymax).." done"
  return print(msg)
end

-- Create check_marked_tags() function
local function check_marked_tags()
  local f = assert(io.open(sourcefiledir.."/"..module..".dtx", "r"))
  marked_tags = f:read("*all")
  f:close()

  local m_pkgd, m_pkgv = string.match(marked_tags, "%ProvidesExplPackage{"..module.."}{(%d%d%d%d%/%d%d%/%d%d)}{(%S+)}")
  local pkgdate = string.gsub(pkgdate, "-", "/")
  if pkgversion == m_pkgv and pkgdate == m_pkgd then
    os_message("** Checking version and date in "..module..".dtx: OK")
  else
    print("** Warning: "..module..".dtx is marked with version "..m_pkgv.." and date "..m_pkgd)
    print("** Warning: build.lua is marked with version "..pkgversion.." and date "..pkgdate)
    print("** Check version and date in build.lua then run l3build tag")
    os.exit(2)
  end
end

-- Config tag_hook
function tag_hook(tagname)
  check_marked_tags()
end

-- Add "tagged" target to l3build CLI
if options["target"] == "tagged" then
  check_marked_tags()
  os.exit()
end

-- Create make_temp_dir() function
local function make_temp_dir()
  -- Fix basename(path) in windows
  local function basename(path)
    return path:match("^.*[\\/]([^/\\]*)$")
  end
  local tmpname = os.tmpname()
  tempdir = basename(tmpname)
  errorlevel = mkdir(tempdir)
  if errorlevel ~= 0 then
    error("** Error!!: The ./"..tempdir.." directory could not be created")
    return errorlevel
  else
    os_message("** Creating the temporary directory ./"..tempdir..": OK")
  end
end

-- Add "testpkg" target to l3build CLI
if options["target"] == "testpkg" then
  make_temp_dir()
  errorlevel = cp("*.*", sourcefiledir, tempdir)
  if errorlevel ~= 0 then
    error("** Error!!: Can't copy files from "..sourcefiledir.." to /"..tempdir)
    return errorlevel
  else
    os_message("** Copying files from "..sourcefiledir.." to ./"..tempdir..": OK")
  end
  -- Unpack files
  local file = jobname(tempdir.."/"..module..".dtx")
  errorlevel = run(tempdir, "pdftex -interaction=batchmode "..file..".dtx > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: pdftex -interaction=batchmode "..file..".dtx")
    return errorlevel
  else
    os_message("** Running: pdftex -interaction=batchmode "..file..".dtx")
  end
  -- pdflatex
  local file = jobname(tempdir.."/example.tex")
  errorlevel = run(tempdir, "pdflatex -interaction=nonstopmode "..file.." > "..os_null)
  if errorlevel ~= 0 then
    error("** Error!!: pdflatex -interaction=nonstopmode "..file..".tex")
    return errorlevel
  else
    os_message("** Running: pdflatex -interaction=nonstopmode "..file..".tex")
  end
  -- Copying
  os_message("** Copying "..file..".log and "..file..".pdf files to main dir: OK")
  cp("example.log", tempdir, maindir)
  cp("example.pdf", tempdir, maindir)
  -- Clean
  os_message("** Remove temporary directory ./"..tempdir..": OK")
  cleandir(tempdir)
  lfs.rmdir(tempdir)
  os.exit()
end


-- 
-- RELEASING THE PACKAGE ON GIT and CTAN
-- 

-- Creating the os_capture(cmd, raw) function
local function os_capture(cmd, raw)
  local f = assert(io.popen(cmd, 'r'))
  local s = assert(f:read('*a'))
  f:close()
  if raw then return s end
    s = string.gsub(s, '^%s+', '')
    s = string.gsub(s, '%s+$', '')
    s = string.gsub(s, '[\n\r]+', ' ')
  return s
end

-- Add "release" target to l3build CLI
if options["target"] == "release" then
  -- Capture output of git commands
  local gitbranch = os_capture("git symbolic-ref --short HEAD")
  local gitstatus = os_capture("git status --porcelain")
  local tagongit  = os_capture('git for-each-ref refs/tags --sort=-taggerdate --format="%(refname:short)" --count=1')
  local gitpush   = os_capture("git log --branches --not --remotes")

  if gitbranch == "master" or gitbranch == "main" then
    os_message("** Checking git branch '"..gitbranch.."': OK")
  else
    error("** Error!!: You must be on the 'master' branch")
  end
  if gitstatus == "" then
    os_message("** Checking status of the files: OK")
  else
    error("** Error!!: Files have been edited, please commit all changes")
  end
  if gitpush == "" then
    os_message("** Checking pending commits: OK")
  else
    error("** Error!!: There are pending commits, please run git push")
  end
  check_marked_tags()

  local pkgversion = "v"..pkgversion
  os_message("** Checking last tag marked in GitHub "..tagongit..": OK")
  errorlevel = os.execute("git tag -a "..pkgversion.." -m 'Release "..pkgversion.." "..pkgdate.."'")
  if errorlevel ~= 0 then
    error("** Error!!: tag "..tagongit.." already exists, run git tag -d "..pkgversion.." && git push --delete origin "..pkgversion)
    return errorlevel
  else
    os_message("** Running: git tag -a "..pkgversion.." -m 'Release "..pkgversion.." "..pkgdate.."'")
  end
  os_message("** Running: git push --tags --quiet")
  os.execute("git push --tags --quiet")
  if fileexists(ctanzip..".zip") then
    os_message("** Checking "..ctanzip..".zip file to send to CTAN: OK")
  else
    os_message("** Creating "..ctanzip..".zip file to send to CTAN")
    os.execute("l3build ctan > "..os_null)
  end
  os_message("** Running: l3build upload -F ctan.ann --debug")
  os.execute("l3build upload -F ctan.ann --debug >"..os_null)
  print("** Now check "..ctanzip..".curlopt file and add changes to ctan.ann")
  print("** If everything is OK run (manually): l3build upload -F ctan.ann")
  os.exit(0)
end

-- EoF