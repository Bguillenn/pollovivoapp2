class DataResponse<T> {
  final String cMensaje;
  final String cMsjError;
  final int nCodError;
  final T dataResponse;

  DataResponse(this.cMensaje, this.cMsjError, this.nCodError, this.dataResponse);

  DataResponse.fromJson(Map<String, dynamic> json)
      : cMensaje = json['cMensaje'],
        cMsjError = json['cMsjError'],
        nCodError = json['nCodError'],
        dataResponse = json['oContenido'];
}
