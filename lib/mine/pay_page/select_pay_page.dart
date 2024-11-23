import 'dart:convert';
import 'dart:developer';

import 'package:animate_do/animate_do.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/mine/pay_page/pay_provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../core/localization/translations.dart';
import '../../utils/custom_loggers.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';

import '../all_res/api_request.dart';
import '../all_res/color_styles.dart';
import '../all_res/my_util.dart';
import '../all_res/pressable_container.dart';

// PayPage 组件
class SelectPayPage extends HookConsumerWidget with PresLogger {
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  late InAppPurchase _inAppPurchase;
  List<ProductDetails>? _products; //内购的商品对象集合

  @override
  Widget build(BuildContext context1, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    /// 购买失败
    void _handleError(IAPError? iapError) {
      ToastUtils.show("购买失败啦：${iapError?.code} message${iapError?.message}");
    }

    /// 等待支付
    void _handlePending() {
      ToastUtils.show("等待支付的逻辑");
    }

    /// Android支付成功的校验
    void loadAndroidGetPayInfo(GooglePlayPurchaseDetails googleDetail) async {
      final originalJson = googleDetail.billingClientPurchase.originalJson;
      if (jsonDecode(originalJson)["orderId"] != "") {
        ToastUtils.show("Pay Success");
        await ref.read(itemListProvider.notifier).checkOut(2);
        showDialog(
          context: context1,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(t.payOk),
              content: Text(t.payOkTips),
              actions: [
                TextButton(
                  child: Text(t.noSuccess),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text(t.paySuccess),
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
      }
    }

    /// Apple支付成功的校验
    void loadAppleGetPayInfo(AppStorePurchaseDetails appstoreDetail) {}

    /// 内购的购买更新监听
    void _listenToPurchaseUpdated(
        List<PurchaseDetails> purchaseDetailsList) async {
      for (PurchaseDetails purchase in purchaseDetailsList) {
        if (purchase.status == PurchaseStatus.pending) {
          // 等待支付完成
          _handlePending();
        } else if (purchase.status == PurchaseStatus.error) {
          // 购买失败
          _handleError(purchase.error);
        } else if (purchase.status == PurchaseStatus.purchased ||
            purchase.status == PurchaseStatus.restored) {
          //完成购买, 到服务器验证
          if (Platform.isAndroid) {
            var googleDetail = purchase as GooglePlayPurchaseDetails;
            print(purchase);
            loadAndroidGetPayInfo(googleDetail);
          } else if (Platform.isIOS) {
            var appstoreDetail = purchase as AppStorePurchaseDetails;
            print(purchase);
            loadAppleGetPayInfo(appstoreDetail);
          }
        }
      }
    }

    useEffect(() {
      // 在构建时调用 fetchItems
      Future.microtask(() {
        ref.read(itemListProvider.notifier).initPay(ref);
        // 初始化in_app_purchase插件
        _inAppPurchase = InAppPurchase.instance;

        //监听购买的事件
        final Stream<List<PurchaseDetails>> purchaseUpdated =
            _inAppPurchase.purchaseStream;
        _subscription = purchaseUpdated.listen((purchaseDetailsList) {
          _listenToPurchaseUpdated(purchaseDetailsList);
        }, onDone: () {
          _subscription.cancel();
        }, onError: (error) {
          error.printError();
          ToastUtils.show("购买失败了");
        });
      });
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
            const SizedBox(
              height: 80,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Pay Now",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    )
                  ],
                ),
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
                  width: 300,
                  onTap: () async {
                    for (var value in ref.watch(itemListProvider).payItems) {
                      if (value.isSelected) {
                        if (value.iconPath.contains("alipay")) {
                          await ref.read(itemListProvider.notifier).checkOut(1);
                          showDialog(
                            context: context1,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text(t.payOk),
                                content: Text(t.payOkTips),
                                actions: [
                                  TextButton(
                                    child: Text(t.noSuccess),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text(t.paySuccess),
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
                        }else if(value.iconPath.contains("paypal")){

                          final PriceModel priceModel =
                              ref.read(itemListProvider.notifier).currentPayItems;
                          Navigator.of(ref.context).push(MaterialPageRoute(
                            builder: (BuildContext context) => PaypalCheckoutView(
                              sandboxMode: false,
                              clientId: "AVdl0kT914cLSGmsjbFYu_hvmnU4KWXgK6HwM5_lalCJgwyfcBaV1tqRXYWyQaXTZzcC12qTpOUMd7Tq",
                              secretKey: "ENI8GDYJ9Hs1k2dJiMiXc_IdvWpBCVphZl7a_yqX8bLs3T-53cHpdC5YqEq5XOBTSgOKOZV5A9P54mD7",
                              transactions:  [
                                {
                                  "amount": {
                                    "total": priceModel.price,
                                    "currency": "USD",
                                    "details": {
                                      "subtotal": priceModel.price,
                                      "shipping": '0',
                                      "shipping_discount": 0
                                    }
                                  },
                                  "description": "XnetVPN",
                                  // "payment_options": {
                                  //   "allowed_payment_method":
                                  //       "INSTANT_FUNDING_SOURCE"
                                  // },
                                  "item_list": {
                                    "items": [
                                      {
                                        "name": priceModel.period,
                                        "quantity": 1,
                                        "price": priceModel.price,
                                        "currency": "USD"
                                      },
                                    ],

                                    // Optional
                                    //   "shipping_address": {
                                    //     "recipient_name": "Tharwat samy",
                                    //     "line1": "tharwat",
                                    //     "line2": "",
                                    //     "city": "tharwat",
                                    //     "country_code": "EG",
                                    //     "postal_code": "25025",
                                    //     "phone": "+00000000",
                                    //     "state": "ALex"
                                    //  },
                                  }
                                }
                              ],
                              note: "Contact us for any questions on your order.",
                              onSuccess: (Map params) async {
                                ToastUtils.show("Pay Success");
                                Navigator.of(context).pop();
                                await ref.read(itemListProvider.notifier).checkOut(2);
                                showDialog(
                                  context: context1,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(t.payOk),
                                      content: Text(t.payOkTips),
                                      actions: [
                                        TextButton(
                                          child: Text(t.noSuccess),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        TextButton(
                                          child: Text(t.paySuccess),
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
                              onError: (error) {
                                log("onError: $error");
                                Navigator.pop(context);
                              },
                              onCancel: () {
                                print('cancelled:');
                                Navigator.pop(context);
                              },
                            ),
                          ));


                        }


                        else {
                          String currentPeriod =
                              ref.read(itemListProvider.notifier).currentPeriod;
                          print(currentPeriod);
                          Set<String> _kIds = <String>{currentPeriod};
                          final ProductDetailsResponse response =
                              await InAppPurchase.instance
                                  .queryProductDetails(_kIds);
                          if (response.notFoundIDs.isNotEmpty) {
                            // Handle the error.
                          }
                          List<ProductDetails> products =
                              response.productDetails;
                          final ProductDetails productDetails = products[0];
                          final PurchaseParam purchaseParam =
                              PurchaseParam(productDetails: productDetails);
                          InAppPurchase.instance
                              .buyConsumable(purchaseParam: purchaseParam);
                        }
                      }
                    }
                  },
                  enableLoading: ref.watch(itemListProvider).isLoadingBuy,
                  enableDeepColor: true,
                  enableVibrate: true,
                  enableAnimate: true,
                  child: Center(
                    child: Text("Pay"),
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
    final items = ref.watch(itemListProvider).payItems;
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
                  ref.read(itemListProvider.notifier).selectPay(index);
                },
                selected: item.isSelected,
                child: Stack(
                  children: [
                    InkWell(
                      onTap: () {
                        ref.read(itemListProvider.notifier).selectPay(index);
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
                                    SvgPicture.asset(
                                      item.iconPath,
                                      width: 30,
                                      height: 30,
                                    ),
                                    const SizedBox(
                                      width: 6,
                                    ),
                                    Text(
                                      item.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                                const SizedBox(height: 3),
                              ],
                            ),
                            const Spacer(),
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
