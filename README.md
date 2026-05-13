# ${project_name}
${project_description}

---

## ⚡ 30초 시작 가이드

어떤 상황인지 선택하세요.

---

### 🆕 신규 프로젝트

```bash
# 1. 클론
git clone <repo-url> && cd <repo-name>

# 2. 초기화 마법사 실행
chmod +x SETUP.sh && ./SETUP.sh
```

마법사가 다음을 묻습니다:
- 프로젝트 정보 (이름, 설명, GitHub)
- **Spec 결정 방법** 선택:
  - 1️⃣ 직접 선택 — 스택을 단계별로 직접 고름
  - 2️⃣ 프로젝트 유형 기반 — 6가지 유형 중 선택, 권장 묶음 자동 적용
  - 3️⃣ PRD 기반 추천 — PRD 작성 후 `spec-recommender` 에이전트가 추천
- 보안 수준, Notion 연동 여부

지원 스택:
- **백엔드**: Python(FastAPI/Django/Flask) / TypeScript(NestJS/Express) / Java(Spring Boot) / .NET(ASP.NET Core)
- **프론트엔드**: React(Vite) / Vue 3 / Next.js
- **DB**: PostgreSQL / MS SQL / Snowflake / MySQL / SQLite
- **클라우드**: AWS / Azure / Self-hosted
- **CI**: GitHub Actions / GitLab CI / Azure DevOps

---

### 🔧 기존 운영 중인 프로젝트

기존 코드는 건드리지 않습니다. `.claude/` 폴더와 핵심 파일만 복사합니다.

```bash
# 1. ClaudeStarter 클론 (임시)
git clone <repo-url> ClaudeStarter-temp

# 2. 기존 프로젝트로 이동
cd /your/existing/project

# 3. 핵심 파일만 복사
cp -r ../ClaudeStarter-temp/.claude ./
cp ../ClaudeStarter-temp/CLAUDE.md ./CLAUDE.md
cp -r ../ClaudeStarter-temp/scripts ./scripts
cp ../ClaudeStarter-temp/SETUP.sh ./SETUP.sh
cp ../ClaudeStarter-temp/ARCHITECTURE.md ./ARCHITECTURE.md
chmod +x SETUP.sh scripts/detect-stack.sh scripts/hooks/pre-commit

# 4. SETUP.sh 실행 → "2) 기존 운영 프로젝트" 선택
./SETUP.sh
# 자동 감지가 동작: pom.xml/build.gradle → Java, *.csproj → .NET,
#                  @nestjs/* → NestJS, requirements.txt → Python 등

# 5. 감지 결과 확인 + 보완 입력 → .claude/project-spec.conf 생성 완료

# 6. 임시 폴더 삭제
rm -rf ../ClaudeStarter-temp

# 7. Claude Code 실행
claude
```

> **브랜치 전략 충돌 주의**
> 기존 프로젝트에서 `feature/`, `bugfix/` 등 브랜치를 사용 중이라면
> `.claude/hooks/pretooluse-bash-guard.sh`의 브랜치 명명 규칙을 수정해야 합니다.
> 허용 패턴은 파일 하단 주석 참조.

---

> **공통**: Windows 사용자는 Git Bash 또는 WSL2에서 실행하세요. PowerShell은 `.sh` 미지원.

---

## 핵심 산출물

SETUP.sh 실행 후 다음 파일이 생성됩니다:

| 파일 | 역할 |
|---|---|
| `.claude/project-spec.conf` | **모든 도구가 참조하는 프로젝트 스펙** |
| `.claude/tmp/security-level.conf` | 보안 수준 (hooks 참조) |
| `.mcp.json` | MCP 서버 설정 |
| `.env` | 환경변수 (실제 값 직접 입력) |
| `CLAUDE.md` | AI 협업 지침 (플레이스홀더 치환됨) |
| `README.md` | 프로젝트 README (플레이스홀더 치환됨) |

---

## 템플릿 저장소 구조

```
project-root/
├── .gitignore
├── .env.example                # 샘플 환경 변수
├── .mcp.json                   # MCP 서버 설정 (SETUP이 생성)
├── SETUP.sh                    # ⭐ 초기화 마법사
├── README.md
├── CLAUDE.md                   # ⭐ AI 협업 지침
├── ARCHITECTURE.md             # 변수 안내 + 아키텍처 개요
├── PRD.md                      # 제품 요구사항 정의
├── ROADMAP.md                  # 프로젝트 로드맵
├── CHANGELOG.md                # 변경 이력
├── DEPLOY.md                   # 배포 후 수동 작업 목록
│
├── .claude/
│   ├── project-spec.conf       # ⭐ 프로젝트 스펙 (SETUP이 생성)
│   ├── stack-registry.md       # 지원 스택 카탈로그
│   ├── settings.json           # Claude 권한·훅 설정
│   ├── agents/                 # Claude 에이전트 (8개)
│   ├── commands/               # 슬래시 커맨드
│   ├── hooks/                  # 도구 실행 전후 자동 실행
│   ├── rules/                  # 조건부 자동 로드 규칙
│   │   ├── backend.md          # 디스패처
│   │   ├── frontend.md         # 디스패처
│   │   ├── harness-engineering.md
│   │   ├── sprint-workflow.md
│   │   ├── notion.md
│   │   └── stack/              # 스택별 상세 (선택된 것만 활성)
│   │       ├── backend-python.md
│   │       ├── backend-typescript.md
│   │       ├── backend-java.md
│   │       ├── backend-dotnet.md
│   │       ├── frontend-react.md
│   │       ├── frontend-vue.md
│   │       ├── frontend-nextjs.md
│   │       ├── db-mssql.md
│   │       └── db-snowflake.md
│   └── skills/                 # 호출형 스킬 모음
│
├── .github/workflows/          # GitHub Actions (CI_TOOL=github-actions 시)
│
├── strategy/                   # 전략 지침
├── docs/                       # 산출물 저장
├── scripts/
│   ├── detect-stack.sh         # 기존 프로젝트 스택 자동 감지
│   └── hooks/pre-commit        # 커밋 전 검증 (스택 무관)
```

