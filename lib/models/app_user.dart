class AppUser {
  const AppUser({required this.id, required this.name, required this.email});

  final int id;
  final String name;
  final String email;

  String get firstName => name.split(' ').first;

  factory AppUser.fromRow(Map<String, Object?> row) {
    return AppUser(
      id: row['id']! as int,
      name: row['name']! as String,
      email: row['email']! as String,
    );
  }
}
