#import "@preview/cetz:0.4.0"
#import "@preview/equate:0.3.2": equate
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *
#import "@preview/hydra:0.6.1": hydra

#set page(paper: "a4", margin: (y: 4em), numbering: "1", header: context {
  align(right, emph(hydra(2)))
  line(length: 100%)
})

#set heading(numbering: "1.1")
#show heading.where(level: 1): it => pagebreak(weak: true) + it

#show: equate.with(breakable: true, sub-numbering: true)
#set math.equation(numbering: "(1-1)")
#set text(
  size: 10pt)

  
#show: codly-init.with()
#codly(languages: codly-languages)

// 封面页
#align(center + horizon)[
  #block(
    width: 100%,
    inset: 2em,
    [
      #text(size: 42pt, weight: "bold")[
        C++ 内存管理
      ]
      
      #v(1em)
      
      #text(size: 18pt)[
        从基础到高级的完整指南
      ]
      
      #v(3em)
      
      #line(length: 60%, stroke: 2pt + rgb("#333333"))
      
      #v(3em)
      
      #text(size: 14pt)[
        *涵盖内容*
      ]
      
      #v(1em)
      
      #grid(
        columns: 1,
        row-gutter: 0.8em,
        align(left)[
          #text(size: 12pt)[
            • 内存布局与分配机制 \
            • 智能指针详解 (unique\_ptr, shared\_ptr, weak\_ptr) \
            • 内存对齐原理与优化 \
            • Placement New 与内存池 \
            • 内存泄漏检测与防范 \
            • RAII 与异常安全 \
            • 最佳实践与常见陷阱
          ]
        ]
      )
      
      #v(4em)
      
      #line(length: 60%, stroke: 2pt + rgb("#333333"))
      
      #v(2em)
      
      #text(size: 12pt, style: "italic")[
        面试准备 · 技术进阶 · 实战指南
      ]
      
      #v(2em)
      
      #text(size: 11pt)[
        *作者*：Aweo
      ]
      
      #v(1em)
      
      #text(size: 11pt)[
        #datetime.today().display("[year]年[month]月")
      ]
    ]
  )
]

#pagebreak()

#outline()

#pagebreak()

= C++ 内存管理

== 内存布局概述

C++程序的内存主要分为以下几个区域：

```cpp
// 内存布局示意（从低地址到高地址）
┌─────────────────┐ 低地址
│   代码段(.text)  │ 存放程序的机器码
├─────────────────┤
│   常量区(.rodata)│ 存放字符串常量等
├─────────────────┤
│  全局/静态区     │
│  - .data段      │ 已初始化的全局/静态变量
│  - .bss段       │ 未初始化的全局/静态变量
├─────────────────┤
│   堆(Heap) ↓   │ 动态分配，向下增长
│                 │
│   ···自由空间··· │
│                 │
│   栈(Stack) ↑  │ 局部变量，向上增长
├─────────────────┤
│   内核空间       │
└─────────────────┘ 高地址
```

*各区域特点*：

```cpp
// 1. 栈（Stack）
void func() {
    int local = 42;  // 栈上分配
    char buffer[100]; // 栈上分配
    // 函数返回时自动释放
}
// 特点：
// - 自动管理，LIFO
// - 速度快（只需移动栈指针）
// - 大小有限（通常1-8MB）
// - 编译期确定大小

// 2. 堆（Heap）
void func() {
    int* p = new int(42);  // 堆上分配
    delete p;  // 手动释放
}
// 特点：
// - 手动管理
// - 速度较慢（需要分配器管理）
// - 大小受限于物理内存
// - 运行时确定大小

// 3. 全局/静态区
int global_var = 10;        // .data段
static int static_var = 20; // .data段
int uninit_global;          // .bss段（零初始化）

// 特点：
// - 程序启动时分配
// - 程序结束时释放
// - 整个程序运行期间存在

// 4. 常量区
const char* str = "Hello";  // "Hello"存储在.rodata段
// 特点：
// - 只读，不可修改
// - 字符串字面量可能被合并
```

*内存大小示例*：

```cpp
#include <iostream>

struct Empty {};
struct Padding {
    char c;   // 1字节
    int i;    // 4字节
};

int main() {
    std::cout << "栈上对象:\n";
    int stack_var;
    std::cout << "sizeof(int): " << sizeof(int) << "\n";
    std::cout << "sizeof(Empty): " << sizeof(Empty) << "\n";  // 1（最小）
    std::cout << "sizeof(Padding): " << sizeof(Padding) << "\n";  // 8（对齐）
    
    std::cout << "\n堆上对象:\n";
    int* heap_var = new int;
    std::cout << "指针大小: " << sizeof(heap_var) << "\n";  // 8（64位系统）
    delete heap_var;
}
```

== 智能指针详解

智能指针通过RAII自动管理内存，是现代C++的核心工具。

=== unique_ptr - 独占所有权

```cpp
#include <memory>

// 1. 基本使用
std::unique_ptr<int> p1(new int(42));
std::unique_ptr<int> p2 = std::make_unique<int>(42);  // C++14，推荐

// 访问
*p2 = 100;
int value = *p2;

// 自动释放（作用域结束时）
{
    auto p = std::make_unique<int>(42);
}  // 自动delete

// 2. 数组版本
std::unique_ptr<int[]> arr(new int[10]);
arr[0] = 1;  // 可以使用下标

auto arr2 = std::make_unique<int[]>(10);  // C++14

// 3. 所有权转移（移动）
std::unique_ptr<int> p3 = std::make_unique<int>(10);
std::unique_ptr<int> p4 = std::move(p3);  // p3变为nullptr
// std::unique_ptr<int> p5 = p4;  // 错误！不能拷贝

// 4. 自定义删除器
auto deleter = [](int* p) {
    std::cout << "Custom delete: " << *p << "\n";
    delete p;
};
std::unique_ptr<int, decltype(deleter)> p5(new int(42), deleter);

// 文件句柄示例
auto file_deleter = [](FILE* fp) {
    if (fp) fclose(fp);
};
std::unique_ptr<FILE, decltype(file_deleter)> file(
    fopen("data.txt", "r"), 
    file_deleter
);

// 5. 工厂函数
template<typename T, typename... Args>
std::unique_ptr<T> create(Args&&... args) {
    return std::make_unique<T>(std::forward<Args>(args)...);
}

// 6. 作为类成员
class Widget {
    std::unique_ptr<Resource> resource;  // 自动管理资源
public:
    Widget() : resource(std::make_unique<Resource>()) {}
    // 析构时自动释放resource
};

// 7. 释放所有权
auto p6 = std::make_unique<int>(42);
int* raw = p6.release();  // p6不再拥有，返回裸指针
delete raw;  // 需要手动删除

// 8. 重置
auto p7 = std::make_unique<int>(42);
p7.reset();  // 释放当前对象，p7变为nullptr
p7.reset(new int(100));  // 释放当前对象，指向新对象
```

*unique_ptr的优势*：
- 零开销（相比裸指针）
- 明确所有权语义
- 异常安全
- 不能拷贝，避免多次删除

