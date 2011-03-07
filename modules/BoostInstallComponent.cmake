##########################################################################
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################

string(TOLOWER ${CMAKE_INSTALL_CONFIG_NAME} config)
string(TOUPPER ${CMAKE_INSTALL_CONFIG_NAME} CONFIG)
set(export_dir "${CMAKE_BINARY_DIR}/export/${CMAKE_INSTALL_CONFIG_NAME}")
file(STRINGS ${BOOST_TARGETS} targets)

##########################################################################
# write component file

set(config_file_prefix "${CMAKE_BINARY_DIR}/install/${BOOST_PROJECT}")
set(component_file "${config_file_prefix}.cmake")

set(include_guard "_boost_${BOOST_PROJECT}_component_included")

file(WRITE ${component_file}
  "#\n\n"
  "if(${include_guard})\n"
  "  return()\n"
  "endif(${include_guard})\n"
  "set(${include_guard} TRUE)\n\n"
  )

foreach(depend ${BOOST_DEPENDS})
  file(APPEND ${component_file}
    "include(\${CMAKE_CURRENT_LIST_DIR}/${depend}.cmake)\n"
    )
endforeach(depend)

file(READ ${BOOST_EXPORTS} exports)
file(APPEND ${component_file} "${exports}")

if(targets)
  file(APPEND ${component_file} "\n"
    "file(GLOB config_files \"\${CMAKE_CURRENT_LIST_DIR}/${BOOST_PROJECT}-*.cmake\")\n"
    "foreach(file \${config_files})\n"
    "  include(\"\${file}\")\n"
    "endforeach(file)\n"
    )
endif(targets)

file(INSTALL
  DESTINATION "${CMAKE_INSTALL_PREFIX}/share/boost/CMake/components"
  TYPE FILE
  FILES "${component_file}"
  )

##########################################################################
# write config file (if there are any targets)

if(NOT targets)
  return()
endif(NOT targets)

set(config_file "${config_file_prefix}-${config}.cmake")

file(WRITE "${config_file}"
  "#\n"
  )

foreach(target ${targets})
  file(READ "${export_dir}/${target}.txt" location)
  file(APPEND ${config_file} "\n"
    "set_property(TARGET \${BOOST_NAMESPACE}${target} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${CONFIG})\n"
    "set_property(TARGET \${BOOST_NAMESPACE}${target} PROPERTY IMPORTED_LOCATION_${CONFIG} \"${location}\")\n"
    )
endforeach(target)

file(INSTALL
  DESTINATION "${CMAKE_INSTALL_PREFIX}/share/boost/CMake/components"
  TYPE FILE
  FILES "${config_file}"
  )
