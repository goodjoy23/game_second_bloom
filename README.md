# 《오후 네 시, 다시 봄》

40대 이후의 사랑을 다루는 선택형 2D 비주얼 노벨 프로젝트입니다. 서로를 돌보는 기쁨뿐 아니라 부모 간병, 자녀, 생업, 건강, 돈, 혼자 살아온 습관처럼 중년의 연애가 실제로 마주하는 문제를 함께 다룹니다.

게임의 핵심 질문은 하나입니다.

> 사랑은 상대의 삶을 대신 짊어지는 일일까, 아니면 각자의 삶을 존중하며 곁을 내어주는 일일까?

## 현재 기획 기준

- 엔진: Godot 4.x
- 언어: GDScript 우선
- 형식: 2D 비주얼 노벨 + 주간 일정 선택 + 관계 상태 변화
- 1차 주인공: 강민우(46세, 돌싱, 비양육 자녀 있음)
- 중심 상대역: 윤서정(44세, 미혼, 자녀 없음)
- 플레이 관점: 민우 시점으로 시작하고, 주요 장면에서 서정의 시점을 해금
- 출판 기준 정사: 민우와 서정의 관계를 중심으로 한 문학적 재구성
- 게임 분기: 재회, 성숙한 이별, 새로운 만남, 자발적 홀로서기

## 게임 실행 방법

이 프로젝트는 Godot 4.x에서 실행한다. 현재 개발 환경에서 확인한 엔진 버전은 Godot 4.7.2다.

### Godot 에디터에서 실행

1. Godot을 실행하고 `가져오기(Import)`를 선택한다.
2. 프로젝트 루트의 `project.godot` 파일을 선택한다.
3. 프로젝트가 열리면 `F5` 또는 오른쪽 위의 프로젝트 실행 버튼을 누른다.
4. 방향키 또는 `WASD`로 강민우를 움직인다.
5. 윤서정 가까이에서 `E`를 눌러 대화를 시작하고, 대화 중에는 `스페이스바`로 진행한다.

현재 개발 PC에서는 다음 PowerShell 명령으로 에디터를 바로 열 수 있다.

```powershell
& "D:\utils\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe" --editor --path "D:\게임\중년의연애소설"
```

에디터를 거치지 않고 게임을 바로 실행하려면 다음 명령을 사용한다.

```powershell
& "D:\utils\Godot_v4.7.2\Godot_v4.7.2-stable_win64.exe" --path "D:\게임\중년의연애소설"
```

다른 환경에서는 위 경로를 각자의 Godot 실행 파일과 프로젝트 폴더 경로로 바꾸면 된다. 자세한 현재 구현 범위와 파일 구조는 [게임 시작 안내](GAME_START.md)를 참고한다.

### 챕터 데이터 검증

제1장 데이터의 중복 ID와 끊어진 대화 연결은 다음 명령으로 검사한다.

```powershell
& "D:\utils\Godot_v4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path "D:\게임\중년의연애소설" --script "res://tests/validate_chapter.gd"
```

정상이면 `Chapter validation passed: 27 nodes`가 출력된다.

## 문서 안내

1. [프로젝트 바이블](docs/00_project_bible.md)
2. [Godot 공식 사이트 요약과 개발 방향](docs/01_godot_research.md)
3. [등장인물 설정](docs/02_characters.md)
4. [세계관과 문체](docs/03_world_and_tone.md)
5. [게임 시스템](docs/04_game_system.md)
6. [분기와 엔딩](docs/05_branching_and_endings.md)
7. [출판 전환 계획](docs/06_publication_plan.md)
8. [제미나이 기록 정리](docs/99_gemini_record.md)
9. [마스터 시나리오](scenario/00_master_scenario.md)
10. [섹터별 시나리오](scenario/sectors/01_meeting.md)
11. [제1장 소설 본문](scenario/chapter_01_novel.md)
12. [제1장 게임 대본](scenario/chapter_01_game_script.md)

## 작업 원칙

- 돌봄은 성별 역할이 아니라 두 사람이 서로 배우는 사랑의 언어로 쓴다.
- 큰 사건보다 밥, 약, 귀가, 수리, 병원 대기실 같은 생활 장면에서 감정을 드러낸다.
- 선택지는 정답 찾기가 아니라 가치관의 비용을 선택하는 구조로 만든다.
- 이혼, 비혼, 자녀 유무를 결핍이나 벌로 취급하지 않는다.
- 간병과 건강 문제를 사랑의 시험 도구로만 소비하지 않는다.
- 게임 원문과 출판 원고를 분리해 관리하되 인물의 사실관계는 프로젝트 바이블을 기준으로 통일한다.
