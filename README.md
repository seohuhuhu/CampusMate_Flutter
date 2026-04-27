# 🎓 캠퍼스메이트 (CampusMate)

> **숭실대학교 대학생을 위한 스터디룸 예약 + 밥친구 AI 매칭 올인원 캠퍼스 라이프 앱**  
> `mitesh77/Best-Flutter-UI-Templates` 를 클론하여 기능을 추가·개편한 프로젝트

---

## 1. 프로젝트 개요

대학생이 캠퍼스에서 매일 겪는 두 가지 불편을 하나의 앱으로 해결합니다.

| 탭 | 기능 | 한 줄 설명 |
|---|---|---|
| 🏫 | **스터디룸 예약** | 날짜·인원 조건에 맞는 스터디룸을 찾아 바로 예약 |
| 🍜 | **밥친구 AI 매칭** | 단순 모집을 넘어, AI가 취향·시간·장소를 분석해 최적의 밥친구를 추천 |

---

## 2. 주요 기능

### 🏫 스터디룸 예약

| 기능 | 설명 |
|---|---|
| 스터디룸 목록 | 건물명·층수·수용인원·최대 이용시간·예약 가능 건수를 카드 UI로 표시 |
| 건물명 검색 | 검색어 입력 시 즉시 필터링 |
| 인원 기반 필터 | 선택 인원보다 수용인원이 작은 방은 목록에서 자동 제외 |
| 단일 날짜 선택 | 커스텀 캘린더 팝업 — 헤더에 요일(`EEE`) / 날짜(`MMM dd`) 두 줄 표시 |
| 날짜별 예약 관리 | 날짜마다 독립적인 예약 건수 관리 — 날짜 변경 시 해당 날짜의 잔여 건수로 갱신 |
| 예약 / 취소 | 버튼 한 번으로 예약·취소 토글, 내 예약엔 "내 예약" 배지 표시 |
| 예약 마감 | 예약 가능 건수 0이 되면 버튼 비활성 + "예약 마감" 배지 자동 표시 |
| 내 예약 목록 | 벨(🔔) 아이콘 → 예약한 방·날짜 목록 확인 및 즉시 취소 가능 |
| 멀티유저 시뮬레이션 | 브라우저 탭마다 독립 세션 ID — 예약 버튼 상태는 탭별 분리, 예약 건수는 탭 간 공유 |
| WiFi · 콘센트 뱃지 | 설비 여부 칩으로 표시 |

### 🍜 밥친구 AI 매칭

| 기능 | 설명 |
|---|---|
| 기본 샘플 데이터 | 첫 실행 시 다양한 메뉴·장소·시간대의 샘플 게시글 7개 자동 로드 |
| 모집 글 목록 | 장소·시간·메뉴·인원·한마디를 카드 UI로 표시, 최신순 정렬 |
| 글 작성 | 장소·메뉴 빠른선택 칩 제공 + 직접 입력 병행 |
| 참가하기 | 버튼 클릭 시 현재 인원 증가, 정원 초과 시 자동 마감 |
| 자기 글 보호 | 내가 작성한 글에는 참가 불가 — "내 글" 배지 + 삭제 버튼만 표시 |
| 스와이프 삭제 | 내 글을 오른쪽으로 스와이프하여 삭제 |
| **🤖 취향 설정** | 선호 메뉴 · 선호 장소 · 공강 시간을 설정하면 AI 추천 활성화 |
| **🤖 궁합 점수 배지** | 각 카드 우상단에 `87%` 형태로 실시간 궁합 점수 표시 |
| **🤖 AI 추천순 정렬** | "최신순 / 🤖 AI 추천순" 칩으로 정렬 방식 전환 |
| **🔥 매너 온도 배지** | 작성자 닉네임 옆에 신뢰도 온도 표시 (색상으로 단계 구분) |
| **🔥 내 매너 온도** | 정렬 바에서 내 현재 온도 확인 + 탭 시 획득 방법 안내 팝업 |
| 멀티유저 시뮬레이션 | 탭마다 다른 세션 ID → 각 탭이 서로 다른 유저로 동작 |
| 새로고침 동기화 | 새로고침 버튼으로 다른 탭의 변경사항 반영 |
| 데이터 영속성 | `SharedPreferences`로 앱 재시작 후에도 게시글·취향 유지 |

---

## 3. 🤖 AI 매칭 알고리즘

> 바이브 코딩(Claude AI)을 활용해 설계한 **취향 기반 밥친구 추천 엔진**입니다.

### 궁합 점수 계산 방식 (총 100점)

