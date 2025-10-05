#import "@preview/cetz:0.4.0"
#import "@preview/equate:0.3.2": equate
#import "@preview/codly:1.3.0": *
#import "@preview/codly-languages:0.1.1": *

== go 特性
1.简单高效
2.原生支持并发编程
3.垃圾回收：自动管理内存
4.跨平台：Go 可以编译成跨平台的二进制文件，支持多种操作系统和硬件架构。

主要应用领域：
1.服务器开发
2.云计算
3.网络编程
4.分布式系统


=== 变量
1.变量类型
- bool
- string
- int  int8  int16  int32  int64
- float float32 float64
- complex
- byte (uint8 的别名)
- rune (int32 的别名)
- uint uint8 uint16 uint32 uint64
- uintptr
- complex64 complex128
注意：int、uint 和 uintptr 类型在 32-位系统上通常为 32-位宽，在 64-位系统上则为 64-位宽。

2.变量声明
var 语句用于声明一系列变量。和函数的参数列表一样，类型在最后。

如例中所示，var 语句可以出现在包或函数的层级。
```go
var c, python, java bool
var c, python, java = true, false, "no!"
var i, j int = 1, 2

func main() {
  a := 1
}
```

变量声明可以包含初始值，每个变量对应一个。
如果提供了初始值，则类型可以省略；变量会从初始值中推断出类型。

在函数中，短赋值语句 := 可在隐式确定类型的 var 声明中使用。
函数外的每个语句都 必须 以关键字开始（var、func 等），因此 := 结构不能在函数外使用。

没有明确初始化的变量声明会被赋予对应类型的零值：
- 数值类型为 0，
- 布尔类型为 false，
- 字符串为 ""（空字符串）。

类型转换
类型转换为显示类型转换
```go
i := 42
f := float64(i)
u := uint(f)
```

如果不是显示转换，GO 也会完成类型推断，但如果是一些数值常量，则取决于常量精度：
```go
i := 42           // int
f := 3.142        // float64
g := 0.867 + 0.5i // complex128
```

常量的声明与变量类似，只不过使用 const 关键字。
常量可以是字符、字符串、布尔值或数值。
常量不能用 := 语法声明
```go
const Pi = 3.14
```
一个未指定类型的常量由上下文来决定其类型。
在不同类型里是高精度的，例如 int64 和 float64 都是高精度的。

=== 循环
Go 只有一种循环结构：for 循环。
```go
func main() {
	sum := 0
	for i := 0; i < 10; i++ {
		sum += i
	}
	fmt.Println(sum)
}
```
和 C、Java、JavaScript 之类的语言不同，Go 的 for 语句后面的三个构成部分外没有小括号， 大括号 { } 则是必须的。
初始化语句和后置语句是可留空的。

for 是 Go 中的「while」
```go
func main() {
	sum := 1
	for sum < 1000 {
		sum += sum
	}
	fmt.Println(sum)
}
```
无限循环：
```go
for {
}
```

range 遍历
for 循环的 range 形式可遍历切片或映射。

当使用 for 循环遍历切片时，每次迭代都会返回两个值。 第一个值为当前元素的下标，第二个值为该下标所对应元素的一份副本。

将下标或值赋予 `_` 来忽略它


=== if 判断
if 判断
Go 的 if 语句与 for 循环类似，表达式外无需小括号 ( )，而大括号 { } 则是必须的。
此外，if 语句可以在条件表达式前执行一个简短语句，该语句声明的变量作用域仅在 if 和 else 范围之内。
```go
func pow(x, n, lim float64) float64 {
	if v := math.Pow(x, n); v < lim {
		return v
	}
	return lim
}
```

=== switch 语句
switch 语句是编写一连串 if - else 语句的简便方法。它运行第一个 case 值 值等于条件表达式的子句。

Go 的 switch 语句类似于 C、C++、Java、JavaScript 和 PHP 中的，不过 Go 只会运行选定的 case，而非之后所有的 case。 在效果上，Go 的做法相当于这些语言中为每个 case 后面自动添加了所需的 break 语句。

```go
func main() {
	switch os := runtime.GOOS; os {
	case "darwin":
		fmt.Println("OS X.")
	case "linux":
		fmt.Println("Linux.")
	}
}
```

无条件的 switch 相当于 switch true，这种形式能将一长串 if-else 写得更加清晰。
```go
func main() {
	switch os := runtime.GOOS; os {
	case "darwin":
		fmt.Println("OS X.")
	}
}
```


