class UserProfile {
  final String id;
  final String? name;
  final String? language;
  final String? homeType;
  final List<String> highEnergyDevices;

  UserProfile({
    required this.id,
    this.name,
    this.language,
    this.homeType,
    this.highEnergyDevices = const [],
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    List<String> parseDevices(dynamic value) {
      if (value == null) return [];
      if (value is List) return value.map((e) => e.toString()).toList();
      if (value is String) {
        try {
          // Remove the quotes and brackets, then split by comma
          String cleaned = value
              .replaceAll('"', '')
              .replaceAll('[', '')
              .replaceAll(']', '');
          if (cleaned.isEmpty) return [];
          return cleaned.split(',').map((e) => e.trim()).toList();
        } catch (e) {
          return [];
        }
      }
      return [];
    }

    return UserProfile(
      id: json['auth_user_id'] as String,
      name: json['name'] as String?,
      language: json['language'] as String?,
      homeType: json['home_type'] as String?,
      highEnergyDevices: parseDevices(json['high_energy_devices']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'auth_user_id': id,
      'name': name,
      'language': language,
      'home_type': homeType,
      'high_energy_devices': highEnergyDevices,
    };
  }

  UserProfile copyWith({
    String? name,
    String? language,
    String? homeType,
    List<String>? highEnergyDevices,
  }) {
    return UserProfile(
      id: this.id,
      name: name ?? this.name,
      language: language ?? this.language,
      homeType: homeType ?? this.homeType,
      highEnergyDevices: highEnergyDevices ?? this.highEnergyDevices,
    );
  }
}
