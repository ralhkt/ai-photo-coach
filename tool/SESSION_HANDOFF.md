# AI Photo Coach — 工作交接摘要

> 下次開工：先讀此檔，再依 Action Items 依序執行。

**最後更新：** 2026-06-19  
**Repo：** https://github.com/ralhkt/ai-photo-coach  
**本地路徑：** `/Users/Personal/Documents/Photographer`  
**最新 commit：** `66a5e08`（`main` 已 push）

---

## 專案目標

打卡照智慧引導 App：參考圖分析 → 姿態/構圖/九頭身/水平校正 → 即時引導拍攝。  
香港需透過 **Cloudflare Proxy** 使用 Gemini（直連被封）。

---

## 已完成

### 參考圖分析（`4e0f0d7`）
- [x] EXIF 讀取（ISO、快門、光圈、焦距、相機型號）
- [x] 上傳照 ML Kit 失敗 → 中央 placeholder，不亂放框
- [x] `subjectDetectionReliable=false` 時禁用「開始引導拍攝」
- [x] Cloudflare Gemini Proxy Worker + `deploy_iphone_with_proxy.sh`

### 姿態教練 / 效能（`66a5e08`）
- [x] `SubjectPoseTracker` — 多人 IoU 主角鎖定（取代 `poses.first`）
- [x] `PoseJointSmoother` — 關節 EMA 抗抖
- [x] `PoseAligner` — Kabsch 旋轉不變比對
- [x] 關節補償（手腕/臀部遮擋）
- [x] ML 節流前置、移除 `latestResult` bypass
- [x] `AdaptiveCoachingScheduler` 動態降頻
- [x] iOS `IosSceneStabilityPoller`（JPEG pHash）
- [x] BGRA buffer pool
- [x] **116 項測試全過**

### 部署
- [x] iPhone release 安裝（裝置 `00008130-001A01610AA0001C`）
- [x] Proxy URL：`https://photo-coach-gemini-proxy.marsh-year.workers.dev/gemini`
- [ ] **GEMINI_API_KEY 未設定** → 雲端分析目前走本機

---

## Action Items（下次依序）

### P0 — 啟用雲端 AI
1. [ ] [Google AI Studio](https://aistudio.google.com/apikey) 建立 **Gemini API 金鑰**
2. [ ] 註冊 [Cloudflare](https://www.cloudflare.com/)（或 claim 臨時帳號）
3. [ ] `npx wrangler login` → `npx wrangler deploy`
4. [ ] `npx wrangler secret put GEMINI_API_KEY`
5. [ ] 重裝 iPhone：
   ```bash
   export GEMINI_API_KEY=你的金鑰
   bash tool/deploy_iphone_with_proxy.sh
   ```

### P1 — 驗證測試（拔線後可測）
1. [ ] 上傳含 EXIF 原始 JPEG → 確認 ISO 等顯示
2. [ ] 上傳人物難辨識照 → 框穩定、引導按鈕禁用
3. [ ] 姿態教練 + 路人入鏡 → 框鎖定主角
4. [ ] 侧身/微轉 → 姿態分數合理
5. [ ] 姿勢到位後 → 更新變慢、發熱改善
6. [ ] 啟用 Gemini 後 → 分析來源顯示 proxy/gemini

### P2 — 待規劃（CTO 審查建議）
- [ ] 合照「點選主角」UI
- [ ] Android `CameraImage` → `InputImage` 直通
- [ ] 共用單一 `PoseDetector` 實例
- [ ] 爬蟲 pipeline + 遠端 trendy catalog
- [ ] 陀螺儀 + 加速度計融合（Madgwick）

---

## 快速指令

```bash
cd /Users/Personal/Documents/Photographer
flutter test
flutter devices
export GEMINI_API_KEY=...   # 取得後
bash tool/deploy_iphone_with_proxy.sh
git pull origin main
```

---

## 給 AI 的開場白（下次貼這段即可開工）

```
請讀取 tool/SESSION_HANDOFF.md，輸出摘要與 Action Items，
然後從第一個未完成的 P0 項目開始帶我執行。
```