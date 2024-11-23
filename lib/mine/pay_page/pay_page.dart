import 'package:animate_do/animate_do.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/mine/pay_page/pay_provider.dart';
import 'package:hiddify/mine/pay_page/select_pay_page.dart';
import 'package:path/path.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/localization/translations.dart';
import '../../utils/custom_loggers.dart';
import '../all_res/color_styles.dart';
import '../all_res/my_util.dart';
import '../all_res/pressable_container.dart';

// PayPage 组件
class PayPage extends HookConsumerWidget with PresLogger,WidgetsBindingObserver {

  @override
  Widget build(BuildContext context1, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    //界面重新返回时
    @override
    void initState() {
      // 添加观察者
      WidgetsBinding.instance.addObserver(this );
    }

    @override
    void dispose() {
      // 移除观察者
      WidgetsBinding.instance.removeObserver(this);
    }

    @override
    void didChangeAppLifecycleState(AppLifecycleState state) {
      if (state == AppLifecycleState.resumed) {
        //显示弹窗
        ToastUtils.show("name");

      }
    }

    useEffect(() {
      // 在构建时调用 fetchItems
      ref.read(itemListProvider.notifier).fetchItems(ref);

      return null;
    }, []);
    return Scaffold(
      backgroundColor: ColorStyles.color_95_white,
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              child: const Icon(FluentIcons.dismiss_24_filled),
              onTap: () {
                Navigator.pop(context1);
              },
            ),
            SizedBox(
              height: 150,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      BounceInDown(
                        from: 10,
                        child: SizedBox(
                          height: 70,
                          width: 70,
                          child: SvgPicture.asset(
                            "assets/images/black.svg",
                            height: 70,
                            width: 70,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Text("XnetVPN"),
                   Text(
                    t.openConnect,
                    style: const TextStyle(color: ColorStyles.color_deep_unselect_text),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ItemList(),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.zero,
                child: PressableContainer(
                  height: 40,
                  width: 160,
                  onTap: () async {
                    Navigator.of(context1).pop();
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context1,
                      builder: (BuildContext context) {
                        return Container(
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)), // 设置圆角
                            color: ColorStyles.color_95_white,
                          ),
                          padding: const EdgeInsets.all(16),
                          height: MediaQuery.of(context).size.height - 300,
                          child: SelectPayPage(),
                        );
                      },);
                    //跳转到SelectPayPage

                    return;


                   showDialog(
                     context: context1,
                     builder: (BuildContext context) {
                       return AlertDialog(
                         title:  Text(t.payOk),
                         content:  Text(t.payOkTips),
                         actions: [
                           TextButton(
                             child:  Text(t.noSuccess),
                             onPressed: () {
                               Navigator.of(context).pop();
                             },
                           ),
                           TextButton(
                             child:  Text(t.paySuccess),
                             onPressed: () {
                               //清空所有界面
                               Navigator.of(context).pop();
                               Navigator.of(context1).pop();
                               context.go("/");
                             },
                           ),
                         ],
                       );
                     },
                   );

                  },
                  enableLoading: ref.watch(itemListProvider).isLoadingBuy,
                  enableDeepColor: true,
                  enableVibrate: true,
                  enableAnimate: true,
                  child:  Center(
                    child: Text(t.pay),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ItemList 组件
class ItemList extends ConsumerWidget {

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemListProvider).items;
    return items.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.separated(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return PressableContainer(
          enableAnimate: false,
          enableShape: false,
          onTap: () {
          },
          selected: item.isSelected,
          child: Stack(
            children: [
              InkWell(
                onTap: (){
                  ref.read(itemListProvider.notifier).toggleSelection(index);
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 5),
                              if (index!=0) Container(
                                height: 19,
                                width: 45,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.green,
                                ),
                                child: Center(
                                  child: Text(
                                    item.topDes,
                                    style: const TextStyle(color: ColorStyles.color_100_white),
                                  ),
                                ),
                              ) else const SizedBox(),
                            ],
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.des,
                            style: const TextStyle(
                              fontSize: 13,
                              color: ColorStyles.color_deep_unselect_text,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(item.price.toString()),
                      const SizedBox(width: 8),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index) {
        return const SizedBox(height: 8);
      },
    );
  }
}
