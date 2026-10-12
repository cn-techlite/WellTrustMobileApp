import 'package:well_trust_mobile_app/features/account/data/model/assigned_client.dart';

abstract class ClientRepository {
  Future<List<AssignedClient>> getAssignedClients();
}