---

## 에이전트 개요

ClaudeStarter는 **8개의 특화 에이전트**를 포함합니다.

**핵심 흐름**:
```
prd-to-roadmap → (spec-recommender) → (phase-planner) → sprint-planner
  → /sprint-dev → sprint-close → sprint-review → deploy-prod
```

긴급 수정: `hotfix-close`

### 1. prd-to-roadmap (Opus)
PRD(제품 요구사항 문서) 분석 → Agile/스크럼 기반 ROADMAP.md 자동 생성

### 2. spec-recommender (Opus) ⭐ 신규
PRD 기반으로 권장 백엔드/프론트엔드/DB/인프라 Spec을 추천 + 대안 검토 (Weighted Matrix)

### 3. phase-planner (Opus)
3스프린트 이상 대규모 기능을 독립 배포 가능한 Phase 단위로 분할

### 4. sprint-planner (Opus)
ROADMAP 기반 스프린트 계획 수립. Task별 스킬 자동 배정 (`secure-coding`, `systematic-debugging`, `frontend-design` 등)

### 5. sprint-close (Sonnet)
스프린트 구현 완료 후 문서화 + PR 생성

### 6. sprint-review (Sonnet)
코드 리뷰 + 자동 검증 + 회고 작성

### 7. deploy-prod (Sonnet)
develop → main 프로덕션 배포 + 배포 후 검증

### 8. hotfix-close (Sonnet)
긴급 패치 마무리 + develop 역머지 안내

---

## 하네스 엔지니어링 6대 원칙

```
1. Planning First       — scope.md 작성 후 코드 수정
2. Strict Guardrails    — scope 외 파일 변경 금지
3. Verification Loops   — 3-retry, 동일 수정 반복 금지
4. Policy Enforcement   — 배포 전 harness-ci-gate 통과
5. Continuous Verification — 배포 후 CV 체크리스트
6. ISMS·시큐어코딩      — 하드코딩·DDL·민감정보 노출 금지
```

상세: `.claude/rules/harness-engineering.md`

---

## ISMS·시큐어코딩

이 템플릿은 AI 코드 생성 시 ISMS 인증 기준을 강제합니다:

| 영역 | 자동 감지 | 비고 |
|---|---|---|
| 시크릿 하드코딩 | ✅ posttooluse hook | API Key/Password 등 |
| 하드코딩 URL/엔드포인트 | ✅ posttooluse hook | 환경변수 분리 권고 |
| 민감정보 응답 노출 | ✅ posttooluse hook | password, jumin 등 |
| DDL 직접 실행 | ✅ pretooluse hook (Level 2) | CREATE/DROP/ALTER/TRUNCATE |
| SQL Injection | ⚠️ 코드 리뷰 | Parameterized Query 권장 |

상세 체크리스트: `.claude/skills/secure-coding.md`

---

## Credits — 원본 템플릿

이 템플릿은 다음 저장소의 ClaudeStarter를 기반으로 **스택 무관 범용 템플릿**으로 확장한 버전입니다:

- **원본 저장소**: https://github.com/mailtome7072/ClaudeStarter.git
- **원본 특징**: Python + React + Docker + PostgreSQL 고정 스택 기반의 하네스 엔지니어링 템플릿

### 본 버전의 주요 확장

| 영역 | 원본 | 본 버전 |
|---|---|---|
| 백엔드 스택 | Python (FastAPI 고정) | Python (FastAPI/Django/Flask) / TypeScript (NestJS/Express) / Java (Spring Boot) / **.NET (ASP.NET Core + Framework Legacy)** |
| 프론트엔드 | React 고정 | React / Vue / Next.js |
| 데이터베이스 | PostgreSQL 고정 | PostgreSQL / MS SQL / **Snowflake** / MySQL / SQLite |
| 컨테이너 | Docker 고정 | Docker / Podman / 사용 안 함 |
| 클라우드 | AWS Lightsail 가정 | AWS / Azure / Self-hosted |
| CI/CD | GitHub Actions 가정 | GitHub Actions / GitLab CI / Azure DevOps |
| 초기화 | 고정 스택용 SETUP | **신규/기존 분기 + 3가지 Spec 모드 (직접/유형/PRD 기반)** |
| 자동 감지 | 없음 | `scripts/detect-stack.sh` — pom.xml/csproj/@nestjs/requirements.txt 등으로 스택 자동 감지 |
| 추가 에이전트 | — | `spec-recommender` (Opus) — PRD 기반 권장 Spec 추천 |
| 추가 룰 | — | 글로벌 `code-style.md` + 스택별 10개 룰 분리 |
| 행동 원칙 | 분산 | CLAUDE.md "0. Claude Code 필수 행동 원칙" 통합 + **응답 마지막 자가 체크포인트 14개** 강제 |

---

## 라이선스

(프로젝트 라이선스를 여기에 명시하세요)
