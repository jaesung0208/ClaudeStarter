# CLAUDE.md

> AI 협업 도구(Claude Code)가 이 저장소에서 작업할 때 따르는 핵심 지침.
> **인간 팀원**: README.md / PRD.md / ROADMAP.md 참고
> **AI**: 이 파일을 항상 먼저 읽고, `.claude/project-spec.conf`를 함께 참조한다.

---

## 0. Claude Code 필수 행동 원칙

> 모든 작업에 앞서 반드시 따라야 하는 기본 동작이다. 다른 모든 규칙보다 우선한다.

### 0-1. 세션 시작 시
- 이 CLAUDE.md 파일을 읽고 규칙이 활성화되었음을 확인
- `.claude/project-spec.conf`를 함께 로드해 현재 프로젝트 스택을 파악

### 0-2. 파일 수정 전
- 수정 대상 파일을 먼저 읽고 현재 상태를 파악한 후 작업 시작
- 여러 파일에 영향을 주는 작업은 변경 범위를 먼저 설명하고 진행

### 0-3. 구현 전 계획 제시 (정량 트리거)
다음 중 하나 이상에 해당하면 **구현 전 TODO 리스트를 먼저 제시하고 사용자 승인 후** 시작:
- 3개 파일 이상 수정
- 신규 기능 추가
- DB 스키마·마이그레이션 관련 작업
- 인증·인가 관련 작업

### 0-4. 응답 언어
- 모든 텍스트 응답은 한국어로 작성
- 코드·명령어·고유명사는 영어 그대로 유지

### 0-5. `@파일경로` 참조 의무화
- 코드를 수정하기 전 반드시 `@파일경로`로 대상 파일을 참조하고 현재 상태 파악
- 연관 파일이 있는 경우 함께 참조하여 영향 범위 확인

### 0-6. todo 활용 의무화
- 3단계 이상의 작업은 구현 전 todo 리스트를 먼저 제시하고 사용자 승인 후 시작
- 작업 중 예상치 못한 추가 작업이 생기면 todo에 추가하고 사용자에게 알림

### 0-7. 컨텍스트 위생 (`/compact` · `/clear`)
- 대화가 20턴 이상 길어지거나 컨텍스트가 복잡해졌다고 판단되면 `/compact` 사용 권고
- 새로운 기능 작업을 시작할 때 이전 작업 내용이 불필요하면 `/clear` 후 시작 권고

### 0-8. 코드 생성 스타일

#### 주석
- 모든 함수·메서드 상단에 목적·파라미터·반환값을 주석으로 기재
- WHAT(무엇을 하는가) 설명은 불필요 — 코드 자체로 읽히도록 작성
- WHY(왜 이렇게 했는가), 숨겨진 제약, 예외적 처리 이유는 반드시 주석으로 남김

#### 함수 길이
- 함수·메서드는 50줄 이하 권고
- 80줄 초과 시 단일 책임 원칙(SRP) 기준으로 분리 가능한 단위를 제안

#### 에러 핸들링
- 각 레이어(Controller·Service·Repository 등)에서 자체적으로 예외를 처리
- 모든 catch 블록에서 반드시 로그를 출력 — **silent catch 절대 금지**
- 로그 출력 후 상위 레이어로 예외를 다시 던질지 여부를 명시적으로 결정하고 주석으로 이유 기재
- 민감정보(비밀번호·토큰·개인정보)는 로그에 포함 금지

#### 금지 패턴
다음 패턴이 포함된 코드는 생성하지 않음:
- `console.log` · `System.out.println` · `print()` 등 디버그 출력문 잔존 — 로깅 프레임워크(Logger)만 사용
- TypeScript `any`, Java `Object`, Python `Any` 등 타입 안전성을 포기하는 타입 남용
- 중첩 if 3단계 이상 — early return 또는 분리 함수로 대체 제안
- `TODO` · `FIXME` 주석을 달고 구현 없이 넘어가는 코드 — 구현하거나 이슈로 등록 후 링크 기재

---

## ⭐ 응답 마지막 자가 체크포인트 (필수)

**AI가 코드를 생성·수정한 후, 응답 마지막에 아래 체크포인트를 반드시 출력한다.**