=== shared_ptr - 共享所有权

```cpp
#include <memory>

// 1. 基本使用
std::shared_ptr<int> sp1 = std::make_shared<int>(42);  // 推荐
std::shared_ptr<int> sp2(new int(42));  // 不推荐（两次内存分配）

// 2. 共享所有权
auto sp3 = std::make_shared<int>(100);
auto sp4 = sp3;  // 拷贝，引用计数+1
auto sp5 = sp3;  // 引用计数=3
std::cout << sp3.use_count() << "\n";  // 输出：3

sp4.reset();  // 引用计数-1
// 当最后一个shared_ptr销毁时，对象才被删除

// 3. 从unique_ptr转换
auto up = std::make_unique<int>(42);
std::shared_ptr<int> sp6 = std::move(up);  // 转移所有权

// 4. 自定义删除器
auto deleter = [](int* p) {
    std::cout << "Delete: " << *p << "\n";
    delete p;
};
std::shared_ptr<int> sp7(new int(42), deleter);

// 5. 数组支持（C++17起）
std::shared_ptr<int[]> sp_arr(new int[10]);  // C++17
sp_arr[0] = 1;

// C++20推荐
auto sp_arr2 = std::make_shared<int[]>(10);

// 6. 别名构造（aliasing constructor）
struct Data {
    int x, y;
};
auto sp_data = std::make_shared<Data>();
std::shared_ptr<int> sp_x(sp_data, &sp_data->x);  // 指向x，但共享Data的生命周期

// 7. enable_shared_from_this
class Node : public std::enable_shared_from_this<Node> {
public:
    std::shared_ptr<Node> getPtr() {
        return shared_from_this();  // 安全地返回shared_ptr
    }
};

auto node = std::make_shared<Node>();
auto ptr = node->getPtr();  // 正确

// 8. 循环引用问题（需要weak_ptr解决）
struct Bad {
    std::shared_ptr<Bad> next;
};

auto b1 = std::make_shared<Bad>();
auto b2 = std::make_shared<Bad>();
b1->next = b2;
b2->next = b1;  // 循环引用，内存泄漏！
```

*shared_ptr实现原理*：

```cpp
// 简化的shared_ptr实现
template<typename T>
class SimpleSharedPtr {
    T* ptr;
    size_t* ref_count;  // 引用计数
    
public:
    SimpleSharedPtr(T* p) : ptr(p), ref_count(new size_t(1)) {}
    
    SimpleSharedPtr(const SimpleSharedPtr& other) 
        : ptr(other.ptr), ref_count(other.ref_count) {
        ++(*ref_count);  // 增加引用计数
    }
    
    ~SimpleSharedPtr() {
        if (--(*ref_count) == 0) {  // 减少引用计数
            delete ptr;
            delete ref_count;
        }
    }
    
    T& operator*() { return *ptr; }
    T* operator->() { return ptr; }
    size_t use_count() const { return *ref_count; }
};

// make_shared的优势：一次内存分配
// new：两次分配（对象+控制块）
// make_shared：一次分配（对象和控制块在一起）
┌─────────────┬──────────────┐
│  对象数据    │  控制块       │
│  T object   │  ref_count   │
│             │  weak_count  │
│             │  deleter     │
└─────────────┴──────────────┘
```

=== weak_ptr - 弱引用

```cpp
#include <memory>

// 1. 基本使用
auto sp = std::make_shared<int>(42);
std::weak_ptr<int> wp = sp;  // 不增加引用计数

std::cout << sp.use_count() << "\n";  // 1（weak_ptr不影响）
std::cout << wp.use_count() << "\n";  // 1

// 2. 检查对象是否存在
if (wp.expired()) {
    std::cout << "对象已被删除\n";
} else {
    std::cout << "对象仍存在\n";
}

// 3. 访问对象（需要转换为shared_ptr）
if (auto sp2 = wp.lock()) {  // 临时提升为shared_ptr
    std::cout << *sp2 << "\n";
} else {
    std::cout << "对象已被删除\n";
}

// 4. 解决循环引用
struct Good {
    std::shared_ptr<Good> next;
    std::weak_ptr<Good> prev;  // 使用weak_ptr打破循环
};

auto g1 = std::make_shared<Good>();
auto g2 = std::make_shared<Good>();
g1->next = g2;
g2->prev = g1;  // 不会造成循环引用

// 5. 观察者模式
class Subject;

class Observer {
    std::weak_ptr<Subject> subject;  // 弱引用，不控制生命周期
public:
    void setSubject(std::shared_ptr<Subject> s) {
        subject = s;
    }
    
    void notify() {
        if (auto s = subject.lock()) {
            // 使用subject
        }
    }
};

// 6. 缓存实现
class Cache {
    std::map<std::string, std::weak_ptr<Resource>> cache;
    
public:
    std::shared_ptr<Resource> get(const std::string& key) {
        auto it = cache.find(key);
        if (it != cache.end()) {
            if (auto sp = it->second.lock()) {
                return sp;  // 缓存命中
            }
            cache.erase(it);  // 已过期，删除
        }
        
        // 创建新资源
        auto resource = std::make_shared<Resource>();
        cache[key] = resource;
        return resource;
    }
};
```

*智能指针选择指南*：

```cpp
// 1. 独占所有权 → unique_ptr
std::unique_ptr<Widget> widget = std::make_unique<Widget>();

// 2. 共享所有权 → shared_ptr
std::shared_ptr<Resource> shared = std::make_shared<Resource>();

// 3. 不控制生命周期 → weak_ptr
std::weak_ptr<Resource> observer = shared;

// 4. 工厂函数返回 → unique_ptr（可转为shared_ptr）
std::unique_ptr<Base> createObject() {
    return std::make_unique<Derived>();
}

// 5. 容器中存储 → shared_ptr或unique_ptr
std::vector<std::unique_ptr<Widget>> widgets;  // 独占
std::vector<std::shared_ptr<Resource>> resources;  // 共享
```

== 内存对齐

内存对齐影响性能和跨平台兼容性。

=== 为什么需要内存对齐？

*1. 硬件访问效率*

现代CPU访问内存不是逐字节访问，而是按"字(word)"访问（通常4或8字节）。

```cpp
// CPU访问内存的方式
// 32位系统：每次读取4字节（地址0, 4, 8, 12...）
// 64位系统：每次读取8字节（地址0, 8, 16, 24...）

// 未对齐访问（假设int=4字节）
┌─────┬─────┬─────┬─────┬─────┬─────┐
│  0  │  1  │  2  │  3  │  4  │  5  │  内存地址
└─────┴─────┴─────┴─────┴─────┴─────┘
        └─────int(addr=1)─────┘
        
// CPU需要：
// 1. 读取地址0-3的4字节
// 2. 读取地址4-7的4字节  
// 3. 拼接提取中间的int
// → 两次内存访问！

// 对齐访问
┌─────┬─────┬─────┬─────┬─────┬─────┐
│  0  │  1  │  2  │  3  │  4  │  5  │
└─────┴─────┴─────┴─────┴─────┴─────┘
  └─────int(addr=0)─────┘
  
// CPU只需一次内存访问！
```

