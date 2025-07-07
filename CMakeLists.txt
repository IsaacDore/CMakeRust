cmake_minimum_required(VERSION 3.0...3.5)

project(CMakeRust)

set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")

enable_language(Rust)
include(CMakeCargo)

if (PROJECT_IS_TOP_LEVEL)
    add_subdirectory(hello_world)
    add_subdirectory(crates)
endif()
