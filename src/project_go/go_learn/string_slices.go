package main

import (
	"fmt"
	"strings"
)

func main() {
	// 创建一个井字棋（经典游戏）
	// board := [][]string{
	// 	[]string{"_", "_", "_"},
	// 	[]string{"_", "_", "_"},
	// 	[]string{"_", "_", "_"},
	// }

	// // 两个玩家轮流打上 X 和 O
	// board[0][0] = "X"
	// board[2][2] = "O"
	// board[1][2] = "X"
	// board[1][0] = "O"
	// board[0][2] = "X"

	// for i := 0; i < len(board); i++ {
	// 	fmt.Printf("%s\n", strings.Join(board[i], " "))
	// }

	test_string := "  foo bar  baz   "
	new_string := strings.Fields(test_string)
	for _, v := range new_string {
		fmt.Println(v)
	}
	fmt.Printf("Fields are: %q", new_string)

}
