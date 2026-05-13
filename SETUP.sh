#!/usr/bin/env bash
# SETUP.sh — ClaudeStarter 인터랙티브 초기화 마법사 v2.0
# 실행: ./SETUP.sh
# 역할: 신규/기존 분기 + 스택 선택/감지 + project-spec.conf 생성

set -e

# ── 색상 정의 ──────────────────────────────────────────────────────
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'
CYAN='\033[0;36m'; BLUE='\033[0;34m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
err()  { echo -e "${RED}❌ $1${NC}"; }
info() { echo -e "${CYAN}ℹ️  $1${NC}"; }
hdr()  { echo ""; echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; \
         echo -e "${BLUE}  $1${NC}"; \
         echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

# ── 전역 변수 (project-spec.conf 출력용) ────────────────────────────
PROJECT_NAME=""
PROJECT_DESCRIPTION=""
PROJECT_TYPE=""
GITHUB_ORG=""
GITHUB_REPO=""
BACKEND_STACK="none"
BACKEND_DIR=""
BACKEND_TEST_CMD=""
BACKEND_LINT_CMD=""
BACKEND_BUILD_CMD=""
BACKEND_RUN_CMD=""
FRONTEND_STACK="none"
FRONTEND_DIR=""
FRONTEND_TEST_CMD=""
FRONTEND_LINT_CMD=""
FRONTEND_BUILD_CMD=""
DB_TYPE="none"
DB_MIGRATION_TOOL=""
CONTAINER_RUNTIME="none"
CLOUD_PROVIDER="none"
CI_TOOL="github-actions"
SECURITY_LEVEL="1"
RECOMMENDED_LINTER=""
RECOMMENDED_FORMATTER=""
RECOMMENDED_ORM=""

# ── 스택 ID → 권장 명령어 매핑 함수 ──────────────────────────────────
_apply_backend_defaults() {
  case "$1" in
    python-fastapi)
      BACKEND_TEST_CMD="pytest"
      BACKEND_LINT_CMD="ruff check ."
      BACKEND_BUILD_CMD=""
      BACKEND_RUN_CMD="uvicorn main:app --reload"
      RECOMMENDED_LINTER="ruff"
      RECOMMENDED_FORMATTER="ruff format"
      RECOMMENDED_ORM="SQLAlchemy + Alembic"
      ;;
    python-django)
      BACKEND_TEST_CMD="pytest"
      BACKEND_LINT_CMD="ruff check ."
      BACKEND_BUILD_CMD=""
      BACKEND_RUN_CMD="python manage.py runserver"
      RECOMMENDED_LINTER="ruff"
      RECOMMENDED_FORMATTER="ruff format"
      RECOMMENDED_ORM="Django ORM"
      ;;
    python-flask)
      BACKEND_TEST_CMD="pytest"
      BACKEND_LINT_CMD="ruff check ."
      BACKEND_BUILD_CMD=""
      BACKEND_RUN_CMD="flask run"
      RECOMMENDED_LINTER="ruff"
      RECOMMENDED_FORMATTER="ruff format"
      RECOMMENDED_ORM="SQLAlchemy"
      ;;
    typescript-nestjs)
      BACKEND_TEST_CMD="pnpm test"
      BACKEND_LINT_CMD="pnpm lint"
      BACKEND_BUILD_CMD="pnpm build"
      BACKEND_RUN_CMD="pnpm start:dev"
      RECOMMENDED_LINTER="eslint"
      RECOMMENDED_FORMATTER="prettier"
      RECOMMENDED_ORM="Prisma 또는 TypeORM"
      ;;
    typescript-express)
      BACKEND_TEST_CMD="pnpm test"
      BACKEND_LINT_CMD="pnpm lint"
      BACKEND_BUILD_CMD="pnpm build"
      BACKEND_RUN_CMD="pnpm dev"
      RECOMMENDED_LINTER="eslint"
      RECOMMENDED_FORMATTER="prettier"
      RECOMMENDED_ORM="Prisma"
      ;;
    java-spring)
      BACKEND_TEST_CMD="./gradlew test"
      BACKEND_LINT_CMD="./gradlew spotlessCheck"
      BACKEND_BUILD_CMD="./gradlew build"
      BACKEND_RUN_CMD="./gradlew bootRun"
      RECOMMENDED_LINTER="Checkstyle"
      RECOMMENDED_FORMATTER="Spotless"
      RECOMMENDED_ORM="JPA/Hibernate"
      ;;
    dotnet-aspnet)
      BACKEND_TEST_CMD="dotnet test"
      BACKEND_LINT_CMD="dotnet format --verify-no-changes"
      BACKEND_BUILD_CMD="dotnet build"
      BACKEND_RUN_CMD="dotnet run"
      RECOMMENDED_LINTER="dotnet format"
      RECOMMENDED_FORMATTER="dotnet format"
      RECOMMENDED_ORM="Entity Framework Core"
      ;;
    dotnet-framework)
      BACKEND_TEST_CMD='vstest.console.exe **\\bin\\Release\\*.Tests.dll'
      BACKEND_LINT_CMD="msbuild /t:Rebuild /p:RunCodeAnalysis=true"
      BACKEND_BUILD_CMD="msbuild /p:Configuration=Release"
      BACKEND_RUN_CMD="iisexpress (또는 Visual Studio F5)"
      RECOMMENDED_LINTER="StyleCop + FxCop"
      RECOMMENDED_FORMATTER="EditorConfig + ReSharper"
      RECOMMENDED_ORM="Entity Framework 6"
      ;;
  esac
}

