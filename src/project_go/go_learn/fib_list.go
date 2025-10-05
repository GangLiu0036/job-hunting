package main

import "fmt"

// fibonacci 返回一个闭包函数，每次调用返回下一个斐波那契数
func fibonacci() func() int {
    a, b := 0, 1  // 使用两个变量保存状态
    return func() int {
        ret := a
        a, b = b, a+b  // 更新状态到下一个数
        return ret
    }
}

func main() {
    f := fibonacci()
    for i := 0; i < 10; i++ {
        fmt.Println(f())  // 输出：0, 1, 1, 2, 3, 5, 8, 13, 21, 34
    }

	fmt.Println((1+2)/3)
}