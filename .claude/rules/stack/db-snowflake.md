---
description: Snowflake 사용 시 자동 로드.
globs: ["**/*.sql", "**/migrations/**", "**/dbt_project.yml"]
---

## Snowflake 개발 필수 준수 사항

### 보안 (ISMS)
- 계정 식별자(`<org>-<account>`)·사용자명·비밀번호·키 페어는 환경변수로만 주입 — 코드 하드코딩 금지
- 키 페어 인증 우선 (비밀번호 인증보다 권장)
- 역할(RBAC): 최소 권한 원칙 — PUBLIC 역할에 Cortex AI 등 민감 기능 부여 금지
- 사용자별 일일 크레딧 한도 설정 권장

### 비용 관리
- 웨어하우스(Warehouse) 크기·자동 정지(auto_suspend) 설정 필수
- 쿼리 실행 전 추정 비용 인지 — 큰 테이블 `SELECT *` 금지
- Cross-Region Inference 사용 시 추가 비용 확인
- `WAREHOUSE_METERING_HISTORY`, `CORTEX_FUNCTIONS_USAGE_HISTORY` 정기 모니터링

### SQL 변환 (T-SQL → Snowflake SQL)
- `WHILE` 루프 → Stored Procedure (JavaScript / Python / SQL)
- `#temp` 테이블 → `TEMPORARY TABLE`
- `EXEC(@SQL)` → `EXECUTE IMMEDIATE`
- `ISNULL(a, b)` → `COALESCE(a, b)`
- 한국어·언더스코어 시작 식별자는 DDL에서 double-quote 필수

### 마이그레이션
- DDL 변경은 schemachange 또는 dbt seed/snapshot 사용
- 운영 DB 직접 DDL 실행 금지
- Time Travel 기능 활용 (실수 복구)

### 성능
- 클러스터링 키 설정 (대용량 테이블)
- 결과 캐시 / 메타데이터 캐시 활용
- Micro-partition 통계 확인

### Cortex AI
- 모델 사용 시 사용자/역할별 권한 명시
- 응답 로그·프롬프트 로그 보관 정책 설정
