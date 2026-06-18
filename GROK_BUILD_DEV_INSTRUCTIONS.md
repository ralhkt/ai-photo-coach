# 【Grok Build 開發指令】AI Photo Coach App - MVP 開發任務

**項目目標**：使用 Flutter 開發一個跨平台（iOS & Android）實時 AI 攝影教練 App，重點為 on-device 低功耗運行。必須先完成 MVP。

**核心要求**：

- 純 on-device AI（無 cloud 依賴，除非 optional analytics）。
- 電池友好（10 分鐘使用 < 7% 耗電，中階機）。
- 良好 UI/UX（非侵入式 overlays + prompts）。
- 支援英/繁中。

## MVP 必須功能

1. Real-time Camera 畫面 + AR 支援。
2. Dynamic composition overlays（Rule of Thirds, Golden Ratio 等，AI 自動選擇）。
3. Real-time framing guidance（文字 + 箭頭提示，如 "Lower angle 10°"）。
4. Semantic detection（簡單主體 + 背景分類）。
5. Scene stabilization（使用 perceptual hashing 避免頻繁分析）。
6. Basic aesthetic scoring（NIMA-like）。
7. Session summary（拍完後簡單 feedback）。
8. Onboarding + Settings（voice toggle、語言、prompt 強度）。

## 技術規格（必須遵守）

- **Framework**：Flutter 3.24+。
- **State**：Riverpod。
- **Camera**：camera plugin + platform channels。
- **AR**：ar_flutter_plugin 或自建（iOS ARKit + Android ARCore）。
- **ML**：TensorFlow Lite（Android）+ Core ML Delegate（iOS）。Models：MobileNetV3 / EfficientNet-Lite + NIMA aesthetic model（Quantized INT8，Inference < 150ms）。
- **Scene Change**：pHash 或 frame difference。
- **Project Structure**：按 v3.0 建議（core / features / models 等）。
- **Performance**：真機測試必須達標。

**交付物**：每個 Phase 結束後提供可運行代碼 + README。

## 開發階段建議

1. Project setup + Camera + basic overlays。
2. AR integration + scene stabilization。
3. AI model integration + guidance logic。
4. Polish UI/UX + session summary。
5. Testing + optimization。