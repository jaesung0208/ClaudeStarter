---
description: TypeScript 백엔드 (NestJS/Express) 개발 시 자동 로드.
globs: ["**/*.ts", "package.json", "tsconfig.json"]
---

## TypeScript 백엔드 개발 필수 준수 사항

### 테스트
- 새 API 엔드포인트 추가 시 통합 테스트 필수 (Vitest 또는 Jest)
- 컨트롤러·서비스 단위 테스트 분리
- 테스트 파일은 `*.spec.ts` 또는 `tests/` 디렉토리

### TypeScript
- `tsconfig.json`에 `strict: true` 필수
- `any` 타입 사용 최소화 — 불가피한 경우 주석으로 사유 명시
- 공유 타입은 `types/` 또는 `interfaces/` 디렉토리에 정의

### DB 마이그레이션
- 스키마 변경 시 ORM 마이그레이션 파일 동시 생성 (Prisma migrate, TypeORM migration)
- 프로덕션 DB에 직접 DDL 실행 금지

### 보안 (ISMS)
- 환경변수는 `.env` 또는 환경 주입으로만 로드 — 코드 하드코딩 금지
- `process.env.X`는 검증 후 사용 (zod 또는 class-validator 권장)
- SQL/NoSQL 인젝션: ORM Query Builder 또는 Prepared Statement 필수

### 의존성 주입 (NestJS)
- 모듈 단위로 의존성 명시 — 글로벌 인스턴스 직접 import 금지
- 서비스는 `@Injectable()` 데코레이터 필수

### 에러 처리
- HttpException 또는 커스텀 Exception 사용
- 스택 트레이스가 응답에 포함되지 않도록 글로벌 필터 적용

## 코드 리뷰 우선 체크 항목

상세 체크리스트: `.claude/skills/code-review.md`

- **Critical**: SQL/NoSQL 인젝션, 하드코딩된 시크릿, 인증·인가 누락
- **High**: any 타입 남용, 의존성 주입 누락, 예외 미처리
