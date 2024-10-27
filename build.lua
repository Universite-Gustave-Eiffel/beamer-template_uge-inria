#!/usr/bin/env texlua

--[[
  ** Build config for gothamSubThemes using l3build **
--]]

-- Identification
module     = "gothamSubThemes"
pkgversion = "0.1"
pkgdate    = "2023-12-01"

-- 
-- CONFIGURATION of files for build and installation
-- 
maindir       = "." -- Top level directory for the module/bundle
sourcefiledir = "./sources" -- Directory containing source files
sourcefiles   = {"*.dtx", "*.ins", sourcefiledir.."*/", "*.sty"} -- Files to copy for unpacking
installfiles  = { sourcefiledir.."*/","*.sty", "*.cls", "*.pdf",} -- Files to install to the tex area of the texmf tree
-- local fake_tds = "build/distrib" -- Define the fake TDS directory
-- supportdir = "./sources/" -- Directory containing general support files
-- typesetsuppfiles = { "original*/" } -- Files needed to support typesetting when “sandboxed”


-- 
-- DOCUMENTATION + EXAMPLES
-- 

-- -- Generating documentation
-- textfiledir   = "original/tests" -- Directory containing plain text files
-- textfiles     = {"ctan/CTANREADME.md"} -- Plain text files to send to CTAN as-is
-- docfiledir = "./doc" -- Directory containing documentation files
docfiles = {"resources*/", "supplies*/", "parts*/", "original*/", sourcefiledir.."*/" } --Files which are part of the documentation but should not be typeset
-- demofiles = {"original/Simplest_example.tex", } -- Files which show how to use a module
-- typesetdemofiles = {"original/Simplest_example.tex", } --{"ready2Go.tex",} -- Files to typeset before the documentation for inclusion in main documentation files --"original/examples_*/*.tex","original/*.tex", "parts/*.tex"

-- typesetdir = "build/doc"
-- typesetfiles  = {"original/Simplest_example.tex", } --{ ""..module.."-example.tex", ""..module..".dtx", ""..module.."-doc.tex", } --,    ""..module.."-user-cmds.tex", ""..module.."-dev-implementation.tex" -- Files to typeset for documentation
typesetexe    = "pdflatex" -- Executable for compiling doc(s)
typesetopts   = "--shell-escape" --Options passed to engine when typesetting
-- typesetruns   = 3 --Number of cycles of typesetting to carry out
-- typesetcmds = "" -- Instructions to be passed to TEX when doing typesetting

-- -- Function to typeset files within their subdirectories
-- function typesetoriginal()
--   -- local typesetfile = "doc/original/example.tex"
--   local errorlevel = -1 --call(typesetengine, "-interaction=batchmode", typesetfile)
--   if errorlevel ~= 0 then
--     error("Typesetting failed for " .. typesetfile)
--   end
-- end

-- -- Typeset target
-- typesettargets = {"typesetoriginal"}

-- 
-- UNIT TESTS
-- 

testfiledir = "./original/tests/gotham" -- Directory containing test files
-- testsuppdir = testfiledir .. "/support" -- Directory containing test-specific support files
checksearch = true -- Enable command printing during check phase


-- EoF