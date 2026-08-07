+++
date = '2026-08-03T01:43:46+08:00'
draft = false
title = 'Road to CS day9 Linux_8'
tags = ["linux", "network"]
categories = ["linux", "nwtwork"]
+++

## 1. Network basic

| Layer             | 中文    | 負責                    | PDU (資料單位)                     | Address     | 常見 Protocol                      |
| ----------------- | ----- | --------------------- | ------------------------------ | ----------- | -------------------------------- |
| Application Layer | 應用層   | 提供使用者服務               | Data (Message)                 | -           | HTTP, HTTPS, DNS, SMTP, FTP, SSH |
| Transport Layer   | 傳輸層   | Process-to-Process 傳輸 | Segment (TCP) / Datagram (UDP) | Port        | TCP, UDP                         |
| Network Layer     | 網路層   | Host-to-Host Routing  | Packet (IP Packet)             | IP Address  | IP, ICMP, IGMP              |
| Link Layer        | 資料鏈結層 | Node-to-Node 傳輸       | Frame                          | MAC Address | Ethernet, Wi-Fi (802.11), PPP, ARP    |

### Load balancing

---
## 2. DNS & Service discovery
DNS 把給人讀的主機名稱 (domain name) (ex: www.google.com) 翻譯成給機器讀的 IP 位址 (ex: 192.78.12.4)，稱為 **resolution**。  
DNS 是個大型的分散式系統，每個網站持有者管理著他們的 DNS 紀錄來讓別人找到他們的 domain。domains 彼此互相溝通，形成一個巨大的相連的目錄，這種去中心化的結構既彈性也容易擴張。   

### 2-1. DNS Components：
```
name server > zone file > resource record
```
- **name server**: 回答 client 的 queryent 的 query (ex: www.google.com 在哪？)，或者 "recursive" 把問題轉給其他 server，recursive server 也可以把資訊 cache 起來。
- **zone file**: name server 裡的檔案
- **resource record**: zone file 裡的紀錄，欄位如下：
    - Record name
    - TTL:  - The time after which we discard the record and obtain a new one. In DNS, TTL is denoted by time, so records could have a TTL of one hour，因為 IP 常常變化。
    - Class: Namespace， IN->Internet.
    - Type: Type of information stored in the record data，ex: MX->mail exchanger。
    - Data:  - This field can contain an IP address if it's an A record or something else depending on the record type.
    ```bash
    patty    IN  A      192.168.0.4
    ```

### 2-2. DNS process：
1. The Initial Query:  
    向 recursive DNS server 發出 query (ex: Where is catzontheinterwebz.com)，recurisve 可能不知道，於是把問題轉給 **root server**。
2. Root Server:  
    網際網路域名系統（DNS）的最頂層核心，有 13 位，他們不知道每個 domain，但他們會把 query 引流到正確的 **TLD server** (ex: .com, .org, and .net)
3. TLD (Top-Level Domain) Servers:  
    指到目標 domain 的 **authoritative name servers**
4. Authoritative DNS Server:  
    查找紀錄，回傳 IP 位址。

### 2-3. /etc/hosts：
`/etc/hosts` 提供 hostnames -> IP 的靜態 mapping
```bash
pete@icebox:~$ cat /etc/hosts
127.0.0.1       localhost
127.0.1.1       icebox
```
如果 `/etc/hosts` 的 hostname map 到錯的 IP，搜尋會失效。

### 2-4. DNS setup：
- BIND：最有名，Linux 的標準，完整的功能與彈性
- DNSmasq：輕量化的 BIND，只是 set up DHCP 和 DNS 的話夠了,
- PowerDNS：完整、類似 BIND，更多彈性，可以從多個資料庫 (ex: MySQL, PostgreSQL) 讀資訊

### 2-5. DNS tool：
`nslookup` 與 `dig`，`dig` 更詳細，適合 troubleshooting。

### Service discovery
處理好整套微服務架構內，每個各別的服務的管理，讓其他服務或是外界的服務，能夠很明確的 “找到” 他需要的服務在哪裡 (IP，PORT 等等資訊)。為了讓這個機制能順利運作，服務發現的機制通常也包含了可用服務的清單維護，同時也涵蓋了讓其他 服務順利找到正確服務端點的 config management 機制。