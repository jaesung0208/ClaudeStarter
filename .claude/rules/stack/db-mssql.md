---
description: MS SQL Server / Azure SQL Database 사용 시 자동 로드.
globs: ["**/*.sql", "**/migrations/**"]
---

## MS SQL Server / Azure SQL 개발 필수 준수 사항

### 보안 (ISMS)
- 연결 문자열은 환경변수 또는 시크릿 매니저에서만 로드 — 코드 하드코딩 금지
- Azure SQL 사용 시 Azure AD 인증 우선 (SQL 인증보다 권장)
- SQL Injection 방어: Parameterized Query / ORM 필수, 동적 SQL은 `sp_executesql`로 파라미터화

### 인덱스 관리
- Columnstore 인덱스: 정기 REORGANIZE + 월간 COMPRESS_ALL_ROW_GROUPS 권장
- 인덱스 유지보수 스토어드 프로시저는 별도 마이그레이션으로 분리

### 트랜잭션
- 명시적 `BEGIN TRAN ... COMMIT/ROLLBACK` 사용
- 장기 트랜잭션 회피 (락 경합 방지)
- READ COMMITTED SNAPSHOT 권장 (블로킹 감소)

### 쿼리 작성
- `SELECT *` 금지 — 명시적 컬럼 지정
- `WITH (NOLOCK)` 사용 시 더티 리드 위험 이해 후 사용
- 페이지네이션: `OFFSET ... FETCH NEXT ... ROWS ONLY` 사용

### 마이그레이션
- DDL 변경은 반드시 마이그레이션 파일 (Flyway / EF Core Migration / 자체 스크립트)
- 운영 DB 직접 DDL 실행 금지 (Forbidden Area)
- 변경 전 백업 또는 롤백 스크립트 준비

### Azure SQL 특화
- 가격 티어 (DTU vs vCore) 확인 후 쿼리 최적화
- Elastic Pool 사용 시 리소스 분배 모니터링
