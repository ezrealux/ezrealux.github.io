+++
date = '2026-08-01T22:17:42+08:00'
draft = false
title = 'Road to CS day8: linux7-debug (unfinished)'
tags = ["linux"]
categories = ["linux"]
+++

## 1. Process Monitoring

### 1-1. top
用 top 檢查 CPU、記憶體與 Process。畫面會持續更新
```bash
top - 18:06:26 up 6 days,  4:07,  2 users,  load average: 0.92, 0.62, 0.59
Tasks: 389 total,   1 running, 387 sleeping,   0 stopped,   1 zombie
%Cpu(s):  1.8 us,  0.4 sy,  0.0 ni, 97.6 id,  0.1 wa,  0.0 hi,  0.0 si,  0.0 st
KiB Mem:  32870888 total, 27467976 used,  5402912 free,   518808 buffers
KiB Swap: 33480700 total,    39892 used, 33440808 free. 19454152 cached Mem

  PID USER      PR  NI    VIRT    RES    SHR S  %CPU %MEM     TIME+ COMMAND
 6675 patty    20   0 1731472 520960  30876 S   8.3  1.6 160:24.79 chrome
 6926 patty    20   0  935888 163456  25576 S   4.3  0.5   5:28.13 chrome
```

### 1-2. isof & fuser
`lsof` (list open files) 展示所有開啟的檔案，與正在使用他們的 process。
也可以指定目錄或檔案：
```bash
$ lsof .
COMMAND   PID   USER   FD   TYPE DEVICE SIZE/OFF             NODE NAME
bash      303 wilson  cwd    DIR   0,83     4096 7036874420186068 .
lsof    26282 wilson  cwd    DIR   0,83     4096 7036874420186068 .
lsof    26283 wilson  cwd    DIR   0,83     4096 7036874420186068 .
```
`fuser` (file user)
```bash
$ fuser -v .
                     USER        PID ACCESS COMMAND
/mnt/c/Users/wilso:  wilson      303 ..c.. bash
```
`fuser` 也可以殺死正在使用 mount point 的 process
```bash
$ sudo fuser -k /mnt/usb
```

### 1-3. threads
`ps m`
```bash
$ ps m
    PID TTY      STAT   TIME COMMAND
    303 pts/0    -      0:00 -bash
      - -        Ss     0:00 -
    407 pts/1    -      0:00 -bash
      - -        S+     0:00 -
  26288 pts/0    -      0:00 ps m
      - -        R+     0:00 -
```
在 process 下方，PID 為 `-` 的就是隸屬 process 的 threads，這個例子可以看到 303, 407, 26288 都是 single-threaded 的 process

### 1-4. CPU, I/O, memory Monitoring
`uptime`
```bash
$ uptime
 14:11:08 up 3 days,  6:45,  1 user,  load average: 0.00, 0.00, 0.00
```

`iostat`
```bash
o$ iostat
Linux 5.15.167.4-microsoft-standard-WSL2 (LAPTOP-7TCEDO3U)      08/07/26        _x86_64_        (16 CPU)

avg-cpu:  %user   %nice %system %iowait  %steal   %idle
           0.01    0.01    0.02    0.00    0.00   99.96

Device             tps    kB_read/s    kB_wrtn/s    kB_dscd/s    kB_read    kB_wrtn    kB_dscd
sda               0.00         0.30         0.00         0.00      85173          0          0
sdb               0.00         0.01         0.00         0.00       2228          4          0
sdc               0.91         7.07        21.62       100.32    2009225    6139680   28490776
```

`vmstat`
```bash
$ vmstat
procs -----------memory---------- ---swap-- -----io---- -system-- -------cpu-------
 r  b   swpd   free   buff  cache   si   so    bi    bo   in   cs us sy id wa st gu
 1  0      0 6354204   3408 269504    0    0     7    21    8    0  0  0 100  0  0  0
```

### 1-5. Continuous Monitoring
用來收集、報告、保存資訊
`sudo sar -q` 列出自目標那天開始的資訊細節
`sudo sar -r` 列出自目標那天開始的記憶體使用資訊細節
`sudo sar -P` 列出自目標那天開始的CPU使用資訊細節

如果想看某天的資訊，去 `/var/log/sysstat/saXX` XX 代表我要看的那天。

### 1-6. cron job
`cron` daemon 可以讓我們安排在特定時間或區間自動運行任務，
---
## 2. Logging
有個核心服務叫 syslog 他負責收集資訊，並把資訊引導到 system logger。  
syslog 有幾個部件，最重要的就是 daemon syslogd (rsyslogd) ，負責在背景運行，等待事件訊息，過濾後寫到檔案內。  

### 2-1. syslog
`/var/log/syslog`

### 2-2. general logging
`/var/log/messages`

### 2-3. kernel logging
`/var/log/dmesg`
`/var/log/kern.log`

### 2-4. authentication logging
`/var/log/auth.log`

### 2-5. 管理 log files
 log rotation `logrotate`