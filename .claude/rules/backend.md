---
description: 백엔드 파일 작업 시 자동 로드. 프로젝트 스택에 맞는 가이드를 디스패치한다.
globs:
  - "**/*.py"
  - "**/*.ts"
  - "**/*.java"
  - "**/*.cs"
  - "**/requirements*.txt"
  - "**/package.json"
  - "**/pom.xml"
  - "**/build.gradle*"
  - "**/*.csproj"
---

## 백엔드 가이드 디스패처

이 프로젝트의 백엔드 스택은 `.claude/project-spec.conf`의 `BACKEND_STACK` 값을 따른다.

스택별 상세 가이드:

| BACKEND_STACK 값 | 상세 가이드 |
|---|---|
| `python-fastapi`, `python-django`, `python-flask` | [.claude/rules/stack/backend-python.md](stack/backend-python.md) |
| `typescript-nestjs`, `typescript-express` | [.claude/rules/stack/backend-typescript.md](stack/backend-typescript.md) |
| `java-spring` | [.claude/rules/stack/backend-java.md](stack/backend-java.md) |
| `dotnet-aspnet` (ASP.NET Core, .NET 5+) | [.claude/rules/stack/backend-dotnet-aspnet.md](stack/backend-dotnet-aspnet.md) |
| `dotnet-framework` (.NET Framework 4.x — Legacy) | [.claude/rules/stack/backend-dotnet-framework.md](stack/backend-dotnet-framework.md) |

## 스택 무관 공통 원칙

스택과 관계없이 모든 백엔드 코드에 적용된다:

### 보안 (ISMS)
- 시크릿·API 키·DB 접속 정보 하드코딩 절대 금지 — 환경변수 주입
- SQL Injection 방어: Parameterized Query 또는 ORM 필수
- API 응답·로그에 비밀번호·주민번호 등 민감정보 노출 금지

### 테스트
- 새 API 엔드포인트 추가 시 통합 테스트 필수 작성
- 단위·시나리오·엣지케이스 3단계 (상세: `.claude/skills/test-checklist.md`)

### DB 마이그레이션
- 스키마 변경 시 마이그레이션 파일 동시 생성
- 프로덕션 DB에 직접 DDL 실행 금지 (Forbidden Area)

상세 보안 체크리스트: `.claude/skills/secure-coding.md`
