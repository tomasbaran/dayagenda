import 'package:equatable/equatable.dart';

class Owner extends Equatable {
  final String uid;
  final String? email;

  const Owner({
    required this.uid,
    this.email,
  });

  @override
  List<Object?> get props => [uid, email];

  @override
  bool get stringify => true;
}
