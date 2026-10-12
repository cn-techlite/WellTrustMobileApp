import 'package:well_trust_mobile_app/features/account/data/model/assigned_client.dart';

class ClientState {
  final List<AssignedClient> assignedClients;

  const ClientState({this.assignedClients = const []});
}
