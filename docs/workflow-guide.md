# Workflow Guide — 실전 사용 가이드

> 이 문서는 ClaudeStarter를 **실제로 어떻게 사용하는지**를 시나리오 중심으로 설명합니다.
> 셋업 가이드는 `README.md`의 30초 시작 가이드를, 환경 설정은 `docs/setup-guide.md`를 참조하세요.

---

## 0. 이 문서의 목적

| 누가 | 언제 | 무엇을 알게 되는가 |
|---|---|---|
| 신규 팀원 | 온보딩 시 | 일일 작업 흐름 + 도구 사용법 |
| 본인 (6개월 후) | "그때 어떻게 했더라?" 의문 시 | 과거 결정 컨텍스트 + 표준 작업 흐름 |
| 외부 협업자 | 처음 ClaudeStarter 사용 시 | 시나리오별 대응 방법 |

---

## 1. 전체 워크플로우 한눈에

### 큰 그림 (PRD → 배포)

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   PRD 작성                                                  │
│      ↓                                                      │
│   prd-to-roadmap 에이전트 → ROADMAP.md 생성                 │
│      ↓                                                      │
│   (선택) phase-planner → Phase 분할                          │
│      ↓                                                      │
│   sprint-planner → sprint{n}.md 계획                        │
│      ↓                                                      │
│   ┌─── 개발 루프 (Sprint 마다 반복) ────┐                   │
│   │                                      │                   │
│   │   코드 작성 (AI 보조)                │                   │
│   │      ↓                               │                   │
│   │   14개 자가 체크포인트 자동 점검     │                   │
│   │      ↓                               │                   │
│   │   sprint-close → PR 생성             │                   │
│   │      ↓                               │                   │
│   │   sprint-review → 코드 리뷰          │                   │
│   │      ↓                               │                   │
│   │   develop 머지                       │                   │
│   │                                      │                   │
│   └──────────────────────────────────────┘                   │
│      ↓                                                       │
│   deploy-prod → main 배포 + CV 검증                          │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### 핵심 도구들의 역할

| 도구 | 역할 | 호출 시점 |
|---|---|---|
| **에이전트 8개** | 큰 단계의 자동 수행 (계획·리뷰·배포) | 명시적 호출 |
| **스킬 11개** | 각 작업의 사고 패턴 (보안·디버깅 등) | 자동 배정 + 명시 호출 |
| **Hook 4개** | 위험·실수 자동 차단 | 자동 (백그라운드) |
| **14개 체크포인트** | 응답마다 자가 점검 | 자동 (응답 마지막) |

---

## 2. 새 프로젝트 시작하기

### 4단계 (총 30분~1시간)

| 단계 | 작업 | 소요 |
|---|---|---|
| 1 | 템플릿 클론 + SETUP 실행 | 5분 |
| 2 | PRD.md 작성 | 15~30분 |
| 3 | `prd-to-roadmap`으로 ROADMAP 생성 | 5분 |
| 4 | `sprint-planner`로 첫 스프린트 시작 | 5분 |

### Step 1 — 클론 + SETUP

```bash
# 템플릿 클론 (새 프로젝트명으로)
git clone https://github.com/jaesung0208/ClaudeStarter.git my-new-project
cd my-new-project

# 원본 git 히스토리 제거 (내 프로젝트로 새로 시작)
rm -rf .git
git init && git branch -M main

# SETUP 실행
chmod +x SETUP.sh
./SETUP.sh
```

**SETUP에서 묻는 핵심 질문 — Spec 결정 방법 3가지:**

| 모드 | 적합한 상황 | 추천 |
|---|---|---|
| 1) 직접 선택 | 스택이 이미 명확 | 빠름 |
| **2) 유형 기반** | 풀스택/데이터파이프라인 등 유형만 정해짐 | ⭐ 첫 프로젝트 추천 |
| 3) PRD 기반 | 무엇을 만들지 미정 | `spec-recommender`가 분석·추천 |

### Step 2 — PRD.md 작성

```bash
claude  # Claude Code 실행
```

Claude Code 안에서:
```
@PRD.md 견본을 참고해서 새로 작성해줘.
프로젝트: [한 줄 설명]
사용자: [누구]
핵심 기능 3개: ...
보안 요구: ISMS 적용 여부
```

**필수 포함 항목:**
- 목적 — 왜 만드는가
- 사용자 — 누가 쓰는가
- 핵심 기능 3~5개
- 비기능 요구사항 — 보안·성능·동시접속
- 제약 — 마감일·인력·예산

