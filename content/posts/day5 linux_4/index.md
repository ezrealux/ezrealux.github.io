+++
date = '2026-07-28T14:38:27+08:00'
draft = false
title = 'Road to CS day5: linux4-process (unfinished)'
tags = ["linux"]
categories = ["linux"]
+++

今天來學 process。  

我們的電腦裡存著各式各樣的程式，這些程式叫做 **program**，program 本身只是一團不會動的靜態代碼。而如果要執行的話，則需要先把 program 加載到 memory 內，而此時它在 memory 內，成為了一個正在執行的程式，就稱為 **process**。  

  1. [**1. 檢查 process**](#1-檢查-process)
  2. [**2. process 從建立到終結)**](#2-process-從建立到終結)
  3. [**3. 控制 process**](#3-控制-process)

---
## 1. 檢查 process

此刻我們的電腦中，就運行著各式各樣的 process，每個 process 使用 process ID (PID) 辨別彼此的身分，電腦中的 proess 可以使用 `ps` 指令檢查：
```bash
$ ps
    PID TTY          TIME CMD
    305 pts/0    00:00:00 bash
    623 pts/0    00:00:00 ps
```
可以看到幾個欄位如下：
- `PID`  
- `TTY`：也就是這個行程是從哪個終端 (terminal) 啟動的，具體細節可以看[**TTY**](#主題1-tty)主題  
- `TIME`：這個行程從啟動到現在，總共使用了多少 CPU 時間。  
- `CMD`：啟動這個行程所使用的命令。  

第一行，`CMD` 是 `bash`，`TTY` 是 `pts/0` 代表我們目前的終端機，`TIME` 是 `00:00:00`，因為它幾乎都在等我們輸入指令，實際上在 CPU 裡執行的時間沒多少。  
第二行，`CMD` 是 `ps`，因為我們輸入了 `ps` 指令後，`bash` 會建立一個新的 process 去執行 `ps`，所以 `ps` 會查到自己的 process，`TTY` 是 `pts/0` 同樣來自我們目前的終端機，`TIME` 是 `00:00:00`，因為它一瞬間就執行完成了。  

但是 `ps` 只會顯示目前終端機的行程，如果要看到更完整的行程資訊，可以用 `ps aux`。
- `a`：也展示其他使用者建立的 process
- `u`：展示出 process 的更多細節
- `x`：就算是不由終端啟動的 process，也同樣全展示出來 (沒有終端的 process 在 `TTY` 的欄位會顯示 `?`)
```bash
$ ps aux
USER         PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root           1  0.0  0.1  21744 12760 ?        Ss   14:34   0:01 /sbin/init
root           2  0.0  0.0   2776  1924 ?        Sl   14:34   0:00 /init

...

root         304  0.0  0.0   2776   208 ?        S    14:35   0:00 /init
wilson       305  0.0  0.0   6204  5380 pts/0    Ss   14:35   0:00 -bash
root         306  0.0  0.0   6824  4628 pts/1    Ss   14:35   0:00 /bin/login -f
wilson       392  0.0  0.1  20260 11468 ?        Ss   14:35   0:00 /usr/lib/systemd/systemd --user
wilson       399  0.0  0.0  21148  1728 ?        S    14:35   0:00 (sd-pam)
wilson       412  0.0  0.0   6072  5048 pts/1    S+   14:35   0:00 -bash
wilson       733  0.0  0.0   8336  4296 pts/0    R+   15:30   0:00 ps aux
```
可以看到幾個欄位如下：
- `USER`：執行此 prcoess的使用者。
- `%CPU`：process 在單位時間內佔用了多少 CPU 的時間  
- `%MEM`：process 佔用了多少實體記憶體（RAM）的空間  
- `VSZ`：Virtual Memory Size，虛擬記憶體大小（KB）
- `RSS`：Resident Set Size，實際占用的實體記憶體大小（KB）
- `STAT`：process 狀態，具體可以看[**後續**](#3-控制-process)主題
- `START`：行程開始時間
關於 `STAT` 顯示的 process 狀態碼後續會講。
---
## 2. process 從建立到終結

### 2-1. process creation
一般 process 的建立，是由一個 parent process 呼叫 `fork` system call，它會分身出一個與 parent process 一模一樣的 child process，之後 child process 就可繼續執行與 parent process 一樣的內容，或導入新的程式碼。  
使用 `ps l` 可以看到 process 細節，包括 parent process ID (PPID)

### 2-2. process termination
process 若要結束，需要 parent 與 child process 兩方的動作。  
child process 需要呼叫 `__exit` system call，把它占用的記憶體空間等等資源，同時向 kernel 傳達自己結束的狀態 (通常 `0` 代表程式執行順利完成)
而 parent process 則要負責呼叫 `wait` system call，來檢查 child 的結束狀態。  
但是有時會發生一些異常情況，分別是 orphan process 與 zombie process

- **orphan process**: orphan process 發生在 parent process 比 child process 更早結束的情況。此時 child process 已經沒有人在 wait 它了，於是 kernel 便會標記它為 'orphan'，並將它置於 **init** (所有 process 的共同祖先) 的照顧之下，init 會呼叫 `wait` 讓這些 orphan 可以死去。
- **zombie process**: zombie process 發生在 child process 已經結束，但 parent process 還沒呼叫 wait 的情況。這時 kernel 便會判定他是 zombie process，zombie process 仍然會釋放它占用的資源，但依然在 process table 上留下一筆紀錄，等待 parent process 未來呼叫 `wait` 來收屍。而假設 parent process 直到結束都沒有來，zombie 就會同樣成為 orphan，同樣交由 **init** 來收屍 (留太多 zombie 給 init 不是好事)。

### 2-3. process signal
process signal 是用來通知 process 有事發生用的。process 在應對不同 signal 會有不同反應，也可以設定這些行為。常見的 signal 有：
- SIGHUP or HUP or 1: Hangup
- SIGINT or INT or 2: Interrupt
- SIGKILL or KILL or 9: Kill
- SIGSEGV or SEGV or 11: Segmentation fault
- SIGTERM or TERM or 15: Software termination
- SIGSTOP or STOP: Stop

SIGHUP, SIGINT, SIGTERM, SIGKILL, SIGSTOP 都是用來結束一個 process 的 signal，但略有不同：
- SIGHUP: 當 terminal 關掉時會送出，ex: 當你還在執行一個程式時，就關掉整個 terminal 視窗
- SIGINT: 當使用者中斷 process (按 Ctrl-C) 時送出
- SIGTERM: 請求依照正常程序結束 process (會先做一些 cleanup)
- SIGKILL: 強制結束 process  
- SIGSTOP: 強制暫停process

---
## 3. 控制 process

### 3-1. nice
time-sharing sysyem  
`top` 可以看 process 資訊, `NI` 是 process 的 niceness，數字愈大代表 process 優先級愈低  

使用 `nice` 跟 `renice` 可以設定 process 的 NI 值：
- `nice`是用來**新啟動**一個 process，並且設定 NI 值
  具體用法為`$ nice -n [NI值] [指令]`，例如：
  ```bash
  $ nice -n 5 apt upgrade
  ```
  代表執行一個叫 `apt upgrade` 的指令，並且把它的 NI 值設為5  

- `renice` 則是用來修改一個已存在 process 的 NI 值
  具體用法為`renice [NI值] -p [PID]`，例如：
  ```bash
  $ renice 5 -p 2350
  ```
  代表將 PID 為 2350 的 process 的 NI 值設定為 5  
  此外也可以同時修改多個 process，只要像這樣即可：
  ```bash
  $ renice 10 -p 1001 1002 1003
  ```
### 3-2. state
前面說 `ps aux` 可以檢查 process 的 STAT，狀態碼各自代表不同意思：
- R (running or runnable)：在等待 CPU 處理它
- S (Interruptible sleep)：在等待一些活動完成，例如 terminal 的 IO 之類的
- D (Uninterruptible sleep)：processes that cannot be killed or interrupted with a signal, usually to make them go away you have to reboot or fix the issue
- Z (Zombie)：正如前述
- T (Stopped)：被暫停了

### 3-3. /proc
先前提過，在 linux 內萬無皆可為檔案，process 也不例外，process 的資訊存在一個名為 `/proc` 的特殊資料夾：
```bash
$ ls /proc
1    176   305  916        consoles     filesystems  key-users    mdstat        partitions  thread-self
100  1777  306  921        cpuinfo      fs           keys         meminfo       schedstat   timer_list
140  194   392  acpi       crypto       interrupts   kmsg         misc          self        tty
143  195   399  buddyinfo  devices      iomem        kpagecgroup  modules       softirqs    uptime
153  2     412  bus        diskstats    ioports      kpagecount   mounts        stat        version
154  205   58   cgroups    dma          irq          kpageflags   mtrr          swaps       vmallocinfo
167  303   7    cmdline    driver       kallsyms     loadavg      net           sys         vmstat
170  304   915  config.gz  execdomains  kcore        locks        pagetypeinfo  sysvipc     zoneinfo
```
在這裡就可以看到許多以 PID 命名的目錄，用一些例如 `$ cat /proc/921/status` 的方法翻找，可以找到比 `ps` 顯示更詳盡的資訊

### 3-4. job control
可以送程式進入 slepping 狀態：
```bash
$ sleep 1000 &
```
`&` 讓 process 在背景工作，把 shell 交還給使用者

`jobs`：檢查背景 process
`fg`：從背景移回前台
`kill`：殺死背景 process