*2. 性能差异*

```cpp
#include <chrono>
#include <iostream>

struct Unaligned {
    char c;
    int i;   // 偏移1，未对齐
} __attribute__((packed));

struct Aligned {
    char c;
    // 3字节填充
    int i;   // 偏移4，对齐
};

// 性能测试
void performance_test() {
    const int N = 100000000;
    
    // 未对齐访问
    Unaligned* arr1 = new Unaligned[N];
    auto start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < N; ++i) {
        arr1[i].i = i;  // 未对齐写入
    }
    auto end = std::chrono::high_resolution_clock::now();
    auto unaligned_time = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    
    // 对齐访问
    Aligned* arr2 = new Aligned[N];
    start = std::chrono::high_resolution_clock::now();
    for (int i = 0; i < N; ++i) {
        arr2[i].i = i;  // 对齐写入
    }
    end = std::chrono::high_resolution_clock::now();
    auto aligned_time = std::chrono::duration_cast<std::chrono::milliseconds>(end - start).count();
    
    std::cout << "未对齐: " << unaligned_time << "ms\n";
    std::cout << "对齐:   " << aligned_time << "ms\n";
    std::cout << "性能提升: " << (double)unaligned_time / aligned_time << "x\n";
    // 典型结果：对齐访问快2-10倍
    
    delete[] arr1;
    delete[] arr2;
}
```

*3. 跨平台兼容性*

某些架构对未对齐访问的处理不同：

```cpp
// x86/x64架构
// - 允许未对齐访问，但性能下降
int* p = (int*)((char*)buffer + 1);  // 未对齐
*p = 42;  // 可以运行，但慢

// ARM架构（早期版本）
// - 未对齐访问可能触发硬件异常
// - 或者读取错误的数据（静默失败）
int* p = (int*)((char*)buffer + 1);
*p = 42;  // 可能崩溃！

// MIPS架构
// - 未对齐访问直接抛出异常
int* p = (int*)((char*)buffer + 1);
*p = 42;  // 崩溃！
```

*4. 原子操作要求*

```cpp
#include <atomic>

struct Data {
    char c;
    std::atomic<int> counter;  // 必须对齐，否则原子操作失败
};

// 错误示例
struct __attribute__((packed)) Bad {
    char c;
    std::atomic<int> counter;  // 未对齐，原子性无法保证！
};

// 在多线程环境下：
// - 未对齐的原子操作可能不是真正的原子操作
// - 导致数据竞争和未定义行为
```

*5. SIMD指令要求*

```cpp
#include <immintrin.h>

void simd_example() {
    // SSE要求16字节对齐
    alignas(16) float data1[4];
    __m128 vec1 = _mm_load_ps(data1);  // ✓ 对齐加载
    
    float data2[4];
    // __m128 vec2 = _mm_load_ps(data2);  // 可能崩溃！未对齐
    __m128 vec2 = _mm_loadu_ps(data2);  // ✓ 使用未对齐加载（慢）
    
    // AVX要求32字节对齐
    alignas(32) float data3[8];
    __m256 vec3 = _mm256_load_ps(data3);  // ✓ 对齐加载
    
    // 性能差异：
    // _mm_load_ps（对齐）   vs  _mm_loadu_ps（未对齐）
    // 快约2倍
}
```

*6. 缓存行效率*

```cpp
// 现代CPU缓存行通常64字节
// 每次从内存加载数据到缓存时，以缓存行为单位

struct Data {
    int x;  // 4字节
};

// 未对齐到缓存行
Data arr[100];  // 可能跨越多个缓存行

// 对齐到缓存行
struct alignas(64) CacheAlignedData {
    int x;
    char padding[60];
};

CacheAlignedData arr2[100];  // 每个元素独占一个缓存行

// 多线程场景的false sharing
struct Counter {
    int count1;  // 缓存行1
    int count2;  // 同一缓存行
};

// 线程1修改count1 → 整个缓存行失效
// 线程2修改count2 → 需要重新加载缓存行
// → False Sharing，性能下降！

// 解决方案：对齐到独立缓存行
struct alignas(64) GoodCounter {
    int count1;
    char padding1[60];
};
GoodCounter counters[2];  // 每个counter独立缓存行
```

*总结：内存对齐的好处*

| 方面 | 未对齐 | 对齐 |
|------|--------|------|
| 访问速度 | 慢（多次内存访问） | 快（单次访问） |
| 跨平台 | 可能崩溃 | 兼容所有平台 |
| 原子操作 | 不保证原子性 | 保证原子性 |
| SIMD | 不可用或慢 | 高效 |
| 缓存利用 | 差 | 优 |
| 内存占用 | 少（无填充） | 多（有填充） |

*权衡*：对齐以空间换时间，绝大多数情况下是正确的选择。

=== 内存对齐示例

```cpp
#include <iostream>

// 1. 自然对齐
struct Natural {
    char c;    // 1字节，偏移0
    // 3字节填充
    int i;     // 4字节，偏移4
    short s;   // 2字节，偏移8
    // 2字节填充（保证数组元素对齐）
};
// sizeof(Natural) = 12（不是7）

// 2. 手动排列减少空间
struct Optimized {
    int i;     // 4字节，偏移0
    short s;   // 2字节，偏移4
    char c;    // 1字节，偏移6
    // 1字节填充
};
// sizeof(Optimized) = 8

// 3. 查看对齐要求
std::cout << "int对齐: " << alignof(int) << "\n";  // 4
std::cout << "double对齐: " << alignof(double) << "\n";  // 8

// 4. 指定对齐（C++11）
struct alignas(16) Aligned16 {
    int x;
};
std::cout << alignof(Aligned16) << "\n";  // 16

// 5. 对齐分配
void* aligned_alloc_example() {
    // C++17: aligned_alloc
    void* ptr = std::aligned_alloc(64, 128);  // 64字节对齐，128字节大小
    std::free(ptr);
    
    // C++11: alignas + new
    struct alignas(64) AlignedData {
        char data[128];
    };
    auto* p = new AlignedData;
    delete p;
    
    return ptr;
}

// 6. SIMD要求对齐
#include <immintrin.h>

alignas(32) float data[8];  // AVX需要32字节对齐
__m256 vec = _mm256_load_ps(data);  // 对齐加载

// 7. 缓存行对齐（避免false sharing）
struct alignas(64) CacheLine {  // 64字节 = 典型缓存行大小
    int counter;
    char padding[60];  // 填充到64字节
};

// 多线程场景
CacheLine counters[4];  // 每个counter在独立缓存行，避免false sharing
```

*内存对齐规则*：

```cpp
// 规则1：成员对齐
// 每个成员的偏移必须是其大小的倍数

// 规则2：结构体对齐
// 结构体大小必须是最大成员对齐的倍数

// 规则3：数组对齐
// 确保数组元素正确对齐

struct Example {
    char c1;      // 偏移0
    // 7字节填充
    double d;     // 偏移8（double要求8字节对齐）
    char c2;      // 偏移16
    // 7字节填充
};
// sizeof(Example) = 24
```

== Placement New

