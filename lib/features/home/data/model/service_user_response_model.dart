class ServiceUser {
  final String id;
  final String initials;
  final String name;
  final int age;
  final String address;
  final String keySafe;
  final String weeklyHours;
  final List<Flag> flags;
  final String summary;
  final String nok;
  final String gp;

  const ServiceUser({
    required this.id,
    required this.initials,
    required this.name,
    required this.age,
    required this.address,
    required this.keySafe,
    required this.weeklyHours,
    required this.flags,
    required this.summary,
    required this.nok,
    required this.gp,
  });

  String get addressShort => address.split(',').first;
}

class Flag {
  final String type; // falls | allergy | dementia | dnar | ...
  final String label;
  const Flag(this.type, this.label);
}