### Step 3 — ROADMAP 생성

```
prd-to-roadmap 에이전트로 PRD를 ROADMAP.md로 변환해줘.
```

→ AI가 자동으로 4~8개 스프린트로 분할해서 `ROADMAP.md` 생성.

### Step 4 — 첫 스프린트 시작

```
sprint-planner 에이전트로 sprint1을 계획해줘.
```

→ `docs/sprint/sprint1.md` 자동 생성 + `sprint1` 브랜치 자동 생성.

---

## 3. 기능 추가하기 — 3가지 케이스

> **핵심 원칙**: PRD.md는 **누적 문서**. 새로 작성하지 않고 **추가/업데이트**합니다.

### 케이스별 의사결정

```
새 기능 추가 요청 들어옴
       │
       ▼
[크기는?]
   │
   ├── 1주 이하  ─────────────► 케이스 A: PRD 수정 없이 바로 sprint
   │
   ├── 1~4주    ─────────────► 케이스 B: PRD에 섹션 추가 + sprint
   │
   └── 1개월+   ─────────────► 케이스 C: PRD + phase-planner 분할
```

### 케이스 A — 작은 기능 (예: "검색 기능 추가")

PRD에 명시 없어도, 기존 PRD가 허용하는 범위면 **PRD 수정 없이 바로 sprint**.

```bash
git checkout develop && git pull
claude
```

```
sprint-planner로 sprint{n}을 계획해줘.
이번 스프린트는 처방 검색 기능 추가야.
조건: 약품명·환자ID로 검색, 응답속도 1초 이내.
```

→ `docs/sprint/sprint{n}.md` 자동 생성 + `sprint{n}` 브랜치 자동 생성.

### 케이스 B — 중간 기능 (예: "알람 시스템 신규")

PRD에 없던 큰 기능 영역이면 **PRD에 섹션 추가**.

**1) PRD.md에 추가 (삭제하지 않고 누적)**

```markdown
## 3. 핵심 기능
- (1) 일일 처방데이터 수집       ← 기존
- (2) 이상값 자동 감지           ← 기존
- (3) 트렌드 대시보드            ← 기존
- (4) 🆕 실시간 알람 시스템      ← 추가
- (5) 🆕 사용자별 알람 구독       ← 추가

## 변경 이력                      ← 권장 추가
- 2026-Q3: 초기 PRD 작성
- 2026-Q4: 알람 시스템 (4·5) 추가
```

**2) ROADMAP 갱신**

```
PRD.md에 알람 시스템을 추가했어.
ROADMAP.md에 이 기능을 위한 새 스프린트를 추가해줘.
```

**3) 새 sprint 시작**

```
sprint-planner로 알람 시스템 첫 스프린트를 계획해줘.
```

### 케이스 C — 큰 기능 (예: "AI 추천 모델 영역")

3+ 스프린트가 필요한 큰 영역이면 **Phase 분할**.

```
phase-planner로 'AI 추천 모델' 영역을 phase2로 정리해줘.
```

→ `docs/phase/phase2.md` 생성 (5개 스프린트로 자동 분할).

```
sprint-planner로 phase2의 sprint1을 계획해줘.
```

---

## 4. PRD.md 관리

### 4-1. 두 개의 PRD.md 구분

같은 이름의 **다른 파일**입니다.

| 위치 | 무엇? | 누가 씀? |
|---|---|---|
| `ClaudeStarter/PRD.md` | **템플릿 (양식 견본)** | 원본이 갖고 있는 가이드 |
| `my-project/PRD.md` | **실제 PRD (내 프로젝트)** | 본인이 직접 작성 |

원본 ClaudeStarter 저장소의 PRD.md는 건드리지 않습니다.

### 4-2. 폴더 구조 진화

#### 초기 (1~3개월, 300~500줄)
```
my-project/
└── PRD.md                          ← 단일 파일로 충분
```

#### 6개월차 (600~800줄)
```
my-project/
├── PRD.md                          ← 인덱스 + 핵심
└── docs/prd/
    └── CHANGELOG.md                ← 변경 이력만 분리
```

#### 1년차 (1000줄+)
```
my-project/
├── PRD.md                          ← 인덱스 (200~400줄)
└── docs/prd/
    ├── CHANGELOG.md
    ├── feature-collection.md       ← 영역별 분리
    ├── feature-detection.md
    └── feature-dashboard.md
```

### 4-3. 분할 시점 신호

