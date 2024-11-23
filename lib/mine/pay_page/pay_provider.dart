import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../all_res/api_request.dart';

// 定义新的状态类
class ItemListState {
  final List<PriceModel> items;
  final List<PayModel> payItems;
  final bool isLoadingBuy;

  ItemListState({ required this.items,this.isLoadingBuy = false,required this.payItems});
  // 添加 copyWith 方法
  ItemListState copyWith({
    List<PriceModel>? items,
    List<PayModel>? payItems,
    bool? isLoadingBuy,
  }) {
    return ItemListState(
      items: items ?? this.items,
      payItems: payItems ?? this.payItems,
      isLoadingBuy: isLoadingBuy ?? this.isLoadingBuy,
    );
  }
}

final itemListProvider = StateNotifierProvider<ItemListNotifier, ItemListState>((ref) => ItemListNotifier());

class ItemListNotifier extends StateNotifier<ItemListState> {


  ItemListNotifier() : super(ItemListState( items: [], payItems: []));
  String currentPeriod="";
  PriceModel currentPayItems=PriceModel(name: "", des: "", topDes: "", price: 0, isSelected: false, period: '');
  bool isLoadingBuy=false;



  Future<List<PriceModel>> fetchItems(WidgetRef ref) async {
    final List<PriceModel> items = await RequestAPi().fetchItemsOrder(ref);
    state = state.copyWith(items: items);
    toggleSelection(items.length-1);
    return items;
  }

  void toggleSelection(int index) {
    state = state.copyWith(
      items: [
        for (var i = 0; i < state.items.length; i++)
          state.items[i].copyWith(isSelected: i == index),
      ],
      isLoadingBuy: false

    );
    currentPeriod=state.items[index].period;
    currentPayItems=state.items[index];
  }

  void selectPay(int index) {
    state = state.copyWith(
      payItems: [
          for (var i = 0; i < state.payItems.length; i++)
            state.payItems[i].copyWith(isSelected: i == index),
        ],

    );
  }

  Future<void> checkOut(int method) async {
    state=state.copyWith(isLoadingBuy: true);
    final orderList = await RequestAPi().orderFetch();
    await Future.forEach(orderList, (e) async {
      if (e["status"] == 0) {
        await RequestAPi().orderCancel(e["trade_no"].toString());
      }
    });
    final String tradeNo = await RequestAPi().orderSave(currentPeriod);
    final String url=await RequestAPi().checkout(tradeNo,method);
    state=state.copyWith(isLoadingBuy: false);
    if(method==2){
      //发起http请求
      Dio dio = Dio();
      Response response = await dio.get(url);
      if(response.data["message"]=="success"){
        return;
      }
      return;
    }
    final Uri url0 = Uri.parse(url);
    if (!await launchUrl(url0)) {
      throw Exception('Could not launch $url0');
    }
  }

  List<PayModel> initPay(WidgetRef ref) {
    final List<PayModel> list=[PayModel(name: "Google Play", iconPath: "assets/images/google_play.svg"),PayModel(name: "AliPay/WeChat", iconPath: "assets/images/alipay.svg"),PayModel(name: "Paypal", iconPath: "assets/images/paypal.svg"),];
    state = state.copyWith(payItems: list);
    selectPay(0);
    return list;
  }

}