_apply_frontend_defaults() {
  case "$1" in
    react-vite|vue|nextjs)
      FRONTEND_TEST_CMD="pnpm test"
      FRONTEND_LINT_CMD="pnpm lint"
      FRONTEND_BUILD_CMD="pnpm build"
      ;;
  esac
}

_apply_db_defaults() {
  case "$1" in
    postgres)
      case "$BACKEND_STACK" in
        python-*) DB_MIGRATION_TOOL="alembic" ;;
        typescript-*) DB_MIGRATION_TOOL="prisma" ;;
        java-spring) DB_MIGRATION_TOOL="flyway" ;;
        dotnet-aspnet) DB_MIGRATION_TOOL="ef core migrations" ;;
      esac ;;
    mssql)
      case "$BACKEND_STACK" in
        python-*) DB_MIGRATION_TOOL="alembic" ;;
        typescript-*) DB_MIGRATION_TOOL="prisma" ;;
        java-spring) DB_MIGRATION_TOOL="flyway" ;;
        dotnet-aspnet) DB_MIGRATION_TOOL="ef core migrations" ;;
      esac ;;
    snowflake)
      DB_MIGRATION_TOOL="dbt 또는 schemachange" ;;
    mysql)
      case "$BACKEND_STACK" in
        python-*) DB_MIGRATION_TOOL="alembic" ;;
        typescript-*) DB_MIGRATION_TOOL="prisma" ;;
        java-spring) DB_MIGRATION_TOOL="flyway" ;;
      esac ;;
  esac
}

# ═══════════════════════════════════════════════════════════════════
# 시작
# ═══════════════════════════════════════════════════════════════════
clear
hdr "ClaudeStarter — 프로젝트 초기화 마법사 v2.0"
echo ""
echo "  이 마법사는 다음을 자동으로 처리합니다:"
echo "  - 프로젝트 스펙(Spec) 입력 및 자동 감지"
echo "  - .claude/project-spec.conf 생성 (모든 hooks·agents가 참조)"
echo "  - 플레이스홀더 자동 치환"
echo "  - 개발 도구 설치"
echo ""

# ── STEP 0: 신규 vs 기존 ────────────────────────────────────────────
hdr "[STEP 0] 프로젝트 유형 선택"
echo ""
echo "  1) 신규 프로젝트   — 빈 폴더에서 처음 시작"
echo "  2) 기존 운영 프로젝트 — 이미 코드가 있는 폴더에 적용"
echo ""
read -rp "  선택 (1~2): " PT_CHOICE

case "$PT_CHOICE" in
  1) PROJECT_TYPE="new" ;;
  2) PROJECT_TYPE="existing" ;;
  *) err "잘못된 선택. 1 또는 2를 입력하세요."; exit 1 ;;
esac

# ── STEP 1: 프로젝트 기본 정보 ──────────────────────────────────────
hdr "[STEP 1] 프로젝트 기본 정보"
echo ""
read -rp "  프로젝트 이름 (예: MyApp): " PROJECT_NAME
while [ -z "$PROJECT_NAME" ]; do
  warn "필수 항목입니다."; read -rp "  프로젝트 이름: " PROJECT_NAME
done
read -rp "  프로젝트 한 줄 설명: " PROJECT_DESCRIPTION
read -rp "  GitHub 조직 또는 계정명 (예: myorg, 없으면 Enter): " GITHUB_ORG
read -rp "  GitHub 저장소명 (예: myapp, 없으면 Enter): " GITHUB_REPO

# ═══════════════════════════════════════════════════════════════════
# 분기: 신규 (new) vs 기존 (existing)
# ═══════════════════════════════════════════════════════════════════