| 요소 | 만점 | 세부 기준 |
|---|---|---|
| 메뉴 궁합 | 40점 | 완전 일치 40 / 유사 장르(예: 한식↔분식) 20 / "아무거나" 35 |
| 장소 궁합 | 35점 | 완전 일치 35 / 부분 일치 18 / 기타 10 |
| 시간 궁합 | 25점 | 차이 0분 25 / 15분 이내 22 / 30분 이내 18 / 60분 이내 10 |
| 고정 변동값 | ±8점 | 포스트 ID 기반 시드 — 새로고침해도 점수가 변하지 않음 |

### 점수별 배지 색상

| 점수 | 색상 | 의미 |
|---|---|---|
| 85점 이상 | 🟢 초록 | 매우 높은 궁합 |
| 70 ~ 84점 | 🩵 teal | 높은 궁합 |
| 50 ~ 69점 | 🟠 주황 | 보통 궁합 |
| 49점 이하 | ⚫ 회색 | 낮은 궁합 |

### 사용 흐름

```
① 앱바 🧠 아이콘 클릭
② 선호 메뉴 / 선호 장소 / 공강 시간 설정
③ "취향 저장하고 AI 추천받기" 버튼
④ 각 게시글 카드에 궁합 점수 배지 자동 표시
⑤ "🤖 AI 추천순" 칩 클릭 → 높은 궁합 순으로 정렬
```

---

## 4. 🔥 매너 온도 — No-Show 방지 신뢰 시스템

> 밥친구·스터디룸 서비스의 고질적 문제인 **노쇼(No-Show)**를 억제하기 위한 신뢰 기반 매칭 로직입니다.

### 개념

유저마다 **0 ~ 100° 범위의 신뢰도 점수**를 부여하고, 점수가 높을수록 AI 매칭 상단에 노출됩니다.  
단순한 연속 이용보다 **책임감 있는 행동(참가·취소)**에 점수를 집중 부여하여 지속 가능한 서비스 생태계를 설계했습니다.

### 점수 획득 구조

| 행동 | 점수 | 근거 |
|---|---|---|
| 밥친구 모임에 참가 | +2° | 직접 나타날 의사 표현 |
| 내 글에 누군가 참가 | +3° | 신뢰받는 호스트 |
| 스터디룸 예약을 제때 취소 | +1° | 다른 유저에게 자리 양보 |

### 신뢰도 등급

| 온도 | 등급 | 색상 |
|---|---|---|
| 90° 이상 | 최우수 😎 | 🟢 초록 |
| 80 ~ 89° | 우수 😊 | 🩵 teal |
| 70 ~ 79° | 보통 🙂 | 🔵 파랑 |
| 55 ~ 69° | 주의 😐 | 🟠 주황 |
| 54° 이하 | 낮음 😶 | 🔴 빨강 |

### AI 매칭 연동

궁합 점수 계산 시 작성자의 신뢰도가 반영됩니다.

```
authorTrustScore ≥ 90  →  +5점 보너스
authorTrustScore ≥ 80  →  +3점 보너스
authorTrustScore < 70  →  -2점 패널티
authorTrustScore < 55  →  -5점 패널티
```

### UI 표현

- 각 게시글 카드의 **닉네임 옆에 🔥 온도 배지** (색상으로 등급 즉시 확인)
- 정렬 바 우측에 **내 현재 온도** 상시 표시
- 온도 탭 시 **획득 방법 안내 다이얼로그** 팝업

### 구현 방식 (백엔드 없이)

```
SharedPreferences["trust_scores"] = JSON 맵 { sessionId: 점수 }

탭 A 참가 → scores["user_A"] += 2, scores["post.authorId"] += 3
탭 B 새로고침 → _loadTrustScore() → 내 점수 반영
```

---

## 5. 구현 내역

### 기존 파일 수정

