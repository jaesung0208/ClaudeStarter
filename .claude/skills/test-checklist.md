# test-checklist

Sprint / Hotfix / deploy-prod 단계별 검증 매트릭스입니다.

## 테스트 전략 기반 (Testing Trophy)

이 프로젝트의 테스트 우선순위는 Kent C. Dodds의 **Testing Trophy** 원칙을 따른다. (출처: kentcdodds.com, 2024)

```
          [ E2E 테스트 ]     ← 핵심 사용자 워크플로우만
      [ 통합 테스트 ]         ← 최우선 (가장 높은 ROI)
    [ 단위 테스트 ]           ← 복잡한 비즈니스 로직에만
  [ 정적 분석 / 린트 ]        ← 항상 실행
```

**핵심 원칙**:
- "테스트가 소프트웨어가 실제로 사용되는 방식과 유사할수록, 더 큰 신뢰를 준다."
- 테스트는 **구현 상세가 아닌 동작**을 검증한다 (Google Testing on the Toilet)
- 커버리지 목표: 핵심 비즈니스 로직 **80%+** / 100% 달성 강제는 오히려 유지보수 부담 증가

## 검증 매트릭스

| 검증 항목 | Sprint | Hotfix | deploy-prod | 자동/수동 | 수동 담당 |
|-----------|--------|--------|-------------|----------|---------|
| `$BACKEND_TEST_CMD` (예: `pytest -v`, `pnpm test`, `./gradlew test`) (백엔드 통합 테스트) | ✅ | ✅ | — | **자동** | — |
| API curl/httpx 검증 | ✅ 전체 | ✅ 변경분만 | — | **자동** | — |
| 데모 모드 API 검증 | ✅ | — | — | **자동** | — |
| Playwright UI 검증 | ✅ 전체 | ✅ 변경분만 | ✅ 접속만 | **자동** | — |
| SSH 헬스체크 (`/api/v1/health`) | — | — | ✅ | **자동** | — |
| Docker 컨테이너 상태 확인 | — | — | ✅ | **자동** | — |
| 백엔드 로그 오류 확인 | — | — | ✅ | **자동** | — |
| `docker compose up --build` | ⬜ | ⬜ | — | **수동** | 개발자 (스프린트 구현자) |
| `alembic upgrade head` | ⬜ DB변경시 | — | ✅ DB변경시 (deploy.yml 자동) | **혼합** | 로컬: 수동 / 프로덕션: GitHub Actions 자동 |
| UI 디자인/시각적 품질 판단 | ⬜ | — | ⬜ | **수동** | 개발자 또는 기획자 |

## 자동 검증 전제 조건

- Docker 컨테이너가 실행 중일 때만 자동 실행
- 서버가 응답하는지 확인 후 진행 (`http://localhost:3000`, `http://localhost:8000`)
- Docker가 미실행인 경우: 자동 검증을 건너뛰고, DEPLOY.md에 "⬜ Docker 미실행으로 자동 검증 미수행" 기록 후 수동 검증 항목으로 안내

## 수동 항목 미완료 시 진행 기준

수동 항목(`⬜`)이 남은 상태에서의 **PR 생성** 가능 여부:

| 수동 항목 | 미완료 시 PR 생성 차단 여부 | 근거 |
|----------|---------------------------|------|
| `docker compose up --build` | **차단 안 함** — PR 생성 진행 가능. 단, DEPLOY.md에 `⬜` 기록 필수 | 로컬 검증이므로 PR 생성과 병렬 수행 가능 |
| `alembic upgrade head` (로컬) | **차단 안 함** — 프로덕션 자동 적용되므로 로컬 미수행 시 DEPLOY.md에 `⬜` 기록 | 프로덕션은 GitHub Actions가 처리 |
| UI 디자인/시각적 품질 판단 | **차단 안 함** — PR 생성 진행 가능. DEPLOY.md에 `⬜` 기록 후 merge 전 완료 권고 | 기능 오류가 아닌 품질 판단이므로 팀 협의 후 결정 |

**공통 규칙**: 위 항목들은 PR **생성**을 차단하지 않는다. 그러나 모든 수동 항목이 `✅`로 완료되기 전까지 **merge/배포는 진행하지 않는다**. Critical 보안 이슈와 관련된 수동 항목은 반드시 완료 후 merge한다.

## Flaky 테스트 처리

CI 자동 검증 중 불규칙적으로 실패하는 테스트(Flaky Test)를 만나면 아래 기준으로 처리한다.

**판별 기준**: 동일 테스트가 변경 없이 3회 실행 중 1회 이상 성공하면 flaky로 분류한다.

**주요 원인**:
- 타이밍 의존성 (sleep, 명시적 대기 없이 비동기 처리)
- 외부 서비스 응답 지연
- 테스트 순서 의존성 (이전 테스트의 상태를 공유)

