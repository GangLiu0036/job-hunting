#import "@preview/cetz:0.4.0"
#import "@preview/equate:0.3.2": equate
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *



= C++ 笔记

when you need to write a code with fast performance, you should use cpp.

game engine, 内存受限场景
== cpp环境配置并输出hello World
=== windows
- 安装visual studio 202x，选择cpp开发桌面套件即可；
- 打开visual studio 202x，选择general，选择创建新项目；
- 选择空项目，输入项目名称，选择位置，点击创建；
- 创建一个cpp文件，输入代码：
```cpp
#include <iostream>
using namespace std;
int main() {
    cout << "Hello, World!" << endl;
    return 0;
}
```
- 选择默认的debug+x64模式，点击 build，选择build solution，输出hello World。
如果改为 release+x64模式，则会自动添加一些优化，加速程序运行。

=== linux
- 安装g++，cmake，一个编辑器，如vscode；
- mkdir filename建立文件夹，cd filename进入文件夹；
- touch main.cpp创建空的main.cpp文件；
- 输入代码（直接在vim打开cpp文件或者在终端输入vscode，然后打开main.cpp文件）：
```cpp
#include <iostream>
using namespace std;
int main() {
    cout << "Hello, World!" << endl;
    return 0;
}
```
- 在终端输入g++ main.cpp -o main，输出hello World
- 在终端输入./main，输出hello World。 注意这里需要确认文件的权限，在终端输入ls -l main，如果文件没有可执行权限(-x)，则需要输入chmod +x main。

在编译阶段，也可以使用使用cmake+shell脚本，这样在编译阶段会自动生成可执行文件。这一步需要准备一个CMakeLists.txt文件，以及一个build.sh脚本。
这里不具体展开，好处是，当你需要编译多个cpp文件以及使用多个头文件时，只需要修改CMakeLists.txt文件，然后运行build.sh脚本，就会自动生成可执行文件。

=== Mac
安装 xcode IDE 直接搞定

== cpp基础
=== 程序运作原理
$"*.cpp"$ ->(compiler) $"*.obj"$ ->(linker) $"*.exe"$

首先通过编译器将cpp文件编译成obj文件，然后通过链接器将obj文件链接成exe文件。这里需要注意的是一个预处理器，会将cpp文件中的宏定义替换为实际的值，以及将cpp文件中的头文件包含进来，即把头文件中涉及到的代码在入口cpp文件中进行拼接。

=== 变量
不同变量的区别只有size的区别，具体来说就是占用的内存大小，这个大小取决于编译器。
可以使用sizeof(变量名)来查看变量占用的内存大小。

类型转换



=== 函数
需要多次调用的代码，可以封装成函数，这样在需要调用时，只需要调用函数名即可。

多值返回问题

optional 类型

=== 函数指针

=== 头文件
头文件中通常包含变量、函数、类的声明，以及一些宏定义。
cpp 和 c 的头文件在语法上只有一个.h的扩展名的区别。
例如：
```cpp
#include <iostream>
using namespace std;
void print() {
    cout << "Hello, World!" << endl;
}
```


```c
#include <stdio.h>
void print() {
    printf("Hello, World!\n");
}
```
对于宏文件，它一般对应一个同名的.cpp文件，但是这个文件不会被编译，而是被预处理器处理。





=== debug 调试
在visual studio 202x中，可以通过设置断点来调试程序L:
- 选中需要调试的代码行，点击行号旁边的空白处或者按F9，设置断点；
- 然后点击本地 windows 调试器，开始调试。
- 在调试过程中，可以通过点击调试器中的按钮来执行程序，或者点击调试器中的按钮来查看变量值。
- 可以选择逐个语句调试（F11, 进入到函数内部）或者逐个过程（F10, 直接执行整个涉及到的函数）调试。
- 如果需要直接跳到下一个断点，可以选择跳出（shift + F11）来快速执行完代码段（循环）。

此外我们可以在左下角的控制台中输入变量名来查看变量值。并且可以打开内存视图来查看内存中的数据。
更详细的调试技巧可以参考：
- https://cloud.tencent.com/developer/article/2508178

条件断点
可以在不重新编译的情况下debug


=== 结构体和类
区别是类内属性和方法默认是private的，而结构体是public的。




成员初始化

=== static 静态变量
将变量声明为static，则该变量会被存储在静态区，而不是栈区。
- 在类和结构体内定义的static变量，都只会在全局中存在一个（所有实例共享一个），不会被重复定义；
- 在函数内定义的static变量，则只会被当作该cpp文件中的“局部变量”，不会被其他cpp文件中的同名变量影响。

需要注意的是，当static变量在类和结构体中定义时，它们已经失去了成员变量的意义，它们已经变成了命名空间里的全局变量。
这个命名空间的名字是类名或结构体名。

关于类的静态属性以及local static知识需要进一步补充：TODO

=== 继承


=== 多态


=== 虚函数
虚函数是实现多态的关键，通过虚函数可以实现父类指针指向子类对象。


=== 内存
栈内存和堆内存

=== 字符串
某人：字符串是c++中的一种数据类型，用于存储和操作文本数据。
一般以 char* 类型来表示字符串，但是char* 类型并不是字符串类型，而是一个指向字符的指针。或者 char[] 类型来表示字符串。

注意：在字符串最后一个可见字符后面，还有一个空字符'\0'，，这个字符表示字符串的结束。


=== const
三种用法：
- 放在变量前，表示该变量的值不可被修改；
- 放在变量后，表示该变量的地址不可被修改；
- 放在函数名后，表示该函数无法修改变量；

=== 数组
在cpp里，数组是存放在连续内存空间上的相同类型数据的集合。而像 Java 是没有指针的，同时也不对程序员暴露其元素的地址，寻址操作完全交给虚拟机。

=== 运算符重载
+，>>

=== this指针

=== 智能指针 unique 指针 和 shared 指针, weak 指针

=== 拷贝

=== 库的使用
静态库和动态库

=== 模板 template


=== 异常处理


=== 宏
文本替换，便于调试

可以用 \\ 来换行

=== 静态数组 array

=== 命名空间 namespace
类本身也是一个命名空间，类名就是命名空间名。

=== 线程 thread

=== 联合体



=== 编译
预编译头文件可以节省大量时间。一般可以在visual studio 202x中设置。

== cpp 17
std::variant
std::any
std::future
std::string_view

== STL 标准模板库

=== vector
vector的底层实现是array，严格来讲vector是容器，不是数组。