```
✅ 코드 리뷰 체크포인트

[작업 범위]
- [✅/⚠️/❌] 1. 요청 범위 외 파일을 수정하지 않았는가
- [✅/⚠️/❌] 2. 삭제·변경된 기존 기능이 없는가

[보안 — ISMS]
- [✅/⚠️/❌] 3. 하드코딩된 환경값(시크릿·URL·DB접속정보)이 없는가
- [✅/⚠️/❌] 4. 사용자 입력에 대한 유효성 검증이 있는가
- [✅/⚠️/❌] 5. 개인정보·민감정보가 로그/응답에 노출되지 않는가
- [✅/⚠️/❌] 6. 인증·인가 코드가 함께 작성되었는가 (해당 시)
- [✅/⚠️/❌] 7. 감사 로그가 기록되는가 (인증·민감 데이터 접근 시)

[코드 품질]
- [✅/⚠️/❌] 8. 테스트 코드가 함께 작성되었는가 (정상+오류+엣지케이스)
- [✅/⚠️/❌] 9. 함수가 50줄 이하인가 (80줄+ 시 분리 제안)
- [✅/⚠️/❌] 10. 디버그 출력(console.log·print 등)이 남아있지 않은가
- [✅/⚠️/❌] 11. catch 블록에 로그 출력이 있는가 (silent catch 없음)

[문서 일관성]
- [✅/⚠️/❌] 12. MD 파일의 경로·파일명이 실제 파일시스템과 일치하는가
- [✅/⚠️/❌] 13. 파일 추가·삭제·이동 시 관련 MD 파일에도 반영되었는가
- [✅/⚠️/❌] 14. MD 파일에 기술된 내용(설명·규칙·구조)이 현재 실제 상태와 일치하는가
```

### 체크포인트 사용 규칙
- 항목별 표시: `✅` (통과) / `⚠️` (주의 — 사유 명시) / `❌` (위반 — 즉시 수정)
- `⚠️` 또는 `❌`가 있으면 사유를 1줄로 함께 표기
- **코드 작업이 없는 단순 질답 응답에는 체크포인트 출력 생략**
- 작업 범위에 해당하지 않는 항목은 `[N/A]`로 표기 (예: DB 작업 없을 때 4번)

상세 보안 체크리스트: [.claude/skills/secure-coding.md](.claude/skills/secure-coding.md)

---

## ⭐ 프로젝트 스펙 (Single Source of Truth)

**모든 스택·명령어·인프라 정보는 `.claude/project-spec.conf`에 있다.**

코드 작성·테스트·배포 명령이 필요할 때 이 파일을 먼저 읽어라. AI는 이 파일의 값을 기반으로 동작한다.

```bash
# spec 확인 예시
source .claude/project-spec.conf
echo "테스트 명령: $BACKEND_TEST_CMD"
echo "린트 명령: $BACKEND_LINT_CMD"
```

주요 변수:

| 변수 | 의미 |
|---|---|
| `BACKEND_STACK` | python-fastapi, typescript-nestjs, java-spring, dotnet-aspnet 등 |
| `FRONTEND_STACK` | react-vite, vue, nextjs, none |
| `BACKEND_TEST_CMD` / `FRONTEND_TEST_CMD` | 테스트 실행 명령 |
| `BACKEND_LINT_CMD` / `FRONTEND_LINT_CMD` | 린트 실행 명령 |
| `DB_TYPE` | postgres, mssql, snowflake 등 |
| `CONTAINER_RUNTIME` | docker, podman, none |
| `CLOUD_PROVIDER` | aws, azure, self-hosted, none |
| `CI_TOOL` | github-actions, gitlab-ci, azure-devops |

상세 카탈로그: [`.claude/stack-registry.md`](.claude/stack-registry.md)

---

## 프로젝트 개요

- **프로젝트명**: ${project_name}
- **설명**: ${project_description}
- **기술 스택**: ${stack_label}
- **원격 저장소**: ${repo_url}

**핵심 흐름**: `PRD.md` → `ROADMAP.md` → `sprint{n}` 브랜치 → `develop` PR → `main` 배포

---

## 즉시 참조 — 어떤 에이전트/커맨드를 쓸지

| 상황 | 사용할 것 |
|------|----------|
| PRD → 로드맵 변환 | `prd-to-roadmap` 에이전트 |
| PRD 기반 Spec 추천 | `spec-recommender` 에이전트 |
| 새 스프린트 계획 | `sprint-planner` 에이전트 |
| 스프린트 구현 시작 | `/sprint-dev [n]` 커맨드 |
| 스프린트 마무리 | `sprint-close` → `sprint-review` 에이전트 |
| 프로덕션 배포 | `deploy-prod` 에이전트 |
| 긴급 패치 | `hotfix-close` 에이전트 |

