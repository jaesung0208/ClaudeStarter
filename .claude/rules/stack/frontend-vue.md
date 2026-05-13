---
description: Vue 3 프론트엔드 개발 시 자동 로드.
globs: ["**/*.vue", "**/*.ts", "**/*.js"]
---

## Vue 3 개발 필수 준수 사항

### TypeScript / Composition API
- `<script setup lang="ts">` 권장
- `tsconfig.json`에 `strict: true` 필수
- `any` 타입 사용 최소화

### API 통합
- 백엔드 API 호출은 `composables/` 또는 `services/`에서만 — 컴포넌트 직접 호출 금지
- 환경변수: `VITE_` 접두사로만 노출, 시크릿 절대 포함 금지

### 보안 (ISMS)
- `v-html` 사용 지양 — XSS 방지 (불가피한 경우 DOMPurify 등으로 sanitize)
- 사용자 입력은 머스타치(`{{ }}`) 사용 — 자동 이스케이프됨
- 인증 토큰은 httpOnly 쿠키 또는 Pinia store 메모리만 사용 — localStorage 금지
- Composables에 민감 정보 노출 금지

### 상태 관리
- 컴포넌트 로컬 상태: `ref()` / `reactive()`
- 글로벌 상태: Pinia 사용 권장
- 서버 상태: VueQuery 또는 unhead 등

### 컴포넌트 구조
- `<script setup>` + `<template>` + `<style scoped>` 순서
- Props는 `defineProps` with TypeScript 타입
- Emits는 `defineEmits`로 명시

### 에러 처리
- `onErrorCaptured` 또는 `app.config.errorHandler`로 전역 처리
- 사용자에게 친절한 에러 메시지 표시

## 코드 리뷰 우선 체크 항목

- **Critical**: XSS (`v-html` + 사용자 입력), 민감정보 노출, localStorage 인증 토큰
- **High**: TypeScript `any` 남용, Composables 외 API 호출, 글로벌 에러 핸들러 누락
