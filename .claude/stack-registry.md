# Stack Registry — 지원 스택 정의

> 이 파일은 SETUP.sh가 참조하는 스택 카탈로그입니다.
> `.claude/project-spec.conf`의 `BACKEND_STACK`, `FRONTEND_STACK` 값이 여기에 정의된 ID 중 하나가 됩니다.

---

## 백엔드 스택

| 스택 ID | 언어 | 프레임워크 | 권장 패키지 매니저 | 권장 테스트 | 권장 린터 | 권장 ORM |
|---|---|---|---|---|---|---|
| `python-fastapi` | Python | FastAPI | pip + venv | pytest | ruff | SQLAlchemy + Alembic |
| `python-django` | Python | Django | pip + venv | pytest-django | ruff | Django ORM |
| `python-flask` | Python | Flask | pip + venv | pytest | ruff | SQLAlchemy |
| `typescript-nestjs` | TypeScript | NestJS | pnpm | vitest | eslint + prettier | Prisma 또는 TypeORM |
| `typescript-express` | TypeScript | Express | pnpm | vitest | eslint + prettier | Prisma |
| `java-spring` | Java | Spring Boot | Gradle | JUnit 5 | Spotless | JPA/Hibernate |
| `dotnet-aspnet` | C# (.NET 5+) | ASP.NET Core | dotnet | xUnit | dotnet format | Entity Framework Core |
| `dotnet-framework` | C# (.NET Framework 4.x — Legacy) | ASP.NET MVC 5 / WebForms / WCF | NuGet + MSBuild | MSTest / NUnit / xUnit | StyleCop / FxCop | Entity Framework 6 |
| `none` | — | — | — | — | — | — |

### 권장 명령어 (스택별 기본값 — SETUP.sh가 자동 채움)

| 스택 ID | TEST_CMD | LINT_CMD | BUILD_CMD | RUN_CMD |
|---|---|---|---|---|
| `python-fastapi` | `pytest` | `ruff check .` | (생략) | `uvicorn main:app --reload` |
| `python-django` | `pytest` 또는 `python manage.py test` | `ruff check .` | (생략) | `python manage.py runserver` |
| `python-flask` | `pytest` | `ruff check .` | (생략) | `flask run` |
| `typescript-nestjs` | `pnpm test` | `pnpm lint` | `pnpm build` | `pnpm start:dev` |
| `typescript-express` | `pnpm test` | `pnpm lint` | `pnpm build` | `pnpm dev` |
| `java-spring` | `./gradlew test` | `./gradlew spotlessCheck` | `./gradlew build` | `./gradlew bootRun` |
| `dotnet-aspnet` | `dotnet test` | `dotnet format --verify-no-changes` | `dotnet build` | `dotnet run` |
| `dotnet-framework` | `vstest.console.exe **\bin\Release\*.Tests.dll` | `msbuild /t:Rebuild /p:RunCodeAnalysis=true` | `msbuild /p:Configuration=Release` | IIS Express 또는 Visual Studio F5 |

---

## 프론트엔드 스택

| 스택 ID | 프레임워크 | 빌드 도구 | 권장 패키지 매니저 | 권장 테스트 | 권장 린터 |
|---|---|---|---|---|---|
| `react-vite` | React | Vite | pnpm | vitest | eslint + prettier |
| `vue` | Vue 3 | Vite | pnpm | vitest | eslint + prettier |
| `nextjs` | Next.js | Next | pnpm | vitest 또는 jest | next lint |
| `none` | — | — | — | — | — |

### 권장 명령어

| 스택 ID | TEST_CMD | LINT_CMD | BUILD_CMD |
|---|---|---|---|
| `react-vite` | `pnpm test` | `pnpm lint` | `pnpm build` |
| `vue` | `pnpm test` | `pnpm lint` | `pnpm build` |
| `nextjs` | `pnpm test` | `pnpm lint` | `pnpm build` |

---

## 데이터베이스

| DB ID | 이름 | 마이그레이션 도구 (Python/Node/Java/.NET) |
|---|---|---|
| `postgres` | PostgreSQL | Alembic / Prisma / Flyway / EF Core |
| `mssql` | MS SQL Server (Azure SQL 포함) | Alembic / Prisma / Flyway / EF Core |
| `snowflake` | Snowflake | dbt 또는 schemachange |
| `mysql` | MySQL / MariaDB | Alembic / Prisma / Flyway / EF Core |
| `sqlite` | SQLite | Alembic / Prisma |
| `none` | — | — |

---

## 클라우드 / 배포

| Provider ID | 이름 | 권장 배포 방식 |
|---|---|---|
| `aws` | AWS | Lightsail / EC2 / ECS / Lambda |
| `azure` | Azure | App Service / Container Apps / Functions |
| `self-hosted` | 자체 서버 | SSH + Docker Compose |
| `none` | — | — |

---

## CI/CD

| CI ID | 이름 | 워크플로우 파일 위치 |
|---|---|---|
| `github-actions` | GitHub Actions | `.github/workflows/*.yml` |
| `gitlab-ci` | GitLab CI | `.gitlab-ci.yml` |
| `azure-devops` | Azure DevOps Pipelines | `azure-pipelines.yml` |
| `none` | — | — |

---

## 컨테이너 런타임

| Runtime ID | 도구 |
|---|---|
| `docker` | Docker + Docker Compose |
| `podman` | Podman + podman-compose |
| `none` | 사용 안 함 |
