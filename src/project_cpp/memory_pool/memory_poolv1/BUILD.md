# 🛠️ 编译和运行指南

## 📋 前置要求

### Windows 系统
- **CMake**: 版本 3.10 或更高
- **编译器**: 
  - MinGW-w64 (推荐)
  - MSVC (Visual Studio 2015 或更高)
  - Clang

### Linux/macOS 系统
- **CMake**: 版本 3.10 或更高
- **编译器**: GCC 或 Clang (支持 C++11)

---

## 🚀 快速开始

### 方法 1：使用命令行（推荐）

#### Windows (PowerShell/CMD)

**使用 MinGW (推荐):**
```powershell
# 1. 进入 build 目录
cd build

# 2. 生成构建文件（必须指定 MinGW Makefiles！）
cmake .. -G "MinGW Makefiles"

# 3. 编译所有目标
cmake --build .

# 4. 运行测试程序
.\bin\test_memory_pool.exe

# 5. 运行 mutex 学习程序
.\bin\learn_mutex.exe
```

**使用 Visual Studio:**
```powershell
# 如果您使用 Visual Studio 2022
cmake .. -G "Visual Studio 17 2022"

# 如果您使用 Visual Studio 2019
cmake .. -G "Visual Studio 16 2019"

# 然后编译
cmake --build .
```

#### Linux/macOS (Bash)
```bash
# 1. 进入项目根目录
cd /path/to/memory_poolv1

# 2. 创建并进入 build 目录
mkdir -p build && cd build

# 3. 生成构建文件（可选指定构建类型）
cmake .. -DCMAKE_BUILD_TYPE=Release

# 4. 编译所有目标
cmake --build . -j$(nproc)  # 使用所有 CPU 核心

# 5. 运行测试程序
./bin/test_memory_pool

# 6. 运行 mutex 学习程序
./bin/learn_mutex
```

---

## 🎯 分步骤详细说明

### 步骤 1: 配置项目（生成构建文件）

```bash
cd build
cmake ..
```

**可选配置选项：**
```bash
# 指定构建类型为 Debug（包含调试信息）
cmake .. -DCMAKE_BUILD_TYPE=Debug

# 指定构建类型为 Release（优化性能）
cmake .. -DCMAKE_BUILD_TYPE=Release

# 指定编译器（如果有多个编译器）
cmake .. -DCMAKE_CXX_COMPILER=g++
cmake .. -DCMAKE_CXX_COMPILER=clang++
```

### 步骤 2: 编译项目

```bash
# 编译所有目标
cmake --build .

# 只编译特定目标
cmake --build . --target memory_pool       # 只编译库
cmake --build . --target test_memory_pool  # 只编译测试程序
cmake --build . --target learn_mutex       # 只编译教程

# 并行编译（加速）
cmake --build . -j 4  # 使用 4 个线程
```

### 步骤 3: 运行程序

**Windows:**
```powershell
.\bin\test_memory_pool.exe
.\bin\learn_mutex.exe
```

**Linux/macOS:**
```bash
./bin/test_memory_pool
./bin/learn_mutex
```

---

## 📂 构建产物说明

编译完成后，`build` 目录下会生成：

```
build/
├── bin/                      # 可执行文件目录
│   ├── test_memory_pool.exe # 测试程序
│   └── learn_mutex.exe      # Mutex 教程程序
├── lib/                      # 库文件目录
│   └── libmemory_pool.a     # 内存池静态库
└── CMakeFiles/               # CMake 生成的中间文件
```

---

## 🧹 清理构建

```bash
# 方法 1: 删除 build 目录（推荐）
cd ..
rm -rf build  # Linux/macOS
rmdir /s build  # Windows CMD

# 方法 2: 使用 CMake 清理
cd build
cmake --build . --target clean
```

---

## 🐛 常见问题

### 1. Windows 上出现 "nmake" 找不到的错误
```
CMake Error: Running 'nmake' '-?' failed with: no such file or directory
```

**原因**: CMake 在 Windows 上默认尝试使用 MSVC 的 NMake，但您安装的是 MinGW。

**解决方案**: 必须明确指定使用 MinGW Makefiles 生成器：
```powershell
# 清理 build 目录
cd build
Remove-Item * -Recurse -Force

# 重新配置（关键步骤！）
cmake .. -G "MinGW Makefiles"

# 编译
cmake --build .
```

### 2. CMake 找不到
```bash
# 检查 CMake 是否安装
cmake --version

# 如果未安装，请访问：https://cmake.org/download/
```

### 3. 编译器未找到
```bash
# Windows: 确保 MinGW 或 MSVC 在 PATH 中
# Linux: 安装 g++
sudo apt install g++  # Ubuntu/Debian
sudo yum install gcc-c++  # CentOS/RHEL

# macOS: 安装 Xcode Command Line Tools
xcode-select --install
```

### 4. 线程库链接错误
```bash
# Linux 上可能需要显式链接 pthread
# CMakeLists.txt 已经配置好了，如果仍有问题，尝试：
cmake .. -DCMAKE_CXX_FLAGS="-pthread"
```

### 5. 中文路径问题
- 确保终端支持 UTF-8 编码
- Windows 上建议使用 PowerShell 而不是 CMD

---

## 🎓 高级用法

### 生成 Visual Studio 工程
```bash
# 生成 VS 2019 解决方案
cmake .. -G "Visual Studio 16 2019"

# 生成 VS 2022 解决方案
cmake .. -G "Visual Studio 17 2022"

# 然后在 Visual Studio 中打开 MemoryPoolV1.sln
```

### 生成 Makefile
```bash
cmake .. -G "Unix Makefiles"
make -j4
```

### 查看所有可用目标
```bash
cmake --build . --target show_help
```

---

## 📊 性能测试

如果您添加了性能测试代码，可以这样运行：

```bash
# Release 模式编译（性能最优）
cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
cmake --build .

# 运行性能测试
./bin/test_memory_pool
```

---

## 💡 提示

1. **首次编译**推荐使用 Debug 模式，方便调试
2. **性能测试**时使用 Release 模式
3. **修改代码后**只需运行 `cmake --build .` 即可增量编译
4. **修改 CMakeLists.txt 后**需要重新运行 `cmake ..`

---

## 📞 需要帮助？

如果遇到问题，请检查：
1. CMake 版本是否 >= 3.10
2. 编译器是否支持 C++11
3. 构建目录是否干净（尝试删除 build 重新构建）
