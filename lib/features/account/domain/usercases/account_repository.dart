import 'package:well_trust_mobile_app/features/account/data/dto/staff_requests.dart';
import 'package:well_trust_mobile_app/features/account/data/model/user_response_model.dart';
import 'package:well_trust_mobile_app/shared/model/response_result_model.dart';

abstract class AccountRepository {
  Future<RegisterResponseModel> getUserData();

  //! UPDATE PROFILE
  Future<GeneralResultModel> updateProfile(UpdateStaffRequest request);

  //! STAFF RECORDS (job details, emergency contact, documents, qualifications,
  //! certificates, competencies)
  Future<GeneralResultModel> saveStaffRecord(
    StaffRecordRequest request, {
    required String adminStaffId,
  });
  Future<GeneralResultModel> updateStaffRecord(
    String id,
    StaffRecordRequest request,
  );
  Future<GeneralResultModel> deleteStaffRecord(StaffRecordKind kind, String id);
  Future<GeneralResultModel> sendReferenceRequest(String id);

  //! The carer's own lists that the profile call does not include.
  Future<List<StaffReference>> getReferences(String staffId);
  Future<List<StaffSupervision>> getSupervisions(String staffId);
  Future<List<StaffProbation>> getProbation(String staffId);
  Future<List<StaffDeclaration>> getDeclarations(String staffId);

  Future<GeneralResultModel> sendFeedBack({
    required String feedback,
    required String phoneNo,
  });
}
