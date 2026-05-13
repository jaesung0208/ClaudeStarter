#!/usr/bin/env bash
# detect-stack.sh — 현재 디렉토리의 프로젝트 스택을 자동 감지
# 사용: ./scripts/detect-stack.sh
# 출력: detect-stack.conf 형식 (key=value)

set -uo pipefail

# ── 감지 결과 변수 ─────────────────────────────────────────────────
BACKEND_STACK="none"
BACKEND_DIR=""
FRONTEND_STACK="none"
FRONTEND_DIR=""
DB_TYPE="none"
CONTAINER_RUNTIME="none"
CI_TOOL="none"

# ── 백엔드 감지 ────────────────────────────────────────────────────
_detect_backend() {
  local search_dirs=("." "app/backend" "backend" "server" "src/main/java" "src" "api")

  # .NET은 어디에 있는 csproj든 먼저 검색 (구조가 다양함)
  local csproj_file=""
  csproj_file=$(find . -maxdepth 4 -name "*.csproj" -not -path "*/node_modules/*" -not -path "*/bin/*" -not -path "*/obj/*" 2>/dev/null | head -1)
  if [ -n "$csproj_file" ]; then
    BACKEND_DIR=$(dirname "$csproj_file")
    # .NET Framework (legacy 4.x) vs .NET Core/5+ (modern) 구분
    # 모든 csproj를 읽어 TargetFramework / TargetFrameworkVersion 검사
    local has_framework="false"
    local has_modern="false"
    while IFS= read -r f; do
      # Modern SDK-style: <TargetFramework>net48</TargetFramework> 등
      if grep -qE '<TargetFramework[s]?>[^<]*net4[0-9]' "$f" 2>/dev/null; then
        has_framework="true"
      fi
      # Old-style: <TargetFrameworkVersion>v4.x</TargetFrameworkVersion>
      if grep -qE '<TargetFrameworkVersion>v?4\.' "$f" 2>/dev/null; then
        has_framework="true"
      fi
      # Modern .NET: net5.0/6.0/7.0/8.0, netcoreapp*, netstandard2.1
      if grep -qE '<TargetFramework[s]?>(net[5-9]\.0|net1[0-9]\.0|netcoreapp|netstandard2\.1)' "$f" 2>/dev/null; then
        has_modern="true"
      fi
    done < <(find . -maxdepth 5 -name "*.csproj" -not -path "*/node_modules/*" -not -path "*/bin/*" -not -path "*/obj/*" 2>/dev/null)

    # packages.config 존재는 legacy 강한 힌트
    if find . -maxdepth 4 -name "packages.config" -not -path "*/node_modules/*" 2>/dev/null | head -1 >/dev/null; then
      has_framework="true"
    fi

    # 판정 우선순위: Modern이 있으면 dotnet-aspnet 우선 (마이그레이션 중일 가능성)
    #                Framework만 있으면 dotnet-framework
    #                둘 다 없으면 (구조만 .NET) dotnet-aspnet 기본 매핑
    if [ "$has_modern" = "true" ]; then
      BACKEND_STACK="dotnet-aspnet"
    elif [ "$has_framework" = "true" ]; then
      BACKEND_STACK="dotnet-framework"
    else
      BACKEND_STACK="dotnet-aspnet"
    fi
    return
  fi

  for dir in "${search_dirs[@]}"; do
    [ ! -d "$dir" ] && continue

    # Java
    if [ -f "$dir/pom.xml" ] || [ -f "$dir/build.gradle" ] || [ -f "$dir/build.gradle.kts" ]; then
      if grep -lr "spring-boot" "$dir" --include=pom.xml --include=build.gradle --include=build.gradle.kts 2>/dev/null | head -1 >/dev/null; then
        BACKEND_STACK="java-spring"
      else
        BACKEND_STACK="java-spring"  # 일단 spring으로 매핑
      fi
      BACKEND_DIR="$dir"
      return
    fi

    # Node.js / TypeScript (백엔드)
    if [ -f "$dir/package.json" ]; then
      if grep -q '"@nestjs/' "$dir/package.json" 2>/dev/null; then
        BACKEND_STACK="typescript-nestjs"
        BACKEND_DIR="$dir"
        return
      elif grep -qE '"(express|fastify|koa|hapi)"' "$dir/package.json" 2>/dev/null && \
           ! grep -qE '"(react|vue|next|@vue/|svelte)"' "$dir/package.json" 2>/dev/null; then
        BACKEND_STACK="typescript-express"
        BACKEND_DIR="$dir"
        return
      fi
    fi

    # Python
    if [ -f "$dir/requirements.txt" ] || [ -f "$dir/pyproject.toml" ] || [ -f "$dir/Pipfile" ]; then
      if grep -qE 'fastapi' "$dir/requirements.txt" "$dir/pyproject.toml" 2>/dev/null; then
        BACKEND_STACK="python-fastapi"
      elif grep -qE 'django|Django' "$dir/requirements.txt" "$dir/pyproject.toml" 2>/dev/null; then
        BACKEND_STACK="python-django"
      elif grep -qE 'flask|Flask' "$dir/requirements.txt" "$dir/pyproject.toml" 2>/dev/null; then
        BACKEND_STACK="python-flask"
      else
        BACKEND_STACK="python-fastapi"  # 기본 매핑
      fi
      BACKEND_DIR="$dir"
      return
    fi
  done
}

