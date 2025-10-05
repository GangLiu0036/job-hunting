= 基础部分
== 静态局部变量，全局变量，局部变量的特点，以及使用场景？

三者的特点可以从存储位置、生命周期、作用域和初始化方式四个维度分析：

1. 存储位置
- 静态局部变量：静态存储区（显示初始化的存储在数据段，未初始化的存储在bss段）
- 全局变量：静态存储区（显示初始化的存储在数据段，未初始化的存储在bss段）
- 局部变量：栈区

2. 生命周期
- 静态局部变量：程序运行期间持续存在（首次调用时初始化）
- 全局变量：程序运行期间持续存在（main函数执行前初始化）
- 局部变量：函数调用期间存在（每次调用重新创建）

3. 作用域
- 静态局部变量：仅在定义它的函数/代码块内可见（因此同名变量之间不会冲突）
- 全局变量：从定义位置到文件结尾可见（可通过extern扩展到其他文件，如果添加static关键字，则只在本文件中可见）
- 局部变量：仅在定义它的函数/代码块内可见

4. 初始化
- 静态局部变量：默认零初始化，只初始化一次
- 全局变量：默认零初始化，编译期初始化
- 局部变量：需要显式初始化，每次调用重新初始化

使用场景：
- 静态局部变量：需要保持状态但不需要全局可见的场景（如计数器、统计函数执行次数、递归深度控制）
- 全局变量：需要跨多个函数/文件共享数据的场景（例如配置信息，缓冲区等）
- 局部变量：函数内部临时使用的数据存储

关于静态全局变量的补充：
静态全局变量（static修饰的全局变量）具有文件作用域，与普通全局变量的主要区别在于：
1. 链接属性不同：静态全局变量具有internal linkage，普通全局变量具有external linkage
2. 可见性不同：静态全局变量仅在定义它的编译单元（.cpp文件）内可见
3. 使用建议：当需要文件内共享数据但避免与其他文件产生符号冲突时使用
4. 使用时与变量类型的顺序无关，例如 int static a; 和 static int a; 是等价的，但规范是static int a;


#figure(
  image("./figs/memory_4regions.png", width: 34%),
  caption: [内存四区示意图（图示提供：KamAcademy（卡码笔记））],
  // align: center
)



= 指针和引用的区别
指针是变量，存储的值是内存地址，可以被修改，可以为空(nullptr)，可以进行加减运算（加减运算的单位是sizeof(指针类型)）。可以有const修饰。此外，指针变量占用独立内存（32位系统4字节，64位系统8字节）

引用是别名，必须初始化且不能被修改，不能为空(nullptr)，不能进行加减运算。没有 const 修饰。它不占内存，由编译器在内部实现。

= const 语法
const 修饰变量，表示该变量不可被修改。对于单一变量类型，const 放在类型前面和后面都是等价的。
但是对于复合类型，const 放在类型前面和后面是不同的。此时需要遵循自右向左的阅读方式。例如：
```cpp
int *const p; 
// 1. p是const（常量），即它的值不可变
// 2. 往左看*，表示p是指针
// 3. 再往左看int，表示指向int的常量指针，最后得出结论：p是常量，指向int，指向的内存里的值可以改变，但p的值不能被修改
const int* q;
// 1. * 表明q是指向int的指针
// 2. 再往左看const int，表示指向const int的指针, 最后得出结论：q是指向常量的指针，指向的内存里的值不可改变，但q的值可以被修改

const int* const r;
// 1. 往左看是const, 表示r是常量，它的值不可修改
// 2. 再往左看是const int*，r是指向const int的常量指针, 最后得出结论：r是常量，指向const int，指向的内存里的值不可改变，但r的值也不可以被修改
```

注意：cpp 里面空格不影响编译，因此` int *const p; 和 int * const p; `是等价的。


== static关键字的作用
static关键字主要用于控制变量和函数的生命周期、作用域以及访问权限。



== const 关键字的作用
const关键字主要用于指定变量、指针、引用、成员函数等的性质

```cpp
// file1.cpp
void duplicate() {}  // 普通全局函数

// file2.cpp
void duplicate() {}  // 链接错误：重复定义

// 若改为static修饰则不会冲突
static void duplicate() {} // file1/file2可各自定义
```

== define 和 typedef， inline，const 的区别
#table(
  columns: 2,
  [特性], [define], [typedef],
  [处理阶段], [预处理阶段], [编译阶段],
  [本质], [纯粹的文本替换，没有类型检查], [创建类型别名，受类型系统约束],
  [作用域], [从定义处到文件结尾都有效，无视作用域], [遵守 C++ 的作用域规则 (namespace, class, function)],
  [指针处理], [容易出错], [安全、符合直觉],
  [结尾分号], [不需要], [必须有],
)

