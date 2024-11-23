import 'dart:convert';

import 'package:crisp_chat_sdk/crisp_chat_sdk.dart';
import 'package:dartx/dartx.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/home/widget/connection_button.dart';
import 'package:hiddify/features/home/widget/empty_profiles_home_body.dart';

import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/profile/widget/profile_tile.dart';
import 'package:hiddify/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:hiddify/features/proxy/active/active_proxy_footer.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../../../mine/all_res/AccountInfo.dart';
import '../../../mine/all_res/color_styles.dart';
import '../../../mine/all_res/local_storage.dart';
import '../../../mine/mine/AccountNotifier.dart';
import '../../../mine/pay_page/pay_page.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final hasAnyProfile = ref.watch(hasAnyProfileProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final leftTimeProfile = ref.watch(leftTimeProvider);
    String time = "";
    String timeNumber = "";
    if (leftTimeProfile.contains("天")) {
      time = t.days;
      //在 leftTimeProfile 去掉字符串 天
      timeNumber = leftTimeProfile.replaceAll("天", "");
    } else if (leftTimeProfile.contains("小时")) {
      time = t.hours;
      timeNumber = leftTimeProfile.replaceAll("小时", "");
    } else if (leftTimeProfile.contains("分钟")) {
      timeNumber = leftTimeProfile.replaceAll("分钟", "");
      time = t.minute;
    }
    time = t.remaining + " " + timeNumber + time;

    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          CustomScrollView(
            slivers: [
              NestedAppBar(
                title: Text.rich(
                  TextSpan(
                    children: [
                      // TextSpan(text: t.general.appTitle),
                      //插入图标assets/images/ic_black_launcher.webp
                      WidgetSpan(
                        child: Image.asset(
                          "assets/images/ic_black_launcher.webp",
                          width: 24,
                          height: 24,
                        ),
                        alignment: PlaceholderAlignment.middle,
                      ),
                      // const WidgetSpan(
                      //   child: Icon(FluentIcons.globe_24_filled),
                      //   alignment: PlaceholderAlignment.middle,
                      // ),
                      const WidgetSpan(
                        child: SizedBox(
                          width: 8,
                        ),
                      ),
                      const TextSpan(text: "XnetVPN"),
                      const TextSpan(text: " "),
                      // const WidgetSpan(
                      //   child: AppVersionLabel(),
                      //   alignment: PlaceholderAlignment.middle,
                      // ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                    onPressed: () => const QuickSettingsRoute().push(context),
                    icon: const Icon(FluentIcons.options_24_filled),
                    tooltip: t.config.quickSettings,
                  ),
                  // IconButton(
                  //   onPressed: () => const AddProfileRoute().push(context),
                  //   icon: const Icon(FluentIcons.add_circle_24_filled),
                  //   tooltip: t.profile.add.buttonText,
                  // ),
                ],
              ),
              switch (activeProfile) {
                AsyncData(value: final profile?) => MultiSliver(
                  children: [
                    ProfileTile(profile: profile, isMain: true),
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ConnectionButton(),
                                ActiveProxyDelayIndicator(),
                              ],
                            ),
                          ),
                          Row(
                            children: [
                              const SizedBox(
                                width: 5,
                              ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: ColorStyles.color_left_time,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          FluentIcons.timer_20_filled,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          time,
                                          style: const TextStyle(
                                              color: Colors.white,),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              // const Spacer(),
                              //紫色圆角Container
                              InkWell(
                                onTap: () {
                                  showModalBottomSheet(
                                    isScrollControlled: true,
                                    context: context,
                                    builder: (BuildContext context) {
                                      return Container(
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(20)),
                                          // 设置圆角
                                          color: ColorStyles.color_95_white,
                                        ),
                                        padding: const EdgeInsets.all(16),
                                        height: MediaQuery.of(context)
                                            .size
                                            .height -
                                            140,
                                        child: PayPage(),
                                      );
                                    },
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Container(
                                    padding: const EdgeInsets.all(8.0),
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: Colors.purple,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          FluentIcons.building_shop_20_filled,
                                          color: Colors.white,
                                        ),
                                        Text(
                                          t.renewal,
                                          style:
                                          const TextStyle(color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              )
                            ],
                          ),
                          if (MediaQuery.sizeOf(context).width < 840)
                            const ActiveProxyFooter(),
                        ],
                      ),
                    ),
                  ],
                ),
                AsyncData() => switch (hasAnyProfile) {
                  AsyncData(value: true) =>
                  const EmptyActiveProfileHomeBody(),
                  _ => const EmptyProfilesHomeBody(),
                },
                AsyncError(:final error) =>
                    SliverErrorBodyPlaceholder(t.presentShortError(error)),
                _ => const SliverToBoxAdapter(),
              },
            ],
          ),
          //右下角
          Positioned(
            bottom: 160,
            right: 20,
            child: FloatingActionButton.small(
              heroTag: 'chat',
              onPressed: () async {
                final String jsonStr = SpUtil.get("account_info").toString();
                String id = "";
                if (jsonStr.isNotEmpty) {
                  AccountInfo accountInfo;
                  accountInfo = AccountInfo.fromJson(
                      jsonDecode(jsonStr) as Map<String, dynamic>);
                  id = accountInfo.email;
                }
                try {
                  final sdk = CrispChatSdk();
                  await sdk.configure(
                      websiteId: "c0c85d43-3437-43dd-9fb5-5d54abc4ac2a");
                  await sdk.setUserEmail(email: id);
                  await sdk.setSessionString(key: "id", value: id);
                  await CrispChatSdk().openChat();
                } catch (e) {}
              },
              child: const Icon(FluentIcons.chat_16_filled),
            ),
          ),
        ],
      ),
    );
  }
}

class AppVersionLabel extends HookConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);

    final version = ref.watch(appInfoProvider).requireValue.presentVersion;
    if (version.isBlank) return const SizedBox();

    return Semantics(
      label: t.about.version,
      button: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 1,
        ),
        child: Text(
          version,
          textDirection: TextDirection.ltr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