# ── 프론트엔드 감지 ────────────────────────────────────────────────
_detect_frontend() {
  local search_dirs=("." "app/frontend" "frontend" "web" "client" "ui")

  for dir in "${search_dirs[@]}"; do
    [ ! -d "$dir" ] && continue
    [ "$dir" = "$BACKEND_DIR" ] && continue  # 백엔드와 동일 디렉토리 제외

    if [ -f "$dir/package.json" ]; then
      if grep -q '"next"' "$dir/package.json" 2>/dev/null; then
        FRONTEND_STACK="nextjs"
        FRONTEND_DIR="$dir"
        return
      elif grep -qE '"(vue|@vue/)"' "$dir/package.json" 2>/dev/null; then
        FRONTEND_STACK="vue"
        FRONTEND_DIR="$dir"
        return
      elif grep -q '"react"' "$dir/package.json" 2>/dev/null && \
           ! grep -q '"@nestjs/' "$dir/package.json" 2>/dev/null; then
        FRONTEND_STACK="react-vite"
        FRONTEND_DIR="$dir"
        return
      fi
    fi
  done
}

# ── DB 감지 ────────────────────────────────────────────────────────
_detect_db() {
  # docker-compose 파일에서 DB 추출
  for compose_file in docker-compose.yml docker-compose.yaml docker-compose.prod.yml; do
    [ ! -f "$compose_file" ] && continue
    if grep -qE 'postgres|postgresql' "$compose_file"; then DB_TYPE="postgres"; return; fi
    if grep -qE 'mysql|mariadb' "$compose_file"; then DB_TYPE="mysql"; return; fi
    if grep -qE 'mssql|sqlserver' "$compose_file"; then DB_TYPE="mssql"; return; fi
  done

  # 의존성에서 추출
  if [ -n "$BACKEND_DIR" ] && [ -d "$BACKEND_DIR" ]; then
    if grep -rE 'snowflake' "$BACKEND_DIR" --include="requirements.txt" --include="pyproject.toml" --include="package.json" -l 2>/dev/null | head -1 >/dev/null; then
      DB_TYPE="snowflake"; return
    fi
    if grep -rE 'pyodbc|pymssql|mssql' "$BACKEND_DIR" --include="requirements.txt" --include="pyproject.toml" --include="package.json" -l 2>/dev/null | head -1 >/dev/null; then
      DB_TYPE="mssql"; return
    fi
    if grep -rE 'psycopg|pg8000|postgres' "$BACKEND_DIR" --include="requirements.txt" --include="pyproject.toml" --include="package.json" -l 2>/dev/null | head -1 >/dev/null; then
      DB_TYPE="postgres"; return
    fi
  fi
}

# ── 컨테이너 감지 ───────────────────────────────────────────────────
_detect_container() {
  if [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ] || \
     find . -maxdepth 3 -name "Dockerfile*" 2>/dev/null | head -1 >/dev/null; then
    CONTAINER_RUNTIME="docker"
  fi
}

# ── CI 감지 ────────────────────────────────────────────────────────
_detect_ci() {
  if [ -d ".github/workflows" ] && [ "$(ls -A .github/workflows 2>/dev/null)" ]; then
    CI_TOOL="github-actions"
  elif [ -f ".gitlab-ci.yml" ]; then
    CI_TOOL="gitlab-ci"
  elif [ -f "azure-pipelines.yml" ] || [ -f ".azure-pipelines.yml" ]; then
    CI_TOOL="azure-devops"
  fi
}

# ── 실행 ───────────────────────────────────────────────────────────
_detect_backend
_detect_frontend
_detect_db
_detect_container
_detect_ci

# ── 결과 출력 (key=value 형식) ──────────────────────────────────────
cat << EOF
BACKEND_STACK=$BACKEND_STACK
BACKEND_DIR=$BACKEND_DIR
FRONTEND_STACK=$FRONTEND_STACK
FRONTEND_DIR=$FRONTEND_DIR
DB_TYPE=$DB_TYPE
CONTAINER_RUNTIME=$CONTAINER_RUNTIME
CI_TOOL=$CI_TOOL
EOF
