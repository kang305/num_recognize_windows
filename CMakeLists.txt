cmake_minimum_required(VERSION 3.16)
project(num_recognize LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

# Find Qt6 (or Qt5 as fallback)
find_package(Qt6 QUIET COMPONENTS Widgets)
if(NOT Qt6_FOUND)
    find_package(Qt5 REQUIRED COMPONENTS Widgets)
    set(QT_VERSION_MAJOR 5)
else()
    set(QT_VERSION_MAJOR 6)
endif()

# Find LibTorch via CMAKE_PREFIX_PATH
find_package(Torch REQUIRED)

add_executable(num_recognize
    main.cpp
    mainwindow.h
    mainwindow.cpp
    canvaswidget.h
    canvaswidget.cpp
    recognizer.h
    recognizer.cpp
)

target_link_libraries(num_recognize
    Qt${QT_VERSION_MAJOR}::Widgets
    ${TORCH_LIBRARIES}
)

target_include_directories(num_recognize PRIVATE
    ${TORCH_INCLUDE_DIRS}
)

# Copy required DLLs to output directory on Windows
if(WIN32)
    add_custom_command(TARGET num_recognize POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        "$<TARGET_RUNTIME_DLLS:num_recognize>"
        "$<TARGET_FILE_DIR:num_recognize>"
        COMMAND_EXPAND_LISTS
    )
endif()