if [ "$PROJECT_TYPE" = "existing" ]; then
  # ────────────────────────────────────────────────────────────────
  # 기존 프로젝트 — 자동 감지 + 사용자 보완
  # ────────────────────────────────────────────────────────────────
  hdr "[STEP 2] 기존 프로젝트 스택 자동 감지 중..."
  echo ""

  if [ ! -x "scripts/detect-stack.sh" ]; then
    chmod +x scripts/detect-stack.sh 2>/dev/null || true
  fi

  if [ -x "scripts/detect-stack.sh" ]; then
    DETECT_OUTPUT=$(./scripts/detect-stack.sh 2>/dev/null || true)
    # shellcheck disable=SC1090
    eval "$DETECT_OUTPUT"
  fi

  echo "  감지 결과:"
  echo "    백엔드 스택   : ${BACKEND_STACK:-(미감지)}"
  echo "    백엔드 디렉토리: ${BACKEND_DIR:-(미감지)}"
  echo "    프론트엔드 스택: ${FRONTEND_STACK:-(미감지)}"
  echo "    프론트 디렉토리: ${FRONTEND_DIR:-(미감지)}"
  echo "    데이터베이스   : ${DB_TYPE:-(미감지)}"
  echo "    컨테이너 런타임: ${CONTAINER_RUNTIME:-(미감지)}"
  echo "    CI 도구       : ${CI_TOOL:-(미감지)}"
  echo ""
  read -rp "  감지 결과가 맞습니까? (Y/n, n이면 수동 입력 모드): " DETECT_OK
  DETECT_OK=$(echo "${DETECT_OK:-y}" | tr '[:upper:]' '[:lower:]')

  if [ "$DETECT_OK" != "y" ]; then
    info "수동 입력 모드로 전환합니다. 감지 결과를 무시하고 직접 입력하세요."
    PROJECT_TYPE_TEMP="new"  # 신규 마법사 흐름 재사용
  else
    PROJECT_TYPE_TEMP="existing-confirmed"
    # 명령어 기본값만 채움 (사용자가 보완)
    _apply_backend_defaults "$BACKEND_STACK"
    _apply_frontend_defaults "$FRONTEND_STACK"
    _apply_db_defaults "$DB_TYPE"

    echo ""
    info "감지된 스택의 기본 명령어를 적용했습니다. 필요 시 수정 가능합니다."
    read -rp "  명령어 수정하시겠습니까? (y/N): " EDIT_CMD
    EDIT_CMD=$(echo "${EDIT_CMD:-n}" | tr '[:upper:]' '[:lower:]')

    if [ "$EDIT_CMD" = "y" ]; then
      [ "$BACKEND_STACK" != "none" ] && {
        read -rp "    백엔드 테스트 명령 [$BACKEND_TEST_CMD]: " _v && [ -n "$_v" ] && BACKEND_TEST_CMD="$_v"
        read -rp "    백엔드 린트 명령   [$BACKEND_LINT_CMD]: " _v && [ -n "$_v" ] && BACKEND_LINT_CMD="$_v"
        read -rp "    백엔드 실행 명령   [$BACKEND_RUN_CMD]: " _v && [ -n "$_v" ] && BACKEND_RUN_CMD="$_v"
      }
      [ "$FRONTEND_STACK" != "none" ] && {
        read -rp "    프론트 테스트 명령 [$FRONTEND_TEST_CMD]: " _v && [ -n "$_v" ] && FRONTEND_TEST_CMD="$_v"
        read -rp "    프론트 린트 명령   [$FRONTEND_LINT_CMD]: " _v && [ -n "$_v" ] && FRONTEND_LINT_CMD="$_v"
        read -rp "    프론트 빌드 명령   [$FRONTEND_BUILD_CMD]: " _v && [ -n "$_v" ] && FRONTEND_BUILD_CMD="$_v"
      }
    fi
  fi
else
  PROJECT_TYPE_TEMP="new"
fi

