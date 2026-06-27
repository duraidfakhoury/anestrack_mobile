class Hospital {
  final String objectId;
  final String name;
  final String? address;
  final String? contactInfo;
  final bool isActive;

  Hospital({
    required this.objectId,
    required this.name,
    this.address,
    this.contactInfo,
    required this.isActive,
  });
}
