import 'package:dayagenda/features/group/domain/entities/owner.dart';
import 'package:dayagenda/features/group/domain/usecases/add_owner_to_db.dart';

class NavBarManager {
  final AddOwnerToDbUsecase addOwnerToDb;
  NavBarManager({required this.addOwnerToDb});

  Future addOwnerToDbCall(String email, String uid) async {
    Owner owner = Owner(uid: uid, email: email);
    return await addOwnerToDb(owner);
  }
}
