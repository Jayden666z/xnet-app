import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/router/app_router.dart';
import 'package:hiddify/core/router/router.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import '../../core/localization/translations.dart';
import '../../core/preferences/preferences_provider.dart';
import '../../features/profile/notifier/profile_notifier.dart';
import '../all_res/color_styles.dart';
import '../all_res/http.dart';
import '../all_res/local_storage.dart';
import '../all_res/my_util.dart';
import '../all_res/pressable_container.dart';

// 假设我们有一个用于管理登录状态的provider
// import 'login_provider.dart'; // 假设这是你的provider文件

class LoginPage extends HookConsumerWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final phoneController = useTextEditingController();
    final pwdController = useTextEditingController();
    final isLoading = useState(false);

    final t = ref.watch(translationsProvider);

    Future<void> getSubscribe() async {
      isLoading.value = true;
      var res = await WooHttpUtil().get("/api/v1/user/getSubscribe", fail: (e) {
        isLoading.value = false;
      });
      SpUtil.save(
          "subscribe_url", res.data["data"]['subscribe_url'].toString());
      await ref.read(addProfileProvider.notifier).add(SpUtil.get("subscribe_url").toString());
      isLoading.value = false;
      // const HomeRoute().pushReplacement(context);
      // context.pushReplacement("/");
      context.go("/");
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(t.login),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Padding(
            padding:  EdgeInsets.all(10),
            child: Container(
              width: MediaQuery.of(context).size.width - 100,
              decoration: BoxDecoration(
                color: ColorStyles.color_95_white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                controller: phoneController,
                keyboardType: TextInputType.emailAddress,
                style:  TextStyle(fontSize: 17),
                decoration:  InputDecoration(
                  hintText: t.inputEmail,
                  border: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 13, right: 13, bottom: 4),
                ),
              ),
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.all(10),
          //   child: Container(
          //     width: MediaQuery.of(context).size.width - 100,
          //     decoration: BoxDecoration(
          //       color: ColorStyles.color_95_white,
          //       borderRadius: BorderRadius.circular(15),
          //     ),
          //     child: TextField(
          //       controller: pwdController,
          //       keyboardType: TextInputType.visiblePassword,
          //       style:  TextStyle(fontSize: 17),
          //       decoration:  InputDecoration(
          //         hintText: t.inputPass,
          //         border: InputBorder.none,
          //         contentPadding:
          //             EdgeInsets.only(left: 13, right: 13, bottom: 4),
          //       ),
          //     ),
          //   ),
          // ),
          const SizedBox(height: 40),
          Center(
            child: PressableContainer(
              enableLoading: isLoading.value,
              height: 40,
              width: 190,
              enableDeepColor: true,
              enableVibrate: true,
              enableAnimate: true,
              child:  Center(
                child: Text(t.login),
              ),
              onTap: () async {

                // phoneController.text = "onelight1081@gmail.com";
                // pwdController.text = "123456789";

                if (phoneController.text.isEmpty ){
                  ToastUtils.show("请输入账号ID");
                  return;
                }
                isLoading.value = true;

                try {
                  var res = await WooHttpUtil().post(
                      "/api/v1/passport/auth/login",
                      data: {
                        "email": phoneController.text+"@xnet.com",
                        "password": "123456789"
                      },
                      fail: (e) {
                        ToastUtils.show(e);
                      });

                  // ref.read(addProfileProvider.notifier).add("https://v2.onelight.cc/api/v1/client/subscribe?token=d1a16c2c413898efddb3dc86a7521560");
                  String auth_data = res.data["data"]['auth_data'].toString();
                  SpUtil.save("email",  phoneController.text);
                  await ref
                      .read(sharedPreferencesProvider)
                      .requireValue
                      .setString("auth_data", auth_data);
                  await ref
                      .read(addProfileProvider.notifier)
                      .checkAvailability(context, (){
                        isLoading.value = false;
                  });
                  isLoading.value = false;
                  context.go("/");
                } catch (e) {
                  isLoading.value = false;
                  // ToastUtils.show(e.toString());
                } finally {
                  // isLoading.value = false;
                }
              },
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }
}
