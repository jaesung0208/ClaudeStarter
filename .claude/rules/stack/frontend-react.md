---
description: React (Vite) 프론트엔드 개발 시 자동 로드.
globs: ["**/*.tsx", "**/*.jsx", "**/*.ts", "**/*.js"]
---

## React 개발 필수 준수 사항

### TypeScript
- `tsconfig.json`에 `strict: true` 필수
- `any` 타입 사용 최소화
- 공유 타입은 `types/` 디렉토리에 정의

### API 통합
- 백엔드 API 호출은 반드시 `api/` 또는 `services/` 디렉토리의 클라이언트 추상화 레이어 경유
- 컴포넌트에서 `fetch`/`axios` 직접 호출 금지
- 환경변수: `VITE_` 접두사로만 노출, 시크릿 절대 포함 금지

### 보안 (ISMS)
- `dangerouslySetInnerHTML` 사용 지양 — XSS 방지
- 사용자 입력 렌더링 시 자동 이스케이프 활용
- 인증 토큰은 httpOnly 쿠키 또는 메모리(useState)에만 저장 — localStorage 금지
- 민감 데이터는 응답에서 제거 후 store에 저장

### 상태 관리
- 컴포넌트 로컬 상태: `useState`
- 서버 상태: React Query / SWR / Tanstack Query 사용
- 글로벌 클라이언트 상태: Zustand / Jotai / Redux Toolkit

### UI 컴포넌트
- 디자인 시스템 라이브러리 우선 검토 (shadcn/ui, Radix, MUI 등)
- 재사용 컴포넌트는 `components/` 디렉토리에 분리

### 에러 처리
- API 실패 시 UI 크래시 방지를 위한 ErrorBoundary 적용
- 사용자에게 친절한 에러 메시지 표시

## 코드 리뷰 우선 체크 항목

- **Critical**: XSS (`dangerouslySetInnerHTML`, 사용자 입력 직접 렌더링), 민감정보 노출, localStorage 인증 토큰
- **High**: TypeScript `any` 남용, API 직접 호출 패턴, ErrorBoundary 누락