在指定内存位置构造对象。

```cpp
#include <new>
#include <iostream>

// 1. 基本用法
char buffer[sizeof(int)];
int* p = new (buffer) int(42);  // 在buffer中构造int
std::cout << *p << "\n";
p->~int();  // 手动调用析构函数（不释放内存）

// 2. 数组
char arr_buffer[sizeof(int) * 10];
int* arr = new (arr_buffer) int[10];  // 构造数组
for (int i = 0; i < 10; ++i) {
    arr[i].~int();  // 逐个析构
}

// 3. 对象池实现
template<typename T, size_t N>
class ObjectPool {
    alignas(T) char storage[N * sizeof(T)];
    bool used[N] = {};
    
public:
    template<typename... Args>
    T* allocate(Args&&... args) {
        for (size_t i = 0; i < N; ++i) {
            if (!used[i]) {
                used[i] = true;
                T* ptr = reinterpret_cast<T*>(&storage[i * sizeof(T)]);
                return new (ptr) T(std::forward<Args>(args)...);  // placement new
            }
        }
        return nullptr;
    }
    
    void deallocate(T* ptr) {
        if (!ptr) return;
        
        size_t index = (reinterpret_cast<char*>(ptr) - storage) / sizeof(T);
        if (index < N && used[index]) {
            ptr->~T();  // 调用析构
            used[index] = false;
        }
    }
};

// 使用
ObjectPool<std::string, 10> pool;
std::string* s1 = pool.allocate("Hello");
std::string* s2 = pool.allocate("World");
pool.deallocate(s1);
pool.deallocate(s2);

// 4. 自定义容器
template<typename T>
class MyVector {
    T* data;
    size_t capacity;
    size_t size;
    
public:
    void push_back(const T& value) {
        if (size == capacity) {
            reserve(capacity * 2);
        }
        new (&data[size]) T(value);  // placement new
        ++size;
    }
    
    void pop_back() {
        if (size > 0) {
            data[--size].~T();  // 显式析构
        }
    }
    
    void reserve(size_t new_cap) {
        if (new_cap <= capacity) return;
        
        T* new_data = static_cast<T*>(::operator new(new_cap * sizeof(T)));
        
        // 移动/拷贝现有元素
        for (size_t i = 0; i < size; ++i) {
            new (&new_data[i]) T(std::move(data[i]));
            data[i].~T();
        }
        
        ::operator delete(data);
        data = new_data;
        capacity = new_cap;
    }
    
    ~MyVector() {
        for (size_t i = 0; i < size; ++i) {
            data[i].~T();
        }
        ::operator delete(data);
    }
};

// 5. 内存映射文件
class MappedObject {
public:
    static void* operator new(size_t size) {
        // 使用mmap分配内存
        void* ptr = mmap(nullptr, size, PROT_READ | PROT_WRITE,
                         MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
        return ptr;
    }
    
    static void operator delete(void* ptr, size_t size) {
        munmap(ptr, size);
    }
};
```

== 内存池

提高小对象分配效率，减少内存碎片。

```cpp
// 1. 固定大小内存池
template<size_t BlockSize, size_t BlockCount>
class FixedMemoryPool {
    struct FreeNode {
        FreeNode* next;
    };
    
    alignas(std::max_align_t) char storage[BlockSize * BlockCount];
    FreeNode* free_list;
    
public:
    FixedMemoryPool() {
        // 初始化空闲链表
        free_list = reinterpret_cast<FreeNode*>(storage);
        FreeNode* current = free_list;
        
        for (size_t i = 0; i < BlockCount - 1; ++i) {
            char* next_block = storage + (i + 1) * BlockSize;
            current->next = reinterpret_cast<FreeNode*>(next_block);
            current = current->next;
        }
        current->next = nullptr;
    }
    
    void* allocate() {
        if (!free_list) return nullptr;
        
        void* ptr = free_list;
        free_list = free_list->next;
        return ptr;
    }
    
    void deallocate(void* ptr) {
        if (!ptr) return;
        
        FreeNode* node = static_cast<FreeNode*>(ptr);
        node->next = free_list;
        free_list = node;
    }
};

// 使用
FixedMemoryPool<32, 100> pool;  // 100个32字节的块
void* p1 = pool.allocate();
void* p2 = pool.allocate();
pool.deallocate(p1);

// 2. 线程安全的内存池
template<typename T>
class ThreadSafePool {
    struct Node {
        alignas(T) char storage[sizeof(T)];
        Node* next;
    };
    
    std::mutex mutex;
    Node* free_list = nullptr;
    std::vector<Node*> blocks;  // 跟踪所有分配的块
    
    static constexpr size_t BLOCK_SIZE = 1024;
    
    void grow() {
        Node* new_block = new Node[BLOCK_SIZE];
        blocks.push_back(new_block);
        
        for (size_t i = 0; i < BLOCK_SIZE; ++i) {
            new_block[i].next = free_list;
            free_list = &new_block[i];
        }
    }
    
public:
    template<typename... Args>
    T* allocate(Args&&... args) {
        std::lock_guard<std::mutex> lock(mutex);
        
        if (!free_list) {
            grow();
        }
        
        Node* node = free_list;
        free_list = free_list->next;
        
        T* ptr = reinterpret_cast<T*>(node->storage);
        return new (ptr) T(std::forward<Args>(args)...);
    }
    
    void deallocate(T* ptr) {
        if (!ptr) return;
        
        ptr->~T();
        
        std::lock_guard<std::mutex> lock(mutex);
        Node* node = reinterpret_cast<Node*>(ptr);
        node->next = free_list;
        free_list = node;
    }
    
    ~ThreadSafePool() {
        for (Node* block : blocks) {
            delete[] block;
        }
    }
};

// 3. STL兼容的分配器
template<typename T>
class PoolAllocator {
    ThreadSafePool<T>* pool;
    
public:
    using value_type = T;
    
    PoolAllocator(ThreadSafePool<T>* p) : pool(p) {}
    
    template<typename U>
    PoolAllocator(const PoolAllocator<U>& other) 
        : pool(reinterpret_cast<ThreadSafePool<T>*>(other.pool)) {}
    
    T* allocate(size_t n) {
        if (n != 1) {
            return static_cast<T*>(::operator new(n * sizeof(T)));
        }
        return pool->allocate();
    }
    
    void deallocate(T* ptr, size_t n) {
        if (n != 1) {
            ::operator delete(ptr);
        } else {
            pool->deallocate(ptr);
        }
    }
};

// 使用自定义分配器
ThreadSafePool<int> int_pool;
std::vector<int, PoolAllocator<int>> vec(PoolAllocator<int>(&int_pool));
```

== 内存泄漏详解

=== 什么是内存泄漏？

*定义*：程序动态分配的内存没有被正确释放，导致内存无法被重新使用。

```cpp
// 典型的内存泄漏
void leak_example() {
    int* p = new int(42);
    // 忘记delete p;
}  // p离开作用域，指针销毁，但内存未释放！

// 调用1000次后
for (int i = 0; i < 1000; ++i) {
    leak_example();  // 泄漏1000个int的内存
}
```

