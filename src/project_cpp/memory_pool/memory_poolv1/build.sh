#!/bin/bash
# ============================================
# Memory Pool V1 - Linux/macOS 编译脚本
# ============================================

set -e  # 遇到错误立即退出

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 打印带颜色的消息
print_success() {
    echo -e "${GREEN}[成功]${NC} $1"
}

print_error() {
    echo -e "${RED}[错误]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[信息]${NC} $1"
}

print_step() {
    echo -e "${YELLOW}[步骤]${NC} $1"
}

# 检查 CMake
check_cmake() {
    if ! command -v cmake &> /dev/null; then
        print_error "未找到 CMake，请先安装"
        echo "Ubuntu/Debian: sudo apt install cmake"
        echo "CentOS/RHEL:   sudo yum install cmake"
        echo "macOS:         brew install cmake"
        exit 1
    fi
}

# 显示菜单
show_menu() {
    echo ""
    echo "========================================"
    echo "   Memory Pool V1 编译工具"
    echo "========================================"
    echo ""
    echo "请选择操作:"
    echo "[1] 配置并编译项目 (Debug)"
    echo "[2] 配置并编译项目 (Release)"
    echo "[3] 仅编译 (增量编译)"
    echo "[4] 清理构建目录"
    echo "[5] 运行测试程序"
    echo "[6] 运行 Mutex 教程"
    echo "[0] 退出"
    echo ""
}

# Debug 模式编译
build_debug() {
    print_step "创建 build 目录..."
    mkdir -p build
    cd build

    print_step "配置项目 (Debug 模式)..."
    cmake .. -DCMAKE_BUILD_TYPE=Debug

    print_step "编译项目..."
    local cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
    cmake --build . -j${cores}

    cd ..
    print_success "项目编译完成！"
    echo "可执行文件位置: build/bin/"
}

# Release 模式编译
build_release() {
    print_step "创建 build 目录..."
    mkdir -p build
    cd build

    print_step "配置项目 (Release 模式)..."
    cmake .. -DCMAKE_BUILD_TYPE=Release

    print_step "编译项目..."
    local cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
    cmake --build . -j${cores}

    cd ..
    print_success "项目编译完成 (Release)！"
    echo "可执行文件位置: build/bin/"
}

# 增量编译
incremental_build() {
    if [ ! -d "build" ]; then
        print_error "build 目录不存在，请先执行完整编译"
        return 1
    fi
    
    cd build
    print_step "增量编译项目..."
    local cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
    cmake --build . -j${cores}
    cd ..
    print_success "编译完成！"
}

# 清理
clean_build() {
    if [ -d "build" ]; then
        print_step "删除 build 目录..."
        rm -rf build
        print_success "构建目录已清理"
    else
        print_info "build 目录不存在，无需清理"
    fi
}

# 运行测试程序
run_test() {
    if [ ! -f "build/bin/test_memory_pool" ]; then
        print_error "测试程序不存在，请先编译项目"
        return 1
    fi
    
    echo ""
    echo "========================================"
    echo "   运行测试程序"
    echo "========================================"
    echo ""
    ./build/bin/test_memory_pool
    echo ""
    echo "========================================"
    echo "   程序执行完毕"
    echo "========================================"
}

# 运行 Mutex 教程
run_mutex() {
    if [ ! -f "build/bin/learn_mutex" ]; then
        print_error "Mutex 教程程序不存在，请先编译项目"
        return 1
    fi
    
    echo ""
    echo "========================================"
    echo "   运行 Mutex 学习程序"
    echo "========================================"
    echo ""
    ./build/bin/learn_mutex
    echo ""
    echo "========================================"
    echo "   程序执行完毕"
    echo "========================================"
}

# 主程序
main() {
    check_cmake
    
    while true; do
        show_menu
        read -p "请输入选项 (0-6): " choice
        
        case $choice in
            1)
                build_debug
                read -p "按 Enter 继续..."
                ;;
            2)
                build_release
                read -p "按 Enter 继续..."
                ;;
            3)
                incremental_build
                read -p "按 Enter 继续..."
                ;;
            4)
                clean_build
                read -p "按 Enter 继续..."
                ;;
            5)
                run_test
                read -p "按 Enter 继续..."
                ;;
            6)
                run_mutex
                read -p "按 Enter 继续..."
                ;;
            0)
                echo ""
                echo "感谢使用！"
                exit 0
                ;;
            *)
                print_error "无效选项，请重新选择"
                sleep 1
                ;;
        esac
    done
}

# 运行主程序
main
