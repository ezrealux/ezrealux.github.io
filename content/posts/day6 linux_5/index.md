+++
date = '2026-07-29T13:27:23+08:00'
draft = false
title = 'Road to CS day6: linux5-file system (unfinished)'
tags = ["linux"]
categories = ["linux"]
+++

今天來學 file system。

  1. [**linux file system**](#1-linux-file-syetem)
  2. [**partition**](#2-partition)
  3. [**mount**](#3-mount)
  4. [**控制 process**](#3-控制-process)

## 1. linux file syetem

### 1-1. file system hierarchy standard
一般 linux 裡的 file system 都遵從一個名為 **file hierarchy standard (FHS)** 的標準，這份標準確保檔案能夠依照用途存放到它們該在的地方，讓系統更加的協調。  
FHS 多半依照以下結構：

#### root
`/` 是整個 file system 的根目錄，所有的檔案與目錄都在它之下。  
然後輸入 `ls -l /` 可以看到更多重要的目錄，最核心的幾個如下：

#### 必要系統目錄
- `/bin`：裝了一些必要的 command-line programs (可執行二進位檔) 供所有 users 使用，如 ls, cp, mv。  
- `/sbin`：裝的是必要的 system binaries，這些程式通常只能由 root 來執行，主要用於系統管理。  
- `/etc`：這裡主要容納 OS 與一些安裝應用程式的 configuration，這裡不該裝任何的 executable binaries。  
- `/lib`：裝了些 `/bin` 與 `/sbin` 的程式執行時會需要依賴的必要 shared library files。  
- `/boot`：系統開機時必要的檔案, 例如 Linux kernel 跟 the boot loader files.  

#### 使用者與應用程式資訊
- `/home`：每個使用者的個人目錄都在這裡，你可以在自己的目錄存些文件、應用設定，或其他個人檔案。  
- `/root`：root 的家目錄，與 `/home` 區別開是為了當 `/home` 無法登入時也不會影響到 root。  
- `/opt`：用來安裝一些選擇性附加第三方軟體與大型應用程式的專用資料夾
- `/usr`：This directory contains user-installed software and utilities. Despite its name, it generally does not hold individual user's home files. It has its own - - - - `/sub`：-directory structure, such as /usr/bin for non-essential user binaries and /usr/local for software compiled from source.

#### 動態或暫時性的資料
- `/var`：存放會隨時間改變大小和內容的資料
- `/tmp`：供所有使用者與程式建立短期暫存檔案，通常重開後這些檔案就會消失。
- `/run`：存放電腦程式執行時需要的資料，例如行程識別碼（PID 檔）。

#### 裝置或 Mount Points
- `/dev`: 用來存放硬體與虛擬設備檔案的特殊目錄，讓系統和使用者可以透過這些檔案直接讀寫硬體。  
- `/media`: 用來自動或手動掛載（Mount）外接裝置（ex: USB 隨身碟、外接硬碟、光碟等）的標準目錄。  
- `/mnt`: 專門用來暫時掛載（Mount）檔案系統的資料夾。  

#### 系統資訊
- `/proc`: 存放目前即時的 running processes and kernel parameters 資料。   
- `/srv`: 用來存放**伺服器對外提供服務的資料**。  

### 1-2. file system type
linux 可以實作不同的 file system 以應對不同的用途，但表層的應用程式並不需要了解每個底層的 file system，因為 linux 會透過一個 virtual file system (VHS) 的機制去讀取 file system。  
VHS 是一個位在應用程式與 file system 之間的抽象層，它提供了一個統一的介面，讓應用程式可以在運作時無需顧慮 file system 的類型。  
現代的 file system 大多都會用 journaling，當你對 file system 內的檔案做出動作，它會記錄那些動作。這樣當一系列的動作因意外中斷，就不用全部重做，從未完成處重新開始就好。  
有幾種常見的 file system：
- ext4：用於 linux，是多數發行版的預設 file system，與過去版本 (ext2/ext3) 相容，支援很大的硬碟空間 (至多 1 exabyte) 與檔案大小 (至多 16TB)。  
- Btrfs：用於 linux，另稱 "B-tree FS,"，使用 (CoW)，支援即時快照、資料總和檢查 (自我修復) 與多裝置 RAID 管理，適用需要求穩的環境。  
- XFS：用於 linux，一個專精處理大檔案以及平行 IO 動作的 journaling filesystem，適用於要處理大量資料的系統，如 media servers。  
- NTFS & FAT：用於 Windows filesystem，Linux 支援對他們做讀和寫。  
- HFS+： 用於 macOS，Linux 預設只支援讀，要寫需另載額外的工具。  

---
## 2. partition

### 2-1.
linux 上的硬碟可以拆分成多個 partition，這樣就可以在不同的 portion 上套用不同的 file system。  
而管理這些 partition 用的是 partition table。partition table 儲存了每個 partition 從哪裡開始、到哪裡結束、是否為 bootable (存放了可以讓系統開機的程式)、使用了硬碟的哪些 sector 等等。partition table 一般有兩種格式：
- MBR (Master Boot Record)：是傳統標準，最多支援 2TB 的硬碟，最多只能有 4 個主要分割區，沒有備份機制。  
- GPT (GUID Partition Table)：是現代新標準，支援大於 2TB 的超大硬碟，支援大於 2TB 的超大硬碟，在硬碟前後都有備份 partition。  

file system 會有幾個資料庫，以用來管理檔案：
- Boot block: 位在 filesystem 最前幾個 sector，不是給 filesystem 自己用的，而是用來啟動 OS。一個 OS 有一個 boot block 就夠了，如果其他 partition 也有則不會用到。  
- Superblock: 一個用來記錄整個檔案系統的整體資訊的 block，如：inode table 大小、logical blocks 大小, 整個 filesystem 的大小等等。  
- Inode table: 用來管理檔案與目錄的資料庫，每筆檔案或目錄在裡面都會有筆記錄，記錄他們的幾個屬性。  
- Data blocks: 實際存資料的地方。  

### 2-2. disk partitioning
Disk Partitioning有很多工具：
- `fdisk`：A basic command-line partitioning tool; 但不支援 GPT。  
- `gdisk`：類似 fdisk，但只支援 GPT.  
- `parted`：支援 MBR 與 GPT。  
- `gparted`：提供 gui 的 parted
這裡以 parted 為例
```bash
$ sudo parted -l
```
可以列出所有裝置 partition table。  

首先：
```bash
sudo parted
```
開啟互動模式，會進到 parted 的 shell，然後
```bash
$ select /dev/sdb
```
選擇想要修改的硬碟，輸入 `print` 可以看該硬碟的 partition table
```bash
(parted) mkpart primary ext4 1MB 5000MB
```
`mkpart` 建立新 partition，然後指定 partition type, file system type, 開始與結束點。
```bash
(parted) resizepart 1 8000MB
```
也可以用 `resizepart` 修改 partition 的大小，同樣指定開始與結束點。

### 2-3. creating file system
然後要在 partition 內，用 `mkfs` 這個工具建立 file system：
```bash
$ sudo mkfs -t ext4 /dev/sdb2
```
- `-t ext4`：用 `-t` 參數指定 file system。  
- `/dev/sdb2`：目標 partition  

---
## 3. mount

### 3-1. mount
要存取儲存裝置時，你需要先把它的 file system，掛載到我們自己系統的目錄底下。  
注意：
- 單一檔案系統不應該被重複掛載在不同的掛載點(目錄)中；  
- 單一目錄不應該重複掛載多個檔案系統；  
- 要作為掛載點的目錄，理論上應該都是空目錄才是。  

```bash
sudo mount -t ext4 /dev/sdb2 /mydrive
```
使用 `mount` 指令，就能把目標儲存裝置內的 file system 掛載到我們準備好的目錄裡了，以後想存取這個 file system 的檔案，就從這個目錄開始。
要取消的話用 `sudo umount /mydrive` 或 `sudo umount /dev/sdb2` 就好。  

但是像 `/dev/sdb2` 這樣的裝置名稱，可能會隨著重開等等而被改掉，這時可以使用裝置的 universally unique ID (UUID)，它是不變的。  
用 `blkid` 可以查看 UUID：
```bash
$ sudo blkid
/dev/sda1: UUID="130b882f-7d79-436d-a096-1e594c92bb76" TYPE="ext4"
/dev/sda5: UUID="22c3d34b-467e-467c-b44d-f03803c2c526" TYPE="swap"
/dev/sda6: UUID="78d203a0-7c18-49bd-9e07-54f44cdb5726" TYPE="xfs"
```
我們可以用 UUID 來掛載：
```bash
sudo mount UUID=130b882f-7d79-436d-a096-1e594c92bb76 /mydrive
```

### 3-2. /etc/fstab
但是掛載狀態是存在記憶體裡的，每次關機就會消失，為了避免手動 mount 的繁瑣，我們可以透過編輯 `/etc/fstab`，讓系統每次開機就掛載好。
注意：
- 根目錄 / 是必須掛載的﹐而且一定要先於其它 mount point 被掛載進來。  
- 其它 mount point 必須為已建立的目錄﹐可任意指定﹐但一定要遵守必須的系統目錄架構原則 (FHS)  
- 所有 mount point 在同一時間之內﹐只能掛載一次。  
- 所有 partition 在同一時間之內﹐只能掛載一次。  
- 如若進行卸載﹐您必須先將工作目錄移到 mount point(及其子目錄) 之外。  
```bash
$ cat /etc/fstab
UUID=130b882f-7d79-436d-a096-1e594c92bb76 /               ext4    relatime,errors=remount-ro 0       1
UUID=78d203a0-7c18-49bd-9e07-54f44cdb5726 /home           xfs     relatime        0       2
UUID=22c3d34b-467e-467c-b44d-f03803c2c526 none            swap    sw              0       0
```
`/etc/fstab` 有以下欄位：
- 裝置的 UUID  
- Mount Point：device 的 file system 被掛載到的目錄 (e.g., / or /home)  
- Filesystem Type  
- Options：控制'如何'掛載 file system，包含 defaults, relatime 與 errors=remount-ro 等等。  
- Dump：是否使用 dump 備份工具來備份該 file syetem。  
    - 0=不備份  
    - 1=每天備份。  
  目前大部分系統已改用 rsync、tar 或其他現代備份工具，因此通常填 0。  
- Pass: 開機時，系統是否要執行 fsck（File System Check）來檢查與修復磁碟錯誤。  
    - 0=不檢查。適用網路磁碟 (NFS/SMB)、虛擬檔案系統 (proc/sys) 或不重要的 partition  
    - 1=最先檢查。這專屬於根目錄 (/)，確保核心系統最先被修復。  
    - 2=後續檢查。適用於其他所有本地實體磁碟分割區 (如 /home, /data) 。系統會等根目錄檢查完後，再依序或同時檢查這些分割區。

---
## 4. 各式功能

### 4-1. swap
可以把 partition 作為 swap space。  
開：`swapon /dev/sdb2`，關：`swapoff /dev/sdb2`，也可以在 `/etc/fstab` 裡指定 filesystem type 為 `sw`  

### 4-2. 修復 file system
`sudo fsck /dev/sda`

### 4-3. inode
inode 的內容在記錄檔案的屬性，以及該檔案實際資料是放置在哪幾號 block 內，以及一些屬性，例如：
- 檔案類型 (e.g., 檔案、目錄, character device)
- Owner
- Group
- 存取權限
- Timestamps: mtime (最後修改), ctime (最後屬性修改), atime (最後存取)
- hard links 的數目
- 檔案大小
- 分配了幾個 block 給這個檔案
- 指向 data blocks 的 pointers (most important!)

建立 filesystem 時就會分配空間給 inodes，分配多少會看空間多大與其他因素，用完 inodes 就不能再建立新檔案了。
`df -i` 可以檢察系統還剩多少 inodes。

`ls -li` 可以檢查檔案的 inode 編號，第一欄就是：
```bash
$ ls -li
140 drwxr-xr-x 2 pete pete 6 Jan 20 20:13 Desktop
141 drwxr-xr-x 2 pete pete 6 Jan 20 20:01 Documents
```
`stat` 可以看更細節的內容：
```bash
pete@icebox:~$ stat ~/Desktop/
  File: ‘/home/pete/Desktop/’
  Size: 6               Blocks: 0          IO Block: 4096   directory
Device: 806h/2054d      Inode: 140         Links: 2
Access: (0755/drwxr-xr-x)  Uid: ( 1000/   pete)   Gid: ( 1000/   pete)
Access: 2016-01-20 20:13:50.647435982 -0800
Modify: 2016-01-20 20:13:06.191675843 -0800
Change: 2016-01-20 20:13:06.191675843 -0800
 Birth: -
```

### 4-4. symlinks & hardlinks
```bash
pete@icebox:~/Desktop$ echo 'myfile' > myfile
pete@icebox:~/Desktop$ echo 'myfile2' > myfile2
pete@icebox:~/Desktop$ echo 'myfile3' > myfile3
```

symlink：
```bash
pete@icebox:~/Desktop$ ln -s myfile myfilelink
pete@icebox:~/Desktop$ ls -li
total 12
  151 -rw-rw-r-- 1 pete pete 7 Jan 21 21:36 myfile
93401 -rw-rw-r-- 1 pete pete 8 Jan 21 21:36 myfile2
93402 -rw-rw-r-- 1 pete pete 8 Jan 21 21:36 myfile3
93403 lrwxrwxrwx 1 pete pete 6 Jan 21 21:39 myfilelink -> myfile
```
兩個 link 使用不同 inode

hardlink：
```bash
pete@icebox:~/Desktop$ ln myfile2 myhardlink
pete@icebox:~/Desktop$ ls -li
total 16
  151 -rw-rw-r-- 1 pete pete 7 Jan 21 21:36 myfile
93401 -rw-rw-r-- 2 pete pete 8 Jan 21 21:36 myfile2
93402 -rw-rw-r-- 1 pete pete 8 Jan 21 21:36 myfile3
93403 lrwxrwxrwx 1 pete pete 6 Jan 21 21:39 myfilelink -> myfile
93401 -rw-rw-r-- 2 pete pete 8 Jan 21 21:36 myhardlink
```
兩個 link 使用相同 inode

Hard Link  
- 想讓同一份資料有多個檔名。  
- 即使原始檔名被刪除，資料仍可存取。  
- 適合同一個檔案系統內使用。  

Symbolic Link  
- 建立捷徑。  
- 可跨不同檔案系統。  
- 可連結目錄。  
- 常見於 /bin、/lib、/usr/bin 等系統路徑。  