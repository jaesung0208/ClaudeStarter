---
description: ASP.NET Core (.NET 5+) 백엔드 개발 시 자동 로드.
globs: ["**/*.cs", "**/*.csproj", "**/*.sln"]
---

## ASP.NET Core 백엔드 개발 필수 준수 사항

### 테스트
- 새 API 엔드포인트 추가 시 `WebApplicationFactory` 기반 통합 테스트 필수
- 비즈니스 로직 단위 테스트 (xUnit + Moq)
- 테스트 프로젝트는 `*.Tests.csproj`로 분리

### DB 마이그레이션
- 스키마 변경 시 EF Core Migration 동시 생성 (`dotnet ef migrations add`)
- 프로덕션 DB에 직접 DDL 실행 금지

### 보안 (ISMS)
- 시크릿: `appsettings.json` 평문 저장 금지 — `Secret Manager`, 환경변수, Azure Key Vault 사용
- 연결 문자열: `appsettings.Development.json`은 예시만, 실제 값은 환경변수
- ASP.NET Core Identity 또는 IdentityServer 사용 시 비밀번호 해시 알고리즘 명시
- SQL 인젝션: EF Core LINQ 또는 Parameterized Query 사용 (`FromSqlInterpolated`)

### 의존성 주입
- `Program.cs` 또는 `Startup.cs`에 등록
- Scoped/Transient/Singleton 수명 주기 명시적 선택

### 예외 처리
- `UseExceptionHandler` 미들웨어로 글로벌 처리
- ProblemDetails (RFC 7807) 형식 응답 권장
- 프로덕션에서 `Developer Exception Page` 비활성화 필수

### 비동기
- I/O 작업은 `async/await` 필수
- `.Result` / `.Wait()` 호출 금지 (데드락 위험)

## 코드 리뷰 우선 체크 항목

- **Critical**: SQL 인젝션 (`FromSqlRaw`에 문자열 결합), 인증·인가 누락, Developer Exception Page 프로덕션 노출
- **High**: 동기 I/O 호출, DI 수명주기 오류, 시크릿 평문 저장
