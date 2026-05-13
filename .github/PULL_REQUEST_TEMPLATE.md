# PR 설명

## 변경 유형

- ⬜ 버그 수정 (Hotfix)
- ⬜ 새 기능 (Sprint)
- ⬜ 리팩토링
- ⬜ 문서 수정

## 관련 스프린트 / 이슈

- 관련 Sprint: `sprint{n}` / Hotfix: `hotfix/{설명}`

## 변경 내용 요약

-

## 코드 리뷰 체크리스트

> 상세 기준: `CLAUDE.md`의 "응답 마지막 자가 체크포인트 (14개 항목)" 참조
> 추가 상세: `docs/dev-process.md` · `.claude/skills/secure-coding.md`

### 작업 범위
- ⬜ 요청 범위 외 파일 미수정
- ⬜ 삭제·변경된 기존 기능 없음

### 보안 (ISMS)
- ⬜ 하드코딩된 시크릿·API 키·비밀번호 없음
- ⬜ 사용자 입력 유효성 검증
- ⬜ SQL 인젝션 방지 (Parameterized Query 또는 ORM)
- ⬜ 개인정보·민감정보가 로그/응답에 노출되지 않음
- ⬜ 인증·인가 체크 누락 없음 (해당 시)
- ⬜ 감사 로그 기록 (인증·민감 데이터 접근 시)

### 코드 품질
- ⬜ 테스트 코드 함께 작성 (정상·오류·엣지케이스)
- ⬜ 함수 50줄 이하 (80줄+ 시 분리)
- ⬜ 디버그 출력 (console.log·print 등) 미잔존 — Logger 사용
- ⬜ Silent catch 없음 (catch 블록에 로그 출력)
- ⬜ TypeScript `any` 등 타입 안전성 회피 없음

### 문서 일관성
- ⬜ MD 파일의 경로·파일명이 실제 파일시스템과 일치
- ⬜ 파일 추가·삭제·이동 시 관련 MD 반영
- ⬜ MD 기술 내용이 실제 상태와 일치

### CI
- ⬜ 백엔드 테스트 통과 (`$BACKEND_TEST_CMD` — project-spec.conf 참조)
- ⬜ 프론트엔드 테스트 통과 (`$FRONTEND_TEST_CMD`, 해당 시)
- ⬜ 컨테이너 빌드 성공 (CONTAINER_RUNTIME=docker/podman 시)

## 테스트 방법

```bash
# project-spec.conf 로드 후 스택별 명령 실행
source .claude/project-spec.conf

# 백엔드 테스트
eval "$BACKEND_TEST_CMD"

# 프론트엔드 테스트 (해당 시)
eval "$FRONTEND_TEST_CMD"

# 로컬 스테이징 (CONTAINER_RUNTIME=docker 시)
# docker compose up --build
```

스택별 명령 매핑: [`docs/build-commands.md`](../docs/build-commands.md)

## 스크린샷 (UI 변경 시)

<!-- 변경된 UI 스크린샷을 첨부하세요 -->