*内存泄漏 vs 悬垂指针*：

```cpp
// 内存泄漏：内存未释放，但无法访问
void memory_leak() {
    int* p = new int(42);
    p = nullptr;  // 内存泄漏！原来的内存无法访问也无法释放
}

// 悬垂指针：内存已释放，但指针仍在使用
void dangling_pointer() {
    int* p = new int(42);
    delete p;
    *p = 100;  // 危险！使用已释放的内存
}

// 双重释放
void double_delete() {
    int* p = new int(42);
    delete p;
    delete p;  // 未定义行为！
}
```

=== 常见内存泄漏场景

*1. 忘记释放*

```cpp
// 场景1：简单遗忘
void simple_leak() {
    char* buffer = new char[1024];
    // ... 使用buffer
    // 忘记：delete[] buffer;
}

// 场景2：提前返回
bool process_data(const std::string& filename) {
    char* buffer = new char[1024];
    
    if (filename.empty()) {
        return false;  // 泄漏！忘记释放buffer
    }
    
    // ... 处理数据
    delete[] buffer;
    return true;
}

// 场景3：异常抛出
void exception_leak() {
    int* data = new int[1000];
    
    // 如果这里抛出异常，data不会被释放
    process(data);  // 可能抛出异常
    
    delete[] data;  // 异常发生时不会执行
}
```

*2. 容器中存储裸指针*

```cpp
// 错误：容器中存储裸指针
void container_leak() {
    std::vector<int*> vec;
    
    for (int i = 0; i < 10; ++i) {
        vec.push_back(new int(i));  // 分配内存
    }
    
    // vec销毁时，只删除指针，不删除指向的内存
}  // 泄漏10个int！

// 正确方式1：手动释放
void correct1() {
    std::vector<int*> vec;
    for (int i = 0; i < 10; ++i) {
        vec.push_back(new int(i));
    }
    
    // 释放所有内存
    for (int* p : vec) {
        delete p;
    }
    vec.clear();
}

// 正确方式2：使用智能指针
void correct2() {
    std::vector<std::unique_ptr<int>> vec;
    for (int i = 0; i < 10; ++i) {
        vec.push_back(std::make_unique<int>(i));
    }
    // 自动释放，无泄漏
}
```

*3. 循环引用*

```cpp
// shared_ptr的循环引用
class Node {
public:
    std::shared_ptr<Node> next;
    std::shared_ptr<Node> prev;  // 问题所在
    ~Node() { std::cout << "~Node\n"; }
};

void circular_reference_leak() {
    auto node1 = std::make_shared<Node>();
    auto node2 = std::make_shared<Node>();
    
    node1->next = node2;  // node2引用计数 = 2
    node2->prev = node1;  // node1引用计数 = 2
    
    // 函数结束时：
    // node1引用计数 = 2 - 1 = 1（还有node2->prev指向）
    // node2引用计数 = 2 - 1 = 1（还有node1->next指向）
    // 两个对象都不会被删除！
}  // 泄漏！析构函数不会被调用

// 正确方式：使用weak_ptr
class GoodNode {
public:
    std::shared_ptr<GoodNode> next;
    std::weak_ptr<GoodNode> prev;  // 弱引用，打破循环
    ~GoodNode() { std::cout << "~GoodNode\n"; }
};

void no_leak() {
    auto node1 = std::make_shared<GoodNode>();
    auto node2 = std::make_shared<GoodNode>();
    
    node1->next = node2;  // node2引用计数 = 2
    node2->prev = node1;  // node1引用计数 = 1（weak_ptr不增加）
    
    // 函数结束时：
    // node1引用计数 = 1 - 1 = 0 → 删除
    // node2引用计数 = 2 - 1 - 1 = 0 → 删除
}  // 正确释放
```

*4. this指针与shared_ptr*

```cpp
// 错误：从this创建shared_ptr
class Widget {
public:
    std::shared_ptr<Widget> getPtr() {
        return std::shared_ptr<Widget>(this);  // 危险！
    }
};

void dangerous_this() {
    auto w1 = std::make_shared<Widget>();
    auto w2 = w1->getPtr();  // 创建了第二个独立的shared_ptr！
    
    // w1和w2都管理同一个对象，但引用计数分别独立
    // 当w1或w2之一为0时，会删除对象
    // 当另一个为0时，会再次删除 → 双重删除！
}

// 正确方式：enable_shared_from_this
class SafeWidget : public std::enable_shared_from_this<SafeWidget> {
public:
    std::shared_ptr<SafeWidget> getPtr() {
        return shared_from_this();  // 正确！共享引用计数
    }
};

void safe_this() {
    auto w1 = std::make_shared<SafeWidget>();
    auto w2 = w1->getPtr();  // w1和w2共享引用计数
    // 正确释放
}
```

*5. 资源管理类忘记释放*

```cpp
// 错误：资源管理类没有正确释放
class ResourceManager {
    int* data;
public:
    ResourceManager() : data(new int[1000]) {}
    // 忘记写析构函数！
};

void resource_leak() {
    ResourceManager rm;
}  // 泄漏！data未释放

// 正确方式：遵循Rule of Three/Five
class GoodResourceManager {
    int* data;
public:
    GoodResourceManager() : data(new int[1000]) {}
    
    ~GoodResourceManager() {
        delete[] data;  // 析构时释放
    }
    
    // 禁止拷贝，或实现深拷贝
    GoodResourceManager(const GoodResourceManager&) = delete;
    GoodResourceManager& operator=(const GoodResourceManager&) = delete;
    
    // 可选：实现移动
    GoodResourceManager(GoodResourceManager&& other) noexcept 
        : data(other.data) {
        other.data = nullptr;
    }
    
    GoodResourceManager& operator=(GoodResourceManager&& other) noexcept {
        if (this != &other) {
            delete[] data;
            data = other.data;
            other.data = nullptr;
        }
        return *this;
    }
};
```

*6. 多线程中的泄漏*

```cpp
#include <thread>
#include <mutex>

// 场景：线程局部存储泄漏
class ThreadManager {
    std::map<std::thread::id, int*> thread_data;
    std::mutex mtx;
    
public:
    void register_thread() {
        std::lock_guard<std::mutex> lock(mtx);
        thread_data[std::this_thread::get_id()] = new int(0);
    }
    
    // 问题：线程结束时没有清理
    ~ThreadManager() {
        // 应该释放所有thread_data中的指针
        for (auto& [id, ptr] : thread_data) {
            delete ptr;
        }
    }
};
```

=== 内存泄漏的危害

```cpp
// 1. 内存耗尽
void memory_exhaustion() {
    std::vector<int*> leaks;
    while (true) {
        leaks.push_back(new int[1024 * 1024]);  // 每次4MB
        // 最终：系统内存耗尽，程序崩溃或被系统杀死
    }
}

// 2. 性能下降
// - 可用内存减少 → 频繁换页（swapping）
// - 系统响应变慢
// - GC语言：GC压力增大

// 3. 长期运行的服务器
void server_leak() {
    // 假设服务器每秒泄漏1KB
    // 1天 = 86400秒 → 84MB
    // 1周 → 588MB
    // 1月 → 2.5GB
    // 最终服务器崩溃
}

// 4. 难以调试
// - 症状不明显：内存缓慢增长
// - 难以重现：可能需要运行数天才出现
// - 难以定位：泄漏点可能在代码的任何地方
```

