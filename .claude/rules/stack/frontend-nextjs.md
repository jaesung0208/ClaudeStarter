---
description: Next.js 프론트엔드 개발 시 자동 로드.
globs: ["**/*.tsx", "**/*.jsx", "next.config.*"]
---

## Next.js 개발 필수 준수 사항

### App Router vs Pages Router
- 신규 프로젝트는 App Router 권장
- Server Component / Client Component 명시적 구분 (`"use client"` 지시어)

### TypeScript
- `tsconfig.json`에 `strict: true` 필수
- `any` 타입 사용 최소화

### 서버 vs 클라이언트
- 시크릿(API 키 등)은 Server Component / Route Handler에서만 사용
- Client Component에 `process.env.SECRET_*` 접근 금지
- 환경변수 클라이언트 노출 시 `NEXT_PUBLIC_` 접두사 필수 (시크릿 포함 금지)

### API 라우트 / Route Handler
- `/app/api/` 또는 `/pages/api/` 에서만 외부 API 키·DB 호출
- 클라이언트에서 직접 외부 API 호출 시 시크릿 노출 위험

### 보안 (ISMS)
- `dangerouslySetInnerHTML` 사용 지양
- 인증: NextAuth.js 또는 자체 구현 시 httpOnly 쿠키 사용
- CSRF 방어: SameSite 쿠키 + 토큰 검증

### 데이터 페칭
- Server Component: 직접 fetch (캐시 활용)
- Client Component: SWR / React Query 사용
- `revalidate` 옵션 명시

### 이미지
- `<img>` 대신 `next/image` 사용 (성능, LCP 최적화)

## 코드 리뷰 우선 체크 항목

- **Critical**: 시크릿 클라이언트 노출 (`NEXT_PUBLIC_` 접두사 오용), XSS, 인증 토큰 localStorage
- **High**: Server/Client Component 혼동, 이미지 최적화 누락
