# DEPLOY.md

> 배포 후 수동으로 진행해야 하는 작업 체크리스트.
> 자동 배포는 `deploy-prod` 에이전트가 처리한다.

## 배포 전 확인

- [ ] PR이 `develop` → `main`으로 머지 완료
- [ ] CI/CD 워크플로우 통과 (`.claude/project-spec.conf`의 `CI_TOOL` 기준)
- [ ] DB 마이그레이션이 필요한 경우 별도 검증 완료
- [ ] 환경변수 변경이 있다면 운영 환경에 반영 완료

## 클라우드별 시크릿 (CLOUD_PROVIDER 기준)

| CLOUD_PROVIDER | GitHub Secrets / 환경변수 |
|---|---|
| `aws` (Lightsail) | `LIGHTSAIL_HOST` / `LIGHTSAIL_USER` / `LIGHTSAIL_SSH_KEY` |
| `aws` (ECS) | `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY` / `AWS_REGION` |
| `azure` | `AZURE_CREDENTIALS` (Service Principal JSON) |
| `self-hosted` | `SSH_HOST` / `SSH_USER` / `SSH_KEY` |

## 배포 후 검증 (CV — Continuous Verification)

- [ ] 헬스체크 엔드포인트 응답 확인
- [ ] 핵심 비즈니스 경로 1~2개 수동 검증
- [ ] 에러 로그 모니터링 (최소 10분)
- [ ] 롤백 절차 숙지 (`develop`에서 hotfix 또는 이전 태그로 재배포)

상세 절차: `docs/harness-engineering/deployment-policy.md`
