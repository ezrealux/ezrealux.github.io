+++
date = '2026-08-14T11:34:10+08:00'
draft = false
title = 'Day12 Go Grammar'
tags = ["go"]
categories = ["go"]
+++

Go 文法

### main function
    同 C
### function
```go
func swap (x, y int) (int, int) {
    fmt.Println("SWAP!")
    return y, x
}
```
### variable
```go
var c, python, java bool // 宣告
var i, j int = 1, 2 // 宣告 + 賦值
k := 3 // 宣告 + 賦值 + 自動推斷型別 (:=)
```
型別有：
- bool
- string
- int  int8  int16  int32  int64
- uint uint8 uint16 uint32 uint64 uintptr
- byte // alias for uint8
- rune // alias for int32 (represents a Unicode code point)
- float32 float64
- complex64 complex128
型別轉換同 C  

常數宣告：
```bash
const ans = 42 // 常數都是最高 precision
```
---
### for-loop
```go
for i:=rng[0]; i<rng[1]; i++ {
    sum += i
}
```
```go
count := 
for count < ans {// for-loop 可以去掉前後項 此時等於 while-loop (不寫條件就是無限迴圈)
    fmt.Printf("%v ", count)
    count++
}
```

### if-else
```go
if x < 0 {
	return sqrt(-x) + "i"
}
```
```go
if res := int(math.Sqrt(float64(x))); res > celling {
    return celling
} else if res < floor {
    return floor
} else {
    return res
}
```
### switch-case
    同 C

---
### defer
```go
func main() {
	fmt.Println("counting")

	for i := 0; i < 10; i++ {
		defer fmt.Println(i) // defer 標記的程式碼會存到 stack 內，等到目前的 function 結束後再執行
	}

	fmt.Println("done")
}
```

---
### pointer
    同 C

### struct
```go
type Vertex struct {
	X int
	Y int
}
```

### array
```go
var a [2]string
```

### slice
slice 就像 array 但它的長度是可變的  
可以使用 `var s []int` 宣告一個空的 slice  
也可以用 `s = append(s, 10)` 的方式對 slice 進行操作  

此外，對 array 或 slice 做 slicing 得到的也會是 slice
```go
a := names[0:2]
```
`len(s)` 跟 `cap(s)` 可以檢查 slice 的長度 (裡面幾個元素) 與容量 (最多幾個元素)
range: 同 C

### map
如果 slice 是用 index 找元素，那 map 就是用 key 找元素   
```go
type Vertex struct {
	Lat, Long float64
}

var m = map[string]Vertex{
	"Bell Labs": Vertex{
		40.68433, -74.39967,
	},
	"Google": Vertex{
		37.42202, -122.08408,
	},
}
```
也可以這樣使用：
```go
var m = map[string]Vertex{
	"Bell Labs": {40.68433, -74.39967},
	"Google":    {37.42202, -122.08408},
}
```
刪除某個 key-value pair 可以用 `delete(m, key)`  

如果 map 內沒有某個 key-value pair，搜尋會回傳 zero value  
而如果要檢查 map 內某個 key-value pair 是否存在，可以用 two-value assignment：
```go
elem, ok = m[key]
```
如果 key 在 m 內，ok 為 `true`，反之 ok 為 `false`