| 신호 | 분할 시점 |
|---|---|
| PRD 1000줄 초과 | 영역별 분리 시작 |
| Ctrl+F로 찾기 어려움 | 인덱스 + 분할 |
| 두 명 이상 동시 수정 시 conflict 잦음 | 영역별 분리 |
| AI가 PRD 일부만 봤다고 응답 | 즉시 분할 |
| 1년 전 결정이 현재 이해 방해 | 아카이브 |

### 4-4. 분할 방법

AI에게 직접 요청 가능:
```
PRD.md가 1200줄로 너무 길어졌어.
docs/prd/ 폴더 만들고 기능 영역별로 분리해줘.
PRD.md는 인덱스 역할만 하도록.
```

> **참고**: 자동 분할 에이전트는 v1.0(2026 Q4)에 추가 예정 (`TEMPLATE-ROADMAP.md` GAP-002 참조).

---

## 5. 자주 발생하는 상황별 대응 ⭐

실전에서 가장 많이 마주치는 시나리오들.

### 🐛 5-1. 버그 발견 (운영 중 긴급)

운영 환경에서 발견된 긴급 버그. 즉시 수정 필요.

```bash
# main 브랜치에서 hotfix 브랜치 분기
git checkout main && git pull
git checkout -b hotfix/[버그-설명]

# 수정 작업
claude
# (코드 수정)

# hotfix-close 에이전트로 마무리
```

```
hotfix-close 에이전트로 이번 핫픽스를 마무리해줘.
```

→ PR 생성 + develop 역머지 안내 + 핫픽스 문서화 자동 처리.

### 🐛 5-2. 버그 발견 (sprint 진행 중)

현재 sprint 중에 발견된 버그. **별도 브랜치 만들지 않음**.

- 현재 sprint{n} 브랜치 안에서 수정
- sprint Task에 버그 수정 항목 추가
- sprint-close 시 정상 PR로 포함

### 💡 5-3. 회의에서 새 요구사항 추가

상사·고객에게 새 요구사항이 들어왔을 때.

**판단 흐름**:
```
요구사항 크기 판단
   │
   ├── 작음 (1주 이하)
   │   → PRD 수정 X
   │   → 다음 sprint-planner에 직접 전달
   │
   ├── 중간 (1~4주)
   │   → PRD에 섹션 추가
   │   → ROADMAP 갱신 요청
   │   → 새 sprint-planner 호출
   │
   └── 큼 (1개월+)
       → PRD에 큰 영역 추가
       → phase-planner로 Phase 분할
       → 우선순위 회의 후 sprint 시작
```

### 🛑 5-4. AI hook이 작업 차단

Claude Code가 작업 중 hook 차단 메시지 출력 시:

```
🚫 [bash-guard · CLAUDE.md 1-2] DB DDL 직접 실행이 차단됩니다.
   차단된 명령어: psql -c "DROP TABLE users"
```

**대응**:
1. 메시지의 `[CLAUDE.md X-Y]` 또는 `[secure-coding §Y]` 참조
2. 해당 룰 파일에서 위반 사유 확인
3. 권고된 대안으로 수정 (예: 마이그레이션 스크립트 사용)
4. 정당한 사유로 hook을 우회해야 한다면 사용자에게 명시적 허가 요청

### 📄 5-5. PRD에 없는 작은 개선 (UI 변경·버그 수정 등)

작은 개선은 PRD 수정 불필요. sprint-planner에 직접 요구:

```
sprint-planner로 sprint{n}을 계획해줘.
이번 스프린트는 다음 개선 작업:
- 대시보드 차트 색상 통일
- 로그인 에러 메시지 한국어로
- 페이지 로딩 스피너 추가
```

### ⏸️ 5-6. Sprint 중 우선순위 변경

진행 중인 sprint를 중단하고 새 작업으로 전환해야 할 때.

```
sprint-close 에이전트로 sprint{n}을 현재 상태에서 마무리해줘.
미완료 항목은 backlog로 이전.

(이후)
sprint-planner로 sprint{n+1}을 계획해줘.
이번에는 [새 우선순위] 작업이야.
```

→ sprint-close가 미완료 Task를 다음 sprint의 backlog로 자동 이전.

### 🔍 5-7. AI가 잘못된 코드 생성

응답 마지막 14개 체크포인트에서 ⚠️ 또는 ❌가 있을 때:

```
체크포인트 8번(테스트 코드)이 ❌인데 즉시 수정해줘.
정상+오류+엣지케이스 테스트 케이스를 추가.
```

