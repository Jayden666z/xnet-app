import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../core/localization/translations.dart';

import '../pay_page/PayModel.dart';
import 'VersionCheck.dart';
import 'http.dart';
import 'my_util.dart';

class RequestAPi {
  Future<VersionCheck> getVersion() async {
    final res = await WooHttpUtil().get("/api/v2/version/check", fail: (e) {
      return "";
    });
    final VersionCheck versionCheck =
        VersionCheck.fromJson(res.data["data"] as Map<String, dynamic>);
    return versionCheck;
  }

  Future<String> checkout(String trade_no,int method) async {
    final res = await WooHttpUtil().post("/api/v1/user/order/checkout",
        data: {"trade_no": trade_no, "method": method}, fail: (e) {
      return "";
    });
    return res.data["data"].toString();
  }

  Future<String> orderSave(String period) async {
    final res = await WooHttpUtil().post("/api/v1/user/order/save",
        data: {"plan_id": 2, "period": period}, fail: (e) {
      return "";
    });
    return res.data["data"].toString();
  }

  Future<String> orderCancel(String trade_no) async {
    final res = await WooHttpUtil().post("/api/v1/user/order/cancel",
        data: {"trade_no": trade_no}, fail: (e) {
      return "";
    });
    return "success";
  }

  Future<List> orderFetch() async {
    final res = await WooHttpUtil().get(
      "/api/v1/user/order/fetch",
      fail: (e) {
        return "";
      },
    );
    return res.data["data"] as List;
  }

  Future<List<PriceModel>> fetchItemsOrder(WidgetRef ref) async {
    final List<PriceModel> list = [];
    final res = await WooHttpUtil().get("/api/v1/user/plan/fetch", fail: (e) {
      // ToastUtils.show("网络异常");
      return false;
    });

    final List<dynamic> listPlant = res.data["data"];

    List<Plan> products = Plan.fromJsonList(listPlant);

    // listPlant.map((ele)=>Plan.fromJson)

    final Plan plan = products[0];
    double monthPriceEveryDay =
        double.parse((plan.monthPrice! / 3000.0).toStringAsFixed(1));
    double quarterPriceEveryDay =
        double.parse((plan.quarterPrice! / 9000.0).toStringAsFixed(1));
    double halfYearPriceEveryDay =
        double.parse((plan.halfYearPrice! / 18000.0).toStringAsFixed(1));
    double yearPriceEveryDay =
        double.parse((plan.yearPrice! / 36500.0).toStringAsFixed(1));

    int monthPrice = plan.monthPrice! ~/ 100;
    double quarterPriceDiscount =
        (monthPrice * 3 - (plan.quarterPrice! ~/ 100)) /
            (plan.quarterPrice! ~/ 100);
    quarterPriceDiscount =
        double.parse((quarterPriceDiscount * 100).toStringAsFixed(0));

    double halfYearPriceDiscount =
        (monthPrice * 6 - (plan.halfYearPrice! ~/ 100)) /
            (plan.halfYearPrice! ~/ 100);
    halfYearPriceDiscount =
        double.parse((halfYearPriceDiscount * 100).toStringAsFixed(0));

    double yearPriceDiscount =
        (monthPrice * 12 - (plan.yearPrice! ~/ 100)) / (plan.yearPrice! ~/ 100);
    yearPriceDiscount =
        double.parse((yearPriceDiscount * 100).toStringAsFixed(0));

    final t = ref.watch(translationsProvider);

    list.add(PriceModel(
        name: t.MonthlyPay,
        des: "$monthPriceEveryDay" + t.day,
        price: plan.monthPrice! ~/ 100,
        topDes: "",
        period: "month_price"));
    list.add(PriceModel(
        name: t.QuarterlyPay,
        des: "$quarterPriceEveryDay" + t.day,
        price: plan.quarterPrice! ~/ 100,
        topDes: "-${quarterPriceDiscount.toInt()}%",
        period: "quarter_price"));
    list.add(PriceModel(
        name: t.Half_year,
        des: "$halfYearPriceEveryDay" + t.day,
        price: plan.halfYearPrice! ~/ 100,
        topDes: "-${halfYearPriceDiscount.toInt()}%",
        period: "half_year_price"));
    list.add(PriceModel(
        name: t.Annual,
        des: "$yearPriceEveryDay" + t.day,
        price: plan.yearPrice! ~/ 100,
        topDes: "-${yearPriceDiscount.toInt()}%",
        period: "year_price"));

    return list;
  }
}

class PayModel {
  String name;
  String iconPath;
  bool isSelected;

  PayModel({
    required this.name,
    required this.iconPath,
    this.isSelected = false,  });

  PayModel copyWith({bool? isSelected}) {
    return PayModel(name: name, iconPath: iconPath,       isSelected: isSelected ?? this.isSelected,
    );
  }
}

class PriceModel {
  String name;
  String des;
  String topDes;
  String period;
  int price;
  bool isSelected;

  PriceModel({
    required this.name,
    required this.des,
    required this.topDes,
    required this.price,
    required this.period,
    this.isSelected = false,
  });

  PriceModel copyWith({bool? isSelected}) {
    return PriceModel(
      name: name,
      price: price,
      isSelected: isSelected ?? this.isSelected,
      des: des,
      topDes: topDes,
      period: period,
    );
  }
}