# ────────────────────────────────────────────────────────────────────
# 신규 프로젝트 — Spec 모드 선택
# ────────────────────────────────────────────────────────────────────
if [ "$PROJECT_TYPE_TEMP" = "new" ]; then
  hdr "[STEP 2] Spec 정의 방법 선택"
  echo ""
  echo "  1) 직접 선택       — 단계별로 스택을 직접 고른다"
  echo "  2) 프로젝트 유형 기반 — 유형 선택 시 권장 묶음 자동 적용 (빠름)"
  echo "  3) PRD 기반 제안   — PRD 작성 후 spec-recommender 에이전트가 추천"
  echo ""
  read -rp "  선택 (1~3): " SPEC_MODE

  case "$SPEC_MODE" in
    # ── 2번: 프로젝트 유형 기반 권장 묶음 ────────────────────────
    2)
      hdr "[STEP 3] 프로젝트 유형 선택"
      echo ""
      echo "  1) Full-Stack 웹앱       — TypeScript+NestJS / React+Vite / PostgreSQL"
      echo "  2) 데이터 파이프라인      — Python+FastAPI / Snowflake"
      echo "  3) 모바일 백엔드 API     — Java+Spring Boot / PostgreSQL"
      echo "  4) 내부 관리 도구        — Python+Django / MSSQL"
      echo "  5) Next.js 풀스택 (BFF)  — Next.js / PostgreSQL"
      echo "  6) .NET 엔터프라이즈     — ASP.NET Core / MSSQL"
      echo ""
      read -rp "  선택 (1~6): " BUNDLE_CHOICE

      case "$BUNDLE_CHOICE" in
        1) BACKEND_STACK="typescript-nestjs"; FRONTEND_STACK="react-vite"; DB_TYPE="postgres"; CONTAINER_RUNTIME="docker"; CLOUD_PROVIDER="aws" ;;
        2) BACKEND_STACK="python-fastapi"; FRONTEND_STACK="none"; DB_TYPE="snowflake"; CONTAINER_RUNTIME="none"; CLOUD_PROVIDER="self-hosted" ;;
        3) BACKEND_STACK="java-spring"; FRONTEND_STACK="none"; DB_TYPE="postgres"; CONTAINER_RUNTIME="docker"; CLOUD_PROVIDER="azure" ;;
        4) BACKEND_STACK="python-django"; FRONTEND_STACK="none"; DB_TYPE="mssql"; CONTAINER_RUNTIME="docker"; CLOUD_PROVIDER="self-hosted" ;;
        5) BACKEND_STACK="none"; FRONTEND_STACK="nextjs"; DB_TYPE="postgres"; CONTAINER_RUNTIME="none"; CLOUD_PROVIDER="aws" ;;
        6) BACKEND_STACK="dotnet-aspnet"; FRONTEND_STACK="react-vite"; DB_TYPE="mssql"; CONTAINER_RUNTIME="docker"; CLOUD_PROVIDER="azure" ;;
        *) err "잘못된 선택."; exit 1 ;;
      esac
      _apply_backend_defaults "$BACKEND_STACK"
      _apply_frontend_defaults "$FRONTEND_STACK"
      _apply_db_defaults "$DB_TYPE"
      [ "$BACKEND_STACK" != "none" ] && BACKEND_DIR="app/backend"
      [ "$FRONTEND_STACK" != "none" ] && FRONTEND_DIR="app/frontend"
      ok "권장 묶음 적용 완료"
      ;;

    # ── 3번: PRD 기반 제안 ────────────────────────────────────────
    3)
      hdr "[STEP 3] PRD 기반 Spec 추천"
      echo ""
      info "이 모드는 PRD.md 작성 후 사용합니다."
      echo ""
      echo "  순서:"
      echo "  1. SETUP.sh를 일단 종료 (스택 정보는 'none'으로 임시 저장)"
      echo "  2. Claude Code 실행 → PRD.md 작성"
      echo "  3. spec-recommender 에이전트로 추천 Spec 생성"
      echo "  4. SETUP.sh --from-spec 으로 재실행"
      echo ""
      read -rp "  지금 종료하시겠습니까? (Y/n): " EXIT_NOW
      EXIT_NOW=$(echo "${EXIT_NOW:-y}" | tr '[:upper:]' '[:lower:]')
      if [ "$EXIT_NOW" = "y" ]; then
        # 임시 spec 저장
        mkdir -p .claude
        cat > .claude/project-spec.conf << EOF
