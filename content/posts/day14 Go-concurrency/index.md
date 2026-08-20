+++
date = '2026-08-18T14:52:57+08:00'
draft = false
title = 'Day14 Go Concurrency'
tags = ["go"]
categories = ["go"]
+++

## 1. go routine
```go
func say(s string) {
	for i := 0; i < 5; i++ {
		time.Sleep(100 * time.Millisecond)
		fmt.Println(s)
	}
}

func main() {
	go say("world")
	say("hello")
}
```
會把 `go say("world")` 交給 go runtime 處理，然後繼續往下執行。

---
## 2. channel
`channel` 主要是用來跟 go routine 之間互相溝通的：
```go
func sum(s []int, c chan int) {
	sum := 0
	for _, v := range s {
		sum += v
	}
	c <- sum // send sum to c
}

func main() {
	s := []int{7, 2, 8, -9, 4, 0}

	c := make(chan int) // 建立一個 channel (chan)
	go sum(s[:len(s)/2], c) // 在建立 go routine 時也把 channel 傳入
	go sum(s[len(s)/2:], c)
	x, y := <-c, <-c // receive from c

	fmt.Println(x, y, x+y)
}
```
`channel` 一般是 unbuffered，意思是當 sender 送出訊息，而 receiver 沒來接收，sender 會持續等待；反之 receiver 先來的話，也會不斷等待，直到有 sender 來送訊息。
不過若是指定容量，`channel` 也可以作為 buffer
```go
func main() {
	ch := make(chan int, 2)
	ch <- 1
	ch <- 2
	fmt.Println(<-ch)
	fmt.Println(<-ch)
}
```

---
## 3. select
`select` 可以讓 go routine 等待特定的 operation，用法類似 switch-case：
```go
func fibonacci(c, quit chan int) {
	x, y := 0, 1
	for { // 函式假如沒從 quit 收到訊號就會無限 loop
		select {
		case c <- x: // 把 x 放入 c，等待有人來接收
			x, y = y, x+y
		case <-quit:
			fmt.Println("quit")
			return
		}
	}
}

func main() {
    // 建立兩個 channel c 和 quit
	c := make(chan int)
	quit := make(chan int)
    // 建立一個 go routine，從 c 收十次資料之後，把 0 傳入 quit
	go func() {
		for i := 0; i < 10; i++ {
			fmt.Println(<-c) // 從 c 接收資料並印出
		}
		quit <- 0
	}()
	fibonacci(c, quit)
}
```
`select` 也可以設置 default，當沒有可以進入的 case 時，就進入 default，主要用於「我不想等待，現在不能做就立刻做別的事情。」
```go
for {
    select {
    case <-tick:
        fmt.Printf("[%6s] tick.\n", elapsed())
    case <-boom:
        fmt.Printf("[%6s] BOOM!\n", elapsed())
        return
    default:
        fmt.Printf("[%6s]     .\n", elapsed())
        time.Sleep(50 * time.Millisecond)
    }
}
```

## 番外：go routine 與 thread 管理
一般學習 process/thread 時會學到，當 process/thread 呼叫 wait()，等待其他人傳來 signal() 後，會進入waiting() queue，然後讓自己變成 blocked 狀態。
```
Process A
├── Thread 1 ── wait(S) ──→ Blocked
├── Thread 2 ──→ Ready / Running
└── Thread 3 ──→ Ready
```
而 go routine 是採用 **M 個 goroutine → N 個 OS threads**
```
Goroutine 1 ─┐
Goroutine 2 ─┤
Goroutine 3 ─┼──→ Go Scheduler ──→ OS Threads
Goroutine 4 ─┤
Goroutine 5 ─┘
```
當 go routine 因為 select 之類的因素進入 waiting 狀態，他所屬的 thread 不會也因此 blocked，go runtime scheduler 會找出其他 runnable 的 go routine，讓這個 thread 去執行。  
而等到等待中的 go routine 等到 channel 信號，他就會變回 runnable go routine，再等待 scheduler 分配 thread 給他。  

而前述的程式碼：
```go
for {
    select {
    case <-tick:
        fmt.Printf("[%6s] tick.\n", elapsed())
    case <-boom:
        fmt.Printf("[%6s] BOOM!\n", elapsed())
        return
    default:
        fmt.Printf("[%6s]     .\n", elapsed())
        time.Sleep(50 * time.Millisecond)
    }
}
```
在 default 使用 time.Sleep() 的原因，是為了在沒信號時印點東西，但又不希望程式變成 busy loop，把 CPU 燒滿。

go routine 相比 thread 的差別在於：
1. go routine 不需要由 OS 管理
2. go routine 的 stack 較 thread 小

所以相比 thread 只能到數千個，go routine 可以建立非常大量。