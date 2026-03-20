#----------------------------------------------------------------
# Generated CMake target import file.
#----------------------------------------------------------------

# Commands may need to know the format version.
set(CMAKE_IMPORT_FILE_VERSION 1)

# Import target "MathProjectA::MathOperationsAdd" for configuration ""
set_property(TARGET MathProjectA::MathOperationsAdd APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(MathProjectA::MathOperationsAdd PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "CXX"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libMathOperationsAdd.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS MathProjectA::MathOperationsAdd )
list(APPEND _IMPORT_CHECK_FILES_FOR_MathProjectA::MathOperationsAdd "${_IMPORT_PREFIX}/lib/libMathOperationsAdd.a" )

# Import target "MathProjectA::MathOperationsSub" for configuration ""
set_property(TARGET MathProjectA::MathOperationsSub APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(MathProjectA::MathOperationsSub PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "CXX"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libMathOperationsSub.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS MathProjectA::MathOperationsSub )
list(APPEND _IMPORT_CHECK_FILES_FOR_MathProjectA::MathOperationsSub "${_IMPORT_PREFIX}/lib/libMathOperationsSub.a" )

# Import target "MathProjectA::MathOperationsMul" for configuration ""
set_property(TARGET MathProjectA::MathOperationsMul APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(MathProjectA::MathOperationsMul PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "CXX"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libMathOperationsMul.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS MathProjectA::MathOperationsMul )
list(APPEND _IMPORT_CHECK_FILES_FOR_MathProjectA::MathOperationsMul "${_IMPORT_PREFIX}/lib/libMathOperationsMul.a" )

# Import target "MathProjectA::MathOperationsDiv" for configuration ""
set_property(TARGET MathProjectA::MathOperationsDiv APPEND PROPERTY IMPORTED_CONFIGURATIONS NOCONFIG)
set_target_properties(MathProjectA::MathOperationsDiv PROPERTIES
  IMPORTED_LINK_INTERFACE_LANGUAGES_NOCONFIG "CXX"
  IMPORTED_LOCATION_NOCONFIG "${_IMPORT_PREFIX}/lib/libMathOperationsDiv.a"
  )

list(APPEND _IMPORT_CHECK_TARGETS MathProjectA::MathOperationsDiv )
list(APPEND _IMPORT_CHECK_FILES_FOR_MathProjectA::MathOperationsDiv "${_IMPORT_PREFIX}/lib/libMathOperationsDiv.a" )

# Commands beyond this point should not need to know the version.
set(CMAKE_IMPORT_FILE_VERSION)
