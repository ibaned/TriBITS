SET(CMAKE_MODULE_PATH
  "${CMAKE_MODULE_PATH}"
  "${CMAKE_CURRENT_LIST_DIR}/find_modules"
  "${CMAKE_CURRENT_LIST_DIR}/utils"
   )

TRIBITS_TPL_FIND_INCLUDE_DIRS_AND_LIBRARIES( Pnetcdf
  REQUIRED_HEADERS pnetcdf.h
  REQUIRED_LIBS_NAMES pnetcdf
  )
