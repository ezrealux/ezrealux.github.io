+++
date = '2026-07-19T19:58:47+08:00'
draft = false
title = 'Road to CS day3: linux advanced - user and permission(1/1) (unfinished)'
tags = ["linux"]
categories = ["linux"]
+++

  1. [**使用者與權限**](#1-使用者與權限)
  2. [**使用者管理檔案**](#2-使用者管理檔案)
  3. [**權限設定**](#3-權限設定)

  ## 1. 使用者與權限。

  一台裝置的作業系統內可以有多個「使用者」，使用 user ID (UID) 區分，每個使用者有自己的家目錄，當使用者要創建獨屬自己的檔案時，通常會置於 `/home/username` 之下，雖說細節會隨不同的發行版而有所不同，但基本大同小異。  
  區分使用者是為了管理「權限」，若我們不希望自己的檔案被其他人閱讀、修改或執行，便可以修改權限擋住他人。

  此外還有一個概念稱為「群組」，檔案除了有所屬使用者外，還可以有所屬的群組，這主要是為了團隊協作。透過設定檔案在群組內的權限，我們可以允許檔案被一些特定人訪問，而將其他人排除在外。

  依照這個邏輯，一個檔案的權限設定分為 'owner'、'group' 和 'other' 三類，如我們今天查看 `/etc/shadow` 的權限設定：
  ```bash
  $ ls -la /etc/shadow
  -rw-r----- 1 root shadow 802 Mar 22  2025 /etc/shadow
  ```
  可以看到 'user' 的權限為 `rw-`，意指這個檔案的擁有者可以讀、寫，但不能執行這份檔案；'group' 裡的成員可以讀、但不能寫、不能執行，'other'、也就是其他人則讀寫執行都不能。  
  這時要是我們執行：
  ```bash
  $ cat /etc/shadow
  cat: /etc/shadow: Permission denied
  ```
  會發現被拒絕存取了，因為我們不是該檔案的擁有者，也不在檔案的所屬群組裡。  
  而其實這個檔案的所有者叫做 'root'，root 是系統的最高管理員，擁有對所有檔案的完整存取權限，有很多重要的系統檔案基於安全考量，只有 root 才能存取，這樣區分是為了安全性的考量，不能讓外人隨意接觸這些檔案。  

  而我們有些方法可以暫時取得 root 的身分，`sudo` 和 `su`。  
  `sudo` 作為前綴，接在平常指令的前面，讓我們在單獨執行這個指令期間，取得 root 的權限：
  ```bash
  $ sudo cat /etc/passwd
  [sudo] password for wilson:
  (內容下略)
  ```
  而 `su` 可以讓我們直接切換為 `root` 本人：
  ```bash
  $ su
  Password:
  root@LAPTOP-7TCEDO3U:#
  ```
  此時我們輸入任何指令，都不會受到權限的限制：
  ```bash
  root@LAPTOP-7TCEDO3U:/mnt/d/Desk/Project/NYCU_CS_0/road_to_CS# cat /etc/passwd
  (內容下略)
  ```

  ## 2. 使用者管理檔案

  有關使用者管理，有三個重要的檔案：  
  2-1. [**/etc/passwd**](#2-1-etcpasswd)  
  2-2. [**/etc/shadow**](#2-2-etcshadow)  
  2-3. [**/etc/group**](#2-3-etcgroup)  

  ### 2-1. /etc/passwd
  `/etc/passwd` 儲存的是所有使用者的帳號資訊，具體案例如下：
  ```bash
  $ sudo cat /etc/passwd
  root:x:0:0:root:/root:/bin/bash
  ```
  這行顯現了 root 使用者的資訊，每一欄的資訊都用 ':' 隔開，各自資訊如下：
  1. **Username**: 這個使用者叫 root
  2. **Password**: 在這裡看不到完整的密碼，因為密碼的實際內容存放在 `/etc/shadow` 裡面，而你在這能看到不同的符號，各自代表著不同的意思：  
    - 'x': 代表密碼已經被移到`/etc/shadow` 裡儲存  
    - '*': 代表帳號被鎖定、禁用，或不允許透過密碼登入 (ex: bin, daemon, sys)  
    - ' ': 代表該帳號沒有密碼，不須密碼就可以登入
  3. **User ID (UID)**: 可以看到 root 的 ID 是0
  4. **Group ID**: 那個使用者所屬 group 的 ID
  5. **GECOS field**: 用來留下一些註解的，有些人會用來留本名或電話號碼之類
  6. **User's home directory**: 可以看到 root 的家目錄在 /root
  7. **User's shell**: 可以看到該使用者對 bash shell 的一些設定

  此外，除了 root 你應該會看到很多不能登入的帳號 (password 欄為 '*')，那些是**系統帳號 (system account)**。他們的用途是讓系統服務或背景程式在執行時，擁有獨立且受限的權限，避免使用 root 執行所有工作。這樣做可以達到權限隔離的安全目的，即使某個服務被駭客控制，損害也僅限於該帳號能存取的範圍。

  ### 2-2. /etc/shadow
  `/etc/shadow` 儲存了使用者們的認證資訊，具體案例如下 (安全起見，我不會展示我的)：
  ```bash
  $ sudo cat /etc/shadow
  root:MyEPTEa$6Nonsense:15000:0:99999:7:::
  ```
  他有幾個欄位如下：
  1. **Username**
  2. **Password**: 不過是加密過的
  3. **密碼最後修改時間**: 表達的方式是自 1970/1/1 以來過了幾天
  4. **密碼最低期限**: 也就是改密碼後，要過多久才能再改，0 代表隨時都能再改
  5. **密碼最高期限**: 密碼多久後過期，過期後就要改密碼，99999 代表永不過期
  6. **警告期**: 密碼過期前提醒你改密碼，這裡是 7，代表在要過期的 7 天前會提醒你趕快改
  7. **寬限期**: 密碼過期後，你還有幾天能改密碼，過了寬限期還沒改帳號就會完全停用
  8. **帳號失效日**: 帳號預定被停用的絕對日期，同樣用「自 1970 年 1 月 1 日起算的天數」表達。
  9. **保留欄位**: 給系統未來擴充功能用的

  題外話，多數 linux 發行版如今已不僅僅依靠 `/etc/shadow` 來認證了，多半會搭配其他機制。

  ### 2-3. /etc/group
  `/etc/group` 儲存了每個 group 的資訊，具體案例如下：
  ```bash
  $ cat /etc/group
  root:*:0:pete
  ```
  他有幾個欄位如下：
  1. **Group name**
  2. **Group password**: 已全面廢棄，值多半放在 `/etc/gshadow` 中。
  3. **Group ID (GID)**
  4. **List of users**: 使用者間以逗號分隔

  ## 3. 權限設定

  多數檔案的權限也是可以設定的，有幾個我們常用的指令：
  3-1. [**chmod**](#3-1-chmod)  
  3-2. [**chown/chgrp**](#3-2-chownchgrp)  
  3-3. [**umask**](#3-3-umask)  
  3-4. [**suid/sgid/sbit**](#3-4-suidsgidsbit)  


  ### 3-1. chmod

  回顧我們剛剛提及的權限設定：
  ```bash
  $ ls -l
  total 0
  -rw-r--r-- 1 wilson wilson 0 Jul 21 21:54 test.txt
  ```
  他分為四個部分'-', 'rw-', 'r--', '---'
  1. 檔案類型，分為 '-', 'd' 兩種，分別對應：
    - '-': 檔案
    - 'd': 目錄
  2. owner 權限，這裡是 'rw-'，說明檔案所屬 owner 可以讀寫、但不能執行。
  3. group 權限，這裡是 'r--'，說明檔案所屬 group 的成員可以讀、但不能寫和執行。
  4. other 權限，這裡是 'rw-'，外人不可以讀寫執行。

  編輯這些權限要用到 `chmod` (change mode) 指令：
  ```bash
  $ chmod u+x test.txt
  ```
  `chmod` 的格式是 `chmod [變更方法] [目標檔案]` 這裡變更方法是 `u+x`，意指為 'u (user)' 添加 'x (execution)' 的權限。
  ```bash
  $ ls -l
  total 0
  -rwxr--r-- 1 wilson wilson 0 Jul 21 21:54 test.txt
  ```
  執行完後可見，owner 的部分多出了可以執行的權限。  
  而如果要移除權限的話就用 `-`:
  ```bash
  $ chmod u-x test.txt
  $ ls -l
  total 0
  -rw-r--r-- 1 wilson wilson 0 Jul 21 21:54 test.txt
  ```
  此外也可以一次編輯多個類型的權限：
  ```bash
  $ chmod ug+x test.txt
  wilson@LAPTOP-7TCEDO3U:~$ ls -l
  total 0
  -rwxr-xr-- 1 wilson wilson 0 Jul 21 21:54 test.txt
  ```
  輸入 `ug+x` 會讓我們同時編輯 u (user) 和 g (group) 的權限。  
  身分上我們可以編輯：u (user), g (group), o (other), a (all)  
  權限上可以編輯：r (read), w (write), x (execution)  
  這些可以任意組合。  

  但實務上，我們更常用一種更方便的方式：
  ```bash
  $ chmod 777 test.txt
  $ ls -l
  total 0
  -rwxrwxrwx 1 wilson wilson 0 Jul 21 21:54 test.txt
  ```
  user, group, other, 二進位 4+2+1=7......

  ### 3-2. chown/chgrp
  `chown` 可以更改一個檔案隸屬的使用者；`chgrp` 可以更改一個檔案隸屬的群組，用法如下：
  ```bash
  $ sudo chown patty myfile
  ```
  ```bash
  $ sudo chgrp whales myfile
  ```
  此外也可以一次同時更改，只要使用 `chown` 搭配以下格式：
  ```bash
  $ sudo chown patty:whales myfile
  ```

  ### 3-3. umask
  `umask` 是用來設定，每個檔案在剛建立時預設的權限，用法如下：
  ```bash
  $ umask 021
  ```

  ### 3-4. SUID/SGID/SBIT
  這裡要介紹三個特殊權限，專門用來突破傳統權限的限制，他們分別是：
  - **SUID (set user ID)**: 分數4  
    只對2進位 (可執行) 程式檔有效，若使用者對某個有 SUID 權限的檔案有 **x (執行)** 的權利，而他執行了這個檔案，他會在執行期間**暫時變成 owner 的權限**  
  - **SGID (set group ID)**: 2  
    對2進位 (可執行) 程式檔有效，若使用者對某個有 SGID 權限的檔案有 **x (執行)** 的權利，而他執行了這個檔案，他會在執行期間**暫時變成檔案所屬 group**  
    也對目錄有效，若使用者某個有 SGID 權限的檔案有 **r (閱讀) 與 x (執行)** 的權利，則他可以進入這個目錄，而在目錄裡的期間，他會**暫時變成檔案所屬 group**，此外，他在目錄裡建立的檔案，所屬的群組也會跟目錄的群組一樣。
  - **SBIT (sticky bit)**: 1  
    只對目錄有效，當使用者對於此目錄具有 **w (撰寫) 與 x (執行)** 的權限，當使用者在該目錄下建立檔案或目錄，他沒辦法刪除這個檔案，只有 **owner 與 root** 才有權力刪除該檔案
  ```bash
  $ ll -d /usr/bin/passwd /usr/bin/locate /tmp
  drwxrwxrwt. 9 root root      280  7月  7 06:35 /tmp
  -rwx--s--x. 1 root slocate 40496  6月 10  2014 /usr/bin/locate
  -rwsr-xr-x. 1 root root    27832  6月 10  2014 /usr/bin/passwd
  ```

  若有小寫 s 或 t 存在時，該欄位需要加入 x 的權限，因此 /tmp 的傳統權限為『 drwxrwxrwx (777) 』外加一個 SBIT，因此分數為『 1777 』。 而 /usr/bin/locate 傳統權限會成為『 -rwx--x--x (711) 』外加一個 SGID，因此分數會成為『 2711 』。 至於 /usr/bin/passwd 的傳統權限是『 -rwxr-xr-x (755) 』，外加一個 SUID，因此分數成為『 4755 』。

  SUID: chmod u+s filename
  SGID: chmod g+s filename
  SBIT: chmod o+t filename


