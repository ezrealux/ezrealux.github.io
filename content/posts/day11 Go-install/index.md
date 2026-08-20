+++
date = '2026-08-12T20:43:51+08:00'
draft = false
title = 'Day11 Go Install'
tags = ["go"]
categories = ["go"]
+++

在 wsl 上安裝 go
go: language
gvm: 用來管理 go 的版本

## 1. 安裝 gvm
下載 gvm: 
```bash
$ bash < <(curl -s -S -L https://raw.githubusercontent.com/moovweb/gvm/master/binscripts/gvm-installer)
```
安裝 gvm:
```bash
$ source ~/.gvm/scripts/gvm
```
記得安裝 `bison` `gcc` `make` `binutils` `git` `curl`
安裝完後檢查：
```bash
$ gvm version
```

---
## 2. 安裝 go
安裝 go：
```bash
$ gvm listall
```
可以在這裡查看 go 所有版本，然後安裝：
```bash
$ gvm install go1.26.5
```
```bash
$ gvm install go1.26.5 -B
```
然後 use
```bash
$ gvm use go1.26.5 --default
```
使用完後檢查：
```bash
$ go version
```

每次打開 shell 都自動設置，在 `.bashrc` 中寫下：
```shell
[[ -s "$HOME/.gvm/scripts/gvm" ]] && source "$HOME/.gvm/scripts/gvm"
```
---
## 3. 編寫 & 執行 go 程式碼
一個 Go 專案通常有自己的資料夾，首先：
```bash
$ mkdir ~/hello-go
cd ~/hello-go
```
接著輸入：
```bash
$ go mod init hello-go
```
以宣告「它是一個」go 專案
- go.mod → 專案/module 的設定與依賴
- go.sum → 依賴套件的版本校驗資訊
- XXX.go → 你的程式碼
這邊在 `main.go` 裡寫入範例程式碼：
```go
package main

import "fmt"

func main() {
    fmt.Println("Hello, Go!")
}
```
fmt (format) 是 Go 裡非常常用的一個標準函式庫（standard library）。
只要執行 `go run main.go` 或 `go run .` 就可以看到結果了，`go run main.go` 與 `go run .` 的差別在於，`go run main.go` 是執行 `main.go` 這個程式，而 `go run .` 則是執行 `/hello-go` 整個 package。

執行：
```bash
$ go build .
```
會編譯出一份二進位可執行檔 (在這裡是 `hello-go`)
而輸入 `./hello-go` 就能執行編譯好的可執行檔