package main

import "fmt"


type Itf interface {
	Print()
	Returncharacteristics()
}

type man struct {
	name string
	characteristics string
}

type maoba struct{
	name string
	characteristics string
}

func (m man) Print() {
	fmt.Println(m.name)
}

func (m man) Returncharacteristics() {
	fmt.Println(m.characteristics)
}

func (ma maoba) Print() {
	fmt.Println(ma.name)
}

func (ma maoba) Returncharacteristics() {
	fmt.Println(ma.characteristics)
}



func main() {
	fmt.Println("start test!")

	var itf Itf

	itf = man{name: "man", characteristics: "manba out"}
	itf.Print()
	itf.Returncharacteristics()


	itf = maoba{name: "dog", characteristics: "woof woof!"}
	itf.Print()
	itf.Returncharacteristics()

}