举例：
```cpp
#define P_CHAR char*
typedef char* PT_CHAR;

P_CHAR p1, p2;   // 预处理后变成: char* p1, p2;
                 // 结果: p1 是 char* 指针, p2 却是一个 char 变量！

PT_CHAR pt1, pt2; // pt1 和 pt2 都是 char* 指针类型。

```

== size_t 类型
size_t 类型是C++标准库中定义的一个无符号整数类型，用于表示内存块的大小或数组索引等。它的定义通常是：
```cpp
typedef unsigned long long size_t;
```
在32位系统上，size_t 通常是4字节，在64位系统上通常是8字节。
使用 size_t 而不是 int 或 unsigned int 主要有两个原因：可移植性 和 语义明确。当你的代码中使用 size_t 时，阅读代码的人（包括未来的你）会立刻明白：
- 这个变量代表一个大小、数量或索引。
- 这个值永远不可能是负数。

== `void*` 类型
`void*` 类型是一种通用的指针类型，可以指向任何类型的数据。它没有类型信息，因此不能直接进行解引用操作。需要先进行类型转换才能使用。
```cpp
void* p = malloc(10);
int* pi = static_cast<int*>(p);
```
C 语言的 malloc，其原型就是 `void* malloc(size_t size);`。malloc 也不知道你要用这块内存做什么，所以它也返回一个通用的 `void*`



== new 和 malloc的区别
首先 new/delete 是cpp的运算符，它可以重载，而 malloc/free 是c/cpp的标准库函数，不可以重载。
new无需指定内存块的大小，编译器会自动计算，而malloc需要指定内存块的大小。
new返回的是对象的指针，而malloc返回的是`void*`，需要类型转换。
new会调用对象的构造函数，而malloc不会。
new操作符从自由存储区上为对象动态分配内存空间，而malloc函数从堆上动态分配内存
new有类型安全检查，而malloc没有类型安全检查。

== constexpr 和 const 的区别
constexpr 只能定义编译期常量，而 const 可以定义编译期常量，也可以定义运行期常量。
```cpp
// 基础示例
const int c1 = 42;          // 运行时常量（可能编译期计算）
constexpr int ce = 42;      // 编译期常量

int runtime_val = rand();
const int c2 = runtime_val; // 合法（运行时初始化）
constexpr int ce2 = runtime_val; // 错误：需要编译期可知值
```
- const作用
修饰普通变量时：指向的变量的值不能修改。
修饰指针时：分为两种情况：如果是 const int *代表的是常量指针，则该指针指向的值不可以改变；如果是int * const，代表的是指针常量，则该指针的指向不可以改变。
修饰函数时：const修饰函数是C++的一个扩展，它的目的是为了保证类的封装性。在该类的成员函数后加上const之后，该函数不能修改该类的成员变量。
修饰函数传参时：修饰的参数在函数内不能修改。

#table(
  columns: 3,
  [特性], [const], [constexpr],
  [求值时机], [运行时常量（可能编译期优化）], [必须编译期确定值],
  [初始化要求], [可运行时初始化], [必须编译期常量表达式],
  [适用对象], [变量/成员函数], [变量/函数/构造函数],
  [类型限制], [无], [必须是字面类型（LiteralType）],
  [数组大小声明], [C99变长数组可能允许], [始终合法],
  [模板元编程], [有限支持], [核心工具（编译期计算）],
)

**函数应用示例**：
```cpp
// constexpr函数（C++11要求单return语句，C++14放宽）
constexpr int factorial(int n) {
    return (n <= 1) ? 1 : n * factorial(n-1);
}

constexpr int fact5 = factorial(5);  // 编译期计算120
int dynamic_val = factorial(runtime_val); // 运行时计算
```

*类与对象示例*：
```cpp
class Point {
public:
    constexpr Point(double x, double y) : x(x), y(y) {}
    constexpr double getX() const { return x; }
private:
    double x, y;
};

constexpr Point origin(0, 0);  // 编译期构造对象
constexpr double x = origin.getX(); // 编译期调用成员函数
```

*工程实践建议*：
1. *优先使用constexpr的场景*：
```cpp
// 数学常量
constexpr double PI = 3.141592653589793;

// 模板元编程
template <size_t N>
struct ArrayWrapper {
    int data[N];
};

// 替代宏定义的常量
constexpr int MAX_BUFFER_SIZE = 1024;
```

