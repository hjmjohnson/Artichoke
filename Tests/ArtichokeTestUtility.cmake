function(check_variable var_name expected_value)
  if(NOT "x${${var_name}}" STREQUAL "x${expected_value}")
    message(FATAL_ERROR "CMake variable [${var_name}] is incorrectly set !\n"
                        "current:${${var_name}}\n"
                        "expected:${expected_value}")
  endif()
endfunction()

function(configure_external_projects_for_test name)
  set(depends "${expected_${name}_DEPENDS}")
  set(indent "${ARGV1}")
  if(ARGC EQUAL 1)
    message(STATUS "----------------------------------------")
    message(STATUS "Configuring external projects")
    set(indent "")
  endif()
  set(txt ${indent})
  if(depends STREQUAL "")
    set(txt "${txt}\\-")
    set(indent "${indent}  ")
  else()
    set(txt "${txt}|-")
    set(indent "${indent}| ")
  endif()
  set(txt "${txt}${name}")
  if(optional_${name})
    set(txt "${txt} [Optional]")
  endif()
  message("\# ${txt}")

  foreach(dep ${depends})
    set(_ep_file ${EXTERNAL_PROJECT_DIR}/External_${dep}.cmake)
    if(NOT EXISTS ${_ep_file})
      set(PROJECT_NAME_CONFIG ${dep})
      set(PROJECT_DEPENDS_CONFIG ${expected_${dep}_DEPENDS})
      set(PROJECT_REQUIRED_DEPENDS_CONFIG ${expected_${dep}_REQUIRED_DEPENDS})
      set(LIB_EXTERNAL_PROJECT_INCLUDE_DEPENDENCIES_EXTRA_ARGS "${${dep}_EXTERNAL_PROJECT_INCLUDE_DEPENDENCIES_EXTRA_ARGS}")
      configure_file(../External_Lib.cmake.in ${_ep_file} @ONLY)
      set(LIB_EXTERNAL_PROJECT_INCLUDE_DEPENDENCIES_EXTRA_ARGS "")
    endif()
    configure_external_projects_for_test(${dep} ${indent})
  endforeach()
  if(ARGC EQUAL 1)
    message(STATUS "----------------------------------------")
  endif()
endfunction()

function(check_for_uses_terminal proj varname)
  ExternalProject_Message(${proj} "Checking for USES_TERMINAL_* in variable ${varname}")
  foreach(step IN ITEMS DOWNLOAD UPDATE CONFIGURE BUILD TEST INSTALL)
    list(FIND ${varname} USES_TERMINAL_${step} _uses_terminal_index)
    if(CMAKE_VERSION VERSION_EQUAL "3.4" OR CMAKE_VERSION VERSION_GREATER "3.4")
      if(_uses_terminal_index EQUAL -1)
        message(FATAL_ERROR "USES_TERMINAL_${step} is expected to be in list ${varname} [${${varname}}]")
      endif()
    else()
      if(NOT _uses_terminal_index EQUAL -1)
        message(FATAL_ERROR "USES_TERMINAL_${step} is NOT expected to be in list ${varname} [${${varname}}]")
      endif()
    endif()
  endforeach()
endfunction()