| 파일 | 수정 내용 |
|---|---|
| `lib/main.dart` | 앱 이름 변경, `BottomNavigationBar` 2탭 구조로 교체, 한국어 로케일 초기화 추가 |
| `lib/hotel_booking/model/hotel_list_data.dart` | 호텔 샘플 데이터 → 숭실대 스터디룸 8개 데이터로 전환, `hasWifi`·`hasOutlet` 필드 추가 |
| `lib/hotel_booking/hotel_home_screen.dart` | 인원 필터, 날짜별 예약 수 관리, 벨 아이콘 내 예약 패널, 커스텀 날짜 피커 연동, `SharedPreferences` 기반 예약 상태 관리 전면 재작성 |
| `lib/hotel_booking/hotel_list_view.dart` | `StatefulWidget` → `StatelessWidget` 변환, 예약 상태를 부모로 끌어올림, 예약 마감·내 예약 배지 추가 |
| `lib/hotel_booking/calendar_popup_view.dart` | Bottom overflow 수정 (`SingleChildScrollView` + `maxHeight` 제약) |
| `lib/hotel_booking/hotel_app_theme.dart` | 순환 import 해결을 위해 `HexColor` import 경로 변경 |
| `lib/meal_buddy/meal_buddy_list_screen.dart` | AI 매칭 엔진, 취향 설정 Bottom Sheet, 궁합 배지, 정렬 토글, 샘플 데이터 초기 로드, **매너 온도 시스템** 추가 |
| `lib/hotel_booking/hotel_home_screen.dart` | 예약 정상 취소 시 `trust_scores` +1 반영 추가 |
| `android/app/src/main/AndroidManifest.xml` | 앱 이름 → 캠퍼스메이트, Impeller 비활성화 |
| `android/gradle.properties` | Gradle 빌드 성능 최적화 (`daemon`, `parallel`, `caching`) |

### 신규 파일

| 파일 | 내용 |
|---|---|
| `lib/utils/hex_color.dart` | `HexColor` 클래스 분리 — 순환 import 문제 해결 |
| `lib/hotel_booking/single_date_picker_view.dart` | 커스텀 단일 날짜 선택 팝업 — teal 헤더에 요일·날짜 두 줄, 달력 그리드 |
| `lib/meal_buddy/model/meal_post.dart` | 밥친구 게시글 데이터 모델 (`authorId`, `authorTrustScore` 포함, JSON 직렬화) |
| `lib/meal_buddy/model/user_preference.dart` | 사용자 취향 모델 — 선호 메뉴·장소·공강시간, JSON 직렬화 |
| `lib/meal_buddy/meal_buddy_list_screen.dart` | 밥친구 목록 화면 — 참가/삭제/새로고침/세션 관리/매너 온도 관리 |
| `lib/meal_buddy/add_meal_post_screen.dart` | 밥친구 모집 글 작성 폼 (작성 시 현재 신뢰도 기록) |

---

## 6. 기술적 설계

### 멀티유저 시뮬레이션 구조 (백엔드 없이)

```
탭 A (유저 1)                      탭 B (유저 2)
──────────────────────             ──────────────────────
세션 ID: user_001  ← 메모리        세션 ID: user_002  ← 메모리
내 예약 목록       ← 메모리        내 예약 목록       ← 메모리
내 취향(pref)      ← 메모리        내 취향(pref)      ← 메모리

           SharedPreferences (브라우저 localStorage 공유)
           ├── room_counts_2026-04-27: {"형남공학관 스터디룸 A": 1}
           ├── meal_posts: [ { authorId: "user_001", ... }, ... ]
           └── my_meal_preference: { menu: "한식", location: "학생식당", ... }
```

| 데이터 | 저장 위치 | 탭 간 공유 |
|---|---|---|
| 세션 ID | 메모리 | ❌ 탭마다 독립 |
| 예약 버튼 상태 | 메모리 | ❌ 탭마다 독립 |
| 취향 설정 | SharedPreferences | ✅ 공유됨 |
| 예약 가능 건수 | SharedPreferences | ✅ 공유됨 |
| 밥친구 게시글 | SharedPreferences | ✅ 공유됨 |
| **매너 온도 점수** | **SharedPreferences** | **✅ 공유됨** |

### 날짜별 예약 건수 관리

```
SharedPreferences 키 구조

room_counts_2026-04-27  →  { "형남공학관 스터디룸 A": 2, "중앙도서관 세미나실 1": 1 }
room_counts_2026-04-28  →  { "미래관 그룹스터디실": 1 }
```

---

## 7. 해결한 버그

| 버그 | 원인 | 해결 방법 |
|---|---|---|
| 앱 실행 시 검은 화면 | `main.dart ↔ hotel_app_theme.dart` 순환 import | `HexColor`를 `utils/hex_color.dart`로 분리 |
| 한국어 날짜 포맷 오류 | `DateFormat` 로케일 미초기화 | `main()`에 `initializeDateFormatting('ko')` 추가 |
| 자기 글에 참가 가능 버그 | 유저 구분 수단 없음 | 탭마다 고유 세션 ID 발급 후 `authorId`와 비교 |
| 탭 간 예약 건수 미반영 | `SharedPreferences` 인스턴스 캐시 | `prefs.reload()` 호출로 강제 재조회 |
| 다른 탭 예약이 내 예약으로 표시 | 예약 여부를 SharedPreferences에 저장 | 예약 버튼 상태는 메모리에만, 건수만 SharedPreferences에 저장 |
| 캘린더 팝업 Bottom overflow | 고정 높이 Column이 화면 높이 초과 | `SingleChildScrollView` + `maxHeight` 제약 추가 |
| 날짜 피커 로케일 오류 | `showDatePicker`에 `Locale('ko')` 지정 시 delegate 누락 | 커스텀 `SingleDatePickerView`로 교체 |

