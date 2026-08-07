+++
date = '2026-07-30T16:20:22+08:00'
draft = false
title = 'Road to CS day7: linux6-shell script (unfinished)'
tags = ["linux"]
categories = ["linux"]
+++

## 1. init
**System V (SysV init)**、**Upstart** 和 **systemd** 都是 Linux 的 **init 系統（初始化系統）**，負責在開機後啟動系統服務、管理背景程序（daemon），以及在系統運行期間控制服務的啟動、停止與重啟。

它們代表 Linux init 系統的三個不同世代。

| 特性   | System V              | Upstart | systemd     |
| ---- | --------------------- | ------- | ----------- |
| 出現時間 | 約 1983（Unix System V） | 2006    | 2010        |
| 啟動方式 | 順序執行                  | 事件驅動    | 相依關係 + 平行啟動 + journal |
| 啟動速度 | 慢                     | 較快      | 最快          |
| 現況   | 幾乎淘汰                  | 已停止發展   | 主流          |

## 2. daemon
| 一般程式     | Daemon   |
| -------- | -------- |
| 由使用者手動啟動 | 通常開機由 init 系統自動啟動 |
| 執行完就結束   | 長時間運作，等待事件或請求，再做對應工作  |
| 有終端機介面   | 沒有互動介面   |
| 使用者操作    | 提供系統服務   |

| 常見 Daemon             | 功能             |
| ------------------ | -------------- |
| `sshd`             | 提供 SSH 遠端登入    |
| `httpd` 或 `nginx`  | 提供網頁服務         |
| `mysqld`           | 提供 MySQL 資料庫服務 |
| `crond`            | 定時執行工作（Cron）   |
| `cupsd`            | 管理印表機服務        |
| `systemd-journald` | 收集系統日誌         |

Daemon 與 Service 的關係
- Daemon：實際執行的背景程式（例如 sshd、nginx）。  
- Service（服務）：作業系統管理這個 daemon 的方式與設定，例如在 systemd 中會有一個 .service 單元檔。  

## 3. shell script

### 3-1. hello world
```bash
#!/bin/bash
# Program:
#       This program shows "Hello World!" in your screen.
# History:
# 2015/07/16	VBird	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
echo -e "Hello World! \a \n"
exit 0
```
1. 第一行 #!/bin/bash 在宣告這個 script 使用的 shell 名稱：  
    以『 #!/bin/bash 』宣告這個檔案內使用 bash 的語法！那麼當這個程式被執行時，他就能夠載入 bash 的相關環境設定檔，並且執行 bash 來使底下指令能夠執行！(如果沒有設定好這一行， 那麼該程式可能無法執行，因為系統無法判斷該程式需要使用什麼 shell)
2. \# 都是『註解』用途：  
    建議養成說明該 script 的：1. 內容與功能； 2. 版本資訊； 3. 作者與聯絡方式； 4. 建檔日期；5. 歷史紀錄 等等
3. 建議務必要將一些重要的環境變數設定好，PATH 與 LANG (如果有使用到輸出相關的資訊時) 是當中最重要的
4. 執行成果告知 (定義回傳值)  
    使用 exit 0 ，這代表離開 script 並且回傳一個 0 給系統， 執行完這個 script 後，若接著下達 echo $? 則可得到 0 的值
```bash
$ sh hello.sh
Hello World !
```

對談式腳本，`read`：
```bash
read -p "Please input your first name: " firstname      # 提示使用者輸入
read -p "Please input your last name:  " lastname       # 提示使用者輸入
echo -e "\nYour full name is: ${firstname} ${lastname}" # 結果由螢幕輸出
```
計算日期，`date`：
```bash
date1=$(date --date='2 days ago' +%Y%m%d)  # 前兩天的日期
date2=$(date --date='1 days ago' +%Y%m%d)  # 前一天的日期
date3=$(date +%Y%m%d)                      # 今天的日期
file1=${filename}${date1}                  # 底下三行在設定檔名
file2=${filename}${date2}
file3=${filename}${date3}
```
數值運算：
```bash
read -p "first number:  " firstnu
read -p "second number: " secnu
total=$((${firstnu}*${secnu}))
echo -e "\nThe result of ${firstnu} x ${secnu} is ==> ${total}"
```
PI：
```bash
read -p "The scale number (10~10000) ? " checking
num=${checking:-"10"}           # 開始判斷有否有輸入數值，沒有則用預設值的 10
echo -e "Starting calculate pi value.  Be patient."
# echo 輸出圓周率精度的參數 (ex: "scale=50; 4*a(1)") 
# 然後透過 pipe 傳遞給 bc，"scale=50" 指定圓周率精度，a(1)=arctan(1)=PI/4, 4*a(1)=PI
time echo "scale=${num}; 4*a(1)" | bc -lq
```

### 3-2. script 的執行方式差異 (source, sh script, ./script)
使用 `sh script`、`./script` 時，script 會新建立一個 child process 來執行腳本內的指令，**當 child process 完成後，在 child process 內的各項變數或動作將會結束而不會傳回到 parent process 中：
```bash
$ sh showname.sh
Please input your first name: VBird <==這個名字是鳥哥自己輸入的
Please input your last name:  Tsai 

Your full name is: VBird Tsai      <==在 script 運作中，這兩個變數有生效
${firstname} ${lastname}
    <==事實上，這兩個變數在 parent process的 bash 中還是不存在的！
```
使用 `source script` 指令會直接在目前的 Shell中逐行執行。
```bash
$ source showname.sh
Please input your first name: VBird
Please input your last name:  Tsai

Your full name is: VBird Tsai
$ echo ${firstname} ${lastname}
VBird Tsai  <==嘿嘿！有資料產生喔！
```