=== 如何防止内存泄漏

*1. 使用RAII（Resource Acquisition Is Initialization）*

```cpp
// 原则：资源获取即初始化，资源释放通过析构函数自动完成

// 差的做法
void bad_raii() {
    FILE* fp = fopen("data.txt", "r");
    if (!fp) return;
    
    // ... 处理文件
    if (error_condition) {
        return;  // 泄漏！忘记fclose
    }
    
    fclose(fp);
}

// 好的做法：RAII
class FileHandle {
    FILE* fp;
public:
    FileHandle(const char* filename, const char* mode) 
        : fp(fopen(filename, mode)) {
        if (!fp) throw std::runtime_error("Cannot open file");
    }
    
    ~FileHandle() {
        if (fp) fclose(fp);
    }
    
    FILE* get() { return fp; }
    
    // 禁止拷贝
    FileHandle(const FileHandle&) = delete;
    FileHandle& operator=(const FileHandle&) = delete;
};

void good_raii() {
    FileHandle file("data.txt", "r");
    // ... 使用file.get()
    // 任何情况下（正常返回、异常、提前返回），文件都会自动关闭
}

// 更好：使用现有的RAII类
void best_raii() {
    auto deleter = [](FILE* fp) { if(fp) fclose(fp); };
    std::unique_ptr<FILE, decltype(deleter)> file(
        fopen("data.txt", "r"), deleter
    );
    // 自动管理
}
```

*2. 优先使用智能指针*

```cpp
// 规则：永远不要使用裸指针管理内存

// ✗ 差
void use_raw_pointer() {
    Widget* w = new Widget();
    // ... 
    delete w;  // 容易忘记，异常时不会执行
}

// ✓ 好：unique_ptr（独占所有权）
void use_unique_ptr() {
    auto w = std::make_unique<Widget>();
    // 自动释放，异常安全
}

// ✓ 好：shared_ptr（共享所有权）
void use_shared_ptr() {
    auto w = std::make_shared<Widget>();
    // 引用计数管理，自动释放
}

// ✓ 好：容器中存储智能指针
void use_container() {
    std::vector<std::unique_ptr<Widget>> widgets;
    widgets.push_back(std::make_unique<Widget>());
    // vector销毁时，自动释放所有Widget
}
```

*3. 避免循环引用*

```cpp
// 设计数据结构时考虑所有权

// 树结构：父节点拥有子节点
class TreeNode {
    std::vector<std::unique_ptr<TreeNode>> children;  // 拥有
    TreeNode* parent;  // 不拥有，裸指针
    
public:
    void addChild(std::unique_ptr<TreeNode> child) {
        child->parent = this;
        children.push_back(std::move(child));
    }
};

// 双向链表：使用weak_ptr
class ListNode {
public:
    std::shared_ptr<ListNode> next;  // 强引用
    std::weak_ptr<ListNode> prev;    // 弱引用，打破循环
};

// 图结构：明确所有权
class Graph {
    std::vector<std::unique_ptr<Node>> nodes;  // Graph拥有所有节点
    
    // 边使用裸指针或weak_ptr（不拥有）
    struct Edge {
        Node* from;
        Node* to;
    };
    std::vector<Edge> edges;
};
```

*4. 容器和异常安全*

```cpp
// 使用容器自动管理资源
void exception_safe() {
    std::vector<std::unique_ptr<Widget>> widgets;
    
    try {
        for (int i = 0; i < 10; ++i) {
            auto w = std::make_unique<Widget>();
            w->initialize();  // 可能抛出异常
            widgets.push_back(std::move(w));
        }
    } catch (...) {
        // widgets会自动释放所有已创建的Widget
        throw;
    }
    // 正常情况也自动释放
}

// 事务性操作
void transactional_resource() {
    std::vector<std::unique_ptr<Resource>> resources;
    
    try {
        // 第1步：分配资源
        resources.push_back(std::make_unique<Resource>(1));
        resources.push_back(std::make_unique<Resource>(2));
        
        // 第2步：可能失败的操作
        if (!validate()) {
            throw std::runtime_error("Validation failed");
        }
        
        // 第3步：提交
        for (auto& r : resources) {
            r->commit();
        }
    } catch (...) {
        // 自动回滚：resources析构会清理所有资源
        throw;
    }
}
```

*5. 遵循Rule of Three/Five/Zero*

```cpp
// Rule of Zero：不管理资源，让编译器生成默认函数
class RuleOfZero {
    std::string name;
    std::vector<int> data;
    std::unique_ptr<Widget> widget;
    // 不需要自定义析构、拷贝、移动 - 编译器生成的版本正确
};

// Rule of Three：如果需要自定义析构、拷贝构造或拷贝赋值之一，
// 则三者都需要定义（C++11之前）
class RuleOfThree {
    int* data;
    size_t size;
    
public:
    // 析构函数
    ~RuleOfThree() {
        delete[] data;
    }
    
    // 拷贝构造函数
    RuleOfThree(const RuleOfThree& other) 
        : size(other.size), data(new int[size]) {
        std::copy(other.data, other.data + size, data);
    }
    
    // 拷贝赋值运算符
    RuleOfThree& operator=(const RuleOfThree& other) {
        if (this != &other) {
            delete[] data;
            size = other.size;
            data = new int[size];
            std::copy(other.data, other.data + size, data);
        }
        return *this;
    }
};

// Rule of Five：C++11，加上移动构造和移动赋值
class RuleOfFive {
    int* data;
    size_t size;
    
public:
    ~RuleOfFive() { delete[] data; }
    
    RuleOfFive(const RuleOfFive& other);  // 拷贝构造
    RuleOfFive& operator=(const RuleOfFive& other);  // 拷贝赋值
    
    // 移动构造函数
    RuleOfFive(RuleOfFive&& other) noexcept 
        : data(other.data), size(other.size) {
        other.data = nullptr;
        other.size = 0;
    }
    
    // 移动赋值运算符
    RuleOfFive& operator=(RuleOfFive&& other) noexcept {
        if (this != &other) {
            delete[] data;
            data = other.data;
            size = other.size;
            other.data = nullptr;
            other.size = 0;
        }
        return *this;
    }
};
```

*6. 工厂函数返回智能指针*

```cpp
// 返回智能指针，明确所有权转移
std::unique_ptr<Widget> createWidget(int id) {
    auto w = std::make_unique<Widget>();
    w->setId(id);
    return w;  // 移动，无拷贝
}

void use_factory() {
    auto widget = createWidget(42);
    // 自动管理
}

// 多态工厂
std::unique_ptr<Base> createObject(const std::string& type) {
    if (type == "A") return std::make_unique<DerivedA>();
    if (type == "B") return std::make_unique<DerivedB>();
    return nullptr;
}
```

*7. 使用标准容器*

