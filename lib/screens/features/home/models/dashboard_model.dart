class DashboardModel {
  final int totalItems;
  final double totalValue;
  final double monthlyChange;

  DashboardModel({
    required this.totalItems,
    required this.totalValue,
    required this.monthlyChange,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalItems: json['totalItems'] != null
          ? int.tryParse(json['totalItems'].toString()) ?? 0
          : 0,
      totalValue: json['totalValue'] != null
          ? double.tryParse(json['totalValue'].toString()) ?? 0.0
          : 0.0,
      monthlyChange: json['monthlyChange'] != null
          ? double.tryParse(json['monthlyChange'].toString()) ?? 0.0
          : 0.0,
    );
  }
}
