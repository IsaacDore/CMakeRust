function(cargo_build)
    cmake_parse_arguments(CARGO "" "NAME" "" ${ARGN})
    string(REPLACE "-" "_" LIB_NAME ${CARGO_NAME})

    set(CARGO_TARGET_DIR ${CMAKE_CURRENT_BINARY_DIR})

    if(WIN32)
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(LIB_TARGET "x86_64-pc-windows-msvc")
        else()
            set(LIB_TARGET "i686-pc-windows-msvc")
        endif()
	elseif(ANDROID)
        if(ANDROID_SYSROOT_ABI STREQUAL "x86")
            set(LIB_TARGET "i686-linux-android")
        elseif(ANDROID_SYSROOT_ABI STREQUAL "x86_64")
            set(LIB_TARGET "x86_64-linux-android")
        elseif(ANDROID_SYSROOT_ABI STREQUAL "arm")
            set(LIB_TARGET "arm-linux-androideabi")
        elseif(ANDROID_SYSROOT_ABI STREQUAL "arm64")
            set(LIB_TARGET "aarch64-linux-android")
        endif()
    elseif(IOS)
		set(LIB_TARGET "universal")
    elseif(CMAKE_SYSTEM_NAME STREQUAL Darwin)
        set(LIB_TARGET "x86_64-apple-darwin")
	else()
        if(CMAKE_SIZEOF_VOID_P EQUAL 8)
            set(LIB_TARGET "x86_64-unknown-linux-gnu")
        else()
            set(LIB_TARGET "i686-unknown-linux-gnu")
        endif()
    endif()

    get_cmake_property(CMC_IS_MULTICONFIG GENERATOR_IS_MULTI_CONFIG)

    if(CMC_IS_MULTICONFIG)
        set(LIB_DIR $<$<CONFIG:DEBUG>:debug>$<$<CONFIG:RELEASE>:release>)
        set(LIB_BUILD_ARG $<$<CONFIG:RELEASE>:release>)
        set(LIB_FILE_REL "${CARGO_TARGET_DIR}/${LIB_TARGET}/release/${CMAKE_STATIC_LIBRARY_PREFIX}${LIB_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
        set(LIB_FILE_DEB "${CARGO_TARGET_DIR}/${LIB_TARGET}/debug/${CMAKE_STATIC_LIBRARY_PREFIX}${LIB_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")
    else()
        if(NOT CMAKE_BUILD_TYPE)
            set(LIB_BUILD_TYPE "debug")
        elseif(${CMAKE_BUILD_TYPE} STREQUAL "Release")
            set(LIB_BUILD_TYPE "release")
        else()
            set(LIB_BUILD_TYPE "debug")
        endif()
        set(LIB_DIR ${LIB_BUILD_TYPE})
        if(LIB_BUILD_TYPE STREQUAL "release")
            set(LIB_BUILD_ARG release)
        endif()
    endif()

    set(LIB_FILE "${CARGO_TARGET_DIR}/${LIB_TARGET}/${LIB_DIR}/${CMAKE_STATIC_LIBRARY_PREFIX}${LIB_NAME}${CMAKE_STATIC_LIBRARY_SUFFIX}")

	if(IOS)
		set(CARGO_ARGS "lipo")
	else()
    	set(CARGO_ARGS "build")
		list(APPEND CARGO_ARGS "--target" ${LIB_TARGET})
	endif()
    
    list(APPEND CARGO_ARGS "--${LIB_BUILD_ARG}")

    file(GLOB_RECURSE LIB_SOURCES "*.rs")

    set(CARGO_ENV_COMMAND ${CMAKE_COMMAND} -E env "CARGO_TARGET_DIR=${CARGO_TARGET_DIR}")

    add_custom_command(
        OUTPUT ${LIB_FILE}
        COMMAND ${CARGO_ENV_COMMAND} ${CARGO_EXECUTABLE} ARGS ${CARGO_ARGS}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        DEPENDS ${LIB_SOURCES}
        COMMENT "running cargo")
    add_custom_target(${CARGO_NAME}_target ALL DEPENDS ${LIB_FILE})
    add_library(${CARGO_NAME} STATIC IMPORTED GLOBAL)
    add_dependencies(${CARGO_NAME} ${CARGO_NAME}_target)

    if(CMC_IS_MULTICONFIG)
        set_target_properties(${CARGO_NAME} PROPERTIES
            IMPORTED_CONFIGURATIONS "Debug"
            IMPORTED_LOCATION ${LIB_FILE_REL}
            IMPORTED_LOCATION_DEBUG ${LIB_FILE_DEB}
        )
    else()
        set_target_properties(${CARGO_NAME} PROPERTIES IMPORTED_LOCATION ${LIB_FILE})
    endif()
endfunction()