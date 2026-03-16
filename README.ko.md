<div align="center">

# IronCensor

### 철면어사 · 인지 에이전트 프레임워크

#### Claude Code를 수동적 편집기에서 자율적 지능형 엔지니어로 단련합니다

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Linux-blue.svg)]()
[![Claude Code](https://img.shields.io/badge/Claude%20Code-Compatible-green.svg)]()
[![Zero Code](https://img.shields.io/badge/Zero%20Code-Pure%20Config-orange.svg)]()
[![Hooks](https://img.shields.io/badge/Hooks-8%20Lifecycle-purple.svg)]()

[中文](./README.md) | [English](./README.en.md) | [日本語](./README.ja.md)

**The Iron Censor that never sleeps. 철면무사, 영원불면.**

**저자: [Tangdan / 汤旦](https://github.com/tangdan2204)**

</div>

---

## 왜 IronCensor인가?

> **한 줄 설치, 제로 코드 침입. Claude Code에 완전한 인지 사이클, 보안 거버넌스, 자기 진화 능력을 부여합니다.**

```bash
git clone https://github.com/tangdan2204/claudecode-IronCensor.git && cd ironcensor && ./install.sh
```

### 3가지 핵심 차별화 요소

**🧠 인지 사이클** — 단순 명령 실행이 아닌, 엔지니어처럼 사고합니다

모든 작업은 **인식→사고→계획→실행→검증→반성→진화**의 완전한 7단계 폐쇄 루프를 거칩니다. AI는 위험을 능동적으로 감지하고, 전문 도구를 호출하여 분석하며, 과학적 계획을 수립하고, 작업하면서 검증하고, 완료 후 반성하고 진화합니다.

**🛡️ 심층 방어** — 8계층 보안 아키텍처, 3개 하드 인터셉트 계층 우회 불가

`settings.json deny`(24개 규칙) → `safety-guard.sh`(26개 탐지) → `sensitive-filter.sh`(24종 필터)의 3계층 exit 2 하드 인터셉트가 보안 핵심을 구성합니다. AI는 이를 우회할 수 없습니다. 추가 5개 보조 모니터링 계층이 심층 중복성을 형성합니다.

**📈 자기 진화** — 사용할수록 강해지며, 유사 문제 발생 빈도가 점감

4계층 단계적 학습: 수정 즉 감사 → 반복 시 글로벌 감사 발동 → 심층 반성 → 유추 추론. 1회 수정→기록, 2회→규칙 승격, 3회→자동화 탐지 제안.

---

## 유사 도구와의 비교

| 차원 | IronCensor | everything-claude-code | oh-my-claudecode | Trail of Bits Config | IronCurtain |
|------|------------|------|------|------|------|
| **인지 사이클** | ✅ 7단계 완전 루프 | ❌ 없음 | ❌ 없음 | ❌ 없음 | ❌ 없음 |
| **보안 계층 수** | ✅ 8계층(3계층 하드) | ⚠️ 가이드만 | ⚠️ 기본 Hook | ✅ 프로덕션급 | ✅ 헌법 엔진 |
| **자기 학습/진화** | ✅ 4계층 단계적 | ❌ 없음 | ❌ 없음 | ❌ 없음 | ❌ 없음 |
| **거버넌스** | ✅ 삼성제 견제 | ❌ 없음 | ⚠️ Agent 편성 | ❌ 없음 | ⚠️ 정책 제약 |
| **설치 방식** | 순수 설정(무의존) | 순수 설정 | npm 설치 | 순수 설정 | npm 설치 |
| **멀티 에이전트** | ✅ OMC 호환 | ⚠️ 제한적 | ✅ 네이티브 | ❌ 없음 | ❌ 없음 |
| **컨텍스트 복구** | ✅ 자동 저장/복원 | ❌ 없음 | ⚠️ 기본적 | ❌ 없음 | ❌ 없음 |
| **서킷 브레이커** | ✅ 카운트+시간+하드 중단 | ❌ 없음 | ❌ 없음 | ❌ 없음 | ❌ 없음 |

> **IronCensor는 「인지 사이클 + 보안 거버넌스 + 자기 진화 + 멀티 에이전트 편성」을 동시에 커버하는 유일한 순수 설정 프레임워크입니다.**

---

## 핵심 기능 일람

| 능력 | 설명 | 기존 Claude Code |
|------|------|-----------------|
| **7단계 인지 사이클** | 인식→사고→계획→실행→검증→반성→진화 | 지시→실행→완료 |
| **8계층 심층 방어** | 하드 인터셉트 + 모니터링 + 소프트 제약, AI 우회 불가 | 프롬프트만 |
| **자기 학습 진화** | 오류 추적→글로벌 감사→규칙 강화→자동화 | 학습 메커니즘 없음 |
| **삼성육부 거버넌스** | 결정/심사/실행 분리, 거부권 견제 | 거버넌스 없음 |
| **증거 기반 검증** | 테스트/빌드/lint 실제 출력 제시 필수 | "문제없을 거야" |
| **무인 운전 실행** | 자동 라우팅+자동 감시+자동 서킷 브레이커 | 지속적 인적 개입 필요 |

---

## 아키텍처 개요

```
┌──────────────────────────────────────────────────────────────┐
│                Claude Code 에이전트 시스템                      │
├──────────────────────────────────────────────────────────────┤
│  ┌─ 하드 보안 레이어 (Hooks + settings.json) ──────────┐    │
│  │  Layer 0: settings.json deny (24개 절대 금지 규칙)    │    │
│  │  Layer 1: safety-guard.sh (메타 커맨드 + 위험 작업    │    │
│  │           + 우회 감지)                                │    │
│  │  Layer 2: sensitive-filter.sh (24종 민감 정보 패턴)   │    │
│  │  [exit 2 하드 차단 — AI가 우회할 수 없습니다]          │    │
│  │  규칙 외부화: rules/dangerous-commands.txt            │    │
│  │              rules/sensitive-patterns.txt             │    │
│  └──────────────────────────────────────────────────────┘    │
│  ┌─ 보조 모니터링 레이어 (Hooks) ─────────────────────┐     │
│  │  Layer 3: pre-compact-save.sh    (압축 전 상태 저장)│     │
│  │  Layer 4: post-compact-restore.sh (컨텍스트 복구)   │     │
│  │  Layer 5: post-edit-audit.sh (감사+서킷 브레이커    │     │
│  │           +flock)                                   │     │
│  │  Layer 6: verify-before-stop.sh  (완료 전 4점 검사) │     │
│  └──────────────────────────────────────────────────────┘    │
│  ┌─ 동작 지시 레이어 (CLAUDE.md) ───────────────────────┐   │
│  │  Layer 7: 지능형 OS v1                                │   │
│  │  ├─ 7단계 인지 사이클                                  │   │
│  │  ├─ 삼성육부 거버넌스 프레임워크                        │   │
│  │  ├─ 의사결정 트리 라우팅                               │   │
│  │  └─ 4층 자기 학습 모델                                 │   │
│  └──────────────────────────────────────────────────────┘    │
│  ┌─ 메모리 지속성 레이어 ───────────────────────────────┐   │
│  │  MEMORY.md + recurring-patterns.md + compact-state.md │   │
│  │  edit-audit.log + hook-stats.jsonl                    │   │
│  └──────────────────────────────────────────────────────┘    │
│  ┌─ 설정 허브 레이어 ───────────────────────────────────┐   │
│  │  configs/env.sh (통합 경로/임계값, 한 곳 수정 전체 적용)│   │
│  └──────────────────────────────────────────────────────┘    │
└──────────────────────────────────────────────────────────────┘
```

---

## 주요 혁신 포인트

### 1. 7단계 인지 사이클 — "실행기"에서 "엔지니어"로

모든 작업이 완전한 인지 루프를 거칩니다: **인식**(의도 인식 + 컨텍스트 인식 + 메모리 호출 + 리스크 예측) → **사고**(전문 에이전트 능동적 호출) → **계획**(의사결정 트리로 최적 실행 경로 라우팅) → **실행**(실행하며 테스트 + 3단계마다 보고) → **검증**(테스트/빌드 실제 출력 필수) → **반성**(패턴 검출 + 유추 적용) → **진화**(수정 업그레이드 체인: 1회→기록, 2회→규칙, 3회→자동화).

### 2. 8층 심층 방어

- **Layer 0-2 (하드 차단)**: `settings.json` deny 규칙(24개: rm -rf, mkfs, dd, chmod 777, SSH 키, sudo, eval, force push, curl|bash 등) + `safety-guard.sh`(메타 커맨드 감지 + Base64/heredoc/xargs 우회 감지 + L4 절대 금지 + L3 고위험 + 자격 증명 유출; 규칙 외부화 `rules/dangerous-commands.txt`) + `sensitive-filter.sh`(24종 민감 정보 패턴: API Key/Token/비밀번호/개인 키/JWT/클라우드 자격 증명/DB 연결; 규칙 외부화 `rules/sensitive-patterns.txt`). `exit 2` 사용 — **AI가 우회할 수 없습니다**.
- **Layer 3-6 (보조)**: 상태 보존, 컨텍스트 복구, flock 동시 보호 포함 편집 감사(5회 경고/8회 하드 차단), 완료 전 4점 검사.
- **Layer 7 (소프트 제약)**: CLAUDE.md 동작 지시, L1-L4 보안 분류.

### 3. 삼성육부 거버넌스 (三省六部)

고대 중국 거버넌스 시스템에서 영감:
- **중서성 (의사결정)**: planner, architect, analyst — 방안 기초만
- **문하성 (심사)**: critic, verifier, reviewers — **거부권(봉박)** 보유
- **상서성 (실행)**: executor — 승인된 계획만 실행
- **어사대 (독립 감사)**: safety-guard + sensitive-filter + post-edit-audit + verify-before-stop

### 4. 4층 자기 학습 모델

| 레이어 | 트리거 | 액션 |
|--------|--------|------|
| 수정 즉 감사 | 버그 수정 시 | 같은 파일/모듈에서 유사 문제 검색 |
| 전역 감사 | 동일 패턴 ≥2회 | 전체 프로젝트 Grep + 방어 규칙 생성 |
| 깊은 반성 | 동일 패턴 ≥3회 | 근본 원인 분석 + 규칙 강화 + 자동화 제안 |
| 유추 적용 | 패턴 성숙 | 유추 추론 + 프로젝트 간 이전 |

---

## 실제 시나리오 비교: Before vs After

### 시나리오 1: API 버그 수정

**일반 Claude Code:**
```
사용자: "/api/users의 500 에러를 수정해줘"
Claude: 파일 열기 → 에러 발견 → 한 줄 수정 → "완료, 문제없을 거예요"
결과: 테스트 미실행, 새 버그 도입; /api/orders에도 같은 문제가 있지만 아무도 발견하지 못함
```

**이 설정을 적용한 Claude Code:**
```
사용자: "/api/users의 500 에러를 수정해줘"
Claude:
  [인식] recurring-patterns.md 읽기 → API 레이어에서 P003 패턴 발견
  [사고] explore agent로 관련 파일 탐색 + debugger로 근본 원인 분석
  [계획] "3개 파일 관련, 중간 경로" → 사용자에게 계획 제시
  [실행] executor 수정 + 변경마다 테스트 → quality-reviewer 감사
  [검증] ✅ npm test 통과 ✅ tsc 클린 ✅ reviewer 승인
  [반성] 프로젝트 전체 Grep → /api/orders에서 동일 문제 발견 → 함께 수정
  [진화] recurring-patterns.md + 지식 그래프에 기록, 다음에 자동 경고
```

### 시나리오 2: 인증 모듈 리팩토링

**일반 Claude Code:**
```
사용자: "인증 모듈을 리팩토링해줘"
Claude: 대규모 변경 시작 → 15개 파일 변경 → 빌드 실패 → 반복 수정 → 악화
     → SSH 키가 로그에 실수로 노출됨 → 보안 사고
```

**이 설정을 적용한 Claude Code:**
```
사용자: "인증 모듈을 리팩토링해줘"
Claude:
  [계획] >10 파일 → 복잡 경로 → ralplan 합의 계획
         → planner + architect + critic 삼자 검토
         → 드라이런 검증: executor 시뮬레이션 + debugger 리스크 예측
  [실행] 병렬 디스패치: executor(핵심) ∥ test-engineer(테스트) ∥ security-reviewer
         → 3단계마다 진행 보고 → 5단계: 키 유출 위험 감지
         → sensitive-filter.sh 하드 블록 (exit 2) → 쓰기 방지
  [검증] 전체 테스트 + 빌드 + ReACT 심층 검토 (5라운드)
  [반성] Agent 인터뷰 → 테스트 커버리지 사각지대 발견 → 경계 테스트 추가
```

---

## 빠른 시작

```bash
git clone https://github.com/tangdan2204/claudecode-IronCensor.git
cd ironcensor
chmod +x install.sh && ./install.sh
```

필수 조건: macOS/Linux, Claude Code CLI, `jq` (`brew install jq`)

### 수동 설치

```bash
# 1. 디렉토리 생성
mkdir -p ~/.claude/hooks ~/.claude/logs ~/.claude/rules ~/.claude/configs

# 2. 설정 배포
cp configs/settings.json ~/.claude/settings.json
cp configs/hooks.json ~/.claude/hooks/hooks.json
cp configs/CLAUDE.md ~/.claude/CLAUDE.md
cp configs/env.sh ~/.claude/configs/env.sh

# 3. Hook 스크립트 배포
cp hooks/*.sh ~/.claude/hooks/
chmod +x ~/.claude/hooks/*.sh

# 4. 규칙 파일 배포 (보안 규칙 외부화)
cp rules/*.txt ~/.claude/rules/

# 5. 메모리 파일 배포
mkdir -p ~/.claude/projects/-Users-$(whoami)/memory
cp memory/*.md ~/.claude/projects/-Users-$(whoami)/memory/

# 6. 검증
claude  # Claude Code 시작, 인지 사이클 활성화 확인
```

자세한 단계는 [QUICK-START.md](./QUICK-START.md)를 참조하세요.

---

## 파일 구조

```
IronCensor/
├── README.md                           # 中文
├── README.en.md                        # English
├── README.ja.md                        # 日本語
├── README.ko.md                        # 한국어
├── AUDIT-REPORT.md                     # 3차원 아키텍처 감사 보고서
├── PRD.md                              # 제품 요구사항 문서
├── RESEARCH-REPORT.md                  # 6차원 과학 연구 보고서
├── QUICK-START.md                      # 빠른 시작 가이드
├── ONE-LINER.md                        # 원라이너 설정 프롬프트
├── install.sh                          # 자동 설치 스크립트
├── LICENSE                             # MIT 라이선스
├── configs/
│   ├── settings.json                   # 권한 설정 + 24개 deny 규칙
│   ├── hooks.json                      # Hook 라우팅 테이블 (7개 라이프사이클)
│   ├── CLAUDE.md                       # 핵심 행동 지시 (지능형 OS v1)
│   └── env.sh                          # 통합 경로/임계값 설정 (모든 Hook 공용)
├── rules/
│   ├── dangerous-commands.txt          # 위험 명령 정규식 규칙 (26개, 동적 로딩)
│   └── sensitive-patterns.txt          # 민감 정보 검출 규칙 (24종, 동적 로딩)
├── hooks/
│   ├── safety-guard.sh                 # Bash 명령 보안 방어 (exit 2 차단)
│   ├── sensitive-filter.sh             # 민감 정보 필터 (exit 2 차단)
│   ├── pre-compact-save.sh             # 압축 전 상태 저장
│   ├── post-compact-restore.sh         # 압축 후 컨텍스트 복구
│   ├── post-edit-audit.sh              # 편집 감사 + 서킷 브레이커 + flock
│   ├── verify-before-stop.sh           # 완료 전 4점 검사
│   └── macos-notify.sh                 # macOS 데스크톱 알림
└── memory/
    ├── MEMORY.md                       # 핵심 메모리 인덱스 템플릿
    └── recurring-patterns.md           # 반복 패턴 추적 템플릿
```

---

## 설계 철학

### SSOT 원칙

모든 규칙은 **한 번만 정의**됩니다 (Single Source of Truth):
- 보안 규칙 외부화: `rules/` 디렉토리 (스크립트가 동적 로딩, 확장 시 코드 수정 불필요)
- 경로 및 임계값 통합: `configs/env.sh` (한 곳 수정으로 전체 적용)
- 행동 지시: CLAUDE.md에 정의
- 메모리 파일: 포인터 참조 사용 (복사 아님)
- 파일 간 규칙 중복 및 불일치 방지

---

## 라이선스

[MIT License](./LICENSE)

---

<div align="center">

**설계 및 유지관리: [Tangdan / 汤旦](https://github.com/tangdan2204)**

*The Iron Censor that never sleeps. 철면무사, 영원불면.*

</div>
