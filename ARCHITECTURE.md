# Architecture.md

이 파일은 프로젝트의 **개요 및 변수 안내** 문서입니다.
실제 스펙은 SETUP.sh가 `.claude/project-spec.conf`에 자동 저장합니다.

---

## 빠른 시작

```bash
./SETUP.sh
```

SETUP.sh가 다음을 자동 수행합니다:
1. 프로젝트 정보 + 기술 스택 입력 (또는 기존 프로젝트는 자동 감지)
2. `.claude/project-spec.conf` 생성
3. `README.md`, `CLAUDE.md` 등 플레이스홀더 자동 치환
4. 스택별 룰 활성화 (사용 안 하는 스택 룰은 비활성화)

---

## 프로젝트 변수 (SETUP.sh가 자동 생성)

SETUP.sh 실행 후 `.claude/project-spec.conf`에서 다음 값들을 확인할 수 있습니다:

| 영역 | 변수 | 가능한 값 |
|------|------|----------|
| **메타** | `PROJECT_NAME`, `PROJECT_DESCRIPTION`, `PROJECT_TYPE` (new/existing) | 자유 입력 |
| **백엔드** | `BACKEND_STACK` | `python-fastapi` / `python-django` / `python-flask` / `typescript-nestjs` / `typescript-express` / `java-spring` / `dotnet-aspnet` / `none` |
| **백엔드 명령** | `BACKEND_TEST_CMD`, `BACKEND_LINT_CMD`, `BACKEND_BUILD_CMD`, `BACKEND_RUN_CMD` | 스택별 권장값 자동 적용, 수정 가능 |
| **프론트엔드** | `FRONTEND_STACK` | `react-vite` / `vue` / `nextjs` / `none` |
| **데이터베이스** | `DB_TYPE` | `postgres` / `mssql` / `snowflake` / `mysql` / `sqlite` / `none` |
| **컨테이너** | `CONTAINER_RUNTIME` | `docker` / `podman` / `none` |
| **클라우드** | `CLOUD_PROVIDER` | `aws` / `azure` / `self-hosted` / `none` |
| **CI/CD** | `CI_TOOL` | `github-actions` / `gitlab-ci` / `azure-devops` / `none` |
| **보안** | `SECURITY_LEVEL` | `1` (표준) / `2` (강화) |

상세 스택 카탈로그: [`.claude/stack-registry.md`](.claude/stack-registry.md)

---

## 아키텍처 개요

```
project-root/
├── .claude/
│   ├── project-spec.conf           # ⭐ 프로젝트 스펙 (SETUP.sh가 생성, 모든 도구가 참조)
│   ├── stack-registry.md           # 지원 스택 카탈로그
│   ├── agents/                     # Claude 에이전트 정의
│   │   ├── prd-to-roadmap.md      # PRD → ROADMAP
│   │   ├── spec-recommender.md    # PRD → 권장 Spec 추천
│   │   ├── phase-planner.md       # 대규모 기능 Phase 설계
│   │   ├── sprint-planner.md      # 스프린트 계획
│   │   ├── sprint-close.md        # 스프린트 마무리
│   │   ├── sprint-review.md       # 코드 리뷰·검증·회고
│   │   ├── deploy-prod.md         # 프로덕션 배포
│   │   └── hotfix-close.md        # 핫픽스 마무리
│   ├── rules/
│   │   ├── backend.md             # 디스패처 (스택별 가이드로 연결)
│   │   ├── frontend.md            # 디스패처
│   │   ├── harness-engineering.md # 6대 하네스 원칙
│   │   ├── code-style.md          # 스택 무관 코드 스타일 (전역)
│   │   ├── sprint-workflow.md
│   │   ├── notion.md              # Notion MCP 사용 시
│   │   └── stack/                 # 스택별 상세 가이드
│   │       ├── backend-python.md
│   │       ├── backend-typescript.md
│   │       ├── backend-java.md
│   │       ├── backend-dotnet.md
│   │       ├── frontend-react.md
│   │       ├── frontend-vue.md
│   │       ├── frontend-nextjs.md
│   │       ├── db-mssql.md
│   │       └── db-snowflake.md
│   ├── skills/                    # 호출형 스킬 모음
│   ├── hooks/                     # 도구 실행 전후 자동 실행 (project-spec.conf 참조)
│   └── commands/                  # 슬래시 커맨드
├── docs/                          # 산출물 저장 (sprint, phase, retrospectives 등)
├── strategy/                      # 전략 지침
├── scripts/
│   ├── detect-stack.sh            # 기존 프로젝트 자동 감지
│   └── hooks/pre-commit           # 스택 무관 커밋 전 검증
├── PRD.md / ROADMAP.md / CHANGELOG.md / DEPLOY.md
└── SETUP.sh                       # 초기화 마법사
```

**핵심 흐름**: `PRD.md` → `ROADMAP.md` → `sprint{n}` 브랜치 → `develop` PR → `main` 배포

**에이전트 역할** (Opus = 계획/설계, Sonnet = 실행/검증):
- `prd-to-roadmap` (Opus) — PRD 분석 → ROADMAP.md
- `spec-recommender` (Opus) — PRD 기반 권장 Spec 추천 ⭐ 신규
- `phase-planner` (Opus) — 대규모 기능 Phase 설계
- `sprint-planner` (Opus) — 스프린트 계획 수립
- `sprint-close` (Sonnet) — 스프린트 마무리: 문서화 + PR
- `sprint-review` (Sonnet) — 코드 리뷰 + 자동 검증 + 회고
- `deploy-prod` (Sonnet) — 프로덕션 배포
- `hotfix-close` (Sonnet) — 핫픽스 마무리

---

## 기존 프로젝트에서 사용하기

이미 코드가 있는 프로젝트에 ClaudeStarter를 적용하는 경우:

1. ClaudeStarter 클론
2. **`.claude/` 폴더 + `CLAUDE.md` + `scripts/` 만** 기존 프로젝트에 복사
3. 기존 프로젝트 루트에서 `./SETUP.sh` 실행
4. STEP 0에서 "2) 기존 운영 프로젝트" 선택
5. 자동 감지된 스택 확인 후 보완

자동 감지 가능 항목: Java(pom.xml/gradle), .NET(*.csproj), NestJS(@nestjs/), Python(requirements.txt), Next.js, Vue, React, Docker, GitHub Actions, GitLab CI 등
