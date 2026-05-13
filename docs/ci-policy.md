# CI 정책

> CI 도구는 `.claude/project-spec.conf`의 `CI_TOOL` 값에 따라 다르다.
> `github-actions` / `gitlab-ci` / `azure-devops` 중 선택된 도구로 워크플로우를 작성한다.

---

## CI 단계 (어떤 도구든 공통 구성)

```
1. Lint        — 코드 스타일 검증
2. Test        — 단위·통합 테스트
3. Build       — (필요 시) 빌드 산출물 생성
4. Security    — 시크릿 스캔, 의존성 취약점 검사
5. Deploy      — develop → staging, main → prod
```

각 단계의 명령은 `.claude/project-spec.conf`의 변수를 사용한다:

| 단계 | 백엔드 | 프론트엔드 |
|---|---|---|
| Lint | `$BACKEND_LINT_CMD` | `$FRONTEND_LINT_CMD` |
| Test | `$BACKEND_TEST_CMD` | `$FRONTEND_TEST_CMD` |
| Build | `$BACKEND_BUILD_CMD` | `$FRONTEND_BUILD_CMD` |

## CI 실패 대응 (스택 무관)

1. **로그에서 실패한 step 확인** — Lint/Test/Build/Deploy 어느 단계인지 식별
2. **로컬에서 동일 명령 재현** — `source .claude/project-spec.conf && eval "$BACKEND_TEST_CMD"` 등
3. **수정 후 staged 상태로 재커밋** — pre-commit hook이 동일 검증 수행
4. **반복 실패 시 sprint-review 에이전트의 5단계 디버깅 적용** — `.claude/skills/systematic-debugging.md`

---

## 도구별 워크플로우 위치

| CI_TOOL | 파일 위치 | 비고 |
|---|---|---|
| `github-actions` | `.github/workflows/*.yml` | 기본값. 본 템플릿에 ci.yml, deploy.yml 샘플 포함 |
| `gitlab-ci` | `.gitlab-ci.yml` | SETUP.sh 선택 시 GitHub Actions 워크플로우 자동 비활성화 권장 |
| `azure-devops` | `azure-pipelines.yml` | Azure 환경과 통합 시 권장 |

---

## 배포 시크릿 (CLOUD_PROVIDER별)

| CLOUD_PROVIDER | 필요 시크릿 |
|---|---|
| `aws` | `LIGHTSAIL_HOST` / `LIGHTSAIL_USER` / `LIGHTSAIL_SSH_KEY` (Lightsail 사용 시) <br> 또는 `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` (ECS/Lambda) |
| `azure` | `AZURE_CREDENTIALS` (Service Principal JSON), `AZURE_WEBAPP_NAME` 등 |
| `self-hosted` | `SSH_HOST` / `SSH_USER` / `SSH_KEY` |

상세 배포 정책: `docs/harness-engineering/deployment-policy.md`
