class Endpoints {
  static const env = String.fromEnvironment('ENV');
  static const _production = "https://new-api-connection.welltrustcare.co.uk/";
  static const _live = "https://new-api-connection.welltrustcare.co.uk/";
  static const _test = "https://new-api-connection.welltrustcare.co.uk/";

  static String get appBaseUrl {
    switch (env) {
      case 'production':
        return _production;
      case 'live':
        return _live;
      case 'test':
        return _test;
      default:
        return _test;
    }
  }

  static Uri get webSocketUrl {
    final uri = Uri.parse(appBaseUrl);
    return uri.replace(
      scheme: uri.scheme == 'https' ? 'wss' : 'ws',
      path: '/ws',
    );
  }

  static String socketBaseUrl = appBaseUrl;
  // appBaseUrl already ends in a slash, so trim it before adding /api/ or the
  // URL comes out as ...co.uk//api/.
  static String baseUrl = "${appBaseUrl.replaceFirst(RegExp(r'/+$'), '')}/api/";

  static String usersUrl = "admin-users";
  static String kioskLoginUrl = "welltrust-kiosk/login";
  static String logoutUrl = "auth/logout";
  static String refreshTokenUrl = "auth/tokens/refresh";

  // Account and staff self-service
  static String userProfile = "$usersUrl/profile";
  static String userUpdate = "admin-users/update";
  static String updateDeviceToken = "$usersUrl/update-device-token";
  static String staffRecordsUrl = "admin-staff-records";
  static String staffProfile(String staffId) =>
      "$staffRecordsUrl/profile/staff/$staffId";
  static String staffProfileUpsert = "$staffRecordsUrl/profile";
  static String staffEmergencyContact(String staffId) =>
      "$staffRecordsUrl/emergency-contact/staff/$staffId";
  static String staffEmergencyContactUpsert =
      "$staffRecordsUrl/emergency-contact";
  static String staffDocuments = "$staffRecordsUrl/documents";
  static String staffQualifications = "$staffRecordsUrl/qualifications";
  static String staffCertificates = "$staffRecordsUrl/certificates";
  static String staffCompetencies = "$staffRecordsUrl/competencies";
  static String staffReferences = "$staffRecordsUrl/references";
  static String staffCompliance = "$staffRecordsUrl/compliance";
  static String staffDocumentsFor(String staffId) =>
      "$staffDocuments/staff/$staffId";
  static String staffQualificationsFor(String staffId) =>
      "$staffQualifications/staff/$staffId";
  static String staffCertificatesFor(String staffId) =>
      "$staffCertificates/staff/$staffId";
  static String staffCompetenciesFor(String staffId) =>
      "$staffCompetencies/staff/$staffId";
  static String staffReferencesFor(String staffId) =>
      "$staffReferences/staff/$staffId";
  static String staffComplianceFor(String staffId) =>
      "$staffCompliance/staff/$staffId";
  static String staffRecordsFor(String segment, String staffId) =>
      "$staffRecordsUrl/$segment/staff/$staffId";
  static String staffRecordCollection(String segment) =>
      "$staffRecordsUrl/$segment";
  static String staffRecord(String segment, String recordId) =>
      "$staffRecordsUrl/$segment/$recordId";
  static String sendReferenceRequest(String referenceId) =>
      "$staffRecordsUrl/references/$referenceId/send-request";
  static String staffSupervisions(String staffId) =>
      staffRecordsFor('supervisions', staffId);
  static String staffProbations(String staffId) =>
      staffRecordsFor('probations', staffId);
  static String staffDeclarations(String staffId) =>
      staffRecordsFor('declarations', staffId);
  static String staffAppointmentRecords(String staffId) =>
      staffRecordsFor('appointment-records', staffId);
  static String staffAppointmentLetter(String staffId) =>
      staffRecordsFor('appointment-letter', staffId);

  // Files and help
  static String uploadUrl = "upload-files/upload-web-server";
  static String feedbackUrl = "info/feedback";
  static String legacyFeedbackUrl = "info-data/feedback";

  // Mobile care API
  static String mobileUrl = "mobile";
  static String assignedClientsUrl = "$mobileUrl/assigned-clients";
  static String rotaUrl = "$mobileUrl/rota";
  static String visitsUrl = "$mobileUrl/visits";
  static String visit(String visitId) => "$visitsUrl/$visitId";
  static String visitClockIn(String visitId) => "${visit(visitId)}/clock-in";
  static String visitTasks(String visitId) => "${visit(visitId)}/tasks";
  static String visitIssues(String visitId) => "${visit(visitId)}/issues";
  static String visitClockOut(String visitId) => "${visit(visitId)}/clock-out";
  static String visitComplete(String visitId) => "${visit(visitId)}/complete";
  static String careNotesUrl = "$mobileUrl/care-notes";
  static String handoversUrl = "$mobileUrl/handovers";
  static String resolveHandover(String handoverId) =>
      "$handoversUrl/$handoverId/resolve";
  static String markClientHandoversRead(String clientId) =>
      "$handoversUrl/client/$clientId/read";
  static String messagesUrl = "$mobileUrl/messages";
  static String markMessageRead(String messageId) =>
      "$messagesUrl/$messageId/read";
  static String assessmentsUrl = "$mobileUrl/care-assessments";
  static String incidentsUrl = "$mobileUrl/incidents";
  static String complaintsUrl = "$mobileUrl/complaints";
  static String meetingsUrl = "$mobileUrl/meetings";

  // Personal notifications
  static String notificationsUrl = "notifications";
  static String notification(String notificationId) =>
      "$notificationsUrl/$notificationId";

  // Admin dashboard projections for mobile handovers and visit tasks
  static String mobileAdminUrl = "mobile-admin";
  static String mobileAdminHandovers = "$mobileAdminUrl/handovers";
  static String mobileAdminHandover(String handoverId) =>
      "$mobileAdminHandovers/$handoverId";
  static String resolveMobileAdminHandover(String handoverId) =>
      "${mobileAdminHandover(handoverId)}/resolve";
  static String mobileAdminVisitTasks(String visitId) =>
      "$mobileAdminUrl/visits/$visitId/tasks";

  // Existing dashboard APIs referenced by the mobile contract.
  static String dashboardVisits = "care-platform/resident-visits";
  static String dashboardCareNotes = "care-platform/health-staff-notes";
  static String dashboardAssessments =
      "care-platform/client-assessment-documents";
  static String dashboardMessages = "care-platform/chat-messages";
  static String dashboardIncidents = "incident-reports";
  static String dashboardComplaints = "info-data/complaint-logs";
}
