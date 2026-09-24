import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:well_trust_mobile_app/core/helpers/globals.dart';
import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/features/account/domain/usercases/account_repository.dart';
import 'package:well_trust_mobile_app/features/account/presentation/state/provider/account_provider.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

class _FakeAccountRepository implements AccountRepository {
  RegisterResponseModel user = RegisterResponseModel(
    id: 'staff-1',
    firstName: 'Jane',
    surName: 'Doe',
  );
  GeneralResultModel saveResult = GeneralResultModel.success(message: 'Saved');
  final calls = <String>[];
  String? lastAdminStaffId;

  @override
  Future<RegisterResponseModel> getUserData() async {
    calls.add('get');
    return user;
  }

  @override
  Future<GeneralResultModel> updateProfile(UpdateStaffRequest request) async {
    calls.add('updateProfile');
    return saveResult;
  }

  @override
  Future<GeneralResultModel> saveStaffRecord(
    StaffRecordRequest request, {
    required String adminStaffId,
  }) async {
    calls.add('save:${request.kind.segment}');
    lastAdminStaffId = adminStaffId;
    return saveResult;
  }

  List<StaffReference> references = [
    StaffReference(id: 'r1', refereeName: 'Sarah'),
  ];
  Object? supervisionsError;

  @override
  Future<GeneralResultModel> updateStaffRecord(
    String id,
    StaffRecordRequest request,
  ) async {
    calls.add('update:${request.kind.segment}');
    return saveResult;
  }

  @override
  Future<GeneralResultModel> sendReferenceRequest(String id) async {
    calls.add('sendRequest:$id');
    return saveResult;
  }

  @override
  Future<List<StaffReference>> getReferences(String staffId) async {
    calls.add('getReferences');
    return references;
  }

  @override
  Future<List<StaffSupervision>> getSupervisions(String staffId) async {
    if (supervisionsError != null) throw supervisionsError!;
    return [StaffSupervision(id: 's1')];
  }

  @override
  Future<List<StaffProbation>> getProbation(String staffId) async => [
    StaffProbation(id: 'p1'),
  ];

  @override
  Future<List<StaffDeclaration>> getDeclarations(String staffId) async => [
    StaffDeclaration(id: 'd1'),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUpAll(() {
    if (!GetIt.I.isRegistered<AppGlobals>()) {
      GetIt.I.registerLazySingleton<AppGlobals>(() => AppGlobals());
    }
  });

  ProviderContainer containerFor(_FakeAccountRepository repo) {
    final c = ProviderContainer(
      overrides: [accountRepositoryProvider.overrideWithValue(repo)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('a save refreshes the profile and keeps the data on screen', () async {
    final repo = _FakeAccountRepository();
    final c = containerFor(repo);
    final notifier = c.read(accountControllerProvider.notifier);
    await c.read(accountControllerProvider.future);
    await notifier.getAccount();

    repo.user = RegisterResponseModel(
      id: 'staff-1',
      firstName: 'Janet',
      surName: 'Doe',
    );
    final states = <bool>[];
    c.listen(
      accountControllerProvider,
      (_, next) => states.add(next.isLoading),
    );

    final result = await notifier.updateProfile(
      const UpdateStaffRequest(firstName: 'Janet'),
    );

    expect(result.isSuccess, isTrue);
    expect(
      states,
      isNot(contains(true)),
      reason: 'never swaps data for a spinner',
    );
    final data = c.read(accountControllerProvider).value!.userData!;
    expect(data.firstName, 'Janet');
    expect(globals.userName, 'Janet Doe');
  });

  test('adding a record sends the carer\'s own staff id', () async {
    final repo = _FakeAccountRepository();
    final c = containerFor(repo);
    final notifier = c.read(accountControllerProvider.notifier);
    await c.read(accountControllerProvider.future);
    await notifier.getAccount();

    await notifier.saveStaffRecord(
      const EmergencyContactRequest(
        name: 'John Doe',
        relationship: 'Husband',
        phone: '07987654321',
        notes: '',
      ),
    );

    expect(repo.lastAdminStaffId, 'staff-1');
    expect(repo.calls, containsAllInOrder(['save:emergency-contact', 'get']));
  });

  test('a failed save keeps what was on screen and does not refresh', () async {
    final repo = _FakeAccountRepository()
      ..saveResult = GeneralResultModel.failure('Something is wrong.');
    final c = containerFor(repo);
    final notifier = c.read(accountControllerProvider.notifier);
    await c.read(accountControllerProvider.future);
    await notifier.getAccount();
    repo.calls.clear();

    final result = await notifier.updateProfile(
      const UpdateStaffRequest(firstName: 'X'),
    );

    expect(result.isSuccess, isFalse);
    expect(result.message, 'Something is wrong.');
    expect(repo.calls, ['updateProfile']);
    expect(
      c.read(accountControllerProvider).value!.userData!.firstName,
      'Jane',
    );
  });

  test('changing a reference reloads the list of references', () async {
    final repo = _FakeAccountRepository();
    final c = containerFor(repo);
    final notifier = c.read(accountControllerProvider.notifier);
    await c.read(accountControllerProvider.future);
    await notifier.getAccount();
    repo.calls.clear();

    await notifier.updateStaffRecord(
      'r1',
      const ReferenceRequest(
        referenceType: 'Character',
        refereeName: 'Sarah',
        organisationName: '',
        jobTitle: '',
        email: '',
        phoneNumber: '',
        relationshipToStaff: '',
        employmentStartDate: null,
        employmentEndDate: null,
        status: 'NotRequested',
        notes: '',
        jobDescriptionUrl: '',
      ),
    );

    expect(
      repo.calls,
      containsAllInOrder(['update:references', 'get', 'getReferences']),
    );
    expect(c.read(accountControllerProvider).value!.references.single.id, 'r1');
  });

  test('sending a reference request refreshes the references', () async {
    final repo = _FakeAccountRepository();
    final c = containerFor(repo);
    final notifier = c.read(accountControllerProvider.notifier);
    await c.read(accountControllerProvider.future);
    await notifier.getAccount();
    repo.calls.clear();

    final result = await notifier.sendReferenceRequest('r1');

    expect(result.isSuccess, isTrue);
    expect(repo.calls, contains('sendRequest:r1'));
    expect(repo.calls, contains('getReferences'));
  });

  test('one office record failing to load does not hide the others', () async {
    final repo = _FakeAccountRepository()..supervisionsError = 'Server error.';
    final c = containerFor(repo);
    final notifier = c.read(accountControllerProvider.notifier);
    await c.read(accountControllerProvider.future);
    await notifier.getAccount();

    final error = await notifier.loadOfficeRecords();

    expect(error, 'Server error.');
    final s = c.read(accountControllerProvider).value!;
    expect(s.supervisions, isEmpty);
    expect(s.probation.single.id, 'p1');
    expect(s.declarations.single.id, 'd1');
  });
}
