import 'dart:async';

import 'package:well_trust_mobile_app/features/clients/data/model/assigned_client.dart';
import 'package:well_trust_mobile_app/features/clients/domain/controller/client_controller.dart';
import 'package:well_trust_mobile_app/features/clients/presentation/state/state_model/client_state.dart';
import 'package:well_trust_mobile_app/features/meetings/data/model/meeting_model.dart';
import 'package:well_trust_mobile_app/features/meetings/domain/controller/meeting_controller.dart';
import 'package:well_trust_mobile_app/features/meetings/presentation/state/state_model/meeting_state.dart';
import 'package:well_trust_mobile_app/features/messages/data/model/message_thread.dart';
import 'package:well_trust_mobile_app/features/messages/domain/controller/message_controller.dart';
import 'package:well_trust_mobile_app/features/messages/presentation/state/state_model/message_state.dart';
import 'package:well_trust_mobile_app/features/notes/data/model/care_note_entry.dart';
import 'package:well_trust_mobile_app/features/notes/domain/controller/care_note_controller.dart';
import 'package:well_trust_mobile_app/features/notes/presentation/state/state_model/care_note_state.dart';

const fixtureClients = <AssignedClient>[
  AssignedClient(
    id: 'U1',
    name: 'Mr Harold Fisher',
    preferred: 'Harold',
    address: '14 Rowan Close',
    phone: '07000000001',
    alerts: [],
    nextVisit: '',
  ),
  AssignedClient(
    id: 'U2',
    name: 'Mrs Margaret Hensley',
    preferred: 'Margaret',
    address: '3 Elm Court',
    phone: '07000000002',
    alerts: [],
    nextVisit: '',
  ),
  AssignedClient(
    id: 'U3',
    name: 'Mrs Dorothy Bell',
    preferred: 'Dorothy',
    address: '22 Meadow Lane',
    phone: '07000000003',
    alerts: [],
    nextVisit: '',
  ),
];

class FixtureAssignedClientsController extends ClientController {
  @override
  FutureOr<ClientState> build() =>
      const ClientState(assignedClients: fixtureClients);
}

class EmptyAssignedClientsController extends ClientController {
  @override
  FutureOr<ClientState> build() => const ClientState();
}

class FixtureMeetingsController extends MeetingController {
  @override
  FutureOr<MeetingState> build() {
    final now = DateTime.now();
    return MeetingState(
      meetings: [
        TeamMeeting(
          id: 'meeting-1',
          title: 'Monthly team meeting (last month)',
          start: DateTime(now.year, now.month, now.day - 9, 10),
          minutes: 60,
          host: 'Registered Manager',
          location: 'Main office',
          agenda: const ['Quality updates'],
          savedMinutes: const MeetingMinutes(
            summary: 'Previous actions were reviewed.',
            decisions: ['Continue the weekly audit.'],
            actions: [
              MeetingAction(action: 'Prepare audit sheet', owner: 'Care team'),
            ],
          ),
        ),
      ],
    );
  }
}

class FixtureMessageController extends MessageController {
  @override
  MessageState build() {
    final now = DateTime.now();
    return MessageState(
      threads: [
        MessageThread(
          id: 'N1',
          party: 'Management',
          subject: 'Your rota for next week',
          unread: true,
          entries: [
            MessageEntry(
              id: 'message-1',
              body:
                  'Next week\'s rota is now live. Please check your visits and acknowledge any changes.',
              at: now,
              mine: false,
            ),
          ],
        ),
        MessageThread(
          id: 'N2',
          party: 'Admin',
          subject: 'Medication Training certificate',
          unread: true,
          entries: [
            MessageEntry(
              id: 'message-2',
              body: 'Please upload the current certificate.',
              at: now.subtract(const Duration(days: 1)),
              mine: false,
            ),
          ],
        ),
        MessageThread(
          id: 'N3',
          party: 'Office',
          subject: 'Key safe reminder',
          unread: true,
          entries: [
            MessageEntry(
              id: 'message-3',
              body: 'Remember to scramble the key safe.',
              at: now.subtract(const Duration(days: 2)),
              mine: false,
            ),
          ],
        ),
      ],
    );
  }
}

class FixtureCareNotesNotifier extends CareNoteController {
  final List<CareNoteEntry> initial;

  FixtureCareNotesNotifier([this.initial = const []]);

  @override
  CareNoteState build() => CareNoteState(notes: initial);

  @override
  Future<CareNoteEntry> add(CareNoteEntry note) async {
    state = CareNoteState(notes: [note, ...state.notes]);
    return note;
  }
}