**처리 방법**:
1. Flaky로 분류된 테스트는 DEPLOY.md에 `⬜ Flaky 테스트 발견: {테스트명} — 수동 재실행 필요`로 기록한다.
2. 해당 테스트 결과를 배포 차단 기준에서 제외하고 나머지 검증을 계속 진행한다.
3. 다음 스프린트 백엔드 작업 목록에 수정 항목으로 등록한다.

## 검증 결과 기록

- 자동 검증 결과는 DEPLOY.md에 즉시 기록
- 스크린샷은 `docs/sprint/sprint{n}/` 폴더에 저장
- `✅ 자동 검증 완료` / `⬜ 수동 검증 필요` 구분 표시

## 검증 항목 정의

프로젝트 환경에 따라 일부 항목이 해당하지 않을 수 있다. 미해당 항목은 DEPLOY.md에 이유를 기록한다.

- **데모 모드 API 검증**: 인증 없이 접근 가능한 공개 엔드포인트(예: `/api/v1/health`, `/api/v1/demo/*`) 또는 시드 데이터로 동작하는 읽기 전용 API를 검증하는 단계. 해당 엔드포인트가 없는 프로젝트는 이 항목을 생략하고 DEPLOY.md에 `⬜ 데모 모드 없음 — 항목 해당 없음`으로 기록한다.

- **Playwright UI 검증**: Playwright가 설치·구성된 경우에만 실행. 미설치 시 자동 검증을 건너뛰고 DEPLOY.md에 `⬜ Playwright 미설치 — 수동 UI 검증 필요`로 기록한다.

- **alembic upgrade head**: DB 스키마 변경이 포함된 스프린트에만 해당. DB 변경이 없으면 이 항목은 생략한다.

---

## AI 생성 코드 3단계 테스트 기준 (품질 검증)

> 로드맵 Q3 표준 항목: AI가 코드를 생성할 때 테스트 코드를 **동시에 요청**하는 것을 원칙으로 한다.
> sprint-planner는 Task Breakdown 작성 시 테스트 Task를 구현 Task와 함께 배정한다.

### 단계 1: 단위 테스트 (Unit Test) — 필수

- 함수·메서드 단위 입출력 검증
- AI 코드 생성 시 테스트 코드 **동시 요청** 원칙:
  > "이 함수를 구현하고 pytest 단위 테스트도 함께 작성해줘"
- 커버리지 기준: 핵심 비즈니스 로직 80%+
- 파일 위치: `app/backend/tests/test_{모듈명}.py`

```python
# 예시: 정상 케이스 + 오류 케이스 동시 작성
def test_calculate_price_normal():
    assert calculate_price(100, 0.1) == 110

def test_calculate_price_zero():
    assert calculate_price(0, 0.1) == 0

def test_calculate_price_negative_raises():
    with pytest.raises(ValueError):
        calculate_price(-1, 0.1)
```

### 단계 2: 시나리오 테스트 (Scenario Test) — 필수

- 주요 사용자 흐름 기반 통합 검증
- **정상 케이스** + **오류 케이스** 반드시 포함
- API 엔드포인트 단위로 요청→응답 전체 흐름 검증
- 인증 흐름이 있는 경우 인증 토큰 포함 시나리오 필수

```python
# 예시: 정상 + 401 오류 케이스
def test_create_user_success(client):
    response = client.post("/api/users", json={"email": "test@example.com"})
    assert response.status_code == 201

def test_create_user_unauthorized(client):
    response = client.post("/api/users", json={"email": "test@example.com"})
    # 인증 헤더 없는 경우
    assert response.status_code == 401
```

### 단계 3: 엣지케이스 테스트 (Edge Case Test) — 필수

아래 케이스를 명시적으로 검증한다:

| 케이스 유형 | 예시 |
|------------|------|
| 빈값·null 입력 | `None`, `""`, `[]`, `{}` |
| 경계값 | 최솟값/최댓값, 0, 음수 |
| 권한 없는 접근 | 다른 사용자 리소스 접근 시도 |
| 중복 데이터 | 동일 이메일 재가입 시도 |
| 긴 문자열 | 최대 길이 초과 입력 |
| 특수문자 | SQL Injection 시도 패턴 (`' OR 1=1`) |

```python
# 예시: 엣지케이스 명시
def test_create_user_empty_email(client):
    response = client.post("/api/users", json={"email": ""})
    assert response.status_code == 422

def test_create_user_duplicate_email(client, existing_user):
    response = client.post("/api/users", json={"email": existing_user.email})
    assert response.status_code == 409

def test_access_other_user_resource_forbidden(client, other_user_token):
    response = client.get("/api/users/999", headers={"Authorization": f"Bearer {other_user_token}"})
    assert response.status_code == 403
```

### 테스트 요청 프롬프트 가이드

AI에게 테스트 코드를 요청할 때 아래 형식을 사용한다:

```
"{기능명}을 구현하고, 다음 3가지 테스트를 함께 작성해줘:
1. 단위 테스트: 정상 케이스 + 오류 케이스
2. 시나리오 테스트: 사용자 흐름 전체
3. 엣지케이스: null·빈값·경계값·권한 없는 접근"
```
