# CMake 最低版本要求
cmake_minimum_required(VERSION 3.10)

# 项目名称和版本
project(MemoryPoolV1 VERSION 1.0 LANGUAGES CXX)

# 设置编码为 UTF-8（解决中文路径问题）
if(WIN32)
    if(MSVC)
        # MSVC 编译器使用 /utf-8
        add_compile_options(/utf-8)
    elseif(MINGW)
        # MinGW 编译器使用 -finput-charset 和 -fexec-charset
        add_compile_options(-finput-charset=UTF-8 -fexec-charset=UTF-8)
    endif()
endif()

# 设置 C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 设置编译选项
if(MSVC)
    # Windows MSVC 编译器选项
    add_compile_options(/W4)
else()
    # GCC/Clang 编译器选项
    add_compile_options(-Wall -Wextra -pedantic)
endif()

# 设置输出目录
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/lib)

# 包含头文件目录
include_directories(${PROJECT_SOURCE_DIR}/include)

# 创建内存池库
add_library(memory_pool STATIC
    src/MemoryPool.cpp
    include/MemoryPool.h
)

# 为库设置包含目录（现代 CMake 方式）
target_include_directories(memory_pool PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>
    $<INSTALL_INTERFACE:include>
)

# 查找线程库（用于 std::mutex）
find_package(Threads REQUIRED)
target_link_libraries(memory_pool PUBLIC Threads::Threads)

# ============================================
# 测试程序
# ============================================
add_executable(test_memory_pool tests/test.cpp)
target_link_libraries(test_memory_pool PRIVATE memory_pool)

# ============================================
# 教程程序
# ============================================
add_executable(learn_mutex tutorials/learn_mutex.cpp)
target_link_libraries(learn_mutex PRIVATE Threads::Threads)

# ============================================
# 编译信息输出
# ============================================
message(STATUS "CMake Version: ${CMAKE_VERSION}")
message(STATUS "Project Name: ${PROJECT_NAME}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Source Directory: ${CMAKE_SOURCE_DIR}")
message(STATUS "Binary Directory: ${CMAKE_BINARY_DIR}")

# ============================================
# 自定义目标：显示帮助信息
# ============================================
add_custom_target(show_help
    COMMAND ${CMAKE_COMMAND} -E echo "可用的构建目标："
    COMMAND ${CMAKE_COMMAND} -E echo "  memory_pool       - 编译内存池静态库"
    COMMAND ${CMAKE_COMMAND} -E echo "  test_memory_pool  - 编译测试程序"
    COMMAND ${CMAKE_COMMAND} -E echo "  learn_mutex       - 编译 mutex 学习程序"
    COMMAND ${CMAKE_COMMAND} -E echo ""
    COMMAND ${CMAKE_COMMAND} -E echo "运行程序："
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build . --target test_memory_pool && ./bin/test_memory_pool"
    COMMAND ${CMAKE_COMMAND} -E echo "  cmake --build . --target learn_mutex && ./bin/learn_mutex"
)
