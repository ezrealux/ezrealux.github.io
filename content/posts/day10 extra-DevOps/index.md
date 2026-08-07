+++
date = '2026-08-03T13:37:15+08:00'
draft = true
title = 'Road to CS extra-DevOps'
+++

## 1. CI/CD

### CI (Continuous Integration) 持續整合：  
開發人員頻繁將程式碼合併到共享的主分支，每次提交會自動執行建置與單元測試，及早發現並修正程式碼衝突或錯誤。   

流程範例：
1. 程式碼提交（commit / PR）
2. 自動化測試（unit test、lint、security check）
3. 建構（build、package）
4. 報告回饋（通知 Slack、Email、GitHub PR 狀態）

工具：
- Pipeline 工具：GitHub Actions、GitLab CI、CircleCI、Jenkins
- 測試工具：Jest、SonarQube（程式碼品質檢查）
- 安全檢查：Dependabot、Snyk

### CD (Continuous Deployment) 持續部署：  
程式碼通過自動化測試後，隨時保持可上線狀態。只要通過所有測試，程式碼就會直接自動部署上線。

流程範例：
1. CI 結果通過 → 部署到測試環境（Staging）
2. 自動化整合測試（integration / e2e）
3. 部署到生產環境（Production）
4. 健康檢查 / 監控（包含 rollback 機制）

工具：
- 部署與 Orchestration：ArgoCD、Spinnaker、FluxCD
- 雲端平台：AWS CodePipeline、GCP Cloud Build、Azure DevOps
- 容器相關：Kubernetes、Helm

---
## 2. Ansible & Terraform

---
## 3. Kubernetes
