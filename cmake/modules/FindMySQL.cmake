# - Find MySQL
# Find the MySQL includes and client library
# This module defines
#  MYSQL_INCLUDE_DIR, where to find mysql.h
#  MYSQL_LIBRARIES, the libraries needed to use MySQL.
#  MYSQL_FOUND, If false, do not try to use MySQL.
#
# Copyright (c) 2006, Jaroslaw Staniek, <js@iidea.pl>
# Lot of adustmens by Michal Cihar <michal@cihar.com>
#
# vim: expandtab sw=4 ts=4 sts=4:
#
# Redistribution and use is allowed according to the terms of the BSD license.

if(UNIX) 
    set(MYSQL_CONFIG_PREFER_PATH "$ENV{MYSQL_HOME}/bin" CACHE FILEPATH
        "preferred path to MySQL (mysql_config)" FORCE)
    find_program(MARIADB_CONFIG mariadb_config
        ${MYSQL_CONFIG_PREFER_PATH}
        /usr/local/mariadb/bin/
        /usr/local/mysql/bin/
        /usr/local/bin/
        /usr/bin/
        )

    if(MARIADB_CONFIG)
        message(STATUS "Found mariadb_config: ${MARIADB_CONFIG}")
        set(MYSQL_CONFIG ${MARIADB_CONFIG})
        exec_program(${MARIADB_CONFIG}
            ARGS --tlsinfo
            OUTPUT_VARIABLE MY_TMP)
        string(STRIP ${MY_TMP} MY_TMP)
        if (NOT ${MY_TMP} STREQUAL "")
            set(MARIADB_SSL TRUE CACHE INTERNAL "libmariadb ssl" FORCE)
        else()
            set(MARIADB_SSL FALSE CACHE INTERNAL "libmariadb ssl" FORCE)
        endif()
        set(MARIADB_FOUND TRUE CACHE INTERNAL "libmariadb found" FORCE)
    else()
        set(MARIADB_FOUND FALSE CACHE INTERNAL "libmariadb found" FORCE)
    endif()

    if(NOT MYSQL_CONFIG)
        find_program(MYSQL_CONFIG mysql_config
            ${MYSQL_CONFIG_PREFER_PATH}
            /usr/local/mysql/bin/
            /usr/local/bin/
            /usr/bin/
            )
    endif()
    
    if(MYSQL_CONFIG) 
        message(STATUS "Using mysql-config: ${MYSQL_CONFIG}")
        # set CFLAGS
        exec_program(${MYSQL_CONFIG}
            ARGS --cflags
            OUTPUT_VARIABLE MY_TMP)

        set(MYSQL_CFLAGS ${MY_TMP} CACHE STRING INTERNAL FORCE)

        # set INCLUDE_DIR
        exec_program(${MYSQL_CONFIG}
            ARGS --include
            OUTPUT_VARIABLE MY_TMP)

        string(REGEX REPLACE "-I([^ ]*)( .*)?" "\\1" MY_TMP "${MY_TMP}")

        set(MYSQL_ADD_INCLUDE_DIR ${MY_TMP} CACHE FILEPATH INTERNAL FORCE)

        # set LIBRARY_DIR
        exec_program(${MYSQL_CONFIG}
            ARGS --libs_r
            OUTPUT_VARIABLE MY_TMP)

        set(MYSQL_ADD_LIBRARIES "")

        # prepend space in order to match separate words only (e.g. rather
        # than "-linux" from within "-L/usr/lib/i386-linux-gnu")
        string(REGEX MATCHALL " +-l[^ ]*" MYSQL_LIB_LIST " ${MY_TMP}")
        foreach(MY_LIB ${MYSQL_LIB_LIST})
            string(REGEX REPLACE "[ ]*-l([^ ]*)" "\\1" MY_LIB "${MY_LIB}")
            list(APPEND MYSQL_ADD_LIBRARIES "${MY_LIB}")
        endforeach(MY_LIB ${MYSQL_LIBS})

        set(MYSQL_ADD_LIBRARY_PATH "")

        string(REGEX MATCHALL " +-L[^ ]*" MYSQL_LIBDIR_LIST " ${MY_TMP}")
        foreach(MY_LIB ${MYSQL_LIBDIR_LIST})
            string(REGEX REPLACE "[ ]*-L([^ ]*)" "\\1" MY_LIB "${MY_LIB}")
            list(APPEND MYSQL_ADD_LIBRARY_PATH "${MY_LIB}")
        endforeach(MY_LIB ${MYSQL_LIBS})
    else(MYSQL_CONFIG)
        set(MYSQL_ADD_LIBRARIES "")
        list(APPEND MYSQL_ADD_LIBRARIES "mysqlclient")
    endif(MYSQL_CONFIG)
else(UNIX)
    set(MYSQL_ADD_INCLUDE_DIR "c:/msys/local/include" CACHE FILEPATH INTERNAL FORCE)
    set(MYSQL_ADD_LIBRARY_PATH "c:/msys/local/lib" CACHE FILEPATH INTERNAL FORCE)
ENDIF(UNIX)

find_path(_include_dir NAMES "mysql.h"
    PATHS "${MYSQL_ADD_INCLUDE_DIR}"
    /usr/local/include
    /usr/local/mysql/include
    /usr/include
    PATH_SUFFIXES "." "mysql" "mysql/private"
    NO_DEFAULT_PATH
    NO_CACHE
)
set(MYSQL_INCLUDE_DIR "${_include_dir}" CACHE FILEPATH INTERNAL FORCE)

set(TMP_MYSQL_LIBRARIES "")
set(CMAKE_FIND_LIBRARY_SUFFIXES .so .lib .so.1 .dylib .a .tbd)
foreach(MY_LIB ${MYSQL_ADD_LIBRARIES})
    find_library("MYSQL_LIBRARIES_${MY_LIB}" NAMES ${MY_LIB}
        HINTS
        ${MYSQL_ADD_LIBRARY_PATH}
        /usr/lib/mysql
        /usr/lib
        /usr/local/lib
        /usr/local/lib/mysql
        /usr/local/mysql/lib
    )
    list(APPEND TMP_MYSQL_LIBRARIES "${MYSQL_LIBRARIES_${MY_LIB}}")
endforeach(MY_LIB ${MYSQL_ADD_LIBRARIES})

set(MYSQL_LIBRARIES ${TMP_MYSQL_LIBRARIES} CACHE FILEPATH INTERNAL FORCE)

if(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARIES)
    set(MYSQL_FOUND TRUE CACHE INTERNAL "MySQL found" FORCE)
    message(STATUS "Found MySQL: ${MYSQL_INCLUDE_DIR}, ${MYSQL_LIBRARIES}")
else(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARIES)
    set(MYSQL_FOUND FALSE CACHE INTERNAL "MySQL found" FORCE)
    message(STATUS "MySQL not found.")
endif(MYSQL_INCLUDE_DIR AND MYSQL_LIBRARIES)

mark_as_advanced(MYSQL_INCLUDE_DIR MYSQL_LIBRARIES MYSQL_CFLAGS)
