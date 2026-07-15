+++
date = '2026-07-14T10:41:32+08:00'
draft = false
title = 'Road to CS day1: hugo basic'
tags = ["hugo", "git"]
categories = ["hugo"]
+++

我用來撰寫部落格的工具是 github pages 搭配 hugo 框架。原因是這樣的話，我就能在撰寫部落格的途中順便熟悉 git 與 github 的用法。
主要可以分為幾個步驟：
  
  1. [**建立github repo**](#1-建立github-repository)
  2. [**搭建hugo框架**](#2-搭建hugo框架)
  3. [**部署到github pages**](#3-部署到github-pages)
  4. [**文章的日常更新流程**](#4-文章的日常更新流程)

---
## 1. 建立github repository  
  假設所有人都已經有 github 帳號了。首先我們來到創建 github repo 的頁面：
  ![repo創建](1_create_repo.jpeg)  
  在這裡將 repository name 取名為 `[你的github帳號].github.io`、visibility設定為 **public**、加入 **README** 跟 **.gitignore**。  
  
  建立完成後來到 repo 的 Setting 頁面，選擇 pages 分類
  ![repo設定](2_repo_setting.jpeg)  
  設定 Source: **Deploy from a branch**、Branch: **main**、Folder: **/(root)** 的方式設定，再按下 save 儲存。

  之後應該就能在頁面看到這樣的訊息：
  ![live site](3_live_site.jpeg)
  說明 repo 設定完成了。  
  我在建立 repo 後，所有的設定都已經預設好了，所以馬上就看到了訊息。如果沒有的話，或許就需要你手動設定，然後等待個幾分鐘。  

## 2. 搭建hugo框架  
### 2-1. 安裝hugo與git
  我的電腦用的是 windows 11 作業系統，所以我安裝 hugo 的方法，就是執行：  
  ```powershell
  > winget install Hugo.Hugo.Extended
  ```
  安裝完成後輸入：
  ```powershell
  > hugo version
  ```
  確認 hugo 安裝完成，此外也別忘記安裝 git
  ```powershell
  > git --version
  git version 2.44.0.windows.1
  ```
---
### 2-2. 建立專案
  要建立一個 blog 網站，首先我們需要建立一個專案資料夾：
  ```powershell
  > mkdir [目錄名稱] ## 建立專案目錄
  > cd [目錄名稱] ## 進入專案目錄內
  \[目錄名稱]> hugo new site . ## 建立專案
  ```
  完成後會看到目錄內的結構像這樣：
  ```
  archetypes/
  content/
  data/
  layouts/
  static/
  themes/
  hugo.toml
  ```
---
###  2-3. 引入主題
  搭建完專案的骨架後，我們可以為部落格挑選一個「主題」。所謂主題，指的就是網頁的風格，在hugo的官網，有許多前人早已設計好的模板，透過引入這些模板，我們便能省去前端設計的心力，專注在文章內容上。這次我選用了 PaperMod 主題。
  
  而從這裡開始，就要開始搭配 git 了。
  首先我們先執行：
  ```powershell
  > git init
  ```
  把目前的這個專案資料夾初始化成 git repo，這樣才可以進到下一步：
  ```powershell
  > git submodule add https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod
  ```
  `git submodule` 可以讓我們把另一個 repo 作為子目錄嵌入我們自己的專案 repo 中，透過這樣，我們成功引入了前人設計的hugo主題而不使專案結構過於臃腫。

  而引入 hugo 主題的程式碼之後，我們也要修改設定檔，來讓我們開始使用主題。我們需要打開 `hugo.toml` 把內容改成：
  ```toml
  baseURL = "https://[github帳號名].github.io/"
  languageCode = "zh-tw"
  title = "[部落格標題]"

  theme = "PaperMod"
  ```
  這樣一來就確立了，這個部落格專案使用的是 PaperMod 主題。而此時若是輸入：
  ```powershell
  hugo server -D
  ```
  看到 `Web Server is available at http://localhost:1313/` 的內容，說明網頁在你的本機開始運行了，你可以預覽文章內容，此時點進網址，應該就能夠看到類似這樣的畫面：
  ![repo創建](4_papermod.jpeg)
  (發現暗色模式害我的網頁預覽圖完全融入背景了，我真是個天才)  

## 3. 部署到github pages
  接下來需要把 hugo 部落格部署到 gitHub pages。
  使用 github pages 的好處是，可以省下架設伺服器的精力，只要把檔案 `git push` 到 github 上的 repo，部落格就會被自動部署成可以公開訪問的網站。而如果要更新網站內容，也只要做同樣的 `git push` 就好，非常方便。

  ### 3-1. github action部屬設定
  為了實現自動部署的功能，我們需要撰寫一份 workflow 設定檔。

  首先建立一個 `workflow/` 資料夾，github action 的 workflow 設定檔都會放在這裡。
  ```powershell
  > mkdir -p .github/workflows
  ```
  接著建立檔案：
  ```
  .github/workflows/hugo.yml
  ```
  建立完後，我們需要撰寫一下 `hugo.yml` 裡的內容：
  ```yaml
  name: Deploy Hugo site to Pages

  on:
    push:
      branches:
        - main

  permissions:
    contents: read
    pages: write
    id-token: write

  concurrency:
    group: "pages"
    cancel-in-progress: true

  jobs:
    build:
      runs-on: ubuntu-latest

      env:
        HUGO_VERSION: 0.152.2

      steps:
        - name: Checkout
          uses: actions/checkout@v4
          with:
            submodules: recursive
            fetch-depth: 0

        - name: Setup Pages
          uses: actions/configure-pages@v5

        - name: Setup Hugo
          uses: peaceiris/actions-hugo@v3
          with:
            hugo-version: ${{ env.HUGO_VERSION }}
            extended: true

        - name: Build
          run: hugo --minify

        - name: Upload artifact
          uses: actions/upload-pages-artifact@v3
          with:
            path: ./public

    deploy:
      environment:
        name: github-pages
        url: ${{ steps.deployment.outputs.page_url }}

      runs-on: ubuntu-latest

      needs: build

      steps:
        - name: Deploy to GitHub Pages
          id: deployment
          uses: actions/deploy-pages@v4
  ```
  (workflow 內容為 AI 撰寫，請根據情況調整內容)
  
  這樣一來自動化的流程就設計好了。

  ---
  ### 3-2. 推送到 github

  之後便可以試著把 hugo repo 推送到 github 上了，方法與一般的 `git push` 流程大同小異。  
  不過在那之前，我們要先編輯一下 **.gitignore**，確保這些內容不會被 git commit 影響：
  ```
  /public/ # 瀏覽器真正會讀取的網站檔案（HTML、CSS、JS 等）
  /resources/ # Hugo 的快取與中間產物
  .hugo_build.lock # 建置鎖定檔(mutual lock，防止 race condition 用的)
  ```
  然後就可以正式開始推送流程了：
  ```powershell
  > git add .
  > git commit -m "一點註解"
  > git remote add origin https://github.com/你的帳號/你的帳號.github.io.git
  > git branch -M main
  > git push -u origin main
  ```
  完成後，hugo repo 就正式推送到 github repo 上了。  

  而此時我們需要再度來到 repo 的 Setting 頁面和 pages 分類([**參照前面建立repo的流程**](#1-建立github-repository))，這次設定 Source: **Github actions**。**Deploy from a branch** 與 **Github actions** 最主要的差別在於**實際網站來源不同**，如果我們選用 **Deploy from a branch**，我們需要先在本地端手動部署好網頁，再將 `/public/` 裡的內容整組推送到github repo；但若是使用 **Github actions**，透過我們剛剛撰寫好的 workflow，我們可以在推送後，由 github 建立的 ubuntu VM，自動完成部署的工作。 

  這樣我們就完成了第一次推送。

---
## 4. 文章的日常更新流程

  接下來來講解一下，建立好這些之後，未來要上傳、更新網站的文章該怎麼辦。  
  流程大抵還是依循著以下流程：
  ```
  寫文章 -> 本機預覽 -> 發布文章 -> git push -> GitHub Actions 自動部署 -> 瀏覽器查看更新
  ```

  ### 4-1. 建立新文章

  若要建立新的文章，需要輸入：
  ```powershell
  > hugo new posts/[文章名稱].md
  ```
  專案資料夾內會產生：
  ```
  content/
  └── posts/
      └── [文章名稱].md
  ```
  而打開 .md 檔，裡面的內容會像是：
  ```md
  +++
  date = '2026-07-14T10:00:00+08:00'
  draft = true
  title = '[文章名稱]'
  +++

  \#\#你的文章就依循 markdown 格式打在這裡
  ```

  我們一樣可以透過 `hugo server -D` 來預覽，參考[**前述文章**](#2-3-引入主題)  
  此外要更新既有的文章的話，打開那篇文章的 .md 檔修改就好。

  ---
  ### 4-2. 發布文章 & git push

  剛建立文章時，你會發現其中一項設定寫著 `draft = true`，這說明你的文章還只是草稿，就這麼推送到 github 的話，是不會顯示在網站上的。

  若是你確認文章已經撰寫完整，可以發布了，有兩種方法可以發布：
  1. 直接修改 `draft = false`
  2. 終端輸入 `hugo publish content/posts/git-basic.md`
  都可以。

  用 `git status` 查看修改確認無誤後，同樣依循：
  ```
  > git add .
  > git commit -m "Add Git basic article"
  > git push
  ```
  的流程推送到 github 上。

  ---
  ### 4-3. 查看 github action 部署 & 網站更新

  打開 github repo 點 **Actions**，看到 Deploy Hugo site，會跑出以下流程：
  ```
  ✓ Checkout
  ✓ Setup Hugo
  ✓ Build
  ✓ Deploy
  ```
  如果部署成功了，那就會看到 `green ✓` 訊息。

  最後，只要進到 `https://ezrealux.github.io` 就能查看實際部署好的網頁內容了。

  ---

  關於如何使用 github pages + hugo 建置部落格的流程就先講到這裡，往後有學到什麼新的知識，我也會盡量持續在這篇部落格更新解說文章。