=== 函数
带名字的返回值
Go 函数的返回值可被命名，它们会被视作定义在函数顶部的变量。

返回值的命名应当能反应其含义，它可以作为文档使用。

没有参数的 return 语句会直接返回已命名的返回值，也就是「裸」返回值。



=== defer 推迟
defer 语句会将函数推迟到外层函数返回之后执行。

推迟调用的函数其参数会立即求值，但直到外层函数返回前该函数都不会被调用。

推迟调用的函数调用会被压入一个栈中。 当外层函数返回时，被推迟的调用会按照后进先出的顺序调用。

=== 指针
Go 拥有指针。指针保存了值的内存地址。其用法和 c 类似。但没有 c 的指针运算。
```go
func main() {
	i, j := 42, 2701

	p := &i         // 指向 i
	fmt.Println(*p) // 通过指针读取 i 的值
	*p = 21         // 通过指针设置 i 的值
	fmt.Println(i)  // 查看 i 的值

	p = &j         // 指向 j
	*p = *p / 37   // 通过指针对 j 进行除法运算
	fmt.Println(j) // 查看 j 的值
}
```
空指针：nil 指针也称为空指针。
nil 指针的值是 nil。

=== 结构体
```go
package main

import "fmt"

type Vertex struct {
	X, Y int
}

var (
	v1 = Vertex{1, 2}  // 创建一个 Vertex 类型的结构体
	v2 = Vertex{X: 1}  // Y:0 被隐式地赋予零值
	v3 = Vertex{}      // X:0 Y:0
	p  = &Vertex{1, 2} // 创建一个 *Vertex 类型的结构体（指针）
)

func main() {
	fmt.Println(v1, p, v2, v3)
}
```
如果我们有一个指向结构体的指针 p 那么可以通过 `(*p).X` 来访问其字段 X。 不过这么写太啰嗦了，所以语言也允许我们使用隐式解引用，直接写 `p.X` 就可以

=== 数组
数组的长度是其类型的一部分，因此数组不能改变长度。
```go
package main

import "fmt"

func main() {
	primes := [6]int{2, 3, 5, 7, 11, 13}

	var s []int = primes[1:4] // 半闭半开区间，包括第一个元素，但排除最后一个元素
	fmt.Println(s)
}
```
注意：切片就像数组的引用 切片并不存储任何数据，它只是描述了底层数组中的一段。
更改切片的元素会修改其底层数组中对应的元素，和它共享底层数组的切片都会观测到这些修改。
对于数组

```go
var a [10]int
```

来说，以下切片表达式和它是等价的：

```go
a[0:10]
a[:10]
a[0:]
a[:]
```
切片拥有 长度 和 容量。
切片的长度就是它所包含的元素个数。
切片的容量是从它的第一个元素开始数，到其底层数组元素末尾的个数。

切片 s 的长度和容量可通过表达式 len(s) 和 cap(s) 来获取。
切片的零值是 nil。

用 make 创建切片
```go
a := make([]int, 5)  // len(a)=5
b := make([]int, 0, 5) // len(b)=0, cap(b)=5
```

=== map 映射
map 就是字典，是go语言内置的一种数据类型，用于存储键值对。
map 的零值是 nil。
```go
type Vertex struct {
	Lat, Long float64
}

var m map[string]Vertex

func main() {
	m = make(map[string]Vertex)
	m["Bell Labs"] = Vertex{
		40.68433, -74.39967,
	}
	fmt.Println(m["Bell Labs"])
}
```
map 的键和值的类型可以是任意类型。

- 在映射 m 中插入或修改元素：
```go
m[key] = elem
```
- 获取元素：
```go
elem = m[key]
```
- 删除元素：
```go
delete(m, key)
```
- 通过双赋值检测某个键是否存在：
```go
elem, ok = m[key]
```
- 若 elem 或 ok 还未声明，你可以使用短变量声明：
```go
elem, ok := m[key]
```

=== 函数闭包
Go 函数可以是一个闭包。闭包是一个函数值，它引用了其函数体之外的变量。 该函数可以访问并赋予其引用的变量值，换句话说，该函数被“绑定”到了这些变量。

例如，函数 adder 返回一个闭包。每个闭包都被绑定在其各自的 sum 变量上。
```go
package main

import "fmt"

func adder() func(int) int {
	sum := 0
	return func(x int) int {
		sum += x
		return sum
	}
}

func main() {
	pos, neg := adder(), adder()
	for i := 0; i < 10; i++ {
		fmt.Println(pos(i), neg(-2*i))
	}
}
```