# 임시 spec — PRD 작성 후 SETUP.sh --from-spec 으로 재실행하세요
PROJECT_NAME="$PROJECT_NAME"
PROJECT_DESCRIPTION="$PROJECT_DESCRIPTION"
PROJECT_TYPE="new"
GITHUB_ORG="$GITHUB_ORG"
GITHUB_REPO="$GITHUB_REPO"
BACKEND_STACK="none"
FRONTEND_STACK="none"
DB_TYPE="none"
SPEC_VERSION="0.1-prd-pending"
GENERATED_AT="$(date +%Y-%m-%d)"
EOF
        ok "임시 spec 저장 완료 (.claude/project-spec.conf)"
        echo ""
        echo "  다음 단계:"
        echo "  1. claude   (Claude Code 실행)"
        echo "  2. > PRD.md 작성 도와줘"
        echo "  3. > spec-recommender 에이전트로 Spec 추천해줘"
        echo "  4. ./SETUP.sh --from-spec   (Spec 적용)"
        exit 0
      fi
      # 종료하지 않으면 직접 선택 모드로 fallthrough
      ;&

    # ── 1번 또는 기타: 직접 선택 ─────────────────────────────────
    *)
      hdr "[STEP 3-A] 백엔드 스택 선택"
      echo ""
      echo "  1) Python + FastAPI"
      echo "  2) Python + Django"
      echo "  3) Python + Flask"
      echo "  4) TypeScript + NestJS"
      echo "  5) TypeScript + Express"
      echo "  6) Java + Spring Boot"
      echo "  7) C# + ASP.NET Core (.NET 5+)"
      echo "  8) C# + ASP.NET Framework (.NET Framework 4.x — Legacy)"
      echo "  9) 백엔드 없음 (프론트엔드만)"
      echo ""
      read -rp "  선택 (1~9): " BE_CHOICE
      case "$BE_CHOICE" in
        1) BACKEND_STACK="python-fastapi" ;;
        2) BACKEND_STACK="python-django" ;;
        3) BACKEND_STACK="python-flask" ;;
        4) BACKEND_STACK="typescript-nestjs" ;;
        5) BACKEND_STACK="typescript-express" ;;
        6) BACKEND_STACK="java-spring" ;;
        7) BACKEND_STACK="dotnet-aspnet" ;;
        8) BACKEND_STACK="dotnet-framework" ;;
        9) BACKEND_STACK="none" ;;
        *) BACKEND_STACK="none"; warn "잘못된 선택 — 백엔드 없음으로 설정" ;;
      esac
      _apply_backend_defaults "$BACKEND_STACK"
      [ "$BACKEND_STACK" != "none" ] && BACKEND_DIR="app/backend"

      hdr "[STEP 3-B] 프론트엔드 스택 선택"
      echo ""
      echo "  1) React (Vite)"
      echo "  2) Vue 3"
      echo "  3) Next.js"
      echo "  4) 프론트엔드 없음 (API/배치 전용)"
      echo ""
      read -rp "  선택 (1~4): " FE_CHOICE
      case "$FE_CHOICE" in
        1) FRONTEND_STACK="react-vite" ;;
        2) FRONTEND_STACK="vue" ;;
        3) FRONTEND_STACK="nextjs" ;;
        4) FRONTEND_STACK="none" ;;
        *) FRONTEND_STACK="none"; warn "잘못된 선택 — 프론트엔드 없음으로 설정" ;;
      esac
      _apply_frontend_defaults "$FRONTEND_STACK"
      [ "$FRONTEND_STACK" != "none" ] && FRONTEND_DIR="app/frontend"

      hdr "[STEP 3-C] 데이터베이스 선택"
      echo ""
      echo "  1) PostgreSQL"
      echo "  2) MS SQL Server (Azure SQL 포함)"
      echo "  3) Snowflake"
      echo "  4) MySQL/MariaDB"
      echo "  5) SQLite"
      echo "  6) 사용 안 함"
      echo ""
      read -rp "  선택 (1~6): " DB_CHOICE
      case "$DB_CHOICE" in
        1) DB_TYPE="postgres" ;;
        2) DB_TYPE="mssql" ;;
        3) DB_TYPE="snowflake" ;;
        4) DB_TYPE="mysql" ;;
        5) DB_TYPE="sqlite" ;;
        *) DB_TYPE="none" ;;
      esac
      _apply_db_defaults "$DB_TYPE"

      hdr "[STEP 3-D] 인프라 / 배포 환경"
      echo ""
      echo "  컨테이너 런타임:"
      echo "  1) Docker + Compose   2) Podman   3) 사용 안 함"
      read -rp "  선택 (1~3, 기본: 1): " CR_CHOICE
      case "${CR_CHOICE:-1}" in
        1) CONTAINER_RUNTIME="docker" ;;
        2) CONTAINER_RUNTIME="podman" ;;
        3) CONTAINER_RUNTIME="none" ;;
        *) CONTAINER_RUNTIME="docker" ;;
      esac

      echo ""
      echo "  클라우드 / 배포:"
      echo "  1) AWS   2) Azure   3) Self-hosted   4) 미정/사용 안 함"
      read -rp "  선택 (1~4, 기본: 4): " CP_CHOICE
      case "${CP_CHOICE:-4}" in
        1) CLOUD_PROVIDER="aws" ;;
        2) CLOUD_PROVIDER="azure" ;;
        3) CLOUD_PROVIDER="self-hosted" ;;
        *) CLOUD_PROVIDER="none" ;;
      esac

      echo ""
      echo "  CI/CD 도구:"
      echo "  1) GitHub Actions   2) GitLab CI   3) Azure DevOps   4) 사용 안 함"
      read -rp "  선택 (1~4, 기본: 1): " CI_CHOICE
      case "${CI_CHOICE:-1}" in
        1) CI_TOOL="github-actions" ;;
        2) CI_TOOL="gitlab-ci" ;;
        3) CI_TOOL="azure-devops" ;;
        *) CI_TOOL="none" ;;
      esac
      ;;
  esac
fi

# ── STEP 4: 보안 수준 ──────────────────────────────────────────────
hdr "[STEP 4] 보안 정책 수준"
echo ""
echo "  1) 표준 — 기본 ISMS + 시큐어코딩 체크"
echo "  2) 강화 — 표준 + DDL 직접 실행 차단 + 민감정보 스캔 강화"
echo ""
read -rp "  선택 (1~2, 기본: 1): " SL_CHOICE
SECURITY_LEVEL="${SL_CHOICE:-1}"

