class VersionCheck {
  VersionCheck({
    required this.force,
    required this.url,
    required this.version,
  });
  late final bool force;
  late final String url;
  late final String version;

  VersionCheck.fromJson(Map<String, dynamic> json){
    force = json['force'];
    url = json['url'];
    version = json['version'];
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['force'] = force;
    _data['url'] = url;
    _data['version'] = version;
    return _data;
  }
}