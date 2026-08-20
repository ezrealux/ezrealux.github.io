+++
date = '2026-08-15T02:01:41+08:00'
draft = false
title = 'Day13 Go OOP'
tags = ["go"]
categories = ["go"]
+++

## 1. method
go 沒有像 C 裡面的 class，取而代之的是 struct method，method 就是**綁定在某個 type 上的 function**，先指定一個 type struct。
```go
type Vertex struct {
	X, Y float64
}
```
此時一般的 function 是這樣：
```go
func Abs(v Vertex) float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}
```
而 method 則是這樣：
```go
func (v Vertex) Abs() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}
```
在前面多一個指定 type 的步驟，稱為 **receiver**，使我們可以用這樣的方式去呼叫他：
```go
func main() {
	v := Vertex{3, 4}
	fmt.Println(v.Abs())
}
```
也可以指定 receiver 在 pointer 上，效果與 C 中的類似：
```go
func (v *Vertex) Scale(f float64) {
	v.X = v.X * f
	v.Y = v.Y * f
}
```
使用 method 的話，無論傳入 value 還是 pointer 都可，反之則否。
```go
var v Vertex
v.Scale(5)  // OK
p := &v
p.Scale(10) // OK
```

---
## 2. interface
interface 是 go 用來實現 OOP polymorphism (多型) 的方式。  
多型簡單來說，就是「同一個動作，因物件不同而產生不同結果」

C++ 使用的是 virtual function + inheritance：
```c++
class Animal {
public:
    virtual void speak() {
        cout << "Animal speaks" << endl;
    }

    virtual ~Animal() = default;
};

class Dog : public Animal {
public:
    void speak() override {
        cout << "Woof!" << endl;
    }
};

class Cat : public Animal {
public:
    void speak() override {
        cout << "Meow!" << endl;
    }
};

int main() {
    Animal* a1 = new Dog();
    Animal* a2 = new Cat();

    a1->speak();  // Woof!
    a2->speak();  // Meow!

    delete a1;
    delete a2;
}
```

而 go 主要用的是 interface + implicit implementation
```go
package main

import "fmt"

type Animal interface {
	Speak()
}

type Dog struct{}

func (Dog) Speak() {
	fmt.Println("Woof!")
}

type Cat struct{}

func (Cat) Speak() {
	fmt.Println("Meow!")
}

func main() {
	var animals []Animal

	animals = append(animals, Dog{})
	animals = append(animals, Cat{})

	for _, animal := range animals {
		animal.Speak()
	}
}
```
interface 不在乎你是什麼 type，只在乎你有沒有他要的 method。

此外 interface value 實際上是一個 (value, type) tuple。

其實也可以宣告 empty interface，此時這個 interface 可以接收任何 type：
```go
func main() {
	var i interface{}
	describe(i)

	i = 42
	describe(i)

	i = "hello"
	describe(i)
}

func describe(i interface{}) {
	fmt.Printf("(%v, %T)\n", i, i)
}
```