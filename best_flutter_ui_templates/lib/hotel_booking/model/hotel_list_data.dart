// 숭실대학교 스터디룸 데이터
class HotelListData {
  HotelListData({
    this.imagePath = '',
    this.titleTxt = '',
    this.subTxt = '',
    this.dist = 1.0,       // 수용 인원 (명)
    this.reviews = 1,      // 층수
    this.rating = 5.0,     // 잔여석
    this.perNight = 2,     // 최대 이용 시간 (시간)
    this.isBooked = false,
    this.hasWifi = true,
    this.hasOutlet = true,
  });

  String imagePath;
  String titleTxt;
  String subTxt;
  double dist;
  int reviews;
  double rating;
  int perNight;
  bool isBooked;
  bool hasWifi;
  bool hasOutlet;

  static List<HotelListData> hotelList = <HotelListData>[
    HotelListData(
      imagePath: 'assets/hotel/hotel_1.png',
      titleTxt: '형남공학관 스터디룸 A',
      subTxt: '형남공학관 · 4층',
      dist: 8,
      reviews: 4,
      rating: 5.0,
      perNight: 3,
      hasWifi: true,
      hasOutlet: true,
    ),
    HotelListData(
      imagePath: 'assets/hotel/hotel_2.png',
      titleTxt: '중앙도서관 세미나실 1',
      subTxt: '중앙도서관 · 3층',
      dist: 12,
      reviews: 3,
      rating: 3.0,
      perNight: 2,
      hasWifi: true,
      hasOutlet: false,
    ),
    HotelListData(
      imagePath: 'assets/hotel/hotel_3.png',
      titleTxt: '글로벌미디어학부 스터디룸',
      subTxt: '글로벌미디어학부관 · 2층',
      dist: 6,
      reviews: 2,
      rating: 6.0,
      perNight: 4,
      hasWifi: true,
      hasOutlet: true,
    ),
    HotelListData(
      imagePath: 'assets/hotel/hotel_1.png',
      titleTxt: '미래관 그룹스터디실',
      subTxt: '미래관 · 1층',
      dist: 10,
      reviews: 1,
      rating: 4.0,
      perNight: 3,
      hasWifi: true,
      hasOutlet: true,
    ),
    HotelListData(
      imagePath: 'assets/hotel/hotel_2.png',
      titleTxt: '학생회관 다목적실',
      subTxt: '학생회관 · 2층',
      dist: 20,
      reviews: 2,
      rating: 8.0,
      perNight: 2,
      hasWifi: true,
      hasOutlet: true,
    ),
    HotelListData(
      imagePath: 'assets/hotel/hotel_3.png',
      titleTxt: '베어드홀 세미나실',
      subTxt: '베어드홀 · 3층',
      dist: 8,
      reviews: 3,
      rating: 2.0,
      perNight: 3,
      hasWifi: false,
      hasOutlet: true,
    ),
    HotelListData(
      imagePath: 'assets/hotel/hotel_1.png',
      titleTxt: '조만식기념관 스터디룸',
      subTxt: '조만식기념관 · 2층',
      dist: 6,
      reviews: 2,
      rating: 3.0,
      perNight: 2,
      hasWifi: true,
      hasOutlet: false,
    ),
    HotelListData(
      imagePath: 'assets/hotel/hotel_2.png',
      titleTxt: '한경직기념관 소회의실',
      subTxt: '한경직기념관 · 1층',
      dist: 15,
      reviews: 1,
      rating: 5.0,
      perNight: 4,
      hasWifi: true,
      hasOutlet: true,
    ),
  ];
}
