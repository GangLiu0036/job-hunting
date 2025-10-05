@echo off
REM ============================================
REM Memory Pool V1 - Windows 编译脚本
REM ============================================

setlocal EnableDelayedExpansion

echo.
echo ========================================
echo   Memory Pool V1 编译工具
echo ========================================
echo.

REM 检查 CMake 是否安装
where cmake >nul 2>nul
if %errorlevel% neq 0 (
    echo [错误] 未找到 CMake，请先安装 CMake
    echo 下载地址: https://cmake.org/download/
    pause
    exit /b 1
)

REM 显示菜单
:menu
echo 请选择操作:
echo [1] 配置并编译项目 (Debug)
echo [2] 配置并编译项目 (Release)
echo [3] 仅编译 (增量编译)
echo [4] 清理构建目录
echo [5] 运行测试程序
echo [6] 运行 Mutex 教程
echo [0] 退出
echo.
set /p choice="请输入选项 (0-6): "

if "%choice%"=="1" goto build_debug
if "%choice%"=="2" goto build_release
if "%choice%"=="3" goto incremental_build
if "%choice%"=="4" goto clean
if "%choice%"=="5" goto run_test
if "%choice%"=="6" goto run_mutex
if "%choice%"=="0" goto end
echo [错误] 无效选项，请重新选择
echo.
goto menu

:build_debug
echo.
echo [步骤 1/3] 创建 build 目录...
if not exist build mkdir build
cd build

echo [步骤 2/3] 配置项目 (Debug 模式)...
cmake .. -DCMAKE_BUILD_TYPE=Debug
if %errorlevel% neq 0 (
    echo [错误] CMake 配置失败
    cd ..
    pause
    goto menu
)

echo [步骤 3/3] 编译项目...
cmake --build .
if %errorlevel% neq 0 (
    echo [错误] 编译失败
    cd ..
    pause
    goto menu
)

cd ..
echo.
echo [成功] 项目编译完成！
echo 可执行文件位置: build\bin\
echo.
pause
goto menu

:build_release
echo.
echo [步骤 1/3] 创建 build 目录...
if not exist build mkdir build
cd build

echo [步骤 2/3] 配置项目 (Release 模式)...
cmake .. -DCMAKE_BUILD_TYPE=Release
if %errorlevel% neq 0 (
    echo [错误] CMake 配置失败
    cd ..
    pause
    goto menu
)

echo [步骤 3/3] 编译项目...
cmake --build . --config Release
if %errorlevel% neq 0 (
    echo [错误] 编译失败
    cd ..
    pause
    goto menu
)

cd ..
echo.
echo [成功] 项目编译完成 (Release)！
echo 可执行文件位置: build\bin\
echo.
pause
goto menu

:incremental_build
echo.
if not exist build (
    echo [错误] build 目录不存在，请先执行完整编译
    pause
    goto menu
)
cd build
echo [编译中...] 增量编译项目...
cmake --build .
if %errorlevel% neq 0 (
    echo [错误] 编译失败
    cd ..
    pause
    goto menu
)
cd ..
echo [成功] 编译完成！
echo.
pause
goto menu

:clean
echo.
if exist build (
    echo [清理中...] 删除 build 目录...
    rmdir /s /q build
    echo [成功] 构建目录已清理
) else (
    echo [提示] build 目录不存在，无需清理
)
echo.
pause
goto menu

:run_test
echo.
if not exist build\bin\test_memory_pool.exe (
    echo [错误] 测试程序不存在，请先编译项目
    pause
    goto menu
)
echo ========================================
echo   运行测试程序
echo ========================================
echo.
build\bin\test_memory_pool.exe
echo.
echo ========================================
echo   程序执行完毕
echo ========================================
pause
goto menu

:run_mutex
echo.
if not exist build\bin\learn_mutex.exe (
    echo [错误] Mutex 教程程序不存在，请先编译项目
    pause
    goto menu
)
echo ========================================
echo   运行 Mutex 学习程序
echo ========================================
echo.
build\bin\learn_mutex.exe
echo.
echo ========================================
echo   程序执行完毕
echo ========================================
pause
goto menu

:end
echo.
echo 感谢使用！
exit /b 0
