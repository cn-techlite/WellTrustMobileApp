class AssignedClient {
  final String id;
  final String name;
  final String preferred;
  final String address;
  final String phone;
  final List<String> alerts;
  final String nextVisit;
  final bool visitToday;

  const AssignedClient({
    required this.id,
    required this.name,
    required this.preferred,
    required this.address,
    required this.phone,
    required this.alerts,
    required this.nextVisit,
    this.visitToday = false,
  });

  factory AssignedClient.fromJson(Map<String, dynamic> json) {
    final risks = (json['keyRisks'] ?? '').toString().trim();
    final arrangements = (json['importantCareArrangements'] ?? '')
        .toString()
        .trim();
    return AssignedClient(
      id: (json['clientId'] ?? '').toString(),
      name: (json['clientName'] ?? '').toString(),
      preferred: ((json['preferredName'] ?? json['clientName']) ?? '')
          .toString(),
      address: [
        json['locationAddress'],
        json['locationPostcode'],
      ].where((value) => (value ?? '').toString().trim().isNotEmpty).join(', '),
      phone: (json['emergencyContact'] ?? '').toString(),
      alerts: [
        if (arrangements.isNotEmpty) arrangements,
        if (risks.isNotEmpty) risks,
      ],
      nextVisit: '',
    );
  }
}
