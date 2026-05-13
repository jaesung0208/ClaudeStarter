# secure-coding

> **호출 시점**: sprint-planner가 보안 관련 Task에 자동 배정 / 개발자가 명시적 참조 시
> **목적**: ISMS 인증 기반 보안 항목 — AI 코드 생성 시 필수 점검 체크리스트

---

## 1. 개인정보 보호 (필수)

- 수집·저장·전송 단계별 처리 기준 준수, 불필요한 개인정보 수집 금지
- API 응답·로그·에러 메시지에 개인정보(이름, 전화번호, 이메일 등) 포함 금지
- 응답 바디에서 민감 필드 마스킹 처리 필수:
  ```python
  # 금지
  return {"user": user.__dict__}
  # 권장
  return {"user": {"id": user.id, "email": mask_email(user.email)}}
  ```

## 2. 암호화 (필수)

- 개인정보·인증정보 저장 시 단방향 암호화 (bcrypt / argon2) 사용
- 비밀번호 평문 저장·비교 절대 금지
- 서비스 간 전송 시 TLS 필수 (http:// 엔드포인트 사용 금지)
- JWT 서명 알고리즘: HS256 이상, 시크릿은 .env에서 주입

## 3. 민감정보 노출 방지 (필수)

- SQL Injection 대응: ORM 또는 Parameterized Query 사용, 문자열 직접 조합 금지
  ```python
  # 금지
  query = f"SELECT * FROM users WHERE id = {user_id}"
  # 권장
  query = "SELECT * FROM users WHERE id = %s"
  cursor.execute(query, (user_id,))
  ```
- XSS 대응: 사용자 입력 출력 시 이스케이프 처리, innerHTML 직접 삽입 금지
- 에러 메시지에 스택 트레이스·쿼리·내부 경로 노출 금지 (프로덕션 환경)
- CORS: 허용 오리진 명시적 지정, `*` 사용 금지

## 4. 하드코딩 금지 (필수)

아래 항목은 반드시 환경변수 또는 설정 파일로 분리:
- API Key / Secret Key
- DB 접속 정보 (HOST, PORT, USER, PASSWORD)
- 서비스 URL / 외부 엔드포인트
- JWT Secret

```python
# 금지
API_KEY = "sk-abc123"
# 권장
API_KEY = os.environ.get("API_KEY")
```

## 5. DDL 임의 실행 금지 (필수)

`CREATE`, `DROP`, `ALTER`, `TRUNCATE` 구문은:
- 명시적 사용자 요청 시에만 실행
- 실행 전 반드시 2차 확인 (영향 범위 설명 후 승인 대기)
- 프로덕션 DB에 직접 실행 금지 — 마이그레이션 스크립트(alembic 등) 경유 필수

## 6. 감사 로그 — Audit Trail (필수, ISMS 핵심)

> ISMS 인증 기준에서 가장 자주 지적되는 항목. **의료 데이터·금융 데이터 처리 시 특히 중요**.

### 6-1. 감사 로그 의무 기록 대상
다음 이벤트는 반드시 별도 감사 로그에 기록:

| 카테고리 | 이벤트 |
|---|---|
| **인증** | 로그인 성공·실패, 로그아웃, 비밀번호 변경, 비밀번호 초기화 |
| **인가** | 권한 변경 (역할 부여·회수), 권한 거부 (403) |
| **민감 데이터 접근** | 개인정보·의료정보·금융정보 조회·수정·삭제·다운로드 |
| **관리자 작업** | 사용자 계정 생성·삭제·정지, 시스템 설정 변경 |
| **데이터 내보내기** | CSV·Excel·PDF 등 대량 다운로드 |

### 6-2. 감사 로그 필수 항목

| 필드 | 형식 | 예시 |
|---|---|---|
| `timestamp` | ISO 8601 (UTC) | `2026-05-11T09:23:45Z` |
| `actor_id` | 사용자 식별자 (ID, 이메일 마스킹) | `user_12345` 또는 `m***@example.com` |
| `action` | 표준 액션 코드 | `LOGIN_SUCCESS`, `PATIENT_RECORD_VIEWED` |
| `resource_type` | 대상 리소스 종류 | `Patient`, `Prescription` |
| `resource_id` | 대상 식별자 | `patient_98765` |
| `result` | 성공/실패 | `success` / `failure` |
| `client_ip` | 클라이언트 IP | `192.0.2.1` |
| `user_agent` | 클라이언트 User-Agent | (선택) |
| `reason` | 실패 시 사유 (민감정보 제외) | `Invalid credentials` |

### 6-3. 절대 기록 금지 항목
- 비밀번호 원문 또는 해시값
- API 토큰·세션 토큰 전체 값 (앞 4글자만 가능)
- 주민번호·신용카드 번호 원문
- 환자 의료 기록 본문 (식별자만)

### 6-4. 감사 로그 저장소
- 일반 애플리케이션 로그와 **분리된 저장소** 사용
  - 별도 DB 테이블 (예: `audit_logs`)
  - 또는 별도 파일 (`audit-YYYY-MM-DD.log`)
  - 또는 외부 로깅 서비스 (Datadog, Splunk 등)
- **변조 방지**: 애플리케이션 권한으로 INSERT만 가능, UPDATE·DELETE 금지
- **보관 기간**: ISMS 기준 최소 1년, 의료 데이터는 5년 이상 권장

### 6-5. 구현 예시 (스택 무관 의사 코드)
```
# 감사 로그 기록 헬퍼
def audit_log(actor_id, action, resource_type, resource_id, result, **extra):
    audit_db.insert({
        "timestamp": utc_now_iso8601(),
        "actor_id": actor_id,
        "action": action,
        "resource_type": resource_type,
        "resource_id": resource_id,
        "result": result,
        "client_ip": request.client_ip,
        **extra
    })

# 사용 예 — 환자 기록 조회 시
@require_auth
def get_patient(patient_id):
    patient = patient_service.get(patient_id)
    audit_log(
        actor_id=current_user.id,
        action="PATIENT_RECORD_VIEWED",
        resource_type="Patient",
        resource_id=patient_id,
        result="success"
    )
    return mask_pii(patient)
```

## 7. 인증·인가 (권고)

- 모든 인증 필요 엔드포인트에 토큰 검증 미들웨어 적용
- 권한 없는 리소스 접근 시 403 반환 (401과 구분)
- 비밀번호 변경·민감 작업 시 재인증 요구

## 8. 코드 생성 후 보안 체크리스트

AI가 코드를 생성한 후 반드시 아래 항목을 점검:

| 항목 | 확인 방법 |
|------|----------|
| 하드코딩 시크릿 없음 | posttooluse hook 자동 감지 |
| SQL Parameterized 사용 | 코드 리뷰 시 직접 확인 |
| 에러 응답 내 스택 트레이스 없음 | 에러 핸들러 코드 확인 |
| 개인정보 응답 마스킹 | API 응답 스키마 확인 |
| CORS 허용 오리진 명시 | 설정 파일 확인 |
| DDL 문 포함 여부 | DB 관련 코드 직접 확인 |
| 감사 로그 기록 (인증·민감 데이터 접근 시) | audit_log 호출 여부 확인 |
| 감사 로그에 민감정보 미포함 | 로그 출력 코드 직접 검토 |

## 관련 문서

- ISMS 인증 기준: `docs/harness-engineering/` 참조
- 시크릿 관리: `.env.example` / `.claude/hooks/posttooluse-code-validator.sh`
- 배포 전 보안 게이트: `.claude/skills/harness-ci-gate.md`
