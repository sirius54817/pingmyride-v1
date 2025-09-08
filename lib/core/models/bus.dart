class Bus {
  final String id;
  final String busNumber;
  final String driverName;
  final String driverPhone;
  final String driverEmail;
  final int capacity;
  final String routeId;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Bus({
    required this.id,
    required this.busNumber,
    required this.driverName,
    required this.driverPhone,
    required this.driverEmail,
    required this.capacity,
    required this.routeId,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory Bus.fromMap(Map<String, dynamic> map, String id) {
    return Bus(
      id: id,
      busNumber: map['busNumber'] ?? '',
      driverName: map['driverName'] ?? '',
      driverPhone: map['driverPhone'] ?? '',
      driverEmail: map['driverEmail'] ?? '',
      capacity: map['capacity'] ?? 0,
      routeId: map['routeId'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'busNumber': busNumber,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'driverEmail': driverEmail,
      'capacity': capacity,
      'routeId': routeId,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  Bus copyWith({
    String? id,
    String? busNumber,
    String? driverName,
    String? driverPhone,
    String? driverEmail,
    int? capacity,
    String? routeId,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Bus(
      id: id ?? this.id,
      busNumber: busNumber ?? this.busNumber,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      driverEmail: driverEmail ?? this.driverEmail,
      capacity: capacity ?? this.capacity,
      routeId: routeId ?? this.routeId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}