**자주 발생하는 ⚠️/❌**:
- 8번 (테스트 코드 누락) → 가장 빈번
- 9번 (함수 50줄 초과) → 분리 요청
- 10번 (console.log 잔존) → 로거로 변경 요청
- 11번 (silent catch) → 로그 출력 추가 요청

### 🤔 5-8. 6개월 후 "왜 이렇게 짰지?" 의문

과거 결정 컨텍스트 추적 방법:

| 정보 | 위치 |
|---|---|
| **기능이 추가된 사유** | `PRD.md` 변경 이력 + 해당 섹션 |
| **스프린트별 작업 내용** | `docs/sprint/sprint{n}.md` |
| **코드 변경 사유** | `git log --oneline` + 해당 커밋 메시지 |
| **PR 리뷰 내용** | GitHub Pull Requests |
| **스프린트 회고** | `docs/sprint-retrospectives/sprint{n}.md` |
| **배포 이력** | `docs/deploy-history/` |

---

## 6. 브랜치 전략 + 머지

### 브랜치 구조

```
main         ← 운영 (deploy-prod 에이전트만 머지)
  │
  ├── develop          ← 통합 브랜치 (모든 sprint 머지)
  │     │
  │     ├── sprint1    ← 완료 후 develop 머지
  │     ├── sprint2    ← 완료 후 develop 머지
  │     └── sprint3    ← 현재 작업
  │
  └── hotfix/xxx       ← 긴급 패치 (main에서 분기, 양쪽 머지)
```

### 머지 규칙

| from → to | 누가 | 어떻게 |
|---|---|---|
| `sprint{n}` → `develop` | 본인 | self-merge OK (단 14개 체크포인트 자체 점검 필수) |
| `develop` → `main` | `deploy-prod` 에이전트 | 자동 + CV 검증 |
| `hotfix/xxx` → `main` | `hotfix-close` 에이전트 | 자동 |
| `hotfix/xxx` → `develop` | `hotfix-close` 에이전트 | 역머지 자동 안내 |

### 머지 전 자가 점검 필수

PR 생성 시 응답 마지막 14개 체크포인트가 자동 출력됩니다. ⚠️/❌가 있으면 머지 금지.

---

## 7. 에이전트 호출 방법

### 호출 패턴

기본 형식:
```
[에이전트명] 에이전트로 [작업 설명].
조건: ...
참조: @[관련 파일]
```

### 에이전트별 호출 예시

```
# 새 프로젝트 시작 단계
prd-to-roadmap 에이전트로 PRD를 ROADMAP으로 변환해줘.

# 큰 영역 분할
phase-planner 에이전트로 'AI 추천 모델' 영역을 phase2로 정리해줘.

# 스프린트 계획
sprint-planner 에이전트로 sprint3을 계획해줘.
이번엔 알람 시스템 백엔드 API 작업.

# 권장 스택 추천 (PRD 기반)
spec-recommender 에이전트로 우리 PRD에 맞는 스택을 추천해줘.

# 스프린트 마무리
sprint-close 에이전트로 sprint3을 마무리해줘.

# 코드 리뷰 + 회고
sprint-review 에이전트로 sprint3을 리뷰해줘.

# 프로덕션 배포
deploy-prod 에이전트로 develop을 main에 배포해줘.

# 긴급 핫픽스
hotfix-close 에이전트로 이번 핫픽스를 마무리해줘.
```

### 에이전트 모델 구분

| 모델 | 특징 | 어느 에이전트? |
|---|---|---|
| **Opus** | 계획·전략 (느림·정확) | prd-to-roadmap, spec-recommender, phase-planner, sprint-planner |
| **Sonnet** | 실행·검증 (빠름·실용) | sprint-close, sprint-review, deploy-prod, hotfix-close |

---

## 8. 문제 해결 (FAQ)

### Q1. SETUP.sh가 권한 거부로 실행 안 됨
```bash
# Windows Git Bash 또는 Mac/Linux
bash SETUP.sh  # 직접 호출
# 또는
chmod +x SETUP.sh && ./SETUP.sh
```

### Q2. Claude Code가 에이전트를 못 찾음
- 작업 디렉토리가 프로젝트 루트인지 확인
- `.claude/agents/` 폴더 존재 확인
- Claude Code 재시작

### Q3. Hook이 갑자기 차단하기 시작함
- 정상 동작 — 시크릿/DDL/민감정보 감지
- 메시지의 `[CLAUDE.md X-Y]` 참조하여 사유 확인
- 정당한 사유면 사용자가 명시적으로 허가 의사 전달

