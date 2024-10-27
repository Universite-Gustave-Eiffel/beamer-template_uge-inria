cmake_minimum_required (VERSION 3.20)

#------------------------------------------------------------------------------
# Project info

# Set parameters of the Project
set(PROJECT_NAME gothamSubThemes)
set(PROJECT_VERSION 1.2.0.1)
set("PROJECT_DESCRIPTION" "A collection of institutions beamer themes using Gotham package.")
set("PROJECT_HOMEPAGE_URL" "https://gitlab.com/irreductibles_gaulois/gothamSubThemes")
set(PROJECT_SITE_METHOD git) # wget, scp, git, svn, file, local 
set(PROJECT_DATE "01.02.2023")

# Project setup, versioning stuff here, change when changing the version
# Note: keep the project name lower case only for easy linux packaging support
project(${PROJECT_NAME} VERSION ${PROJECT_VERSION})
site_name(VERSION_HOST) # read hostname to VERSION_HOST
set(VERSION_HOST "${VERSION_HOST}" CACHE STRING "host of build" FORCE)

message(STATUS "")
message(STATUS "    == ${PROJECT_NAME} Project configuration == " )
message(STATUS "")

set(${PROJECT_NAME}_NAME ${PROJECT_NAME})
set(${PROJECT_NAME}_VERSION ${PROJECT_VERSION})
set(${PROJECT_NAME}_DESCRIPTION ${PROJECT_DESCRIPTION})
set(${PROJECT_NAME}_HOMEPAGE_URL ${PROJECT_HOMEPAGE_URL})
set(${PROJECT_NAME}_SITE_METHOD ${PROJECT_SITE_METHOD})
set(${PROJECT_NAME}_DATE ${PROJECT_DATE})


#------------------------------------------------------------------------------
# General settings

# Check if this project is the master project or a slave.
if(PROJECT_SOURCE_DIR STREQUAL CMAKE_SOURCE_DIR)
    set(${PROJECT_NAME}_MASTER_PROJECT ON)
endif()

# We can use include() and find_package() for our scripts in there
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
# include(projectSetting)
include(UseLATEX.cmake) #https://gitlab.kitware.com/kmorel/UseLATEX

#------------------------------------------------------------------------------

add_latex_document(ready2Go.tex)

# EoF