---

## 8. 멀티유저 테스트 방법

> ⚠️ **멀티유저 동기화는 웹(Chrome) 전용입니다.**
>
> Android 에뮬레이터·실기기는 기기마다 앱 샌드박스가 격리되어 있어  
> `SharedPreferences`가 기기 간에 공유되지 않습니다.  
> 기기 간 실시간 동기화를 구현하려면 Firebase 등 별도 백엔드가 필요합니다.
>
> | 환경 | SharedPreferences 실체 | 기기 간 공유 |
> |---|---|---|
> | Chrome 탭 A / B | 같은 origin의 `localStorage` | ✅ 공유됨 |
> | Android 에뮬레이터 1 | 기기 1 앱 샌드박스 내부 | ❌ 격리됨 |
> | Android 에뮬레이터 2 | 기기 2 앱 샌드박스 내부 | ❌ 격리됨 |

**테스트 순서:**

```bash
flutter run -d chrome
```

1. 실행 후 브라우저에서 동일한 `localhost:포트` 주소를 **새 탭으로 열기**
2. 탭 A에서 스터디룸 예약 또는 밥친구 글 작성
3. 탭 B에서 새로고침(↻) → 변경사항 반영 확인

---

## 9. AI 활용 내역 (바이브 코딩)

본 프로젝트는 **Claude AI (바이브 코딩)** 를 적극 활용하였습니다.

### AI가 기여한 부분

- 기존 Hotel Booking 템플릿을 스터디룸 예약 UI로 리브랜딩하는 설계
- 밥친구 기능 아키텍처 설계 (모델 → 목록 → 등록 폼 3단 구성)
- **취향 기반 AI 매칭 알고리즘 초안 설계** (메뉴·장소·시간 가중치 점수 체계)
- **`UserPreference` 모델 및 궁합 점수 엔진 코드 생성**
- **매너 온도 시스템 초안 설계** (신뢰도 점수 구조 및 SharedPreferences 연동)
- 백엔드 없는 멀티유저 시뮬레이션 구조 제안 (세션 ID + SharedPreferences 역할 분리)
- 날짜별 예약 건수 관리 로직 및 커스텀 캘린더 팝업 코드 생성

### 내가 직접 수정·개선한 부분

- **AI가 생성한 `_calcCompatibility` 초안에서 `prefs.reload()` 누락을 발견** — 다른 탭의 변경사항이 반영되지 않는 원인을 직접 분석하고, `SharedPreferences` 인스턴스 캐시 문제임을 파악하여 `await prefs.reload()` 호출 방식으로 직접 수정
- **AI가 작성한 `showDatePicker(locale: Locale('ko'))` 코드에서 `MaterialLocalizations` delegate 누락 런타임 오류 발생** — 빌드 에러 로그를 읽고 Flutter 로케일 위임 구조를 파악하여, 커스텀 `SingleDatePickerView`로 직접 대체 설계
- AI 초안의 "다른 탭 예약이 내 예약으로 표시되는 버그" 발견 → 예약 버튼 상태(내 예약 여부)와 예약 건수를 분리 저장하는 방식으로 직접 아키텍처 수정
- 매너 온도를 단순 표시 수준에서 **AI 매칭 점수에 실제 연동** (가중치 로직 직접 설계)하고, 스터디룸 예약 취소 흐름과도 연계하도록 기능 확장

---

## 10. 실행 방법

```bash
cd best_flutter_ui_templates
flutter pub get

flutter run -d chrome   # 웹 — 멀티유저 시뮬레이션 + AI 매칭 테스트 권장
flutter run             # Android / iOS
```

---

## 11. 개발 환경 및 라이선스

- **Flutter SDK** / **Dart**
- **주요 패키지** : `shared_preferences ^2.2.2`, `font_awesome_flutter`, `intl`
- **원본 저장소** : [mitesh77/Best-Flutter-UI-Templates](https://github.com/mitesh77/Best-Flutter-UI-Templates)
- **라이선스** : MIT (원본 동일)