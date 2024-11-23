import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/utils/utils.dart';

import 'package:hiddify/core/notification/in_app_notification_controller.dart';
import '../../core/router/app_router.dart';
import '../../core/router/routes.dart';
import '../all_res/AccountInfo.dart';
import '../all_res/color_styles.dart';
import '../all_res/local_storage.dart';
import '../all_res/pressable_container.dart';
import '../pay_page/pay_page.dart';


class MinePage extends HookConsumerWidget with PresLogger {
  MinePage({super.key});

  AccountInfo? accountInfo;
  String formattedDate = "";

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    useEffect(() {
      final String jsonStr = SpUtil.get("account_info").toString();
      if (jsonStr.isEmpty) {
        return;
      }
      try {
        accountInfo =
            AccountInfo.fromJson(jsonDecode(jsonStr) as Map<String, dynamic>);
      }catch (e) {

      }
      final DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(
          (accountInfo?.expiredAt ?? 0) * 1000);
      formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);


      //剩余

      return null; // 返null表示没有清理操作
    });
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: ListView(
          children: [
            Container(
              // height: 122,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: ColorStyles.color_000000,
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  // mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            BounceInDown(
                                from: 10,
                                child: SizedBox(
                                  height: 40,
                                  width: 40,
                                  child: SvgPicture.asset(
                                    "assets/images/white.svg",
                                    height: 40,
                                    width: 40,
                                    fit: BoxFit.contain,
                                  ),
                                )),
                            // Container(
                            //   height: 40,
                            //   width: 40,
                            //   child: Image.asset(
                            //     "assets/whitexhdpi.png",
                            //     height: 40,
                            //     width: 40,
                            //     fit: BoxFit.contain,
                            //   ),
                            // ),
                            const SizedBox(width: 10),
                            Text(
                              t.bugAPlan,
                              style: const TextStyle(
                                  fontSize: 20,
                                  color: ColorStyles.color_100_white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                         Text(
                          t.breakstr,
                          style: const TextStyle(
                              color: ColorStyles.color_deep_unselect_text,
                              fontSize: 11),
                        ),
                      ],
                    ),
                    Spacer(),
                    PressableContainer(
                      onTap: (){
                        showModalBottomSheet(
                            isScrollControlled: true,
                            context: context,
                            builder: (BuildContext context) {
                              return Container(
                                decoration: const BoxDecoration(
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // 设置圆角
                                  color: ColorStyles.color_95_white,
                                ),
                                padding: const EdgeInsets.all(16),
                                height: MediaQuery.of(context).size.height - 140,
                                child: PayPage(),
                              );
                            });
                      },
                      enableAnimate: true,
                        child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(t.buy,style: const TextStyle(fontWeight:FontWeight.bold),),
                    ))
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const SizedBox(
              height: 10,
            ),

            if (accountInfo?.email!=null) Column(
               crossAxisAlignment: CrossAxisAlignment.start,
               children: [
               Padding(
                 padding: const EdgeInsets.only(left: 8),
                 child: Text(t.accountInfo),
               ),
               const SizedBox(
                 height: 2,
               ),
               PressableContainer(
                   child: Column(
                     children: [
                       _buildItem(
                         //去除 字符串中 @后面的字符
                         t.mail,
                         removeAtAndAfter(accountInfo?.email?? ""),InkWell(child: const Icon(Icons.copy),onTap: (){
                         //复制
                         Clipboard.setData(ClipboardData(text: removeAtAndAfter(accountInfo?.email?? "")));
                         final notification = ref.read(inAppNotificationControllerProvider);
                         notification.showToast(context, "复制成功");
                       },),
                       ),
                       _buildItem(
                           t.expiration,
                           formattedDate,null
                       ),
                       _buildItem(
                           t.combo,
                           accountInfo?.plan.name ?? "",null
                       )
                     ],
                   )),
             ],) else Container(),

            SizedBox(
              height: 10,
            ),
            // Padding(
            //   padding: const EdgeInsets.only(left: 8),
            //   child: const Text("其他"),
            // ),
            SizedBox(
              height: 2,
            ),
            // PressableContainer(
            //     child: Column(
            //       children: [
            //         _buildItem(
            //           "版本更新",
            //           "tap",
            //         ),
            //       ],
            //     )),
             Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Text(t.otherUse),
            ),
            PressableContainer(
                child: Column(
                  children: [

                    _buildItem(
                      t.webSite,
                      "https://xnetvpn.com",
                      InkWell(onTap: (){
                        launchUrl(Uri.parse("https://xnetvpn.com"));
                      },child:
                      const Icon(Icons.open_in_new)
                        ,) ,
                    ),


                  ],
                )),
            const SizedBox(
              height: 2,
            ),
            const SizedBox(
              height: 12,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: PressableContainer(
                  height: 40,
                  width: 140,
                  onTap: () {


                    showDialog(
                      context: rootNavigatorKey.currentState!.context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title:  Text(t.reLogin),
                          content:  Text(t.isReLogin),
                          actions: <Widget>[
                            TextButton(
                              child:  Text(t.confirm),
                              onPressed: () {
                                Navigator.of(context).pop();
                                const LoginRoute().push(context);
                                // context.go("/register");
                              },
                            ),
                          ],
                        );
                      },
                    );
                  },
                  enableDeepColor: true,
                  enableVibrate: true,
                  enableAnimate: true,
                  child:  Center(
                    child: Text(t.Logout),
                  )),
            ),

          ],
        ),
      ),
    );
  }

  String removeAtAndAfter(String str) {
    int atIndex = str.indexOf('@');
    if (atIndex != -1) {
      return str.substring(0, atIndex); // 去除 @ 及之后的部分
    }
    return str; // 如果没有 @，返回原字符串
  }

  Widget _buildItem(
    String title,
    String content,
    Widget ? icon,
  ) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Row(
        children: [
          Text(title),
          const Spacer(),
          if (content!="tap") Text(
            content,
            style: const TextStyle(color: ColorStyles.color_deep_unselect_text),
          ) else const Icon(Icons.keyboard_arrow_right_outlined),
          const SizedBox(
            width: 10,
          ),
          if (icon != null) icon,
        ],
      ),
    );
  }
}
