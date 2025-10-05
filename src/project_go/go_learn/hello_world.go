package main

import (
	"fmt"
	// "math/rand"
)

func compare(a int, b int) bool {
	return a > b
}

func compare2(a, b int) bool {
	return a > b
}

func re2Int(a int) (int, int) {
	return a, a
}

func main() {
	// fmt.Println("Hello, World!")
	// fmt.Println(rand.Intn(100))
	// fmt.Println(compare(1, 2))
	// fmt.Println(compare2(1, 2))
	// fmt.Println(re2Int(1))

	// Generate a very small floating point value using bit shifting
	b := 1.0 / (1 << 34)
	// Print the value with exponential notation formatting
	fmt.Printf("Very small value: %e\n", b)
}


  