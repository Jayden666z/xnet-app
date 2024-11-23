import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:version/version.dart';
import 'package:hiddify/core/haptic/haptic_service.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/connection/data/connection_data_providers.dart';
import 'package:hiddify/features/connection/data/connection_repository.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';

import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:rxdart/rxdart.dart';
import '../../../core/app_info/app_info_provider.dart';
import '../../../core/localization/translations.dart';
import '../../../mine/all_res/AccountInfo.dart';
import '../../../mine/all_res/VersionCheck.dart';
import '../../../mine/all_res/api_request.dart';
import '../../../mine/all_res/color_styles.dart';
import '../../../mine/all_res/device_utils.dart';
import '../../../mine/all_res/http.dart';
import '../../../mine/all_res/local_storage.dart';
import '../../../mine/all_res/my_util.dart';
import '../../../mine/mine/AccountNotifier.dart';
import '../../../mine/pay_page/pay_page.dart';
import '../../profile/notifier/profile_notifier.dart';
part 'connection_notifier.g.dart';

class LoadingNotifier extends StateNotifier<bool> {
  LoadingNotifier() : super(false);

  void setLoading(bool isLoading) {
    state = isLoading;
  }
}

final loadingSubProvider = StateNotifierProvider<LoadingNotifier, bool>((ref) {
  return LoadingNotifier();
});

@Riverpod(keepAlive: true)
class ConnectionNotifier extends _$ConnectionNotifier with AppLogger {
  @override
  Stream<ConnectionStatus> build() async* {
    if (Platform.isIOS) {
      await _connectionRepo.setup().mapLeft((l) {
        loggy.error("error setting up connection repository", l);
      }).run();
    }

    ref.listenSelf(
          (previous, next) async {
        if (previous == next) return;
        if (previous case AsyncData(:final value) when !value.isConnected) {
          if (next case AsyncData(value: final Connected _)) {
            await ref.read(hapticServiceProvider.notifier).heavyImpact();

            if (Platform.isAndroid &&
                !ref.read(Preferences.storeReviewedByUser)) {
              if (await InAppReview.instance.isAvailable()) {
                InAppReview.instance.requestReview();
                ref.read(Preferences.storeReviewedByUser.notifier).update(true);
              }
            }
          }
        }
      },
    );

    ref.listen(
      activeProfileProvider.select((value) => value.asData?.value),
          (previous, next) async {
        if (previous == null) return;
        final shouldReconnect = next == null || previous.id != next.id;
        if (shouldReconnect) {
          await reconnect(next);
        }
      },
    );
    yield* _connectionRepo.watchConnectionStatus().doOnData((event) {
      if (event case Disconnected(connectionFailure: final _?)
      when PlatformUtils.isDesktop) {
        ref.read(Preferences.startedByUser.notifier).update(false);
      }
      loggy.info("connection status: ${event.format()}");
    });
  }

  bool loadingSub = false;

  bool getLoadingSub() => loadingSub;

  ConnectionRepository get _connectionRepo =>
      ref.read(connectionRepositoryProvider);
  bool requestUpdate = true;

  Future<void> mayConnect() async {
    if (state case AsyncData(:final value)) {
      if (value case Disconnected()) return _connect();
    }
  }

  Future<void> toggleConnection() async {
    final haptic = ref.read(hapticServiceProvider.notifier);
    if (state case AsyncError()) {
      await haptic.lightImpact();
      await _connect();
    } else if (state case AsyncData(:final value)) {
      switch (value) {
        case Disconnected():
          await haptic.lightImpact();
          await ref.read(Preferences.startedByUser.notifier).update(true);
          await _connect();
        case Connected():
          await haptic.mediumImpact();
          await ref.read(Preferences.startedByUser.notifier).update(false);
          await _disconnect();
        default:
          loggy.warning("switching status, debounce");
      }
    }
  }

  Future<void> reconnect(ProfileEntity? profile) async {
    if (state case AsyncData(:final value) when value == const Connected()) {
      if (profile == null) {
        loggy.info("no active profile, disconnecting");
        return _disconnect();
      }
      loggy.info("active profile changed, reconnecting");
      await ref.read(Preferences.startedByUser.notifier).update(true);
      await _connectionRepo
          .reconnect(
        profile.id,
        profile.name,
        ref.read(Preferences.disableMemoryLimit),
        profile.testUrl,
      )
          .mapLeft((err) {
        loggy.warning("error reconnecting", err);
        state = AsyncError(err, StackTrace.current);
      }).run();
    }
  }

