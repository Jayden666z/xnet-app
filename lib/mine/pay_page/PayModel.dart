class PayModel {
  int? planId;
  int? paymentId;
  int? type;
  String? period;
  String? tradeNo;
  int? totalAmount;
  int? status;
  int? commissionStatus;
  int? commissionBalance;
  int? createdAt;
  int? updatedAt;
  Plan? plan;

  PayModel(
      {this.planId,
        this.paymentId,
        this.type,
        this.period,
        this.tradeNo,
        this.totalAmount,
        this.status,
        this.commissionStatus,
        this.commissionBalance,
        this.createdAt,
        this.updatedAt,
        this.plan});

  PayModel.fromJson(Map<String, dynamic> json) {
    planId = json['plan_id'] as int;
    paymentId = json['payment_id']??0 as int;
    type = json['type']as int;
    period = json['period'] as String;
    tradeNo = json['trade_no'] as String;
    totalAmount = json['total_amount'];
    status = json['status'];
    commissionStatus = json['commission_status'];
    commissionBalance = json['commission_balance'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
    plan = json['plan'] != null ? new Plan.fromJson(json['plan'] as Map<String, dynamic>) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['plan_id'] = this.planId;
    data['payment_id'] = this.paymentId;
    data['type'] = this.type;
    data['period'] = this.period;
    data['trade_no'] = this.tradeNo;
    data['total_amount'] = this.totalAmount;
    data['status'] = this.status;
    data['commission_status'] = this.commissionStatus;
    data['commission_balance'] = this.commissionBalance;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    if (this.plan != null) {
      data['plan'] = this.plan!.toJson();
    }
    return data;
  }
}

class Plan {
  int? id;
  int? groupId;
  int? transferEnable;
  String? name;
  int? show;
  int? renew;
  int? monthPrice;
  int? quarterPrice;
  int? halfYearPrice;
  int? yearPrice;
  int? createdAt;
  int? updatedAt;

  Plan(
      {this.id,
        this.groupId,
        this.transferEnable,
        this.name,
        this.show,
        this.renew,
        this.monthPrice,
        this.quarterPrice,
        this.halfYearPrice,
        this.yearPrice,
        this.createdAt,
        this.updatedAt});

  Plan.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    groupId = json['group_id'];
    transferEnable = json['transfer_enable'];
    name = json['name'];
    show = json['show'];
    renew = json['renew'];
    monthPrice = json['month_price'];
    quarterPrice = json['quarter_price'];
    halfYearPrice = json['half_year_price'];
    yearPrice = json['year_price'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }

  static List<Plan> fromJsonList(List<dynamic> jsonList) {
    List<Plan> plans = [];
    for (var item in jsonList) {
      plans.add(Plan.fromJson(item as Map<String, dynamic>));
    }
    return plans;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['group_id'] = this.groupId;
    data['transfer_enable'] = this.transferEnable;
    data['name'] = this.name;
    data['show'] = this.show;
    data['renew'] = this.renew;
    data['month_price'] = this.monthPrice;
    data['quarter_price'] = this.quarterPrice;
    data['half_year_price'] = this.halfYearPrice;
    data['year_price'] = this.yearPrice;
    data['created_at'] = this.createdAt;
    data['updated_at'] = this.updatedAt;
    return data;
  }
}
