<div align="center">

# IronCensor

### 鉄面御史 · 認知エージェントフレームワーク

#### Claude Code を受動的エディタから自律型インテリジェントエンジニアへ鍛造する

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green.svg)]()
[![Zero Code](https://img.shields.io/badge/Zero%20Code-Pure%20Config-orange.svg)]()
[![Hooks](https://img.shields.io/badge/Hooks-8%20Lifecycle-purple.svg)]()

[中文](./README.md) | [English](./README.en.md) | [한국어](./README.ko.md)

**The Iron Censor that never sleeps. 鉄面無私、永不休眠。**

**著者: [Tangdan / 汤旦](https://github.com/tangdan2204)**

</div>

---

## なぜ IronCensor を選ぶのか？

> **ワンラインインストール、ゼロコード侵入。Claude Code に完全な認知サイクル、安全ガバナンス、自己進化能力を付与します。**

```bash
git clone https://github.com/tangdan2204/claudecode-IronCensor.git && cd ironcensor && ./install.sh
```

### 3つのコア差別化要因

**🧠 認知サイクル** — コマンド実行だけでなく、エンジニアのように思考する

すべてのタスクは **知覚→思考→計画→実行→検証→反省→進化** の完全な7段階クローズドループを経ます。AIはリスクを能動的に感知し、専門ツールを呼び出して分析し、科学的な計画を立て、作業しながら検証し、完了後に反省して進化します。

**🛡️ 多層防御** — 8層セキュリティアーキテクチャ、3層のハードインターセプトはバイパス不可

`settings.json deny`（24ルール）→ `safety-guard.sh`（26検出）→ `sensitive-filter.sh`（24フィルター）の3層 exit 2 ハードインターセプトがセキュリティコアを構成。AIはこれをバイパスできません。さらに5層の補助監視が縦深冗長性を形成します。

**📈 自己進化** — 使うほど強くなり、同類問題の発生頻度が漸減

4層段階的学習：修正即監査 → 繰り返しでグローバル監査発動 → 深層反省 → 類推推論。1回の修正→記録、2回→ルール昇格、3回→自動化検出を提案。

---

## 同類ツールとの比較

| 次元 | IronCensor | everything-claude-code | oh-my-claudecode | Trail of Bits Config | IronCurtain |
|------|------------|------|------|------|------|
| **認知サイクル** | ✅ 7段階完全ループ | ❌ なし | ❌ なし | ❌ なし | ❌ なし |
| **セキュリティ層数** | ✅ 8層（3層ハード） | ⚠️ ガイドのみ | ⚠️ 基本Hook | ✅ 本番レベル | ✅ 憲法エンジン |
| **自己学習/進化** | ✅ 4層段階的 | ❌ なし | ❌ なし | ❌ なし | ❌ なし |
| **ガバナンス** | ✅ 三省制衡 | ❌ なし | ⚠️ Agent編排 | ❌ なし | ⚠️ ポリシー制約 |
| **インストール** | 純粋設定（依存なし） | 純粋設定 | npm インストール | 純粋設定 | npm インストール |
| **マルチエージェント** | ✅ OMC互換 | ⚠️ 限定的 | ✅ ネイティブ | ❌ なし | ❌ なし |
| **コンテキスト回復** | ✅ 自動保存/復元 | ❌ なし | ⚠️ 基本的 | ❌ なし | ❌ なし |
| **サーキットブレーカー** | ✅ カウント+時間+ハード停止 | ❌ なし | ❌ なし | ❌ なし | ❌ なし |

> **IronCensorは「認知サイクル + 安全ガバナンス + 自己進化 + マルチエージェント編排」を同時にカバーする唯一の純粋設定フレームワークです。**

---

## コア機能一覧

| 能力 | 説明 | 従来の Claude Code |
|------|------|--------------------|
| **7段階認知サイクル** | 知覚→思考→計画→実行→検証→反省→進化 | 指示→実行→完了 |
| **8層多層防御** | ハードインターセプト + 監視 + ソフト制約、AIバイパス不可 | プロンプトのみ |
| **自己学習進化** | エラー追跡→グローバル監査→ルール強化→自動化 | 学習機能なし |
| **三省六部ガバナンス** | 決定/審査/実行の分離、拒否権付き制衡 | ガバナンスなし |
| **証拠駆動型検証** | テスト/ビルド/lint の実際出力を提示必須 | 「問題ないはず」 |
| **無人運転実行** | 自動ルーティング+自動監視+自動サーキットブレーカー | 常時人的介入が必要 |

---

## アーキテクチャ概要

```
┌──────────────────────────────────────────────────────────────┐
│                Claude Code エージェントシステム                 │
├──────────────────────────────────────────────────────────────┤
│  ┌─ ハードセキュリティ層 ────────────────────────────────┐   │
│  │  Layer 0-2: settings.json deny(24ルール)              │   │
│  │    + safety-guard.sh(バイパス検出付き)                 │   │
│  │    + sensitive-filter.sh(24パターン) [exit 2 ハードブロック]│ │
│  └──────────────────────────────────────────────────────┘   │
│  ┌─ 設定ハブ層 ────────────────────────────────────────┐   │
│  │  configs/env.sh — 全 Hook 共有変数・パス統一管理       │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌─ 補助監視層 ─────────────────────────────────────────┐   │
│  │  Layer 3-6: 状態保存 + コンテキスト回復 + 編集監査    │   │
│  │             + サーキットブレーカー + 完了前チェック     │   │
│  └──────────────────────────────────────────────────────┘   │
│  ┌─ 行動指示層 (CLAUDE.md) ─────────────────────────────┐  │
│  │  Layer 7: インテリジェントOS v1                       │  │
│  │  ├─ 7段階認知サイクル                                 │  │
│  │  ├─ 三省六部ガバナンスフレームワーク                   │  │
│  │  ├─ デシジョンツリールーティング                       │  │
│  │  └─ 4層自己学習モデル                                 │  │
│  └──────────────────────────────────────────────────────┘   │
│  ┌─ ルール外部化層 ────────────────────────────────────┐  │
│  │  rules/dangerous-commands.txt                        │  │
│  │  rules/sensitive-patterns.txt                        │  │
│  └──────────────────────────────────────────────────────┘   │
│  ┌─ メモリ永続化層 ─────────────────────────────────────┐  │
│  │  MEMORY.md + recurring-patterns.md + compact-state.md │  │
│  │  + hook-stats.jsonl                                   │  │
│  └──────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────────┘
```

---

## 主要な革新ポイント

### 1. 7段階認知サイクル — 「実行器」から「エンジニア」へ

すべてのタスクが完全な認知ループを通過します：**知覚**（意図認識 + コンテキスト認識 + メモリ呼び起こし + リスク予測）→ **思考**（専門エージェントを能動的に呼び出し）→ **計画**（デシジョンツリーで最適な実行パスにルーティング）→ **実行**（実行しながらテスト + 3ステップごとに報告）→ **検証**（テスト/ビルドの実際出力が必須）→ **反省**（パターン検出 + 他への応用）→ **進化**（修正アップグレードチェーン：1回→記録、2回→ルール化、3回→自動化）。

### 2. 8層多層防御

- **Layer 0-2（ハードブロック）**: `settings.json` deny ルール（24種: sudo/eval/force push/curl|bash 等）+ `safety-guard.sh`（メタコマンド検出 + Base64/heredoc/xargs バイパス検出、L4絶対禁止、L3高リスク、認証情報漏洩、ルール外部化: `rules/dangerous-commands.txt`）+ `sensitive-filter.sh`（24種の機密パターン: 秘密鍵/JWT/クラウド/DB接続文字列 等、ルール外部化: `rules/sensitive-patterns.txt`）。`exit 2` を使用 — **AIはバイパスできません**。
- **Layer 3-6（補助）**: 状態保存、コンテキスト回復、サーキットブレーカー付き編集監査（5回警告/8回ハードブロック + flock 並行保護）、完了前4点チェック。
- **Layer 7（ソフト制約）**: CLAUDE.md 行動指示、L1-L4セキュリティ分類。

### 3. 三省六部ガバナンス

古代中国のガバナンスシステムに着想：
- **中書省（意思決定）**: planner, architect, analyst — 案の起草のみ
- **門下省（審査）**: critic, verifier, reviewers — **拒否権（封驳）** を保持
- **尚書省（実行）**: executor — 承認された計画のみ実行
- **御史台（独立監査）**: safety-guard + sensitive-filter + post-edit-audit + verify-before-stop

### 4. 4層自己学習モデル

| 層 | トリガー | アクション |
|----|----------|-----------|
| 修復即監査 | バグ修正ごと | 同ファイル/同モジュールで類似問題を検索 |
| グローバル監査 | 同パターン≥2回 | プロジェクト全体をGrep + 防御ルール作成 |
| 深い反省 | 同パターン≥3回 | 根本原因分析 + ルール強化 + 自動化提案 |
| 他への応用 | パターン成熟 | 類推推論 + プロジェクト間移行 |

---

## リアルシナリオ比較: Before vs After

### シナリオ1: APIバグの修正

**通常の Claude Code:**
```
ユーザー: "/api/users の500エラーを修正して"
Claude: ファイルを開く → エラーを見つける → 1行変更 → "完了、問題ないはずです"
結果: テスト未実行、新しいバグを導入; /api/orders に同じ問題があるが誰も気づかない
```

**本設定を導入した Claude Code:**
```
ユーザー: "/api/users の500エラーを修正して"
Claude:
  [知覚] recurring-patterns.md を読む → API層でP003パターンを発見
  [思考] explore agent で関連ファイルを特定 + debugger で根本原因分析
  [計画] "3ファイル関連、中等パス" → ユーザーに計画を提示
  [実行] executor が修正 + 変更ごとにテスト実行 → quality-reviewer が監査
  [検証] ✅ npm test 通過 ✅ tsc エラーなし ✅ reviewer 承認
  [反省] プロジェクト全体をGrep → /api/orders に同じ問題発見 → 両方修正
  [進化] recurring-patterns.md + ナレッジグラフに記録、次回自動警告
```

### シナリオ2: 認証モジュールのリファクタリング

**通常の Claude Code:**
```
ユーザー: "認証モジュールをリファクタリングして"
Claude: 大規模変更を開始 → 15ファイル変更 → ビルド失敗 → 修復ループ → 悪化
     → SSH鍵がログに誤って公開されていることを発見 → セキュリティ事故
```

**本設定を導入した Claude Code:**
```
ユーザー: "認証モジュールをリファクタリングして"
Claude:
  [計画] >10ファイル → 複雑パス → ralplan コンセンサス計画
         → planner + architect + critic の三者審査
         → ドライラン検証: executor シミュレーション + debugger リスク予測
  [実行] 並列ディスパッチ: executor(コア) ∥ test-engineer(テスト) ∥ security-reviewer
         → 3ステップごとに進捗報告 → ステップ5: 鍵漏洩リスク検出
         → sensitive-filter.sh ハードブロック (exit 2) → 書き込み防止
  [検証] フルテスト + ビルド + ReACT 深度審査（5ラウンド）
  [反省] Agent インタビュー → テストカバレッジの盲点を発見 → 境界テスト追加
```

---

## ファイル構成

```
IronCensor/
├── README.md                           # 本ファイル（中文）
├── README.en.md                        # English README
├── README.ja.md                        # 日本語 README
├── README.ko.md                        # 한국어 README
├── AUDIT-REPORT.md                     # 三次元アーキテクチャ審査レポート
├── PRD.md                              # プロダクト要件定義書
├── RESEARCH-REPORT.md                  # 六次元科学研究レポート
├── QUICK-START.md                      # クイックスタートガイド
├── ONE-LINER.md                        # ワンライナー構築プロンプト
├── install.sh                          # 自動インストールスクリプト
├── LICENSE                             # MIT ライセンス
├── configs/
│   ├── settings.json                   # 権限設定 + 24 deny ルール
│   ├── hooks.json                      # Hook ルーティングテーブル（7 ライフサイクルイベント）
│   ├── CLAUDE.md                       # コア行動指示（インテリジェントOS v1）
│   └── env.sh                          # 統一パス/閾値設定（全 Hook 共用）
├── rules/
│   ├── dangerous-commands.txt          # 危険コマンド正規表現ルール集（26 条、動的ロード）
│   └── sensitive-patterns.txt          # 機密情報検出ルール集（24 種、動的ロード）
├── hooks/
│   ├── safety-guard.sh                 # Bash コマンド安全防護 (exit 2 ブロック)
│   ├── sensitive-filter.sh             # 機密情報フィルタ (exit 2 ブロック)
│   ├── pre-compact-save.sh             # コンパクト前状態保存
│   ├── post-compact-restore.sh         # コンパクト後コンテキスト回復
│   ├── post-edit-audit.sh              # 編集監査 + サーキットブレーカー + flock 並行保護
│   ├── verify-before-stop.sh           # 完了前4点チェック
│   └── macos-notify.sh                 # macOS デスクトップ通知
└── memory/
    ├── MEMORY.md                       # コアメモリインデックステンプレート
    └── recurring-patterns.md           # 反復問題追跡テンプレート
```

---

## クイックスタート

### 前提条件

- macOS または Linux
- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) インストール済み
- `jq` コマンドラインツール（`brew install jq`）

### 一括インストール

```bash
git clone https://github.com/tangdan2204/claudecode-IronCensor.git
cd ironcensor
chmod +x install.sh && ./install.sh
```

### 手動インストール

```bash
# 1. ディレクトリ作成
mkdir -p ~/.claude/hooks ~/.claude/logs ~/.claude/rules ~/.claude/configs

# 2. 設定ファイルのデプロイ
cp configs/settings.json ~/.claude/settings.json
cp configs/hooks.json ~/.claude/hooks/hooks.json
cp configs/CLAUDE.md ~/.claude/CLAUDE.md
cp configs/env.sh ~/.claude/configs/env.sh

# 3. Hook スクリプトのデプロイ
cp hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# 4. ルールファイルのデプロイ（セキュリティルール外部化）
cp rules/*.txt ~/.claude/rules/

# 5. メモリファイルのデプロイ
mkdir -p ~/.claude/projects/-Users-$(whoami)/memory
cp memory/*.md ~/.claude/projects/-Users-$(whoami)/memory/

# 6. 検証
claude  # Claude Code を起動し、認知サイクルが有効になっているか確認
```

詳細な手順は [QUICK-START.md](./QUICK-START.md) を参照してください。

---

## 設計原則

### SSOT 原則

すべてのルールは**一度だけ定義**（Single Source of Truth）：
- セキュリティルールは `rules/` ディレクトリに外部化（スクリプトが動的ロード、拡張時にコード変更不要）
- パスと閾値は `configs/env.sh` に統一管理（一箇所変更で全体反映）
- 行動指示は CLAUDE.md で定義
- メモリファイルはポインタ参照（コピーではない）
- ファイル間のルール重複と不整合を回避

---

## ライセンス

[MIT License](./LICENSE)

---

<div align="center">

**設計・メンテナンス: [Tangdan / 汤旦](https://github.com/tangdan2204)**

*The Iron Censor that never sleeps. 鉄面無私、永不休眠。*

</div>
