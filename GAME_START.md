# Godot 게임 시작 안내

현재 구현된 범위는 북카페를 직접 걸어 다니며 제1장 첫 만남을 시작하는 플레이 가능한 프로토타입이다.

## 실행 방법

1. Godot 4.x를 실행한다.
2. `가져오기` 또는 `Import`를 선택한다.
3. 이 폴더의 `project.godot` 파일을 선택한다.
4. 프로젝트가 열리면 오른쪽 위의 실행 버튼 또는 `F5`를 누른다.
5. 시작 화면에서 플레이할 캐릭터를 선택한다.
6. 방향키 또는 `WASD`로 이동한다. 다른 인물에게 가까이 가면 말풍선 대화가 자동으로 시작된다.

프로젝트 위치:

```text
D:\게임\중년의연애소설\project.godot
```

## 현재 플레이 기능

- 비 오는 북카페의 움직이는 실내 배경
- 5인 플레이 캐릭터 선택과 방향별 이동
- 선택하지 않은 4인의 NPC 자동 배치
- 인물 근처에서 자동으로 시작하는 말풍선 대화
- 일반 NPC의 캐릭터별 자동 응답
- 민우와 서정의 첫 만남 대화
- 글자 타이핑 연출과 스페이스바 진행
- 3번의 선택지 분기
- 애정·신뢰·존중·서운함 상태 변화
- 인물별 감정 표시와 대화 초점 변화
- 자동 저장, 이어하기, 처음부터 다시 보기
- 1280×720 기준 반응형 UI

## 파일 구조

```text
project.godot                 Godot 프로젝트 설정
scenes/main.tscn              첫 화면과 대화 UI
scripts/main.gd               대화 진행 및 선택지 처리
scripts/player_controller.gd  강민우 이동, 방향 전환, 가구 충돌
scripts/game_state.gd         관계 상태와 저장
scripts/rain_backdrop.gd      북카페 실내·창밖의 비 배경
data/chapter_01.json          제1장 실제 게임 대사
tests/validate_chapter.gd     대화 연결 검사
tests/validate_exploration.gd 이동 화면과 접근 대화 검사
```

## 다음 제작 순서

1. 빗소리, 문 종, 공구 소리와 배경 음악을 연결한다.
2. 카페의 추가 조사 지점과 짧은 독백을 만든다.
3. 제1장 두 번째 에피소드 `남은 나사 하나`를 추가한다.
4. 대화 기록과 수동 저장 슬롯을 구현한다.

## 개발자용 데이터 검사

Godot 실행 파일이 명령줄에서 인식되는 환경이라면 다음 방식으로 제1장 데이터의 끊어진 연결을 검사할 수 있다.

```text
godot --headless --path . --script res://tests/validate_chapter.gd
```

이동 화면과 접근 대화 전환은 다음 명령으로 검사한다.

```text
godot --headless --path . --script res://tests/validate_exploration.gd
```