상세: `docs/prompt-guide.md`

---

## 에이전트 (Opus = 계획, Sonnet = 실행)

| 에이전트 | 모델 | 역할 |
|---------|------|------|
| `prd-to-roadmap` | Opus | PRD → ROADMAP.md 생성 |
| `spec-recommender` | Opus | PRD 기반 권장 Spec 추천 |
| `phase-planner` | Opus | 3스프린트+ 대규모 Phase 설계 |
| `sprint-planner` | Opus | 스프린트 계획 수립 |
| `sprint-close` | Sonnet | 스프린트 문서화 + PR 생성 |
| `sprint-review` | Sonnet | 코드 리뷰 + 자동 검증 + 회고 |
| `deploy-prod` | Sonnet | develop → main 배포 |
| `hotfix-close` | Sonnet | 긴급 패치 마무리 |

---

## 슬래시 커맨드

| 커맨드 | 설명 |
|--------|------|
| `/sprint-dev [n]` | sprint{n}.md 기반 구현 오케스트레이터 |
| `/restart` | 로컬 서비스 재시작 (CONTAINER_RUNTIME에 따라) |

---

## 하네스 엔지니어링 원칙

> 상세: `.claude/rules/harness-engineering.md`

| # | 원칙 | 핵심 행동 |
|---|------|----------|
| 1 | Planning First | scope.md 작성 후 코드 수정 |
| 2 | Strict Guardrails | scope 외 파일 변경 금지 |
| 3 | Verification Loops | 3-retry, 동일 수정 반복 금지 |
| 4 | Policy Enforcement | 배포 전 harness-ci-gate 통과 |
| 5 | Continuous Verification | 배포 후 CV 체크리스트 실행 |
| 6 | **ISMS·시큐어코딩** | 하드코딩·DDL·민감정보 노출 금지 |

---

## AI 행동 규칙 (항상 준수)

| 절대 금지 | 항상 준수 |
|---|---|
| 시크릿·DB 접속 정보 하드코딩 / DDL 무허가 실행 / 범위 외 파일 변경 / 민감정보 로그·응답 노출 | 환경변수 주입 / SQL Parameterized Query / 프로덕션 스택트레이스 차단 |

상세 체크리스트: [`.claude/skills/secure-coding.md`](.claude/skills/secure-coding.md)

---

## Hooks 시스템 (자동 실행)

| Hook | 역할 |
|---|---|
| `pretooluse-bash-guard.sh` | 위험 Bash 명령 7가지 차단 (DDL, force push 등) |
| `posttooluse-code-validator.sh` | Edit/Write 후 스택별 syntax + 시크릿·민감정보 감지 |
| `posttooluse-scope-tracker.sh` | 파일 수정 3회+ 시 loop 경고 |
| `stop-doc-checker.sh` | 에이전트 종료 후 문서 누락 감지 |

모든 hook은 `.claude/project-spec.conf`를 읽어 스택에 맞게 동작한다.

---

## Rules (자동 로드 디스패치)

| 파일 | 로드 조건 | 디스패치 |
|------|----------|----------|
| `sprint-workflow.md` | 전체 대화 | — |
| `harness-engineering.md` | 전체 대화 | — |
| `code-style.md` | 전체 대화 (모든 코드 작업) | — |
| `backend.md` | 백엔드 파일 접근 시 | → `stack/backend-{python|typescript|java|dotnet}.md` |
| `frontend.md` | 프론트엔드 파일 접근 시 | → `stack/frontend-{react|vue|nextjs}.md` |
| `notion.md` | "Notion" 언급 또는 MCP 사용 시 | — |

`SETUP.sh`가 선택된 스택의 룰만 `.md`로 유지하고, 나머지는 `.md.disabled`로 비활성화한다.

---

## Skills (명시적 참조)

| 스킬 | 용도 |
|---|---|
| `secure-coding` | ISMS·시큐어코딩 체크리스트 (보안·인증·개인정보 Task) |
| `systematic-debugging` | 버그 5단계 분석 |
| `test-checklist` | 3단계 테스트 기준 (정상·오류·엣지케이스) |
| `code-review` | PR 코드 리뷰 체크리스트 |
| `harness-ci-gate` | 배포 전 Policy Gate |

기타 스킬 (karpathy-guidelines, frontend-design, brainstorming, writing-plans, simplify, loop-detection, retrospective): [`.claude/skills/`](.claude/skills/) 디렉토리 참조

---

## 빌드 및 테스트 명령어

