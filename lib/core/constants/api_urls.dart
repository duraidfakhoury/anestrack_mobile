class ApisUrls {
  static ApisUrls? _instance;
  ApisUrls._();
  factory ApisUrls() => _instance ??= ApisUrls._();

  late String _baseUrl;

  void initBaseUrl(String baseUrl) {
    _baseUrl = baseUrl;
  }

  /// class [ApisUrls] contains all URLs to external services, services,
  /// or APIs, according to the following figure
  ///
  /// add new APIs URL in this way:
  /// EX: static  String get {verb}featureName => '$_baseApiUrl/{route}';

  /// [_baseApiUrl] base API url
  String get _baseApiUrl => '$_baseUrl/api';

  /// [_baseImagesUrl] base Images Url
  //   String get _baseImagesUrl => '$_baseUrl/uploads';
  String baseImagesUrl(String url) => url;

  /// Auth Feature APIs
  String get login => '$_baseApiUrl/functions/login';
  String get logout => '$_baseApiUrl/functions/logout';

  /// Procedure Feature APIs
  String get listProcedures => '$_baseApiUrl/functions/listProcedures';
  String get createProcedure => '$_baseApiUrl/functions/createProcedure';
  String get getProcedure => '$_baseApiUrl/functions/getProcedure';
  String get listHospitals => '$_baseApiUrl/functions/listHospitals';
  String get listProcedureTypes => '$_baseApiUrl/functions/listProcedureTypes';
  String get listSupervisors => '$_baseApiUrl/functions/listSupervisors';

  /// Co-sign & confirmation (reliability) APIs
  String get coSignProcedure => '$_baseApiUrl/functions/coSignProcedure';
  String get getCoSignContext => '$_baseApiUrl/functions/getCoSignContext';
  String get confirmProcedure => '$_baseApiUrl/functions/confirmProcedure';
  String get listPendingForSupervisor =>
      '$_baseApiUrl/functions/listPendingForSupervisor';

  /// Supervisor Students Feature APIs
  /// Uses the supervisor-scoped `listStudents` (auth: any Supervisor) rather
  /// than `listUsers` (admin-only), with server-side search/year/hospital
  /// filters.
  String get listStudents => '$_baseApiUrl/functions/listStudents';

  /// Profile / current user
  String get getCurrentUser => '$_baseApiUrl/functions/getCurrentUser';

  /// Statistics
  String get getSupervisorDashboard =>
      '$_baseApiUrl/functions/getSupervisorDashboard';
  String get getStudentDashboard =>
      '$_baseApiUrl/functions/getStudentDashboard';

  /// Complaints
  String get createComplaint => '$_baseApiUrl/functions/createComplaint';

  /// Notifications
  String get listNotifications => '$_baseApiUrl/functions/listNotifications';
  String get getUnreadCount => '$_baseApiUrl/functions/getUnreadCount';
  String get markNotificationAsRead => '$_baseApiUrl/functions/markAsRead';
  String get markAllNotificationsAsRead =>
      '$_baseApiUrl/functions/markAllAsRead';

  /// Announcements
  String get listAnnouncements => '$_baseApiUrl/functions/listAnnouncements';
  String get createAnnouncement => '$_baseApiUrl/functions/createAnnouncement';

  /// Education — lectures, AI summaries, comprehension quizzes
  String get listLectures => '$_baseApiUrl/functions/listLectures';
  String get getLecture => '$_baseApiUrl/functions/getLecture';
  String get createLecture => '$_baseApiUrl/functions/createLecture';
  String get generateAISummary => '$_baseApiUrl/functions/generateAISummary';
  String get listLectureAssessments =>
      '$_baseApiUrl/functions/listLectureAssessments';
  String get submitAnswers => '$_baseApiUrl/functions/submitAnswers';

  /// Library — research papers
  String get listResearchPapers => '$_baseApiUrl/functions/listResearchPapers';
  String get getResearchPaper => '$_baseApiUrl/functions/getResearchPaper';
  String get createResearchPaper =>
      '$_baseApiUrl/functions/createResearchPaper';
  String get listResearchTypes => '$_baseApiUrl/functions/listResearchTypes';
  String get listResearchPaperComments =>
      '$_baseApiUrl/functions/listResearchPaperComments';
  String get createResearchPaperComment =>
      '$_baseApiUrl/functions/createResearchPaperComment';
}
