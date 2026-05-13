---
description: Java 백엔드 (Spring Boot) 개발 시 자동 로드.
globs: ["**/*.java", "pom.xml", "build.gradle", "build.gradle.kts"]
---

## Java/Spring Boot 백엔드 개발 필수 준수 사항

### 테스트
- 새 API 엔드포인트 추가 시 `@SpringBootTest` 또는 `@WebMvcTest` 통합 테스트 필수
- 비즈니스 로직 단위 테스트 (JUnit 5 + Mockito)
- 테스트 파일은 `src/test/java/` 하위

### DB 마이그레이션
- 스키마 변경 시 Flyway 또는 Liquibase 마이그레이션 파일 동시 생성
- 프로덕션 DB에 직접 DDL 실행 금지
- JPA의 `ddl-auto: update`는 프로덕션 금지

### 보안 (ISMS)
- 환경변수·시크릿은 `application.yml`/`application.properties`가 아닌 환경 주입으로 (Spring profile + env)
- DB 접속 정보·API 키 하드코딩 금지
- Spring Security: 비밀번호는 `BCryptPasswordEncoder` 사용
- SQL 인젝션: JPA Query Method 또는 `@Query` with named parameter 사용 (문자열 결합 금지)

### 의존성 주입
- 생성자 주입 사용 (필드 주입 금지 — final 필드로 immutable)
- `@Component` 스캔 범위 명시

### 예외 처리
- `@ControllerAdvice`로 글로벌 예외 핸들러 구성
- 스택 트레이스가 응답에 포함되지 않도록 에러 응답 DTO 사용

### 성능
- JPA fetch 전략: 기본 LAZY, 필요 시 JOIN FETCH 사용 (N+1 방지)
- 페이지네이션: `Pageable` 사용

## 코드 리뷰 우선 체크 항목

- **Critical**: SQL 인젝션 (`@Query` 문자열 결합), 인증·인가 누락
- **High**: N+1 쿼리, 필드 주입, 예외 미처리, ddl-auto 프로덕션 설정
