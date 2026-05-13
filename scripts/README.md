# scripts/

개발 및 운영 중 필요한 **수동 유틸리티 스크립트**와 **Git hooks**를 보관하는 폴더입니다.

---

## 현재 포함된 파일

| 파일 | 용도 | 실행 방법 |
|---|---|---|
| `detect-stack.sh` | 기존 프로젝트의 스택 자동 감지 (SETUP.sh가 내부 호출) | `bash scripts/detect-stack.sh` |
| `hooks/pre-commit` | 스택 무관 커밋 전 검증 — `.claude/project-spec.conf` 기반 | SETUP.sh가 자동 활성화 |

---

## CI/CD와의 역할 구분

| 위치 | 역할 |
|------|------|
| `.github/workflows/` (또는 GitLab/Azure DevOps) | CI/CD 자동화 — 테스트, 빌드, 프로덕션 배포 |
| `SETUP.sh` | 개발 환경 최초 초기화 (1회성) |
| `scripts/` | CI/CD로 자동화할 수 없는 수동 유틸리티 + Git hooks |

---

## 추가 스크립트 기준

다음 조건 중 하나라도 해당하면 `scripts/`에 추가합니다:
- 개발자가 직접 실행해야 하는 1회성 또는 수동 작업
- 컨테이너 내부에서 실행하는 백엔드 유틸리티 (seed, fixture 등)
- CI/CD 파이프라인에 포함되지 않는 보조 작업

해당하지 않는 경우 (이 폴더에 추가하지 않음):
- 배포 자동화 → `.github/workflows/deploy.yml` 등 CI 워크플로우
- 테스트 실행 → `$BACKEND_TEST_CMD` (CI에서 실행)
- 개발 환경 초기화 → `SETUP.sh`

---

## 스크립트 추가 예시 (스택별)

| 스택 | 예시 명령 |
|---|---|
| Python | `seed.py`, `generate_fixtures.py` |
| Node.js | `seed.ts`, `migrate-data.ts` |
| Java | `seed.kt`, Spring Boot Runner |
| .NET | `Seed.cs`, `dotnet run --project Tools/Seeder` |

> 스크립트 추가 시 이 README의 표에 항목을 함께 추가하세요.
