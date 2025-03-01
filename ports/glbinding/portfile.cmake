include(vcpkg_common_functions)
vcpkg_from_github(
    OUT_SOURCE_PATH SOURCE_PATH
    REPO cginternals/glbinding
    REF v3.1.0
    SHA512 d7294c9a0dc47a7c107b134e5dfa78c5812fc6bf739b9fd778fa7ce946d5ea971839a65c3985e0915fd75311e4a85fb221d33a71856c460199eab0e7622f7151
    HEAD_REF master
    PATCHES 
        force-system-install.patch
        fix-uwpmacro.patch
)

vcpkg_configure_cmake(
    SOURCE_PATH ${SOURCE_PATH}
    OPTIONS
        -DOPTION_BUILD_TESTS=OFF
        -DOPTION_BUILD_GPU_TESTS=OFF
        -DOPTION_BUILD_TOOLS=OFF
        -DGIT_REV=0
        -DCMAKE_DISABLE_FIND_PACKAGE_cpplocate=ON
)

vcpkg_install_cmake()

file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/include)

vcpkg_fixup_cmake_targets(CONFIG_PATH share/glbinding/cmake)

# _IMPORT_PREFIX needs to go up one extra level in the directory tree.
# These files should be modified.
#     /share/glbinding/glbinding-export.cmake 
#     /share/glbinding-aux/glbinding-aux-export.cmake
file(GLOB_RECURSE TARGET_CMAKES "${CURRENT_PACKAGES_DIR}/*-export.cmake")
foreach(TARGET_CMAKE IN LISTS TARGET_CMAKES)
    file(READ ${TARGET_CMAKE} _contents)
    string(REPLACE 
[[
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
]]
[[
get_filename_component(_IMPORT_PREFIX "${CMAKE_CURRENT_LIST_FILE}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
get_filename_component(_IMPORT_PREFIX "${_IMPORT_PREFIX}" PATH)
]]
        _contents "${_contents}")
    file(WRITE ${TARGET_CMAKE} "${_contents}")
endforeach()

file(WRITE ${CURRENT_PACKAGES_DIR}/share/glbinding/glbinding-config.cmake "include(\${CMAKE_CURRENT_LIST_DIR}/glbinding/glbinding-export.cmake)\ninclude(\${CMAKE_CURRENT_LIST_DIR}/glbinding-aux/glbinding-aux-export.cmake)\ninclude(\${CMAKE_CURRENT_LIST_DIR}/KHRplatform/KHRplatform-export.cmake)\nset(glbinding_FOUND TRUE)\n")
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/debug/share)

# Remove files already published by egl-registry
file(REMOVE_RECURSE ${CURRENT_PACKAGES_DIR}/include/KHR)

# Handle copyright
file(RENAME ${CURRENT_PACKAGES_DIR}/share/glbinding/LICENSE ${CURRENT_PACKAGES_DIR}/share/glbinding/copyright)

vcpkg_copy_pdbs()