```cpp
// ✗ 差：手动管理数组
void manual_array() {
    int* arr = new int[1000];
    // ... 使用
    delete[] arr;  // 容易忘记
}

// ✓ 好：使用vector
void use_vector() {
    std::vector<int> arr(1000);
    // 自动管理
}

// ✗ 差：手动管理字符串
void manual_string() {
    char* str = new char[100];
    strcpy(str, "Hello");
    // ...
    delete[] str;
}

// ✓ 好：使用string
void use_string() {
    std::string str = "Hello";
    // 自动管理
}
```

*8. 注意第三方库和API*

```cpp
// 了解所有权语义
void third_party_api() {
    // 示例1：API返回的指针需要用户释放
    char* data = some_library_alloc();  // 分配内存
    // ... 使用
    some_library_free(data);  // 必须用对应的free函数
    
    // 更好：立即封装到智能指针
    std::unique_ptr<char, decltype(&some_library_free)> 
        smart_data(some_library_alloc(), some_library_free);
    
    // 示例2：API接管所有权
    Widget* w = new Widget();
    api_takes_ownership(w);  // API会负责释放
    // 不要再delete w！
    
    // 示例3：API不接管所有权
    Widget* w2 = new Widget();
    api_borrows(w2);  // API只是借用
    delete w2;  // 仍需手动释放
}
```

=== 内存泄漏检测工具

*1. Valgrind（Linux）*

```bash
# 编译时保留调试信息
g++ -g -O0 program.cpp -o program

# 运行Valgrind
valgrind --leak-check=full \
         --show-leak-kinds=all \
         --track-origins=yes \
         --verbose \
         --log-file=valgrind-out.txt \
         ./program

# 输出示例：
# ==12345== LEAK SUMMARY:
# ==12345==    definitely lost: 40 bytes in 1 blocks
# ==12345==    indirectly lost: 0 bytes in 0 blocks
# ==12345==    possibly lost: 0 bytes in 0 blocks
```

*2. AddressSanitizer (ASan)*

```bash
# 编译时启用ASan
g++ -fsanitize=address -fno-omit-frame-pointer -g program.cpp -o program

# 运行
./program

# 自动检测：
# - 内存泄漏
# - 使用已释放的内存
# - 缓冲区溢出
# - 双重释放
```

*3. 自定义内存跟踪*

```cpp
// 1. 重载全局new/delete进行跟踪
#ifdef DEBUG_MEMORY

#include <map>
#include <mutex>

struct AllocationInfo {
    size_t size;
    const char* file;
    int line;
};

std::map<void*, AllocationInfo> allocations;
std::mutex alloc_mutex;

void* operator new(size_t size, const char* file, int line) {
    void* ptr = malloc(size);
    std::lock_guard<std::mutex> lock(alloc_mutex);
    allocations[ptr] = {size, file, line};
    return ptr;
}

void operator delete(void* ptr) noexcept {
    std::lock_guard<std::mutex> lock(alloc_mutex);
    allocations.erase(ptr);
    free(ptr);
}

#define new new(__FILE__, __LINE__)

// 检测泄漏
void check_leaks() {
    std::lock_guard<std::mutex> lock(alloc_mutex);
    for (const auto& [ptr, info] : allocations) {
        std::cerr << "Leak: " << info.size << " bytes at " 
                  << info.file << ":" << info.line << "\n";
    }
}

#endif

// 2. RAII封装检测
class MemoryTracker {
    size_t allocations = 0;
    size_t deallocations = 0;
    
public:
    ~MemoryTracker() {
        if (allocations != deallocations) {
            std::cerr << "Memory leak detected!\n";
            std::cerr << "Allocations: " << allocations << "\n";
            std::cerr << "Deallocations: " << deallocations << "\n";
        }
    }
    
    void on_allocate() { ++allocations; }
    void on_deallocate() { ++deallocations; }
};

// 3. 使用工具
// Valgrind: valgrind --leak-check=full ./program
// AddressSanitizer: g++ -fsanitize=address program.cpp
// 内存分析器: heaptrack, massif
```

*4. Visual Studio内存泄漏检测*

```cpp
// Windows平台
#ifdef _DEBUG
#define _CRTDBG_MAP_ALLOC
#include <stdlib.h>
#include <crtdbg.h>

int main() {
    _CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
    
    // 程序代码
    int* leak = new int(42);  // 故意泄漏
    
    // 程序结束时自动报告泄漏
    return 0;
}
#endif
```

*5. 其他工具*

```bash
# Dr. Memory（跨平台）
drmemory -- ./program

# Heaptrack（Linux，可视化）
heaptrack ./program
heaptrack_gui heaptrack.program.gz

# Massif（Valgrind的一部分，分析堆使用）
valgrind --tool=massif ./program
ms_print massif.out.12345

# GPerfTools
LD_PRELOAD=/usr/lib/libtcmalloc.so HEAPCHECK=normal ./program
```

=== 内存泄漏防范检查清单

*代码审查清单*：

```cpp
// ✓ 检查项
// [ ] 所有new都有对应的delete
// [ ] 所有new[]都有对应的delete[]
// [ ] 异常安全：异常抛出时资源能正确释放
// [ ] 提前返回：所有return路径都释放了资源
// [ ] 容器存储：使用智能指针而非裸指针
// [ ] 循环引用：使用weak_ptr打破循环
// [ ] 资源类：实现或禁用拷贝/移动操作
// [ ] 第三方API：了解所有权语义
// [ ] 多线程：线程局部存储正确清理
// [ ] 单例模式：考虑是否需要释放
```

*代码模式*：

```cpp
// 1. 每个new都应该考虑：谁负责delete？
void allocation_ownership() {
    // 问题：谁负责释放？
    Widget* w = new Widget();
    
    // 答案1：我负责
    std::unique_ptr<Widget> w(new Widget());
    
    // 答案2：调用者负责
    std::unique_ptr<Widget> create() {
        return std::make_unique<Widget>();
    }
    
    // 答案3：共享所有权
    std::shared_ptr<Widget> w = std::make_shared<Widget>();
}

// 2. 容器中的资源
void container_resources() {
    // ✗ 需要手动管理
    std::vector<int*> bad;
    
    // ✓ 自动管理
    std::vector<int> good1;
    std::vector<std::unique_ptr<int>> good2;
}

// 3. 异常安全的资源获取
void exception_safe_acquisition() {
    // ✗ 不安全
    Resource* r1 = new Resource();
    Resource* r2 = new Resource();  // 如果这里抛出异常，r1泄漏
    
    // ✓ 安全
    auto r1 = std::make_unique<Resource>();
    auto r2 = std::make_unique<Resource>();  // 安全！
}

// 4. 成对操作
void paired_operations() {
    // 资源获取和释放应该在同一抽象层次
    
    // ✗ 差：获取和释放分离
    class Bad {
        int* data;
    public:
        void allocate() { data = new int[100]; }
        void deallocate() { delete[] data; }  // 容易忘记调用
    };
    
    // ✓ 好：通过构造和析构配对
    class Good {
        std::vector<int> data;
    public:
        Good() : data(100) {}  // 自动管理
    };
}

// 5. 明确的所有权转移
void ownership_transfer() {
    // ✗ 不清晰
    Widget* transfer_bad() {
        Widget* w = new Widget();
        return w;  // 谁负责删除？不清楚！
    }
    
    // ✓ 清晰
    std::unique_ptr<Widget> transfer_good() {
        auto w = std::make_unique<Widget>();
        return w;  // 明确：调用者获得所有权
    }
}
```

