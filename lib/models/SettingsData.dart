class SettingsData {
  bool? showEPG;
  bool? openFullScreen;
  bool? showRecentsWhatshing;
  bool? openOldPeople;
  String? typelist;

  SettingsData(
      {this.showEPG,
      this.openFullScreen,
      this.showRecentsWhatshing,
      this.openOldPeople,
      this.typelist});

  SettingsData.fromJson(Map<String, dynamic> json) {
    showEPG = json['showEPG'];
    openFullScreen = json['openFullScreen'];
    showRecentsWhatshing = json['showRecentsWhatshing'];
    openOldPeople = json['openOldPeople'];
    typelist = json['typelist'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['showEPG'] = this.showEPG;
    data['openFullScreen'] = this.openFullScreen;
    data['showRecentsWhatshing'] = this.showRecentsWhatshing;
    data['openOldPeople'] = this.openOldPeople;
    data['typelist'] = this.typelist;
    return data;
  }
}