  Future<void> abortConnection() async {
    if (state case AsyncData(:final value)) {
      switch (value) {
        case Connected() || Connecting():
          loggy.debug("aborting connection");
          await _disconnect();
        default:
      }
    }
  }

  Future<Response?> requestLogin(String deviceId) async {
    //直接帮用户注册
    try{
      var res1 = await WooHttpUtil().post(
        "/api/v1/passport/auth/register",
        data: {
          "email": "$deviceId@xnet.com",
          "password": "123456789",
        },
        fail: (e) {
          return "";
        },
      );
      return res1;
    }catch (e){
      var res1 = await WooHttpUtil().post(
        "/api/v1/passport/auth/login",
        data: {
          "email": "$deviceId@xnet.com",
          "password": "123456789",
        },
        fail: (e) {
          print(e.toString());
        },
      );
      return res1;
    }
    return null;

    // return res1;

  }

  Future<void> _connect() async {
    //获取loadingSubProvider 的值
    loadingSub = ref.read(loadingSubProvider);
    final t = ref.watch(translationsProvider);
    String jsonStr = SpUtil.get("account_info").toString();
    print('jsonStr');
    print(jsonStr);
    ref.read(loadingSubProvider.notifier).setLoading(true);

    if (loadingSub) {
      print('loadingSubProvider is true');
      return;
    }
    //判断是否登录
    if (jsonStr.isEmpty) {
      String deviceId = await DeviceUtils.getDeviceId();
      print("deviceId");
      print(deviceId);
      String email = "$deviceId@xnet.com";
      //直接帮用户注册
      var res1=await requestLogin(deviceId);
      if(res1==null){
        ToastUtils.show("登录异常");
        return;
      }
      print("relay");
      print(res1.data.toString());

      String authData = res1.data["data"]['auth_data'].toString();
      SpUtil.save("auth_data", authData);
      SpUtil.save("email", email);

      // await ref
      //     .read(addProfileProvider.notifier)
      //     .checkAvailability(context, (){
      //   isLoading.value = false;
      // });

      // showDialog(
      //   context: rootNavigatorKey.currentState!.context,
      //   builder: (BuildContext context) {
      //     return AlertDialog(
      //       title: Text(t.nologin),
      //       content: Text(t.logintofree),
      //       actions: <Widget>[
      //         TextButton(
      //           child:  Text(t.login),
      //           onPressed: () {
      //             Navigator.of(context).pop();
      //             const RegisterRoute().push(context);
      //             // context.go("/register");
      //           },
      //         ),
      //       ],
      //     );
      //   },
      // );
    }
    if (requestUpdate) {
      late VersionCheck version;
      try {
        version = await RequestAPi().getVersion();
      }catch(e){
        ref.read(loadingSubProvider.notifier).setLoading(false);
      }
      final appInfo = ref.watch(appInfoProvider).requireValue;
      final latestVersion = Version.parse(version.version);
      final currentVersion = Version.parse(appInfo.version);
      if (latestVersion > currentVersion) {
        ref.read(loadingSubProvider.notifier).setLoading(false);
        //弹出提示
        showDialog(
          context: rootNavigatorKey.currentState!.context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('发现新版本'),
              content: const Text('发现新版本,请更新应用'),
              actions: [
                if (version.force)
                  const SizedBox()
                else
                  TextButton(
                    child: const Text('跳过'),
                    onPressed: () async {
                      requestUpdate = false;
                      Navigator.of(context).pop();
                      _connect();
                    },
                  ),
                TextButton(
                  child: const Text('更新'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await UriUtils.tryLaunch(Uri.parse(version.url));
                  },
                ),
              ],
            );
          },
        );
        return;
      }
    }

    try {
      bool isAvailable =   await ref
          .read(addProfileProvider.notifier)
          .checkAvailability(rootNavigatorKey.currentContext, () {});
      if(!isAvailable){
        ref.read(loadingSubProvider.notifier).setLoading(false);

      }
    } catch (e) {
      ref.read(loadingSubProvider.notifier).setLoading(false);
    }
    jsonStr = SpUtil.get("account_info").toString();
    final AccountInfo accountInfo =
    AccountInfo.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);

    final int expiredAt = accountInfo.expiredAt;
    final int currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    if (expiredAt < currentTimestamp) {
      return;
    }

    if ((accountInfo.u + accountInfo.d) > accountInfo.transferEnable) {
      ref.read(loadingSubProvider.notifier).setLoading(false);

      showDialog(
        context: rootNavigatorKey.currentState!.context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('流量已用完'),
            content: const Text('您的流量已用完，请续费！付费后会重置流量'),
            actions: [
              TextButton(
                child: Text(t.renewal),
                onPressed: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                      isScrollControlled: true,
                      context: rootNavigatorKey.currentState!.context,
                      builder: (BuildContext context) {
                        return Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20)), // 设置圆角
                            color: ColorStyles.color_95_white,
                          ),
                          padding: const EdgeInsets.all(16),
                          height: MediaQuery.of(context).size.height - 140,
                          child: PayPage(),
                        );
                      });
                },
              ),
            ],
          );
        },
      );
      // final notification = ref.read(inAppNotificationControllerProvider);
      // notification.showToast(rootNavigatorKey.currentState!.context, "您的流量已用完，请续费！");

      return;
    }
    ref.read(leftTimeProvider.notifier).setLeftTime(accountInfo);
    ref.read(leftTimeProvider.notifier).startTimer();

    await Future.delayed(Duration(seconds: 1));
    final activeProfile = await ref.read(activeProfileProvider.future);
    if (activeProfile == null) {
      //循环判断 activeProfile的值，如果为空就重试判断是否为空
      await Future.delayed(Duration(seconds: 1));
      final activeProfile1 = await ref.read(activeProfileProvider.future);
      if(activeProfile1==null){
        await Future.delayed(const Duration(seconds: 2));
        final activeProfile2 = await ref.read(activeProfileProvider.future);
        if(activeProfile2==null){
          ref.read(loadingSubProvider.notifier).setLoading(false);
          ToastUtils.show("加载失败请重试");
          loggy.info("no active profile, not connecting");
          return;
        }
      }
      ref.read(loadingSubProvider.notifier).setLoading(false);
      return;
    }
    ref.read(loadingSubProvider.notifier).setLoading(false);
    ;
    // EasyLoading.show(status: '加载配置文件中...');

    // showDialog(
    //   context: rootNavigatorKey.currentState!.context,
    //   barrierDismissible: true, // 禁止点击外部关闭弹窗
    //   builder: (BuildContext context) {
    //     return const PopScope(
    //       canPop: true,
    //       child: AlertDialog(
    //         content: SizedBox(
    //           height: 50, // 指定高度
    //           child: Row(
    //             mainAxisAlignment: MainAxisAlignment.center,
    //             children: [
    //               SpinKitFadingCircle(
    //                 color: Colors.black,
    //                 size: 20.0,
    //               ),
    //               SizedBox(width: 20),
    //               Text("加载配置文件中..."),
    //             ],
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );

    // 设置 loadingSub 为 true    loadingSub=true;
    // bool? checkAvailability = await ref
    //     .read(addProfileProvider.notifier)
    //     .checkAvailability(null);
    // EasyLoading.dismiss();
    //将ConnectionStatus的状态改为connecting

    // if (!checkAvailability) {
    //   Navigator.of(rootNavigatorKey.currentState!.context).pop(); // 关闭弹窗
    //   return;
    // }
    // Navigator.of(rootNavigatorKey.currentState!.context).pop(); // 关闭弹窗
    await _connectionRepo
        .connect(
      activeProfile.id,
      activeProfile.name,
      ref.read(Preferences.disableMemoryLimit),
      activeProfile.testUrl,
    )
        .mapLeft((err) async {
      loggy.warning("error connecting", err);
      //Go err is not normal object to see the go errors are string and need to be dumped
      loggy.warning(err);
      await ref.read(Preferences.startedByUser.notifier).update(false);
      state = AsyncError(err, StackTrace.current);
    }).run();
  }

  Future<void> _disconnect() async {
    await _connectionRepo.disconnect().mapLeft((err) {
      loggy.warning("error disconnecting", err);
      state = AsyncError(err, StackTrace.current);
    }).run();
  }
}

@Riverpod(keepAlive: true)
Future<bool> serviceRunning(ServiceRunningRef ref) => ref
    .watch(
  connectionNotifierProvider.selectAsync((data) => data.isConnected),
)
    .onError((error, stackTrace) => false);
