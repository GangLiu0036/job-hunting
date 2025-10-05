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

= 内存池项目学习笔记

== 语法：捕获列表（capture list）
只适用于lambda表达式，专门用于控制 lambda 函数如何访问外部作用域的变量。
语法格式 `[捕获列表](参数列表) -> 返回类型 { 函数体 }`, 其中捕获列表是可选的，参数列表和返回类型是可选的，函数体是必需的。
```cpp
auto increment_task = [&]() {
    for (int i = 0; i < 1000; ++i) {
        mtx.lock();   
        shared_counter++;
        mtx.unlock();
    }
};
```

捕获方式解读：
- [&]：以引用方式捕获所有外部变量
- [=]：以值方式捕获所有外部变量
- [a, &b]：值捕获a，引用捕获b
- [this]：捕获当前类的this指针
- []：不捕获任何外部变量

== 函数对象
函数对象是重载了 `operator()` 的类，可以像函数一样被调用。

与 lambda 表达式的关系：
- Lambda 表达式在编译后会生成匿名的函数对象类
- 函数对象是显式的类定义，lambda 是隐式的语法糖

示例：
```cpp
// 函数对象版本
struct ThreadTask {
    std::mutex& mtx;
    int& counter;
    
    ThreadTask(std::mutex& m, int& c) : mtx(m), counter(c) {}
    
    void operator()() {
        for (int i = 0; i < 1000; ++i) {
            std::lock_guard<std::mutex> lock(mtx);
            counter++;
        }
    }
};

// 等效的 lambda 版本
auto lambda_task = [&]() {
    for (int i = 0; i < 1000; ++i) {
        std::lock_guard<std::mutex> lock(mtx);
        counter++;
    }
};
```

作用：
1. 用于stl中需要函数作为参数的场景，如sort、find_if、transform等。
2. 可以作为模板参数
```cpp
  template<typename Func>
  void process(int x, Func f) {
      std::cout << f(x) << std::endl;
  }
  
  struct Square { int operator()(int x) const { return x * x; } };
  process(5, Square());  // 输出 25
```
3.可以拥有状态，即可以存储数据
```cpp
  struct Counter {
      int count = 0;
      int operator()() { return count++; }
  };
  Counter counter;
  std::cout << counter() << std::endl;  // 输出 0
  std::cout << counter() << std::endl;  // 输出 1
```

== 类成员初始化方式
+ 初始化列表（推荐，构造时直接初始化）
```cpp
class MyClass {
    int x;
    std::string s;
    const int id;
    int arr[5];

    MyClass(int val) : x(val), s("hello"), id(100), arr{1, 2, 3, 4, 5} {
        // 构造函数体
    }
};
```

+ 类内初始化（推荐，编译时提供默认值）
```cpp
class MyClass {
    int x = 0;           // 类内初始化
    std::string s = "default";
    const int id = 100;
    
    MyClass(int val) : x(val) {}  // 可以覆盖类内初始值
    MyClass() = default;          // 使用类内初始值
};
```

+ 静态成员初始化
```cpp
class MyClass {
    static int count;       // 声明
    static const int max = 100; // 整型静态常量可以在类内初始化
};

int MyClass::count = 0;     // 定义和初始化，这里类本身可以看作是一个命名空间，静态成员属于类，不属于对象
```

+ 默认初始化
```cpp
class MyClass {
    int x;          // 未初始化，值不确定
    std::string s;  // 默认构造（空字符串）
};
```

+ 构造函数体内赋值
```cpp
class MyClass {
    int x;
    std::string s;
    
    MyClass(int val) {
        x = val;    // 赋值，不是初始化
        s = "hello"; // 先默认构造，再赋值
    }
};
```

== `void*`
C++ 中的一个特殊指针类型，称为无类型指针或泛型指针。

它的基本特性如下：
- 可以指向任何类型的数据
- 不能直接解引用
- 必须进行类型转换后才能使用

主要用于内存管理，使用过程中需要注意类型安全的问题。
可以使用以下两种方式保证类型安全：
```cpp
// 1.使用模板实现类型安全
template<typename T>
T* allocate() {
    return static_cast<T*>(memory_pool.allocate());
}

// 2.使用 std::any (C++17)
std::any data = x;  // 类型安全的任意值存储

```

== assert()
C/C++ 标准库中的一个调试宏，用于在程序运行时检查条件是否满足。

特性：
- 括号内结果为真，程序继续执行
- 括号内结果为假，程序终止，并输出括号内的错误信息：`Assertion failed: ` + 括号内的内容

在编译中可以可选：
```
g++ -DNDEBUG program.cpp  # 禁用所有assert
g++ -DNDEBUG -O2 program.cpp  # 发布版本禁用assert
```