### 3-3 判斷式
使用 `test` 搭配參數 (如 `test -e /dmtsai`) 可以檢查檔案及相關屬性
https://linux.vbird.org/linux_basic/centos7/0340bashshell-scripts.php#test
```bash
$ test -e /dmtsai
```
執行結果並不會顯示任何訊息，但最後我們可以透過 $? 或 && 及 || 來展現整個結果，例如也可以將上面的例子改寫成這樣：
```bash
$ test -e /dmtsai && echo "exist" || echo "Not exist"
Not exist  <==結果顯示不存在啊！
```

也可以用中括號來做資料判斷：
```bash
$ [ -z "${HOME}" ]
$ echo $?
```
注意：
- 在中括號 [] 內的每個元件都需要有空白鍵來分隔；  
- 在中括號內的變數，最好都以雙引號括號起來；  
- 在中括號內的常數，最好都以單或雙引號括號起來。  
例如：
```bash
$ name="VBird Tsai"
[dmtsai@study ~]$ [ ${name} == "VBird" ]
bash: [: too many arguments
```
這是因為 ${name} 如果沒有使用雙引號刮起來，那麼上面的判定式會變成：`[ VBird Tsai == "VBird" ]`

shell script的預設變數：
```bash
$ vim how_paras.sh
#!/bin/bash
# Program:
#	Program shows the script name, parameters...
# History:
# 2015/07/16	VBird	First release
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

echo "檔名是：      ==> ${0}"
echo "參數個數是：  ==> $#"
[ "$#" -lt 2 ] && echo "The number of parameter is less than 2.  Stop here." && exit 0
echo "全部參數是：  ==> '$@'"
echo "第一個參數：  ==> ${1}"
echo "第二個參數：  ==> ${2}"
```
執行結果如下：
```bash
$ sh how_paras.sh theone haha quot
The script name is        ==> how_paras.sh       <==檔名
Total parameter number is ==> 3                  <==果然有三個參數
Your whole parameter is   ==> 'theone haha quot' <==參數的內容全部
The 1st parameter         ==> theone             <==第一個參數
The 2nd parameter         ==> haha               <==第二個參數
```
此外變數可以 shift：
```bash
echo "Total parameter number is ==> $#"
echo "Your whole parameter is   ==> '$@'"
shift   # 進行第一次『一個變數的 shift 』
echo "Total parameter number is ==> $#"
echo "Your whole parameter is   ==> '$@'"
shift 3 # 進行第二次『三個變數的 shift 』
echo "Total parameter number is ==> $#"
echo "Your whole parameter is   ==> '$@'"
```
執行成果如下：
```bash
$ sh shift_paras.sh one two three four five six <==給予六個參數
Total parameter number is ==> 6   <==最原始的參數變數情況
Your whole parameter is   ==> 'one two three four five six'
Total parameter number is ==> 5   <==第一次偏移，看底下發現第一個 one 不見了
Your whole parameter is   ==> 'two three four five six'
Total parameter number is ==> 2   <==第二次偏移掉三個，two three four 不見了
Your whole parameter is   ==> 'five six'
```

### 3-4. 條件判斷式

if-then：
```shell
if [ 條件判斷式一 ]; then
	當條件判斷式一成立時，可以進行的指令工作內容；
elif [ 條件判斷式二 ]; then
	當條件判斷式二成立時，可以進行的指令工作內容；
else
	當條件判斷式一與二均不成立時，可以進行的指令工作內容；
fi
```
case：
```shell
case  $變數名稱 in   <==關鍵字為 case ，還有變數前有錢字號
  "第一個變數內容")   <==每個變數內容建議用雙引號括起來，關鍵字則為小括號 )
	程式段
	;;            <==每個類別結尾使用兩個連續的分號來處理！
  "第二個變數內容")
	程式段
	;;
  *)                  <==最後一個變數內容都會用 * 來代表所有其他值
	不包含第一個變數內容與第二個變數內容的其他程式執行段
	exit 1
	;;
esac                  <==最終的 case 結尾！『反過來寫』思考一下！
```
function：
```shell
function fname() {
	程式段
}
```

### 3-5. loop
while-do-done，『condition 條件成立時，就進行迴圈，條件不成立才停止』：
```shell
while [ condition ]  <==中括號內的狀態就是判斷式
do            <==do 是迴圈的開始！
	程式段落
done          <==done 是迴圈的結束
```
until-do-done，『condition 條件成立時，就終止迴圈，否則持續進行。』：
```shell
until [ condition ]
do
	程式段落
done
```
for-do-done：
```shell
for var in con1 con2 con3 ...
do
	程式段
done
```
以上面的例子來說，這個 $var 的變數內容在迴圈工作時：  
第一次迴圈時， $var 的內容為 con1，第二次 $var 的內容為 con2，第三次為 con3....  
也能像 `for sitenu in $(seq 1 100)`、`for filename in $(ls ${dir})` 這樣用  
for-loop 也有另一種用法：
```bash
for (( i=1; i<=100; i=i+1 ))
do
        s=$((${s}+${i}))
done
```

### 3-6. debug
shell script 有一些參數方便執行時 DEBUG，`$ sh [-nvx] scripts.sh`：
- `-n`：不要執行 script，僅查詢語法的問題；
- `-v`：再執行 sccript 前，先將 scripts 的內容輸出到螢幕上；
- `-x`：將**使用到的** script 內容顯示到螢幕上！
