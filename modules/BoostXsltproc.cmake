##########################################################################
# Copyright (C) 2008 Douglas Gregor <doug.gregor@gmail.com>              #
# Copyright (C) 2011 Daniel Pfeifer <daniel@pfeifer-mail.de>             #
#                                                                        #
# Distributed under the Boost Software License, Version 1.0.             #
# See accompanying file LICENSE_1_0.txt or copy at                       #
#   http://www.boost.org/LICENSE_1_0.txt                                 #
##########################################################################


# Transforms the input XML file by applying the given XSL stylesheet.
#
#   boost_xsltproc(<output> <stylesheet> <input>
#     [CATALOG <catalog>]
#     [PARAMETERS param1=value1 param2=value2 ...]
#     [DEPENDS <dependancies>]
#     )
#
# This function builds a custom command that transforms an XML file
# (input) via the given XSL stylesheet. 
#
# XML catalogs can be used to remap parts of URIs within the
# stylesheet to other (typically local) entities. To provide an XML
# catalog file, specify the name of the XML catalog file via the
# CATALOG argument. It will be provided to the XSL transform.
#
# The PARAMETERS argument is followed by param=value pairs that set
# additional parameters to the XSL stylesheet. The parameter names
# that can be used correspond to the <xsl:param> elements within the
# stylesheet.
#
# Additional dependancies may be passed via the DEPENDS argument.
# For example, dependancies might refer to other XML files that are
# included by the input file through XInclude.
function(boost_xsltproc output stylesheet input)
endfunction(boost_xsltproc)


if(NOT BOOST_BUILD_DOCUMENTATION)
  return()
endif(NOT BOOST_BUILD_DOCUMENTATION)


function(boost_xsltproc output stylesheet input)
  cmake_parse_arguments(THIS_XSL "" "CATALOG" "PARAMETERS;DEPENDS" ${ARGN})

  set(catalog)
  if(THIS_XSL_CATALOG)
    set(catalog "XML_CATALOG_FILES=${THIS_XSL_CATALOG}")
    if(CMAKE_HOST_WIN32)
      set(catalog set "${catalog}" &)
    endif(CMAKE_HOST_WIN32)
  endif(THIS_XSL_CATALOG)

  # Translate XSL parameters into a form that xsltproc can use.
  set(stringparams)
  foreach(param ${THIS_XSL_PARAMETERS})
    string(REGEX REPLACE "([^=]*)=([^;]*)" "\\1;\\2" name_value ${param})
    list(GET name_value 0 name)
    list(GET name_value 1 value)
    list(APPEND stringparams --stringparam ${name} ${value})
  endforeach(param)

  # Run the XSLT processor to do the XML transformation.
  add_custom_command(OUTPUT ${output}
    COMMAND ${catalog} ${XSLTPROC_EXECUTABLE} --xinclude --nonet
            ${stringparams} -o ${output} ${stylesheet} ${input}
    DEPENDS ${input} ${THIS_XSL_DEPENDS}
    WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
    )
endfunction(boost_xsltproc)
