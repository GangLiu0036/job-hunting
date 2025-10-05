# 🚀 快速开始指南

## ⚡ 最快上手方式（Windows）

### 方式 1：双击运行（最简单）
1. 双击项目根目录的 `build.bat` 文件
2. 选择 `[1] 配置并编译项目 (Debug)`
3. 等待编译完成
4. 选择 `[5] 运行测试程序` 或 `[6] 运行 Mutex 教程`

### 方式 2：命令行（推荐学习）
```powershell
# 在项目根目录打开 PowerShell 或 CMD，运行：
build.bat
```

---

## 📋 三步编译运行（手动方式）

### Windows (PowerShell/CMD)
```powershell
# 步骤 1: 创建并进入 build 目录
mkdir build
cd build

# 步骤 2: 生成构建文件
cmake ..

# 步骤 3: 编译并运行
cmake --build .
.\bin\test_memory_pool.exe
```

### Linux/macOS (Terminal)
```bash
# 步骤 1: 创建并进入 build 目录
mkdir -p build && cd build

# 步骤 2: 生成构建文件
cmake ..

# 步骤 3: 编译并运行
cmake --build . -j$(nproc)
./bin/test_memory_pool
```

---

## 📁 项目结构说明

```
memory_poolv1/
├── CMakeLists.txt      # CMake 配置文件（核心）
├── build.bat           # Windows 自动化脚本
├── build.sh            # Linux/macOS 自动化脚本
├── BUILD.md            # 详细编译说明
├── README.md           # 项目文档
│
├── include/            # 头文件目录
│   └── MemoryPool.h    # 内存池头文件
│
├── src/                # 源代码目录
│   └── MemoryPool.cpp  # 内存池实现
│
├── tests/              # 测试代码目录
│   └── test.cpp        # 测试程序
│
├── tutorials/          # 教程代码目录
│   └── learn_mutex.cpp # Mutex 学习示例
│
└── build/              # 构建目录（首次编译后自动生成）
    ├── bin/            # 可执行文件
    └── lib/            # 库文件
```

---

## 🎯 常用操作速查

### 编译相关
```bash
# 完整编译（Debug 模式）
cmake .. -DCMAKE_BUILD_TYPE=Debug && cmake --build .

# 完整编译（Release 模式，性能最优）
cmake .. -DCMAKE_BUILD_TYPE=Release && cmake --build .

# 增量编译（修改代码后）
cmake --build .

# 清理重新编译
cd ..
rm -rf build  # 或 Windows: rmdir /s build
```

### 运行相关
```bash
# Windows
.\bin\test_memory_pool.exe      # 运行测试程序
.\bin\learn_mutex.exe            # 运行 Mutex 教程

# Linux/macOS
./bin/test_memory_pool           # 运行测试程序
./bin/learn_mutex                # 运行 Mutex 教程
```

### 查看编译信息
```bash
cmake --version              # 查看 CMake 版本
cmake --build . --verbose    # 详细编译输出
cmake .. -LA                 # 查看所有 CMake 变量
```

---

## 🐛 遇到问题？

### 问题 1: "cmake 不是内部或外部命令"
**解决方案**: CMake 未安装或未加入 PATH
1. 下载安装 CMake: https://cmake.org/download/
2. 安装时勾选 "Add CMake to system PATH"

### 问题 2: "找不到编译器"
**Windows 解决方案**:
- 安装 MinGW-w64: https://www.mingw-w64.org/
- 或安装 Visual Studio (包含 MSVC 编译器)

**Linux 解决方案**:
```bash
sudo apt install build-essential  # Ubuntu/Debian
sudo yum install gcc-c++          # CentOS/RHEL
```

### 问题 3: 编译错误 "C++11 features not available"
**解决方案**: 编译器不支持 C++11 或版本过旧
- 确保使用 GCC 4.8+ 或 MSVC 2015+
- 更新编译器版本

### 问题 4: 中文路径问题
**解决方案**: 
- Windows: 使用 PowerShell 而不是 CMD
- 或将项目移到纯英文路径下

---

## 📖 下一步

1. ✅ **运行测试**: 验证编译环境正常
   ```bash
   ./bin/test_memory_pool
   ```

2. ✅ **学习 Mutex**: 理解多线程同步
   ```bash
   ./bin/learn_mutex
   ```

3. ✅ **阅读代码**: 理解内存池实现
   - `include/MemoryPool.h` - 接口设计
   - `src/MemoryPool.cpp` - 核心实现

4. ✅ **编写测试**: 添加自己的测试用例
   - 修改 `tests/test.cpp`
   - 重新编译运行

5. ✅ **性能测试**: 对比内存池与标准分配器
   - 添加性能测试代码
   - Release 模式编译测试

---

## 💡 提示

- 📝 修改代码后，只需在 build 目录运行 `cmake --build .` 即可增量编译
- 🚀 Release 模式编译的程序性能最优，用于性能测试
- 🐛 Debug 模式编译包含调试信息，方便调试
- 🧹 遇到奇怪问题时，尝试删除 build 目录重新编译

---

**祝您学习愉快！** 🎉
