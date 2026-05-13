---
description: .NET Framework 4.x (Legacy) 백엔드 개발 시 자동 로드. ASP.NET MVC 5 / Web Forms / WCF / WebAPI 2 등.
globs: ["**/*.cs", "**/*.csproj", "**/*.sln", "**/web.config", "**/App.config", "**/packages.config"]
---

## .NET Framework (Legacy) 개발 필수 준수 사항

이 프로젝트는 .NET Framework 4.x를 사용하는 **레거시 코드베이스**입니다. 신규 .NET 8+ 코드와 다른 패턴이 적용됩니다.

### 환경 / 빌드

- 빌드 도구: **MSBuild + NuGet** (`dotnet` CLI는 일부 작업만 지원 — `dotnet build`는 SDK-style csproj에서만 동작)
- IDE: Visual Studio 2019/2022 또는 JetBrains Rider 권장
- 호스팅: **IIS / IIS Express** (Windows 종속)
- 패키지 관리: `packages.config` (legacy) 또는 PackageReference (modernized)
- `web.config` ↔ `appsettings.json` 차이 — 설정은 web.config로 관리

### 테스트
- 테스트 프레임워크: MSTest / NUnit / xUnit 중 프로젝트 관례 따름
- 실행: `vstest.console.exe **\bin\Release\*.Tests.dll` 또는 Visual Studio Test Explorer
- 통합 테스트는 OWIN 셀프호스트(`Microsoft.Owin.Testing`)로 구성 권장

### 데이터 액세스
- ORM: **Entity Framework 6** (EF Core 아님) 또는 Dapper
- 마이그레이션: EF6 Migrations (`Add-Migration`, `Update-Database`) — Visual Studio Package Manager Console
- ADO.NET 직접 사용 시 `SqlParameter` 필수 (인젝션 방어)

### 보안 (ISMS) — Legacy 특화
- **web.config의 connectionStrings**: 평문 저장 금지 — `aspnet_regiis -pe` 로 암호화 또는 환경변수/AppSettings.config 외부 파일 + Git 제외
- `<appSettings>`에 시크릿 하드코딩 금지
- ASP.NET Membership / SimpleMembership 사용 시 비밀번호 해시 알고리즘 확인 (오래된 SHA1 사용 케이스 주의)
- **ViewState 암호화** 활성화 (`<pages viewStateEncryptionMode="Always" />`)
- **RequestValidation** 비활성화 금지 (XSS 방어)
- **CSRF 방어**: ASP.NET MVC 5는 `@Html.AntiForgeryToken()` + `[ValidateAntiForgeryToken]` 필수
- SQL 인젝션: EF6 LINQ 또는 `SqlParameter` 사용 (`ExecuteSqlCommand`에 문자열 결합 금지)

### ASP.NET MVC 5 / Web API 2 패턴
- 의존성 주입: **Unity / Autofac / Ninject** (built-in DI 없음 — 컨테이너 명시)
- 비동기: `async/await` 지원되나 `Task.Result` / `.Wait()`로 인한 데드락 주의 (`ConfigureAwait(false)` 권장)
- 예외 처리: `Application_Error` in `Global.asax` 또는 `HandleErrorAttribute`

### WCF (사용 시)
- `app.config` / `web.config`의 `<system.serviceModel>` 설정 검토
- 바인딩 보안: `basicHttpBinding`보다 `wsHttpBinding` 또는 `netTcpBinding` 권장
- 메시지 보안 모드 명시 (`<security mode="Transport" />` 등)

### Legacy 코드 작업 원칙
1. **현상 유지**: 새 기능 추가 시 기존 패턴 따르고 무리한 모더나이즈 지양
2. **점진적 개선**: 새 모듈은 PackageReference, async/await, DI 컨테이너 적극 사용
3. **마이그레이션 계획**: .NET 8 이주 시 `try-convert` 도구로 csproj 형식 변환 → 의존성 검토 → ASP.NET Core로 재작성

### 코드 리뷰 우선 체크 항목

- **Critical**: SQL 인젝션 (`ExecuteSqlCommand` 문자열 결합), CSRF 토큰 누락, web.config 평문 시크릿, RequestValidation 비활성화
- **High**: ViewState 암호화 누락, 동기 I/O 호출, `Task.Result` 사용, 데드락 위험 패턴
- **Medium**: DI 컨테이너 미사용, packages.config 잔존 (모더나이즈 검토)
