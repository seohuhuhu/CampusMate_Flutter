# 캠퍼스메이트 (CampusMate)

숭실대학교 대학생을 위한 **스터디룸 예약 + 밥친구 AI 매칭** 올인원 캠퍼스 라이프 앱

---

## 프로그램 개요

대학생이 캠퍼스에서 매일 겪는 두 가지 불편을 하나의 앱으로 해결합니다.

- **스터디룸 예약** : 날짜·인원 조건에 맞는 스터디룸을 검색하고 바로 예약
- **밥친구 AI 매칭** : AI가 취향·시간·장소를 분석해 최적의 밥친구를 추천

Flutter 웹 기반으로 구현하여 브라우저 탭마다 독립 세션 ID를 발급하고, `SharedPreferences`(localStorage)로 탭 간 데이터를 공유함으로써 **백엔드 없이 멀티유저 시뮬레이션**이 가능합니다.

---

## 주요 기능

### 🏫 스터디룸 예약

- 숭실대 스터디룸 8개 데이터 (건물명·수용인원·WiFi·콘센트 정보)
- 건물명 검색 및 인원 기반 자동 필터링
- 날짜별 예약 건수 관리 — 날짜 변경 시 해당 날짜의 잔여 건수로 갱신
- 예약 / 취소 토글, "내 예약" 배지, 예약 마감 자동 처리
- 벨 아이콘으로 내 예약 목록 확인 및 즉시 취소
- 멀티탭 시뮬레이션 — 예약 건수는 탭 간 공유, 예약 버튼 상태는 탭별 독립

### 🍜 밥친구 AI 매칭

- 밥친구 모집 글 작성 (장소·메뉴 빠른 선택 칩 + 직접 입력)
- 참가하기 버튼 — 인원 자동 증가, 정원 마감 시 비활성화
- 자기 글 보호 — 본인 글에 참가 불가, 삭제 버튼만 노출
- AI 취향 설정 (선호 메뉴·장소·공강 시간) → 궁합 점수 배지 실시간 표시
- 최신순 / AI 추천순 정렬 전환
- `SharedPreferences` 기반 데이터 영속성 및 탭 간 동기화

### 🔥 매너 온도 — No-Show 방지 신뢰 시스템

유저마다 0~100° 신뢰 점수를 부여하여 AI 매칭 순위에 반영합니다.

| 행동 | 점수 |
|---|---|
| 밥친구 모임 참가 | +2° |
| 내 글에 누군가 참가 | +3° |
| 스터디룸 사전 취소 | +1° |
| 참가자 있는 밥친구 글 삭제 | -3° |
| 스터디룸 당일 취소 | -2° |

- 앱바 🔥 아이콘에 현재 온도 뱃지 상시 표시
- 게시글 카드 닉네임 옆에 작성자 온도 배지 표시 (탭 시 상세 팝업)
- 매너 온도가 AI 궁합 점수에 ±5점 보너스/패널티로 연동

---

## 본인이 구현한 부분

### 기존 파일 수정

| 파일 | 내용 |
|---|---|
| `lib/main.dart` | 앱 이름 변경, BottomNavigationBar 2탭 구조 교체, 한국어 로케일 초기화 |
| `lib/hotel_booking/hotel_home_screen.dart` | 인원 필터, 날짜별 예약 수 관리, 내 예약 패널, 당일/사전 취소 매너 온도 연동 전면 재작성 |
| `lib/hotel_booking/model/hotel_list_data.dart` | 호텔 샘플 데이터 → 숭실대 스터디룸 8개로 전환, WiFi·콘센트 필드 추가 |
| `lib/hotel_booking/hotel_list_view.dart` | StatefulWidget → StatelessWidget, 예약 마감·내 예약 배지 추가 |
| `lib/hotel_booking/calendar_popup_view.dart` | Bottom overflow 수정 |
| `lib/meal_buddy/meal_buddy_list_screen.dart` | AI 매칭 엔진, 취향 설정, 궁합 배지, 매너 온도 시스템 추가 |

### 신규 파일

| 파일 | 내용 |
|---|---|
| `lib/utils/hex_color.dart` | HexColor 클래스 분리 — 순환 import 해결 |
| `lib/hotel_booking/single_date_picker_view.dart` | 커스텀 단일 날짜 선택 팝업 |
| `lib/meal_buddy/model/meal_post.dart` | 밥친구 게시글 데이터 모델 (JSON 직렬화) |
| `lib/meal_buddy/model/user_preference.dart` | 사용자 취향 모델 (JSON 직렬화) |
| `lib/meal_buddy/meal_buddy_list_screen.dart` | 밥친구 목록 화면 전체 |
| `lib/meal_buddy/add_meal_post_screen.dart` | 밥친구 모집 글 작성 폼 |

---

## AI 활용 여부 및 활용 범위 (바이브 코딩)

본 프로젝트는 **Claude AI (바이브 코딩)** 를 적극 활용하였습니다.

### AI가 기여한 부분

- Hotel Booking 템플릿을 스터디룸 예약 UI로 리브랜딩하는 초기 설계
- 밥친구 기능 아키텍처 설계 (모델 → 목록 → 등록 폼 3단 구성)
- 취향 기반 AI 매칭 알고리즘 초안 (메뉴·장소·시간 가중치 점수 체계)
- `UserPreference` 모델 및 궁합 점수 엔진 코드 생성
- 매너 온도 시스템 구조 설계 및 SharedPreferences 연동 코드 생성
- 백엔드 없는 멀티유저 시뮬레이션 구조 제안 (세션 ID + SharedPreferences 역할 분리)

### 직접 수정·개선한 부분

- AI 초안에서 `prefs.reload()` 누락 발견 → 탭 간 데이터 미반영 원인 직접 분석 및 수정
- `showDatePicker(locale: Locale('ko'))` delegate 누락 오류 → 커스텀 `SingleDatePickerView`로 직접 대체 설계
- "다른 탭 예약이 내 예약으로 표시되는 버그" 발견 → 예약 버튼 상태와 예약 건수를 분리 저장하는 아키텍처로 직접 수정
- 매너 온도를 AI 궁합 점수에 실제 연동 (가중치 로직 직접 설계) 및 스터디룸 취소 흐름과 연계 확장
- 참가자 있는 글 삭제 시 in-memory 상태가 stale하여 패널티 미적용 버그 → SharedPreferences에서 직접 reload하는 방식으로 수정

---

## 실행 방법

```bash
cd best_flutter_ui_templates
flutter pub get
flutter run -d chrome   # 웹 권장 (멀티탭 시뮬레이션 가능)
```

---

## 라이선스

MIT License — 원본 저장소 라이선스 동일 적용

---

## 원본 저장소

본 프로젝트는 아래 오픈소스 템플릿을 클론하여 기능을 추가·개편하였습니다.

- **원본** : [mitesh77/Best-Flutter-UI-Templates](https://github.com/mitesh77/Best-Flutter-UI-Templates)
- **사용 템플릿** : Hotel Booking UI (스터디룸 예약으로 리브랜딩)