2. *const的典型应用*：
```cpp
// 运行期只读变量
const auto& db_conn = GetDatabaseConnection();

// 成员函数承诺不修改对象状态
class DataProcessor {
public:
    void process() const { /* 不修改成员变量 */ }
};
```

3. *C++17起可组合使用*：
```cpp
constexpr const char* LOG_PREFIX = "[DEBUG]"; // 编译期常量指针
```

*特殊注意*：
- `constexpr`变量隐式包含`const`属性
- `const`指针的常量性：
```cpp
const int* p1;        // 指向常量的指针
int const* p2;        // 同p1
int* const p3 = &var; // 常量指针（需初始化）
constexpr int* p4 = &var; // 编译期常量指针（C++17起）
```

*编译期检测机制*：
```cpp
// 通过模板参数验证编译期常量
template <int N>
struct MustBeCompileTimeConstant {};

MustBeCompileTimeConstant<ce> valid;   // OK
MustBeCompileTimeConstant<c1> invalid; // 错误（除非c1是constexpr）
```

通过合理使用`constexpr`，可以提升代码性能（编译期计算），增强类型安全性，并支持更复杂的模板元编程场景。而`const`主要用于运行时的只读保证和常量语义表达。

== volatile
指令关键字，确保本条指令不会因编译器的优化而省略，且要求每次直接读值，保证对特殊地址的稳定访问。例如：空循环不会被编译器优化。

== 前置++与后置++
前置++和后置++操作符有本质区别，主要体现在返回值和性能上。
```cpp
class CustomInt {
public:
    // 前置++（返回引用）
    CustomInt& operator++() {
        ++value;
        return *this;
    }

    // 后置++（返回旧值副本）
    CustomInt operator++(int) { // int参数用于区分重载，在调用时会传入0，因此i++++是不合法的。
        CustomInt temp = *this; // 构造临时对象，产生额外开销
        ++value;
        return temp;
    }

private:
    int value = 0;
};
```

左值 (lvalue)：有持久地址，可重复使用，例如变量名、前置++结果
亡值 (xvalue)：资源可被移动的临时值，例如std::move()的结果
纯右值 (prvalue)：临时对象，无持久地址，例如字面量、后置++的返回值，因此 i++++不合法，除非定义为 const Type operator++(int){xxx}


== 函数指针
函数指针是指向函数的指针变量。它可以用于存储函数的地址，允许在运行时动态选择要调用的函数。
使用场景：
- 回调函数： 函数指针常用于实现回调机制，允许将函数的地址传递给其他函数，以便在适当的时候调用。
- 函数指针数组： 可以使用函数指针数组实现类似于状态机的逻辑，根据不同的输入调用不同的函数。
- 动态加载库： 函数指针可用于在运行时动态加载库中的函数，实现动态链接库的调用。
- 多态实现： 在C++中，虚函数和函数指针结合使用，可以实现类似于多态的效果。
- 函数指针作为参数： 可以将函数指针作为参数传递给其他函数，实现一种可插拔的函数行为。
- 实现函数映射表： 在一些需要根据某些条件调用不同函数的情况下，可以使用函数指针来实现函数映射表。

```cpp
// 定义函数指针类型
typedef void (*FuncPtr)(int);

// 声明函数指针变量
FuncPtr funcPtr = &function;

// 调用函数
funcPtr(10);

// 函数指针作为参数
void func(FuncPtr funcPtr) {
    funcPtr(10);
}

```

- 函数指针是指向函数的指针变量。可以存储特定函数的地址，并在运行时动态选择要调用的函数。通常用于回调函数、动态加载库时的函数调用等场景。
- 指针函数是一个返回指针类型的函数，用于返回指向某种类型的数据的指针

== cpp强制类型转换
关键字：static_cast、dynamic_cast、reinterpret_cast和 const_cast

- static_cast
没有运行时类型检查来保证转换的安全性
进行上行转换（把派生类的指针或引用转换成基类表示）是安全的
进行下行转换（把基类的指针或引用转换为派生类表示），由于没有动态类型检查，所以是不安全的。

```cpp
// 基本类型转换
double d = 3.14;
int i = static_cast<int>(d);

// 类层次向上转换
Base* pb = static_cast<Base*>(&derived);

// 显式构造函数调用
void* p = malloc(sizeof(int));
int* pi = static_cast<int*>(p);

// 枚举与整型转换
enum Color { RED, GREEN };
int color_code = static_cast<int>(RED);

```