*常见陷阱*：

```cpp
// 陷阱1：忘记虚析构函数
class Base {
public:
    // 缺少virtual析构函数！
    ~Base() { /* ... */ }
};

class Derived : public Base {
    int* data;
public:
    Derived() : data(new int[1000]) {}
    ~Derived() { delete[] data; }
};

void polymorphic_delete() {
    Base* b = new Derived();
    delete b;  // 只调用Base::~Base()，Derived::~Derived()不会调用！
    // data泄漏！
}

// 正确：虚析构
class GoodBase {
public:
    virtual ~GoodBase() = default;
};

// 陷阱2：拷贝资源类
class ResourceHolder {
    int* data;
public:
    ResourceHolder() : data(new int[100]) {}
    ~ResourceHolder() { delete[] data; }
    // 没有禁用拷贝！
};

void copy_trap() {
    ResourceHolder r1;
    ResourceHolder r2 = r1;  // 浅拷贝！r1.data == r2.data
}  // 双重释放！

// 正确：禁用或实现深拷贝
class SafeResourceHolder {
    int* data;
public:
    SafeResourceHolder() : data(new int[100]) {}
    ~SafeResourceHolder() { delete[] data; }
    
    // 方式1：禁用拷贝
    SafeResourceHolder(const SafeResourceHolder&) = delete;
    SafeResourceHolder& operator=(const SafeResourceHolder&) = delete;
    
    // 方式2：或使用智能指针
    // std::unique_ptr<int[]> data;
};

// 陷阱3：返回局部变量的指针/引用
int* local_pointer() {
    int x = 42;
    return &x;  // 危险！返回局部变量地址
}

std::string& local_reference() {
    std::string s = "Hello";
    return s;  // 危险！返回局部变量引用
}

// 陷阱4：单例模式的内存
class Singleton {
    static Singleton* instance;
    Singleton() {}
public:
    static Singleton* getInstance() {
        if (!instance) {
            instance = new Singleton();  // 永不释放
        }
        return instance;
    }
};

// 更好的方式
class GoodSingleton {
public:
    static GoodSingleton& getInstance() {
        static GoodSingleton instance;  // 静态局部变量，程序结束时自动析构
        return instance;
    }
private:
    GoodSingleton() {}
    GoodSingleton(const GoodSingleton&) = delete;
    GoodSingleton& operator=(const GoodSingleton&) = delete;
};
```

*内存泄漏调试流程*：

```cpp
// 步骤1：重现问题
// - 在测试环境中运行程序
// - 监控内存使用（top, htop, Task Manager等）
// - 确认内存持续增长

// 步骤2：定位泄漏点
// - 使用Valgrind或ASan运行程序
// - 分析输出，找到泄漏的分配点
// - 查看调用栈

// 步骤3：分析原因
// - 是否忘记delete？
// - 是否有循环引用？
// - 异常安全问题？
// - 所有权不明确？

// 步骤4：修复
// - 使用智能指针
// - 添加RAII封装
// - 打破循环引用
// - 确保异常安全

// 步骤5：验证
// - 重新运行程序和检测工具
// - 确认泄漏消失
// - 添加单元测试防止回归

// 示例：调试循环引用
void debug_circular_reference() {
    // 问题代码
    auto node1 = std::make_shared<Node>();
    auto node2 = std::make_shared<Node>();
    node1->next = node2;
    node2->prev = node1;  // 循环引用
    
    // 调试：检查引用计数
    std::cout << "node1 count: " << node1.use_count() << "\n";  // 2
    std::cout << "node2 count: " << node2.use_count() << "\n";  // 2
    
    // 修复：使用weak_ptr
    // 在Node类中: std::weak_ptr<Node> prev;
}
```

== 内存管理最佳实践

```cpp
// 1. 优先使用栈
void good() {
    std::string s = "Hello";  // 栈上，自动管理
    std::vector<int> vec(100);  // 内部堆分配，但vec本身在栈上
}

void bad() {
    std::string* s = new std::string("Hello");  // 不必要的堆分配
    delete s;
}

// 2. 使用智能指针，避免裸指针
// ✓ 好
std::unique_ptr<Widget> widget = std::make_unique<Widget>();

// ✗ 差
Widget* widget = new Widget();
delete widget;

// 3. 避免过早优化
// 先写清晰的代码，必要时才优化
std::vector<int> data(1000);  // 简单清晰

// 不要过早使用内存池等复杂技术

// 4. 注意对象生命周期
void dangerous() {
    std::string* ptr;
    {
        std::string temp = "Hello";
        ptr = &temp;  // 危险！temp即将销毁
    }
    // *ptr;  // 悬垂指针！
}

// 5. 移动而非拷贝
std::vector<int> create_large_vector() {
    std::vector<int> vec(1000000);
    return vec;  // 移动，不拷贝
}

auto v = create_large_vector();  // 高效

// 6. 就地构造
std::vector<std::string> vec;
vec.emplace_back("Hello");  // 直接在vector中构造
// 而非：vec.push_back(std::string("Hello"));  // 构造临时对象+移动

// 7. 预分配容量
std::vector<int> vec;
vec.reserve(1000);  // 预分配，避免多次重新分配
for (int i = 0; i < 1000; ++i) {
    vec.push_back(i);
}

// 8. 小对象优化(SSO)意识
std::string short_str = "Hi";  // 可能不分配堆内存（SSO）
std::string long_str = "Very long string...";  // 分配堆内存

// 9. 自定义删除器
auto deleter = [](FILE* fp) { if(fp) fclose(fp); };
std::unique_ptr<FILE, decltype(deleter)> file(fopen("data.txt", "r"), deleter);

// 10. 避免内存碎片
// - 使用内存池管理小对象
// - 预分配连续内存
// - 避免频繁的分配/释放
```

== 总结

*内存管理关键原则*：

1. *RAII*：资源获取即初始化，利用对象生命周期管理资源
2. *智能指针*：优先使用智能指针，避免手动管理
3. *栈优先*：能用栈就用栈，性能最优
4. *移动语义*：利用移动避免不必要的拷贝
5. *就地构造*：使用emplace系列函数
6. *预分配*：已知大小时预分配容量
7. *内存对齐*：性能敏感代码注意对齐
8. *避免泄漏*：使用工具检测，遵循最佳实践

*智能指针选择*：
- 独占所有权 → `unique_ptr`
- 共享所有权 → `shared_ptr`
- 观察者模式 → `weak_ptr`
- 工厂函数 → `unique_ptr`（可转换为`shared_ptr`）

*性能优化*：
- 内存池：小对象频繁分配
- 对象池：复用对象
- 自定义分配器：特定场景
- placement new：精确控制内存位置
