class Building {
  // int? id;
  String? building_number;
  String? name;
  String? donor;
  int? id_en;
  Building({this.building_number, this.name, this.donor, this.id_en});
  Building.fromJson(Map<String, dynamic> json) {
    building_number = json['number'];
    name = json['name'];
    donor = json['donor'];
    id_en = json['id_en'];
  }
}
