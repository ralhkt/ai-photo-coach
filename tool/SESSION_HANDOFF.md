# AI Photo Coach — 工作交接摘要

> 下次開工：先讀此檔，再依 Action Items 依序執行。

**最後更新：** 2026-06-19  
**Repo：** https://github.com/ralhkt/ai-photo-coach  
**本地路徑：** `/Users/Personal/Documents/Photographer`  
**最新 commit：** `eec267e`（`main` 已 push）  
**測試：** 125 項全過

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
- [x] `SubjectPoseTracker` — 多人 IoU 主角鎖定
- [x] `PoseJointSmoother` — 關節 EMA 抗抖
- [x] `PoseAligner` — Kabsch 旋轉不變比對
- [x] 關節補償（手腕/臀部遮擋）
- [x] ML 節流前置、移除 `latestResult` bypass
- [x] `AdaptiveCoachingScheduler` 動態降頻
- [x] iOS `IosSceneStabilityPoller`（JPEG pHash）
- [x] BGRA buffer pool

### PR-4/5 Native 互動與穩定（iOS 15+，最新）
- [x] `AlignmentStateMachine` — 三態 Haptic + `autoCaptureRequested` 事件
- [x] `KalmanContourFilter` C++ — 輪廓時間序列平滑
- [x] 低光降級 — `score < 18` 切換骨架虛線引導
- [x] 深色膠囊 Toast + 自動快門（`captureWithTimer`）
- [x] `PoseSilhouetteSyncController` — 避免重複 channel 寫入

### PR-2 Native 輪廓（iOS 15+）
- [x] `VNGeneratePersonSegmentationRequest` + C++ RDP/B-spline（`ContourProcessor`）
- [x] `PoseSilhouetteHandler` MethodChannel + EventChannel
- [x] `UiKitView` 透明 overlay（CoreGraphics 渲染，Metal shader 待啟用）
- [x] 引導相機自動同步輪廓 + 分數；Native 啟用時隱藏 Flutter 重複輪廓

### PR-1 動態輪廓 MVP（Dart 層）
- [x] `PortraitContourExtractor` — 對比度 mask、Moore 邊界追蹤、RDP、弧長重採樣
- [x] `SubjectSilhouetteService` — 優先真實輪廓，失敗 fallback 模板
- [x] `AlignmentOverlayState` — 三態著色（白 &lt;50 / 黃 50–84 / 綠 ≥85）
- [x] `PhotoFramePainter` — 依 `alignmentScore` 動態 stroke/glow
- [x] 引導相機 overlay 傳入 `coaching?.poseScore`
- [x] `ContourSmoother.resampleClosedContour` — RDP 後補點至平滑曲線

### 部署
- [x] iPhone release 安裝（裝置 `00008130-001A01610AA0001C`）
- [x] Proxy URL：`https://photo-coach-gemini-proxy.marsh-year.workers.dev/gemini`
- [ ] **GEMINI_API_KEY 未設定** → 雲端分析目前走本機

---

## Poze 級路線圖（尚未實作）

| PR | 內容 | 狀態 |
|----|------|------|
| PR-1 | Dart 離線範例輪廓 + 三態 overlay | **完成** |
| PR-2 | Native Vision 分割 + C++ RDP + PlatformChannel | **完成** |
| PR-3 | Metal 60fps 渲染（shader 已備，待啟用 Toolchain） | 進行中 |
| PR-4 | 狀態機 A/B/C + Haptic + 自動快門 | **完成** |
| PR-5 | Kalman 輪廓穩定 + 低光骨架降級 | **完成** |
| PR-6 | 獨立 `AVCaptureSession` 預覽管線 | 待做 |

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
6. [ ] **輪廓三態** — 分數 &lt;50 白、50–84 黃、≥85 綠
7. [ ] **真實輪廓** — 上傳高對比人像 → 輪廓貼合主體（非模板）
8. [ ] **Haptic** — 進入黃/綠階段有震動回饋
9. [ ] **自動快門** — 得分 ≥85 自動拍照（可關閉 `poseSilhouetteAutoCaptureEnabledProvider`）
10. [ ] **低光降級** — 分數極低時改骨架虛線
11. [ ] 啟用 Gemini 後 → 分析來源顯示 proxy/gemini

### P2 — 待規劃
- [ ] 合照「點選主角」UI
- [ ] Android `CameraImage` → `InputImage` 直通
- [ ] 共用單一 `PoseDetector` 實例
- [ ] 爬蟲 pipeline + 遠端 trendy catalog
- [ ] 陀螺儀 + 加速度計融合（Madgwick）
- [ ] `AlignmentOverlayState.toastForPhase` 接入 live coaching UI

---

## 關鍵檔案

| 用途 | 路徑 |
|------|------|
| 交接 | `tool/SESSION_HANDOFF.md` |
| 部署 | `tool/deploy_iphone_with_proxy.sh` |
| Native 輪廓 | `ios/Runner/PoseSilhouette/` |
| Dart Platform | `lib/features/pose/platform/pose_silhouette_platform_service.dart` |
| 輪廓提取 | `lib/features/reference/services/portrait_contour_extractor.dart` |
| 輪廓服務 | `lib/features/reference/services/subject_silhouette_service.dart` |
| 三態著色 | `lib/features/pose/services/alignment_overlay_state.dart` |
| 疊加繪製 | `lib/features/frames/presentation/photo_frame_painter.dart` |
| 弧長重採樣 | `lib/core/utils/contour_smoother.dart` |

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