# ── STEP 5: 협업 도구 ─────────────────────────────────────────────
hdr "[STEP 5] 협업 도구 (선택)"
echo ""
read -rp "  Notion MCP 연동 추가? (y/N): " USE_NOTION
USE_NOTION=$(echo "${USE_NOTION:-n}" | tr '[:upper:]' '[:lower:]')

# ── 최종 확인 ──────────────────────────────────────────────────────
hdr "최종 확인 — 설정 내용"
echo ""
echo "  프로젝트명     : $PROJECT_NAME"
echo "  유형          : $PROJECT_TYPE"
echo "  설명          : $PROJECT_DESCRIPTION"
echo "  GitHub        : ${GITHUB_ORG:-(미입력)}/${GITHUB_REPO:-(미입력)}"
echo ""
echo "  ── 스택 ──"
echo "  백엔드        : $BACKEND_STACK ${BACKEND_DIR:+($BACKEND_DIR)}"
echo "  프론트엔드    : $FRONTEND_STACK ${FRONTEND_DIR:+($FRONTEND_DIR)}"
echo "  데이터베이스  : $DB_TYPE"
echo ""
echo "  ── 인프라 ──"
echo "  컨테이너      : $CONTAINER_RUNTIME"
echo "  클라우드      : $CLOUD_PROVIDER"
echo "  CI 도구       : $CI_TOOL"
echo ""
echo "  ── 옵션 ──"
echo "  보안 수준     : Level $SECURITY_LEVEL"
echo "  Notion 연동   : ${USE_NOTION:-n}"
echo ""
read -rp "  이 설정으로 진행합니까? (Y/n): " CONFIRM
CONFIRM=$(echo "${CONFIRM:-y}" | tr '[:upper:]' '[:lower:]')
[ "$CONFIRM" = "n" ] && { warn "취소됨."; exit 0; }

# ═══════════════════════════════════════════════════════════════════
# 실행: project-spec.conf 생성 + 플레이스홀더 치환 + 환경 세팅
# ═══════════════════════════════════════════════════════════════════
hdr "초기화 실행"
echo ""

mkdir -p .claude
GENERATED_AT=$(date +%Y-%m-%d)

# ── project-spec.conf 생성 ─────────────────────────────────────────
cat > .claude/project-spec.conf << EOF
# ClaudeStarter Project Specification
# 자동 생성: $GENERATED_AT
# 이 파일은 hooks/agents/CLAUDE.md가 참조합니다.

# ── 프로젝트 메타 ──
PROJECT_NAME="$PROJECT_NAME"
PROJECT_DESCRIPTION="$PROJECT_DESCRIPTION"
PROJECT_TYPE="$PROJECT_TYPE"
GITHUB_ORG="$GITHUB_ORG"
GITHUB_REPO="$GITHUB_REPO"
SPEC_VERSION="1.0"
GENERATED_AT="$GENERATED_AT"

# ── 백엔드 ──
BACKEND_STACK="$BACKEND_STACK"
BACKEND_DIR="$BACKEND_DIR"
BACKEND_TEST_CMD="$BACKEND_TEST_CMD"
BACKEND_LINT_CMD="$BACKEND_LINT_CMD"
BACKEND_BUILD_CMD="$BACKEND_BUILD_CMD"
BACKEND_RUN_CMD="$BACKEND_RUN_CMD"

# ── 프론트엔드 ──
FRONTEND_STACK="$FRONTEND_STACK"
FRONTEND_DIR="$FRONTEND_DIR"
FRONTEND_TEST_CMD="$FRONTEND_TEST_CMD"
FRONTEND_LINT_CMD="$FRONTEND_LINT_CMD"
FRONTEND_BUILD_CMD="$FRONTEND_BUILD_CMD"

# ── 데이터베이스 ──
DB_TYPE="$DB_TYPE"
DB_MIGRATION_TOOL="$DB_MIGRATION_TOOL"

# ── 인프라 ──
CONTAINER_RUNTIME="$CONTAINER_RUNTIME"
CLOUD_PROVIDER="$CLOUD_PROVIDER"
CI_TOOL="$CI_TOOL"

# ── 보안 ──
SECURITY_LEVEL="$SECURITY_LEVEL"

# ── 권장 도구 ──
RECOMMENDED_LINTER="$RECOMMENDED_LINTER"
RECOMMENDED_FORMATTER="$RECOMMENDED_FORMATTER"
RECOMMENDED_ORM="$RECOMMENDED_ORM"
EOF
ok ".claude/project-spec.conf 생성 완료"

# ── 보안 수준 conf (hooks용) ────────────────────────────────────────
mkdir -p .claude/tmp
if [ "$SECURITY_LEVEL" = "2" ]; then
  printf 'DDL_BLOCK=true\nSENSITIVE_SCAN=strict\n' > .claude/tmp/security-level.conf
  ok "보안 수준 Level 2 (강화) 적용"
