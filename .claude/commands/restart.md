# /restart

로컬 개발 서비스를 재시작합니다.

## 동작

`.claude/project-spec.conf`의 `CONTAINER_RUNTIME` 값에 따라:

| CONTAINER_RUNTIME | 실행 명령 |
|---|---|
| `docker` | `docker compose down && docker compose up -d --build` |
| `podman` | `podman-compose down && podman-compose up -d --build` |
| `none` | 백엔드/프론트엔드 RUN_CMD를 각각 재실행 안내 |

## 사용 예

```
> /restart
```

## 비고

- 컨테이너 미사용 프로젝트에서는 안내만 출력하고 종료
- 도커 없이 개발 중인 환경에서는 `BACKEND_RUN_CMD`와 `FRONTEND_BUILD_CMD`를 별도 터미널에서 실행
