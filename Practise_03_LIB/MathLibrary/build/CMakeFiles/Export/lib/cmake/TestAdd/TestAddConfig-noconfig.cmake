#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "Math::TestAdd" for configuration ""
set_property(TARGET Math::TestAdd APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(Math::TestAdd PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "CXX"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libTestAdd.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS Math::TestAdd )
list(APPEND _IMPORT_CHECK_FILES_FOR_Math::TestAdd "${_IMPORT_PREFIX}/lib/libTestAdd.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
