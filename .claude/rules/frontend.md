---
description: 프론트엔드 파일 작업 시 자동 로드. 프로젝트 스택에 맞는 가이드를 디스패치한다.
globs:
  - "**/*.tsx"
  - "**/*.jsx"
  - "**/*.vue"
  - "**/*.svelte"
  - "**/next.config.*"
  - "**/vite.config.*"
  - "**/nuxt.config.*"
---

## 프론트엔드 가이드 디스패처

이 프로젝트의 프론트엔드 스택은 `.claude/project-spec.conf`의 `FRONTEND_STACK` 값을 따른다.

스택별 상세 가이드:

| FRONTEND_STACK 값 | 상세 가이드 |
|---|---|
| `react-vite` | [.claude/rules/stack/frontend-react.md](stack/frontend-react.md) |
| `vue` | [.claude/rules/stack/frontend-vue.md](stack/frontend-vue.md) |
| `nextjs` | [.claude/rules/stack/frontend-nextjs.md](stack/frontend-nextjs.md) |

## 스택 무관 공통 원칙

스택과 관계없이 모든 프론트엔드 코드에 적용된다:

### 보안 (ISMS)
- XSS 방어: HTML 직접 삽입 (`dangerouslySetInnerHTML`, `v-html` 등) 지양
- 인증 토큰: httpOnly 쿠키 또는 메모리만 — localStorage 금지
- 시크릿: 클라이언트 번들에 절대 포함 금지

### TypeScript (사용 시)
- `strict: true` 필수
- `any` 타입 사용 최소화

### API 통합
- 백엔드 API 호출은 추상화 레이어 경유 — 컴포넌트 직접 호출 금지

상세 보안 체크리스트: `.claude/skills/secure-coding.md`
