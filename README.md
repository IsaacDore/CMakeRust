# CMakeRust
## Example Usage
```
include(FetchContent)

FetchContent_Declare(
    CMakeRust
    GIT_REPOSITORY https://github.com/IsaacDore/CMakeRust.git
)
FetchContent_MakeAvailable(CMakeRust)

cargo_build(NAME <target>)
```