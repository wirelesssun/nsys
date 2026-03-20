#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "MathProjectA::MathOperations" for configuration ""
set_property(TARGET MathProjectA::MathOperations APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(MathProjectA::MathOperations PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "CXX"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libMathOperations.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS MathProjectA::MathOperations )
list(APPEND _IMPORT_CHECK_FILES_FOR_MathProjectA::MathOperations "${_IMPORT_PREFIX}/lib/libMathOperations.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