注意：不要用于错误处理，因为在发布版本里会静默该行为，应改用异常或者静态断言:
```
// 异常
if (ptr == nullptr) {
    throw std::invalid_argument("指针不能为空");
}

// 静态断言
static_assert(sizeof(int) == 4, "int必须是4字节");

```

== 可变参数包 `typename... Args`
`...` 表示参数包，可以展开为多个参数.
```cpp
template<typename T, typename... Args>
T* HashBucket::newElement(Args&&... args);
```

例如：`newElement<MyClass>(1, "hello", 3.14)` 会展开为：
- `Args = int, const char*, double`
- `args = 1, "hello", 3.14`

注意：`Args&&... args` 和 `Args... args` 是不同的，前者是万能引用`T&&`，后者是可变参数包。
万能引用 `Args&&... args`:
- 保持参数的值类别
- 需要配合 `std::forward<Args>(args)...` 完美转发

`std::forward<Args>(args)...` 的作用是:
- 保持值类别：
-- 如果参数是左值（有名字的对象），转发为左值引用，从而实现拷贝构造的调用
-- 如果参数是右值（临时对象），转发为右值引用，从而实现移动构造的调用

例如：
```cpp
template<typename T>
void func(T&& param);  // T&& 是万能引用

// 如果传入左值，T&& 变成左值引用
int x = 10;
func(x);  // T = int&, param 类型是 int&

// 如果传入右值，T&& 变成右值引用  
func(10);  // T = int, param 类型是 int&&

void process(int& x) { std::cout << "左值版本" << std::endl; }
void process(int&& x) { std::cout << "右值版本" << std::endl; }

template<typename T>
void wrapper(T&& param) {
    process(param);  // ❌ param 有名字，总是左值！
}

int x = 10;
wrapper(x);       // 调用左值版本 ✅
wrapper(10);      // 也调用左值版本！❌ 应该调用右值版本

// 使用完美转发
template<typename T>
void wrapper(T&& param) {
    process(std::forward<T>(param));  // ✅ 保持原始值类别
}

int x = 10;
wrapper(x);       // 调用左值版本 ✅
wrapper(10);      // 调用右值版本 ✅
```


补充：左值和右值的区别
- 左值：有名字的对象，可以取地址
- 右值：临时对象，不可以取地址


== c++11以及之后产生的新的构造方式
+ 移动构造（Move Constructor）
```cpp
class MyString {
    char* data;
    size_t size;
public:
    // 传统拷贝构造（深拷贝，开销大）
    MyString(const MyString& other) {
        size = other.size;
        data = new char[size];
        memcpy(data, other.data, size);  // 复制数据，慢！
    }
    
    // C++11 移动构造（转移所有权，开销小）
    MyString(MyString&& other) noexcept {
        data = other.data;      // 直接"偷"指针
        size = other.size;
        other.data = nullptr;   // 清空原对象
        other.size = 0;
    }
};
```
适合临时对象的拷贝，例如临时字符串，或者直接拷贝一些函数生成的对象。

+ 委托构造（Delegating Constructor）
```cpp
class MyClass {
    int x;
    std::string name;
public:
    // 主构造函数
    MyClass(int val, const std::string& n) : x(val), name(n) {
        std::cout << "主构造函数" << std::endl;
    }
    
    // 委托给主构造函数
    MyClass() : MyClass(0, "default") {}  // 委托构造
    MyClass(int val) : MyClass(val, "unnamed") {}  // 委托构造
};
```

+ 继承构造函数（Inheriting Constructor）
```cpp
class Base {
public:
    Base(int x, double y) {}
};

class Derived : public Base {
public:
    using Base::Base;  // C++11: 继承父类所有构造函数
};

// 现在可以这样用：
Derived d(10, 3.14);  // 直接使用继承来的构造函数
```

+ 列表初始化构造（Initializer List Constructor）
```cpp
class MyVector {
    std::vector<int> data;
public:
    // 接受初始化列表
    MyVector(std::initializer_list<int> list) : data(list) {}
};

// 使用
MyVector v = {1, 2, 3, 4, 5};  // 调用初始化列表构造
```

各种构造方式对比表
#align(center, table(
    columns: 4,
    [构造类型], [C++版本], [语法], [用途],
    [默认构造], [C++98], [T()], [无参数创建对象],
    [参数构造], [C++98], [T(args)], [带参数创建对象],
    [拷贝构造], [C++98], [T(const T&)], [复制对象],
    [移动构造], [C++11], [T(T&&)], [转移资源所有权],
    [委托构造], [C++11], [T() : T(args)], [构造函数互相调用],
    [继承构造], [C++11], [using Base::Base], [继承父类构造函数],
    [列表初始化构造], [C++11], [T{args}], [统一初始化语法]
))