명령어는 스택마다 다르므로 `.claude/project-spec.conf`의 변수 (`$BACKEND_TEST_CMD`, `$BACKEND_RUN_CMD` 등)를 사용한다.

상세 명령어 매핑·DB 마이그레이션 명령: [`docs/build-commands.md`](docs/build-commands.md)

---

## CI/CD · 환경변수 · Bash 명령 (핵심 요약)

| 영역 | 핵심 |
|---|---|
| **CI 도구** | `CI_TOOL` 변수에 따라: `github-actions` (`.github/workflows/`) / `gitlab-ci` (`.gitlab-ci.yml`) / `azure-devops` (`azure-pipelines.yml`) |
| **배포 시크릿** | `CLOUD_PROVIDER`별 다름 — aws: `LIGHTSAIL_*` 또는 `AWS_*` / azure: `AZURE_CREDENTIALS` / self-hosted: `SSH_*` |
| **환경변수 관리** | `.env` (실제 값, Git 금지) / `.env.example` (키 이름만) — 민감 값은 사람이 직접 입력 |
| **Bash 명령** | `cd /path &&` 접두사 금지, 작업 디렉토리는 항상 프로젝트 루트, `git ...` 직접 실행 |

상세: [`docs/ci-policy.md`](docs/ci-policy.md) · [`docs/build-commands.md`](docs/build-commands.md)

---

## 개발 유의사항

1. **plan 모드 수정 요청** → Hotfix vs Sprint 판단 먼저 (`docs/dev-process.md` 섹션 2)
2. **3스프린트+ 대규모 기능** → `phase-planner` 먼저, 그 다음 `sprint-planner`
3. **신규 프로젝트인데 스택이 결정 안 됨** → PRD 먼저 작성 → `spec-recommender` 에이전트 사용
4. **스프린트 마무리 순서**: `sprint-close` (문서+PR) → `sprint-review` (리뷰+검증+회고)
5. **데이터 표준**: 프로젝트별 용어 사전을 `docs/domain-glossary.md`에 작성, 이 파일 경로를 CLAUDE.md에 명시
6. **체크리스트**: ✅ 완료 / ⬜ 미완료 / 🔄 진행 중 / ⏸️ 보류

---

## 문제 해결 참조

| 문제 | 참조 위치 |
|------|----------|
| CI 실패 | `docs/dev-process.md` 섹션 9.1 |
| 컨테이너 빌드 실패 | `docs/dev-process.md` 섹션 9.2 |
| develop 브랜치 충돌 | `docs/dev-process.md` 섹션 9.3 |
| 잘못된 브랜치 작업 | `docs/dev-process.md` 섹션 9.4 |

---

## 협업 규칙 (핵심)

| 영역 | 핵심 |
|---|---|
| **컨텍스트 공유** | 작업 시작 전 브랜치·범위 명시 / 세션 전환 시 `docs/sprint/sprint{n}.md`로 인수인계 (sprint-close 자동) |
| **커밋 단위** | 하나의 커밋 = 하나의 목적 / AI 생성 코드는 사람이 확인 후 커밋 / `--no-verify` 금지 |
| **머지 규칙** | Self-merge 허용 — 단 응답 마지막 체크포인트 14개 자체 점검 필수 / `develop`→`main`은 `deploy-prod` 에이전트로만 |

브랜치 전략 상세: [`.claude/rules/sprint-workflow.md`](.claude/rules/sprint-workflow.md)

---

## Known Limitations (v0.5 현재)

> 본 템플릿의 알려진 한계. v1.0에서 해결 예정.
> 상세 백로그: [`TEMPLATE-ROADMAP.md`](TEMPLATE-ROADMAP.md)

| ID | 한계 | 임시 대응 |
|---|---|---|
| GAP-001 | PRD.md 자동 크기 모니터링·분할 가이드 없음 | 1000줄 초과 시 수동으로 영역별 분리 — `docs/prd/feature-*.md` 패턴 권장 |
| GAP-002 | PRD 자동 분할 에이전트 없음 | 일반 Claude Code에게 "PRD를 영역별로 분리해줘"로 수동 요청 |
| GAP-003 | 회사 환경 실제 검증 미완 | 토이 프로젝트로 먼저 시범 적용 권장 |

PRD가 1000줄을 넘기 시작하면 사용자에게 분할을 권고해야 합니다.

---

## 언어 규칙

- 응답·코드 주석·커밋 메시지·문서: **한국어**
- 변수명·함수명: **영어** (코드 표준)