else
  printf 'DDL_BLOCK=false\nSENSITIVE_SCAN=standard\n' > .claude/tmp/security-level.conf
  ok "보안 수준 Level 1 (표준) 적용"
fi

# ── 플레이스홀더 치환 (REPO_URL, GHCR_PREFIX) ────────────────────────
REPO_URL=""
GHCR_PREFIX=""
if [ -n "$GITHUB_ORG" ] && [ -n "$GITHUB_REPO" ]; then
  REPO_URL="https://github.com/${GITHUB_ORG}/${GITHUB_REPO}.git"
  GHCR_PREFIX="ghcr.io/${GITHUB_ORG}/${GITHUB_REPO}"
fi

STACK_LABEL=""
case "$BACKEND_STACK" in
  python-*) STACK_LABEL="Python" ;;
  typescript-*) STACK_LABEL="TypeScript" ;;
  java-spring) STACK_LABEL="Java/Spring" ;;
  dotnet-aspnet) STACK_LABEL=".NET" ;;
  none) STACK_LABEL="" ;;
esac
case "$FRONTEND_STACK" in
  react-vite) STACK_LABEL="${STACK_LABEL:+$STACK_LABEL + }React" ;;
  vue) STACK_LABEL="${STACK_LABEL:+$STACK_LABEL + }Vue" ;;
  nextjs) STACK_LABEL="${STACK_LABEL:+$STACK_LABEL + }Next.js" ;;
esac
[ -z "$STACK_LABEL" ] && STACK_LABEL="미정"

do_replace() {
  local file="$1"
  [ -f "$file" ] || return
  if sed --version 2>/dev/null | grep -q GNU; then
    sed -i \
      "s|\${project_name}|$PROJECT_NAME|g; \
       s|\${project_description}|$PROJECT_DESCRIPTION|g; \
       s|\${github_org}|$GITHUB_ORG|g; \
       s|\${github_repo}|$GITHUB_REPO|g; \
       s|\${repo_url}|$REPO_URL|g; \
       s|\${ghcr_prefix}|$GHCR_PREFIX|g; \
       s|\${stack_label}|$STACK_LABEL|g; \
       s|\${decision_date}|$GENERATED_AT|g" "$file"
  else
    for pat in \
      "s|\${project_name}|$PROJECT_NAME|g" \
      "s|\${project_description}|$PROJECT_DESCRIPTION|g" \
      "s|\${github_org}|$GITHUB_ORG|g" \
      "s|\${github_repo}|$GITHUB_REPO|g" \
      "s|\${repo_url}|$REPO_URL|g" \
      "s|\${ghcr_prefix}|$GHCR_PREFIX|g" \
      "s|\${stack_label}|$STACK_LABEL|g" \
      "s|\${decision_date}|$GENERATED_AT|g"; do
      sed -i '' "$pat" "$file"
    done
  fi
}

for f in README.md CLAUDE.md ARCHITECTURE.md PRD.md ROADMAP.md CHANGELOG.md; do
  [ -f "$f" ] && do_replace "$f"
done
ok "플레이스홀더 치환 완료"

# ── MCP 설정 ──────────────────────────────────────────────────────
if [ "$USE_NOTION" = "y" ]; then
  printf '{\n  "mcpServers": {\n    "notion": { "type": "http", "url": "https://mcp.notion.com/mcp" }\n  }\n}\n' > .mcp.json
  ok ".mcp.json — Notion MCP 추가"
else
  printf '{\n  "mcpServers": {}\n}\n' > .mcp.json
  ok ".mcp.json — MCP 서버 없음"
fi

# ── 스택별 rules 활성화 (선택된 스택만 살리고 나머지는 .disabled) ──
hdr "스택 룰 활성화"
echo ""

_disable_unused_rules() {
  local prefix="$1"   # backend / frontend / db
  local active_id="$2"
  local active_file=""

  # active_id를 파일명 패턴으로 매핑
  case "$prefix-$active_id" in
    backend-python-fastapi|backend-python-django|backend-python-flask) active_file="backend-python.md" ;;
    backend-typescript-nestjs|backend-typescript-express) active_file="backend-typescript.md" ;;
    backend-java-spring) active_file="backend-java.md" ;;
    backend-dotnet-aspnet) active_file="backend-dotnet-aspnet.md" ;;
    backend-dotnet-framework) active_file="backend-dotnet-framework.md" ;;
    frontend-react-vite) active_file="frontend-react.md" ;;
    frontend-vue) active_file="frontend-vue.md" ;;
    frontend-nextjs) active_file="frontend-nextjs.md" ;;
    db-mssql) active_file="db-mssql.md" ;;
    db-snowflake) active_file="db-snowflake.md" ;;
  esac

  for f in .claude/rules/stack/${prefix}-*.md .claude/rules/stack/${prefix}-*.md.disabled; do
    [ ! -f "$f" ] && continue
    base=$(basename "$f" .disabled)
    if [ "$base" = "$active_file" ]; then
      # 활성화 (.disabled 제거)
      [ "$f" != ".claude/rules/stack/$base" ] && mv "$f" ".claude/rules/stack/$base"
    else
      # 비활성화 (.disabled 추가)
      [ -f ".claude/rules/stack/$base" ] && [ "$base" != "$active_file" ] && \
        mv ".claude/rules/stack/$base" ".claude/rules/stack/$base.disabled" 2>/dev/null || true
    fi
  done
}

