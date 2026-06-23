class PlanModel {
  final String id;
  final String name;
  final int downloadSpeed;
  final int uploadSpeed;
  final double price;
  final String description;

  PlanModel({
    required this.id,
    required this.name,
    required this.downloadSpeed,
    required this.uploadSpeed,
    required this.price,
    required this.description,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      downloadSpeed: int.tryParse('${json['download_speed'] ?? json['speed_down'] ?? '0'}') ?? 0,
      uploadSpeed: int.tryParse('${json['upload_speed'] ?? json['speed_up'] ?? '0'}') ?? 0,
      price: double.tryParse('${json['price'] ?? '0.0'}') ?? 0.0,
      description: '${json['description'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'download_speed': downloadSpeed,
      'upload_speed': uploadSpeed,
      'price': price,
      'description': description,
    };
  }
}
