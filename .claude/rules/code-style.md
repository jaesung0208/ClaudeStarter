---
description: 모든 코드 작업 시 항상 로드. 스택과 무관한 글로벌 코드 품질 기준.
globs: ["**/*"]
alwaysApply: true
---

# 코드 스타일 — 스택 무관 공통 원칙

> 이 규칙은 Python·TypeScript·Java·C# 등 모든 스택에 공통 적용된다.
> 스택별 상세 규칙은 `.claude/rules/stack/backend-*.md`, `frontend-*.md` 참조.

---

## 1. 주석 작성 원칙

- **함수·메서드 상단**: 목적·파라미터·반환값 명시 (JSDoc / docstring / Javadoc / XML doc comment 등 스택별 표준 형식 사용)
- **WHAT 주석 지양**: 코드 자체로 읽히도록 작성 (변수명·함수명이 의도를 전달)
- **WHY 주석 필수**: 다음의 경우 반드시 주석으로 기록
  - 비직관적인 우회 처리 이유 (워크어라운드)
  - 외부 시스템·라이브러리 제약으로 인한 특수 처리
  - 성능 최적화를 위한 특이 구현
  - 도메인 규칙으로 인한 특정 분기

### 예시 (Python)
```python
# ❌ WHAT 주석 — 코드만 보면 명백함
# user_id를 받아서 user 객체를 반환한다
def get_user(user_id: int) -> User: ...

# ✅ WHY 주석 — 의도가 드러나지 않는 부분만
def get_user(user_id: int) -> User:
    # 캐시 우회: 권한 변경 직후에는 최신 권한이 필요하므로 DB 직접 조회
    return db.query(User).filter_by(id=user_id).first()
```

---

## 2. 함수 길이

- **권고**: 50줄 이하
- **80줄 초과 시**: 단일 책임 원칙(SRP) 기준으로 분리 가능한 단위 제안
- 단순 데이터 매핑·DTO 변환 등 본질적으로 긴 함수는 예외 (그러나 별도 함수로 추출 가능한지 우선 검토)

---

## 3. 에러 핸들링 (핵심)

### 3-1. Silent Catch 절대 금지
모든 catch 블록에는 반드시 로그 출력이 있어야 한다.

```typescript
// ❌ Silent catch — 절대 금지
try {
  await processOrder(orderId);
} catch (e) {
  // 아무것도 안 함
}

// ❌ catch만 있고 로그 없음
try {
  await processOrder(orderId);
} catch (e) {
  return null;
}

// ✅ 로그 + 명시적 재던지기 또는 처리
try {
  await processOrder(orderId);
} catch (e) {
  logger.error({ orderId, error: e }, 'Order processing failed');
  throw e;  // 상위 레이어에서 일관된 에러 응답 처리 위함
}
```

### 3-2. 재던지기 결정 명시
catch 블록에서 처리 후:
- **재던지기**: 상위 레이어에서 일관된 에러 응답을 만들기 위함 — 주석으로 사유 기재
- **흡수(swallow)**: 비즈니스적으로 무시 가능한 경우 — 주석으로 사유 명시

### 3-3. 레이어별 책임
- **Repository / DAO 레이어**: 인프라 예외를 도메인 예외로 변환
- **Service 레이어**: 비즈니스 규칙 위반을 명확한 도메인 예외로 표현
- **Controller / Route 레이어**: 도메인 예외를 HTTP 상태 코드로 매핑

### 3-4. 민감정보 로그 제외
로그에 다음 정보 포함 절대 금지:
- 비밀번호·평문
- API 토큰·세션 토큰
- 주민번호·신용카드 번호 등 개인정보
- 환자 식별 정보 (의료 데이터)

→ 식별자(ID)나 마스킹된 값만 기록 (예: `email: m***@example.com`)

---

## 4. 금지 패턴

다음 패턴은 생성 금지. 발견 시 즉시 수정.

### 4-1. 디버그 출력 잔존
- Python: `print()` (디버그 목적)
- JavaScript / TypeScript: `console.log()` · `console.debug()`
- Java: `System.out.println()` · `System.err.println()`
- C#: `Console.WriteLine()` (디버그 목적)

→ 모두 **로깅 프레임워크 (Logger)** 사용:
- Python: `logging`, `loguru`, `structlog`
- Node.js: `pino`, `winston`
- Java: SLF4J + Logback
- .NET: `ILogger<T>` (Microsoft.Extensions.Logging) 또는 Serilog

### 4-2. 타입 안전성 회피
- TypeScript: `any` 남용 → `unknown` + 타입 가드 또는 정확한 타입 정의
- Java: `Object` 타입 남용 → 제네릭 또는 정확한 타입
- Python: `Any` 남용 → `TypedDict`, `Protocol`, `Union` 등 활용
- C#: `dynamic` 남용 → 강타입

### 4-3. 중첩 if 3단계 이상
중첩이 깊어지면 가독성이 급격히 떨어진다.

```python
# ❌ 4단계 중첩
def process(user):
    if user:
        if user.is_active:
            if user.has_permission:
                if user.email_verified:
                    do_something()

# ✅ Early return으로 평탄화
def process(user):
    if not user: return
    if not user.is_active: return
    if not user.has_permission: return
    if not user.email_verified: return
    do_something()
```

### 4-4. TODO·FIXME 방치
- `// TODO: 나중에 구현` → **금지**
- 정말 즉시 구현 불가하다면:
  - 이슈 트래커에 등록 후 주석에 이슈 번호 기재 (예: `// TODO: 캐시 갱신 로직 추가 (ISSUE-123)`)
  - 또는 명시적으로 `NotImplementedError` 던지기 + 사유 명시

---

## 5. 변수·함수·파일 네이밍

- 임의 약어·축약어 사용 금지 (도메인 표준 외)
- 일관된 케이스 규칙 적용 (스택별 룰 따름):
  - 변수·함수: camelCase (Java/TS/C#) 또는 snake_case (Python)
  - 클래스·컴포넌트: PascalCase
  - 상수: UPPER_SNAKE_CASE
  - DB 컬럼: snake_case (프로젝트 기준 따름)
- 도메인 용어 사전이 있으면 (`docs/domain-glossary.md`) 그 표기를 따름

---

## 6. 작업 범위 준수 (Strict Guardrails)

- 요청 범위 외 파일 삭제·폴더 구조 변경·리팩토링 **절대 금지**
- 기존 코드 대량 수정 전 영향 범위를 먼저 설명
- 파일 삭제·이동 시 반드시 사용자 확인 후 진행
