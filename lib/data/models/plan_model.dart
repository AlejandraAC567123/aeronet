class PlanModel {
  final String id;
  final String name;
  final int speedMbps;
  final double price;
  final String description;

  PlanModel({
    required this.id,
    required this.name,
    required this.speedMbps,
    required this.price,
    required this.description,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: '${json['id'] ?? ''}',
      name: '${json['name'] ?? ''}',
      speedMbps: int.tryParse('${json['speed_mbps'] ?? json['download_speed'] ?? json['speed_down'] ?? '0'}') ?? 0,
      price: double.tryParse('${json['price'] ?? '0.0'}') ?? 0.0,
      description: '${json['description'] ?? ''}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'speed_mbps': speedMbps,
      'price': price,
      'description': description,
    };
  }
}