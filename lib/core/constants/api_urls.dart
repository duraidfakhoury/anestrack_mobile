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
}
