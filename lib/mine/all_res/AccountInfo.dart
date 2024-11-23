class AccountInfo {
  AccountInfo({
    required this.planId,
    required this.token,
    required this.expiredAt,
    required this.u,
    required this.d,
    required this.transferEnable,
    required this.email,
    required this.uuid,
    required this.plan,
    required this.subscribeUrl,
  });
  late final int planId;
  late final String token;
  late final int expiredAt;
  late final int u;
  late final int d;
  late final int transferEnable;
  late final String email;
  late final String uuid;
  late final Plan plan;
  late final String subscribeUrl;

  AccountInfo.fromJson(Map<String, dynamic> json)
      : planId = (json['plan_id'] ?? 0) as int,
        token = json['token'] as String,
        expiredAt = json['expired_at'] as int, // 添加类型转换
        u = json['u'] as int, // 添加类型转换
        d = json['d'] as int, // 添加类型转换
        transferEnable = json['transfer_enable'] as int, // 添加类型转换
        email = json['email'] as String,
        uuid = json['uuid'] as String,
        plan = Plan.fromJson(json['plan'] as Map<String, dynamic>),
        subscribeUrl = json['subscribe_url'] as String; // 添加类型转换

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['plan_id'] = planId;
    _data['token'] = token;
    _data['expired_at'] = expiredAt;
    _data['u'] = u;
    _data['d'] = d;
    _data['transfer_enable'] = transferEnable;
    _data['email'] = email;
    _data['uuid'] = uuid;
    _data['plan'] = plan.toJson();
    _data['subscribe_url'] = subscribeUrl;
    return _data;
  }
}

class Plan {
  Plan({
    required this.id,
    required this.groupId,
    required this.transferEnable,
    required this.name,
    required this.show,
    required this.renew,
    required this.createdAt,
    required this.updatedAt,
  });
  late final int id;
  late final int groupId;
  late final int transferEnable;
  late final String name;
  late final int show;
  late final int renew;
  late final int createdAt;
  late final int updatedAt;

  Plan.fromJson(Map<String, dynamic> json)
      : id = json['id'] as int,
        groupId = json['group_id'] as int,
        transferEnable = json['transfer_enable'] as int,
        name = json['name'] as String,
        show = json['show'] as int,
        renew = json['renew'] as int,
        createdAt = json['created_at'] as int,
        updatedAt = json['updated_at'] as int;

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['id'] = id;
    _data['group_id'] = groupId;
    _data['transfer_enable'] = transferEnable;
    _data['name'] = name;
    _data['show'] = show;
    _data['renew'] = renew;
    _data['created_at'] = createdAt;
    _data['updated_at'] = updatedAt;
    return _data;
  }
}
