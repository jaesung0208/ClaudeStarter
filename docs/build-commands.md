# 빌드 및 테스트 명령어

> 명령어는 프로젝트마다 다르다. `.claude/project-spec.conf`의 값을 변수로 사용한다.
> SETUP.sh가 스택 선택에 따라 자동으로 채운다.

---

## 기본 사용 패턴

```bash
# spec 로드
source .claude/project-spec.conf

# 백엔드
eval "$BACKEND_TEST_CMD"      # 테스트 실행
eval "$BACKEND_LINT_CMD"      # 린트 실행
eval "$BACKEND_BUILD_CMD"     # 빌드 (필요 시)
eval "$BACKEND_RUN_CMD"       # 로컬 실행

# 프론트엔드
eval "$FRONTEND_TEST_CMD"
eval "$FRONTEND_LINT_CMD"
eval "$FRONTEND_BUILD_CMD"
```

---

## 스택별 기본 명령어 (참고)

| 스택 | TEST | LINT | BUILD | RUN |
|---|---|---|---|---|
| `python-fastapi` | `pytest` | `ruff check .` | — | `uvicorn main:app --reload` |
| `python-django` | `pytest` | `ruff check .` | — | `python manage.py runserver` |
| `python-flask` | `pytest` | `ruff check .` | — | `flask run` |
| `typescript-nestjs` | `pnpm test` | `pnpm lint` | `pnpm build` | `pnpm start:dev` |
| `typescript-express` | `pnpm test` | `pnpm lint` | `pnpm build` | `pnpm dev` |
| `java-spring` | `./gradlew test` | `./gradlew spotlessCheck` | `./gradlew build` | `./gradlew bootRun` |
| `dotnet-aspnet` | `dotnet test` | `dotnet format --verify-no-changes` | `dotnet build` | `dotnet run` |
| `dotnet-framework` | `vstest.console.exe **\bin\Release\*.Tests.dll` | `msbuild /t:Rebuild /p:RunCodeAnalysis=true` | `msbuild /p:Configuration=Release` | IIS Express |
| `react-vite` | `pnpm test` | `pnpm lint` | `pnpm build` | `pnpm dev` |
| `vue` | `pnpm test` | `pnpm lint` | `pnpm build` | `pnpm dev` |
| `nextjs` | `pnpm test` | `pnpm lint` | `pnpm build` | `pnpm dev` |

→ 상세 카탈로그: `.claude/stack-registry.md`

---

## 컨테이너 사용 시

`CONTAINER_RUNTIME=docker` 또는 `podman`인 경우 프로젝트 루트에 `docker-compose.yml` (또는 `compose.yaml`) 작성 권장.

```bash
# Docker
docker compose up --build

# Podman
podman-compose up --build
```

첫 스프린트에서 `sprint-planner`가 컨테이너 셋업을 Task로 포함시킬 수 있다.

---

## DB 마이그레이션

`DB_MIGRATION_TOOL` 변수에 따라 명령이 다르다.

| DB_MIGRATION_TOOL | 마이그레이션 명령 | 새 마이그레이션 생성 |
|---|---|---|
| `alembic` | `alembic upgrade head` | `alembic revision --autogenerate -m "..."` |
| `prisma` | `prisma migrate deploy` | `prisma migrate dev --name ...` |
| `flyway` | `flyway migrate` | 수동 SQL 파일 작성 |
| `ef core migrations` | `dotnet ef database update` | `dotnet ef migrations add ...` |
| `dbt` | `dbt run` | 모델 파일 직접 추가 |
| `schemachange` | `schemachange deploy` | 버전 명명 규칙대로 SQL 추가 |