### Q4. PRD에 변경 이력을 안 적어도 되나?
- 단기 프로젝트(3개월 이하): 생략 가능
- 중기 이상(6개월+): **강력 권장** — 6개월 후 본인을 위해서

### Q5. sprint{n}.md를 직접 수정해도 되나?
- 가능 — Task 추가/수정/순서 변경 등 직접 가능
- 단 sprint-close 시 사용자 변경분이 자동 반영됨

### Q6. 한국어 응답이 영어로 나오는 경우
- `CLAUDE.md`의 "언어 규칙" 섹션 확인
- 개인 `userPreferences`에 한국어 강제 설정 추가

### Q7. 기존 운영 프로젝트에 적용 시 기존 코드가 변경되나?
- **아니요** — `.claude/`, `CLAUDE.md`, `scripts/`만 복사
- 기존 코드는 무변경 — 신규 작업부터 표준 룰 적용

### Q8. v0.5와 v1.0의 차이는?
- v0.5: 현재 — 기본 기능 + 다중 스택 + 14개 자가 체크포인트
- v1.0: 2026 Q4 예정 — PRD 자동 관리 + 회사 환경 검증 완료
- 상세: `TEMPLATE-ROADMAP.md`

---

## 9. AI와 대화하는 좋은 방법

### 좋은 요청 패턴

| 요소 | 좋은 예 | 나쁜 예 |
|---|---|---|
| **목표 명시** | "사용자 인증 API를 추가해줘" | "뭔가 해줘" |
| **컨텍스트 제공** | "@PRD.md 의 3번 기능 구현 시작" | "그거 하자" |
| **제약 조건** | "응답 1초 이내, JWT 사용" | (제약 없음) |
| **파일 참조** | "@docs/sprint/sprint3.md 참고" | 그냥 설명만 |
| **승인 흐름** | "TODO 리스트 먼저 보여주고 진행" | 바로 코드 작성 |

### 효과적인 프롬프트 예시

```
@PRD.md 3번 기능(이상값 자동 감지) 구현 시작.

조건:
- 일 100만 건 처리 가능
- 이상값 정의는 사용자가 룰로 등록 가능
- 알람은 슬랙으로 전송

진행 전 TODO 리스트 먼저 보여주고 승인받아 진행.
```

### 응답 마지막 14개 체크포인트 활용

매 응답 마지막에 14개 체크포인트가 자동 출력됩니다.
- ✅ 통과: 그대로 진행
- ⚠️ 주의: 사유 확인 후 결정
- ❌ 위반: 즉시 수정 요청

### 컨텍스트 관리

긴 대화 진행 시:
- 20턴 이상 길어지면 `/compact` 사용
- 새 기능 작업 시작할 때 `/clear`로 깨끗하게 시작

### 막힐 때

| 상황 | 대응 |
|---|---|
| AI가 잘못된 방향으로 감 | "잠깐, 다시 시작. 이건 X가 목적이야" |
| 같은 실수 반복 | `loop-detection` 스킬이 자동 동작 — 그래도 반복되면 새 세션 시작 |
| 너무 큰 작업으로 보임 | "이 작업을 5단계로 나눠줘. 1단계만 먼저 보여줘" |

---

## 참고 문서

| 문서 | 내용 |
|---|---|
| [README.md](../README.md) | 30초 시작 가이드 + 전체 개요 |
| [CLAUDE.md](../CLAUDE.md) | AI 행동 규칙 + 14개 자가 체크포인트 |
| [docs/setup-guide.md](setup-guide.md) | 환경 설정 + Claude Code 개인 설정 |
| [docs/prompt-guide.md](prompt-guide.md) | 프롬프트 작성 상세 가이드 |
| [docs/build-commands.md](build-commands.md) | 스택별 빌드 명령 매핑 |
| [docs/dev-process.md](dev-process.md) | 개발 프로세스 + 코드 리뷰 |
| [TEMPLATE-ROADMAP.md](../TEMPLATE-ROADMAP.md) | ClaudeStarter 자체 발전 로드맵 |
| [.claude/skills/secure-coding.md](../.claude/skills/secure-coding.md) | ISMS 보안 체크리스트 |
| [.claude/rules/sprint-workflow.md](../.claude/rules/sprint-workflow.md) | 브랜치 전략 + 스프린트 규칙 |

---

## 변경 이력

- 2026-Q3: 초안 작성 (워크플로우 + 시나리오 8가지 + FAQ)
