import 'package:best_flutter_ui_templates/hotel_booking/hotel_app_theme.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'model/hotel_list_data.dart';

class HotelListView extends StatelessWidget {
  const HotelListView({
    Key? key,
    this.hotelData,
    this.animationController,
    this.animation,
    this.callback,
    required this.isBooked,       // 이 세션(탭)에서 예약했는지 여부
    required this.remainingSeats, // 실시간 잔여석 (공유 데이터 기반)
    required this.onToggleBooking,
  }) : super(key: key);

  final VoidCallback? callback;
  final HotelListData? hotelData;
  final AnimationController? animationController;
  final Animation<double>? animation;

  final bool isBooked;
  final int remainingSeats;
  final VoidCallback onToggleBooking;

  @override
  Widget build(BuildContext context) {
    final data = hotelData!;
    final primaryColor = HotelAppTheme.buildLightTheme().primaryColor;
    final isFull = remainingSeats <= 0 && !isBooked;

    return AnimatedBuilder(
      animation: animationController!,
      builder: (BuildContext context, Widget? child) {
        return FadeTransition(
          opacity: animation!,
          child: Transform(
            transform: Matrix4.translationValues(
                0.0, 50 * (1.0 - animation!.value), 0.0),
            child: Padding(
              padding: const EdgeInsets.only(
                  left: 24, right: 24, top: 8, bottom: 16),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      offset: const Offset(4, 4),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(16.0)),
                  child: Stack(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          // 스터디룸 이미지
                          AspectRatio(
                            aspectRatio: 2,
                            child: Image.asset(
                              data.imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // 카드 하단 정보
                          Container(
                            color: HotelAppTheme.buildLightTheme()
                                .colorScheme
                                .background,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 16, top: 12, right: 16, bottom: 4),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      // 왼쪽: 이름 + 위치 + 뱃지
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              data.titleTxt,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                Icon(
                                                  FontAwesomeIcons.locationDot,
                                                  size: 13,
                                                  color: primaryColor,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  data.subTxt,
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    color: Colors.grey
                                                        .withOpacity(0.9),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                _infoBadge(
                                                  Icons.people_outline,
                                                  '${data.dist.toInt()}명',
                                                  primaryColor,
                                                ),
                                                const SizedBox(width: 6),
                                                if (data.hasWifi)
                                                  _infoBadge(
                                                    Icons.wifi,
                                                    'WiFi',
                                                    Colors.blue,
                                                  ),
                                                const SizedBox(width: 6),
                                                if (data.hasOutlet)
                                                  _infoBadge(
                                                    Icons.power_outlined,
                                                    '콘센트',
                                                    Colors.orange,
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      // 오른쪽: 최대 이용시간 + 잔여석
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: primaryColor
                                                  .withOpacity(0.1),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '최대 ${data.perNight}시간',
                                              style: TextStyle(
                                                fontWeight: FontWeight.w700,
                                                fontSize: 14,
                                                color: primaryColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          // 예약 가능 건수: 실시간 공유 데이터 사용
                                          Text(
                                            remainingSeats > 0
                                                ? '예약 가능 ${remainingSeats}건'
                                                : '예약 마감',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: remainingSeats > 0
                                                  ? Colors.green[600]
                                                  : Colors.red[400],
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                // 예약 버튼
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 10),
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton(
                                      onPressed: isFull ? null : onToggleBooking,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: isBooked
                                            ? Colors.grey[400]
                                            : isFull
                                                ? Colors.grey[300]
                                                : primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 12),
                                        elevation:
                                            (isBooked || isFull) ? 0 : 3,
                                      ),
                                      child: Text(
                                        isBooked
                                            ? '✓ 예약됨 (취소하기)'
                                            : isFull
                                                ? '예약 마감'
                                                : '예약하기',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: (isBooked || isFull)
                                              ? Colors.grey[600]
                                              : Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      // 즐겨찾기 버튼
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.85),
                            shape: BoxShape.circle,
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(32),
                              onTap: () {},
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.favorite_border,
                                  color: primaryColor,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // 예약됨 배지 (내 세션에서 예약한 경우만)
                      if (isBooked)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF54D3C2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '내 예약',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      // 마감 배지 (잔여석 0이고 내가 예약 안 한 경우)
                      if (isFull)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red[400],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              '마감',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _infoBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
