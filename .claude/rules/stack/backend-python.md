---
description: Python 백엔드 (FastAPI/Django/Flask) 개발 시 자동 로드.
globs: ["**/*.py", "requirements*.txt", "pyproject.toml"]
---

## Python 백엔드 개발 필수 준수 사항

### 테스트
- 새 API 엔드포인트 추가 시 통합 테스트 필수 작성 (pytest)
- 테스트 파일은 `tests/` 디렉토리에 위치

### DB 마이그레이션
- DB 스키마 변경 시 마이그레이션 파일 동시 생성 (Alembic 등)
- 프로덕션 DB에 직접 DDL 실행 금지

### 보안 (ISMS)
- 환경변수는 `.env` 또는 환경 주입으로만 로드 — 코드 하드코딩 금지
- API 키·시크릿·DB 접속 정보는 `.env.example`에 키 이름만 기재
- ORM 사용 시 raw SQL은 Parameterized Query 필수

### 성능
- ORM 조회 시 N+1 쿼리 방지 (`joinedload`, `selectinload`, `select_related`)
- 목록 API에는 페이지네이션 필수

### 코드 구조
- 비즈니스 로직은 `services/` 또는 별도 레이어에 분리
- API 라우터와 비즈니스 로직 결합 금지

### 타입 힌트
- 모든 함수 시그니처에 타입 힌트 명시 (mypy strict 권장)

## 코드 리뷰 우선 체크 항목

상세 체크리스트: `.claude/skills/code-review.md` — **보안**, **성능**, **테스트** 섹션 우선 확인

- **Critical**: SQL 인젝션, 하드코딩된 시크릿, 인증·인가 누락
- **High**: N+1 쿼리, 페이지네이션 누락, 예외 미처리
