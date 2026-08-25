# 제1장 게임 대본

## 장면 정보

- 장면 ID: `S01_E01_CAFE_REPAIR`
- 시점: 강민우
- 배경: 비 오는 북카페 실내
- 시간: 9월 목요일 15:17
- BGM: 낮은 피아노와 통기타, 72 BPM
- 환경음: 창문을 두드리는 빗소리, 멀리서 지나가는 버스
- 등장인물: 강민우, 윤서정, 오혜진

## 필요 에셋

```text
bg_cafe_rain_afternoon.png
cg_sliding_door_hands.png
minwoo_work_wet_neutral.png
minwoo_work_wet_smile.png
seojeong_cardigan_tired.png
seojeong_cardigan_smile.png
sfx_door_stuck.ogg
sfx_screwdriver.ogg
sfx_kettle.ogg
sfx_door_slide_soft.ogg
bgm_four_oclock_rain.ogg
```

## 시작 상태

```text
affection = 0
trust = 0
respect = 0
resentment = 0
minwoo_fatigue = 35
seojeong_stress = 48
```

## 대본

```text
[SCENE]
background = bg_cafe_rain_afternoon
transition = fade(1.5)
music = bgm_four_oclock_rain
sound_loop = rain_window

[NARRATION]
오후 세 시를 넘기자 비는 골목의 모양부터 바꾸기 시작했다.

[SFX]
sfx_door_stuck

[SEOJEONG/tired]
하나, 둘…

[HYEJIN/off]
그만해. 그러다 또 파스 붙여.

[SEOJEONG/tired]
예약 손님 오기 전엔 열어놔야 해요.

[SFX]
entrance_bell

[SHOW]
minwoo_work_wet_neutral at left

[MINWOO/neutral]
옹이 공방에서 왔습니다. 미닫이문 수리 맡기셨죠.

[SHOW]
seojeong_cardigan_tired at right

[SEOJEONG/tired]
이쪽이에요. 비만 오면 꼼짝을 안 하네요.

[NARRATION]
문 아래를 살피던 민우의 시선이 서정의 손목에 붙은 살색 테이프에 멈춘다.

[MINWOO/neutral]
자주 미셨어요?

[SEOJEONG/neutral]
문이니까 열어야죠.

[CHOICE id=first_care_response]

A. “다 고치기 전에는 손대지 마세요.”
   effect: trust +1
   effect: respect -1
   goto: response_direct

B. “손목이 아프시면 제가 고칠 때까지 닫아둘까요?”
   effect: trust +2
   effect: respect +2
   flag: asked_before_helping
   goto: response_ask

C. 손목을 본 사실을 말하지 않고 수리부터 시작한다.
   effect: affection +1
   effect: minwoo_fatigue +5
   goto: response_silent

[LABEL response_direct]
[SEOJEONG/guarded]
…네. 빨리 부탁드릴게요.
[GOTO repair]

[LABEL response_ask]
[SEOJEONG/soft]
예약 손님 오기 전까지만 열리면 돼요. 무리해서 서두르진 마세요.
[GOTO repair]

[LABEL response_silent]
[NARRATION]
민우는 문 앞에 천을 펴고 공구를 꺼낸다. 서정은 테이프 끝을 소매 안으로 감춘다.

[LABEL repair]
[SFX]
sfx_screwdriver

[NARRATION]
나사를 풀 때마다 작은 금속음이 빗소리 사이로 솟는다.

[SFX]
sfx_kettle

[SEOJEONG/off]
단 건 괜찮으세요?

[MINWOO/surprised]
네?

[SEOJEONG/neutral]
생강차요. 꿀을 얼마나 넣을지 몰라서.

[MINWOO/soft]
조금만 부탁드립니다.

[NARRATION]
서정은 마른 수건과 김이 오르는 찻잔을 낮은 탁자에 놓는다.

[CHOICE id=accept_tea]

A. 공구를 내려놓고 손부터 씻는다.
   effect: trust +3
   effect: affection +2
   effect: minwoo_fatigue -8
   flag: accepted_ginger_tea
   goto: tea_accept

B. “이것만 마저 조이고 마시겠습니다.”
   effect: trust +1
   effect: minwoo_fatigue +3
   goto: tea_delay

C. “괜찮습니다. 일 끝나고 마시죠.”
   effect: affection -1
   effect: resentment +1
   goto: tea_refuse

[LABEL tea_accept]
[MINWOO/soft]
감사합니다. 손부터 씻고 올게요.
[SEOJEONG/smile]
천천히 드세요. 문은 도망 안 가니까.
[GOTO tea_memory]

[LABEL tea_delay]
[SEOJEONG/neutral]
식으면 더 달아져요.
[NARRATION]
민우는 나사를 끝까지 조인 뒤에야 몸을 일으킨다.
[GOTO tea_memory]

[LABEL tea_refuse]
[SEOJEONG/guarded]
네. 그럼 여기 둘게요.
[NARRATION]
찻잔의 김이 두 사람 사이에서 먼저 옅어진다.
[GOTO door_test]

[LABEL tea_memory]
[MINWOO/soft]
오랜만이네요.
[SEOJEONG/curious]
생강차가요?
[MINWOO/soft]
누가 단 걸 물어봐 준 게요.
[PAUSE 1.2]
[SEOJEONG/soft]
다음엔 안 물어보고 조금만 넣을게요.

[LABEL door_test]
[SFX]
sfx_door_slide_soft

[MINWOO/neutral]
한번 밀어보세요.

[CG]
cg_sliding_door_hands

[SEOJEONG/smile]
이렇게 가벼운 문이었네요.

[MINWOO/smile]
문이 원래 무거운 건 아니었으니까요.

[NARRATION]
두 사람은 거의 동시에 웃는다. 먼저 멈추는 사람은 없다.

[SEOJEONG/neutral]
비 그치면 다시 봐야 한다고 하셨죠?

[CHOICE id=next_visit]

A. “제가 연락드리고 오겠습니다.”
   effect: respect +3
   flag: asked_before_revisit

B. “다음 주 이 시간에 오겠습니다.”
   effect: trust +1

C. “문이 아니라 차 때문에 올지도 모르겠습니다.”
   require: affection >= 2
   effect: affection +3
   effect: trust +1
   flag: early_flirt

[SEOJEONG/smile]
그럼 오후 네 시쯤 오세요. 그때가 제일 한가해요.

[SYSTEM]
flag += four_oclock_promise
autosave
unlock = S01_E02_EXTRA_SCREW

[END]
title = 인연은 아직 이름이 없다
```

## 선택 결과 메모

- `asked_before_helping`과 `asked_before_revisit`을 모두 얻으면 섹터 4의 위기에서 `무엇을 맡을지 묻는다` 선택지가 기본 해금된다.
- 차를 거절해도 관계가 막히지 않는다. 다음 방문에서 서정의 배려를 기억하고 취향을 묻는 방식으로 회복할 수 있다.
- 초반 플러팅은 애정을 빠르게 올리지만 신뢰가 낮으면 서정이 가벼운 호의로 해석한다.

## 구현 메모

- 위 표기는 실제 GDScript 문법이 아니라 시나리오 작성용 중간 형식이다.
- 구현 시 각 블록을 JSON 또는 Godot `Resource` 데이터로 변환한다.
- 수치 효과는 한곳의 밸런스 테이블에서 관리하고 대본 본문에 하드코딩하지 않는다.
- 화면 하단에 수치를 즉시 표시하지 않고, 선택 후 표정·대사·대화 기록으로 먼저 피드백한다.