_disable_unused_rules "backend" "$BACKEND_STACK"
_disable_unused_rules "frontend" "$FRONTEND_STACK"
_disable_unused_rules "db" "$DB_TYPE"
ok "스택별 룰 활성화 완료 (사용하지 않는 스택은 .disabled 처리)"

# ── 개발 도구 자동 설치 (스택 기반) ────────────────────────────────
hdr "개발 도구 환경 확인"
echo ""

# Node.js 도구
case "$BACKEND_STACK $FRONTEND_STACK" in
  *typescript*|*react*|*vue*|*nextjs*)
    if command -v node &>/dev/null; then
      ok "Node.js: $(node --version)"
      if command -v npm &>/dev/null && ! command -v pnpm &>/dev/null; then
        npm install -g pnpm --silent && ok "pnpm 설치 완료"
      fi
    else
      warn "Node.js 미설치 — nodejs.org 에서 v20+ 설치 권장"
    fi
    ;;
esac

# Python 도구
case "$BACKEND_STACK" in
  python-*)
    if command -v python3 &>/dev/null; then
      ok "Python: $(python3 --version)"
      if [ ! -d ".venv" ] && [ "$PROJECT_TYPE" = "new" ]; then
        python3 -m venv .venv && ok ".venv 가상환경 생성"
      fi
    else
      warn "Python 미설치 — Python 3.12+ 설치 권장"
    fi
    ;;
esac

# Java 도구
case "$BACKEND_STACK" in
  java-spring)
    command -v java &>/dev/null && ok "Java: $(java -version 2>&1 | head -1)" || warn "Java 미설치 — JDK 17+ 설치 권장"
    ;;
esac

# .NET 도구
case "$BACKEND_STACK" in
  dotnet-aspnet)
    command -v dotnet &>/dev/null && ok ".NET: $(dotnet --version)" || warn ".NET 미설치 — .NET 8+ 설치 권장"
    ;;
esac

# ── .env 설정 ─────────────────────────────────────────────────────
if [ ! -f ".env" ] && [ -f ".env.example" ]; then
  cp .env.example .env
  ok ".env.example → .env 복사 완료"
elif [ -f ".env" ]; then
  ok ".env 이미 존재"
fi

# ── Git hooks 설치 ─────────────────────────────────────────────────
if [ -d ".git" ] && [ -f "scripts/hooks/pre-commit" ]; then
  git config --local core.hooksPath scripts/hooks
  ok "Git hooks 활성화 완료"
fi

# ── 잔류 플레이스홀더 검사 ──────────────────────────────────────────
hdr "검증"
echo ""
REMAINING=$(grep -rn '\${project_name}\|${github_org}\|${github_repo}\|${project_description}\|${stack_label}' \
  README.md CLAUDE.md ARCHITECTURE.md PRD.md 2>/dev/null || true)
[ -n "$REMAINING" ] && warn "잔류 플레이스홀더:" && echo "$REMAINING" | sed 's/^/  /' \
  || ok "잔류 플레이스홀더 없음"

# ── 완료 ───────────────────────────────────────────────────────────
hdr "✅ 초기화 완료"
echo ""
echo "  생성된 핵심 파일:"
echo "  - .claude/project-spec.conf     (스택 spec — hooks/agents 참조)"
echo "  - .claude/tmp/security-level.conf (보안 수준)"
echo "  - .mcp.json                      (MCP 설정)"
echo ""
echo "  다음 단계:"
echo "  1. .env 파일에 실제 환경변수 값 입력"
case "$CLOUD_PROVIDER" in
  aws) echo "  2. GitHub Secrets: LIGHTSAIL_HOST / LIGHTSAIL_USER / LIGHTSAIL_SSH_KEY" ;;
  azure) echo "  2. GitHub Secrets: AZURE_CREDENTIALS / AZURE_WEBAPP_NAME 등" ;;
  self-hosted) echo "  2. GitHub Secrets: SSH_HOST / SSH_USER / SSH_KEY" ;;
esac
echo "  3. Claude Code 실행 → develop 브랜치 생성"
echo "  4. sprint-planner 에이전트로 첫 스프린트 계획"
echo ""
echo "  📖 가이드: docs/prompt-guide.md"
echo ""
