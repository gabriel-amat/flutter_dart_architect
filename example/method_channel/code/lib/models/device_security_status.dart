class DeviceSecurityStatus {
  final bool isCompromised; // Rooted or Jailbroken
  final String osVersion;
  final String securityPatchLevel;
  final bool hasSecureHardware;

  const DeviceSecurityStatus({
    required this.isCompromised,
    required this.osVersion,
    required this.securityPatchLevel,
    required this.hasSecureHardware,
  });

  factory DeviceSecurityStatus.fromMap(Map<dynamic, dynamic> map) {
    return DeviceSecurityStatus(
      isCompromised: map['isCompromised'] as bool? ?? false,
      osVersion: map['osVersion'] as String? ?? 'Unknown',
      securityPatchLevel: map['securityPatchLevel'] as String? ?? 'Unknown',
      hasSecureHardware: map['hasSecureHardware'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'isCompromised': isCompromised,
    'osVersion': osVersion,
    'securityPatchLevel': securityPatchLevel,
    'hasSecureHardware': hasSecureHardware,
  };
}
