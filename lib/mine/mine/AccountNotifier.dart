import 'dart:async';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../all_res/AccountInfo.dart';


class LeftTimeNotifier extends StateNotifier<String> {
  LeftTimeNotifier() : super("");
  Timer? _timer;
  AccountInfo? accountInfo;


  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      // 更新剩余时间
      if (state.isNotEmpty) {
        // 这里调用你实际的 AccountInfo 源进行获取
        setLeftTime(accountInfo!); // 示例时间戳
      }
    });
  }
  void setLeftTime(AccountInfo accountInfo) {
    this.accountInfo = accountInfo;
    // 假设 expiredAt 包含时间戳（单位为毫秒）
    final expirationTimestamp = accountInfo.expiredAt; // 这里是时间戳（单位：毫秒）
    final expirationDateTime = DateTime.fromMillisecondsSinceEpoch(expirationTimestamp*1000);
    final currentTime = DateTime.now();
    final difference = expirationDateTime.difference(currentTime);

    if (difference.inDays >= 1) {
      state = "${difference.inDays} 天";
    } else if (difference.inHours >= 1) {
      state = "${difference.inHours} 小时";
    } else if (difference.inMinutes >= 1) {
      state = "${difference.inMinutes} 分钟";
    } else {
      state = "已过期";
    }
  }


}

final leftTimeProvider = StateNotifierProvider<LeftTimeNotifier, String>((ref) {
  return LeftTimeNotifier();
});