- dynamic_cast
在进行下行转换时，dynamic_cast具有类型检查（信息在虚函数中）的功能，比static_cast更安全。
转换后必须是类的指针、引用或者`void*`，基类要有虚函数，可以交叉转换。
dynamic本身只能用于存在虚函数的父子关系的强制类型转换；对于指针，转换失败则返回nullptr，对于引用，转换失败会抛出异常。
```cpp
// 安全向下转型
Base* pb = &derived;
Derived* pd = dynamic_cast<Derived*>(pb); // 成功

Base* pbase = new Base;
Derived* pderived = dynamic_cast<Derived*>(pbase); // 返回nullptr

// 引用类型转换（失败时抛出std::bad_cast）
try {
    Derived& rd = dynamic_cast<Derived&>(base);
} catch (const std::bad_cast& e) {
    // 处理转换失败
}
```

- reinterpret_cast
可以将整型转换为指针，也可以把指针转换为数组；可以在指针和引用里进行肆无忌惮的转换，平台移植性比价差。不进行任何类型检查，高度依赖具体实现。
```cpp
// 指针与整数互转
intptr_t addr = reinterpret_cast<intptr_t>(&i);

// 不同类型指针转换
Unrelated* up = reinterpret_cast<Unrelated*>(&derived);

// 函数指针转换
using FuncPtr = void(*)();
FuncPtr func = reinterpret_cast<FuncPtr>(&dummy);

// 结构体二进制处理
struct Packet { char data[128]; };
Packet pkt;
int32_t* pnum = reinterpret_cast<int32_t*>(pkt.data + 4);

```

- const_cast
不能改变基础类型，常量指针转换为非常量指针，并且仍然指向原来的对象。常量引用被转换为非常量引用，并且仍然指向原来的对象。去掉类型的const或volatile属性。
```cpp
// 常量指针转换为非常量指针
const int* p = &i;
int* p2 = const_cast<int*>(p);

// 常量引用转换为非常量引用
const int& r = i;
int& r2 = const_cast<int&>(r);

// 修改mutable成员
class C {
    mutable int counter;
public:
    void inc() const {
        const_cast<C*>(this)->counter++;
    }
};
```




== struct和Class的区别
- 相同点：
如果结构体没有定义任何构造函数，编译器会生成默认的无参数构造函数。如果类没有定义任何构造函数，编译器也会生成默认的无参数构造函数。
- 不同点：
通常，struct用于表示一组相关的数据，而class用于表示一个封装了数据和操作的对象,在实际使用中，可以根据具体的需求选择使用struct或class。如果只是用来组织一些数据，而不涉及复杂的封装和继承关系，struct可能更直观；如果需要进行封装、继承等面向对象编程的特性，可以选择使用class。
struct结构体中的成员默认是公有的（public）。类中的成员默认是私有的（private）。
struct 继承时默认使用公有继承。class 继承时默认使用私有继承

== extern关键字
extern关键字用于声明一个变量或函数，不分配内存。它的作用是告诉编译器这个变量或函数在其他文件中定义，。

```cpp
// 文件A.cpp
int x = 10; // 定义全局变量x（分配内存）
// 文件B.cpp
extern int x; // 声明x，链接到A.cpp中的定义
void func() {
    x = 20; // 使用A.cpp中定义的x
}
```

函数声明默认是带extern的。
```cpp
// 文件A.h
extern void func(); // 等价于 void func();
// 文件B.cpp
void func() { /* 实现 */ } // 定义函数
```

C++ 与 C 混合编程：
```cpp
extern "C" { /* C函数声明 */ } // 告诉C++编译器按C语言规则链接
```

模板与extern（C++11+）
显式实例化声明：
```cpp
// 声明：告知编译器某个模板实例已在其他文件中定义
extern template class std::vector<int>;
// 定义（另一个文件中）
template class std::vector<int>;
```
作用： 减少编译时间（避免重复实例化），常用于大型项目。

== size of
sizeof 是 C++ 中用于获取类型或表达式大小的编译时操作符，其核心价值在于：
内存管理：精确计算数据结构大小，避免内存泄漏
跨平台兼容：处理不同系统的类型大小差异
模板元编程：在编译期进行类型大小的条件判断
性能优化：通过对齐优化减少内存碎片

```cpp
int arr[10];
void func(int arr[]) {
    cout << sizeof(arr) << endl; 
}
int main() {
    cout << sizeof(arr) << endl; // 40
    func(arr);  // 8 (64 bit system)
    return 0;
}
```

== C++中的nullptr与NULL的区别
nullptr 为 C++11引入的关键字，表示一种特殊的空指针类型，具体为std::nullptr_t线程安全类型，这种类型可以隐式转换为任意的指针类型，但不能转换为整数类型。
NULL是一个宏定义，通常定义为0或`(void*)0`，它的本质还是一个整数常量，可以隐式的转换为指针类型，但可能引发分歧。