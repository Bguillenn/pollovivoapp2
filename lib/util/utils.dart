
String DateTimeToWCF(DateTime date){
  final milisegundos = date.millisecondsSinceEpoch.toString();
  final timeZone = date.timeZoneOffset;
  final str1 = "000"+timeZone.inHours.abs().toString()+"00";
  final str2 = str1.substring(str1.length-4,str1.length);
  final signo = timeZone.inHours<0 ? "-": "+";
  return "/Date(${milisegundos}${signo}${str2})/";
}

DateTime WCFtoDateTime(String wcf){
  String STRsegundos = wcf.replaceAll("/Date(", "").replaceAll("-0500)/", "");
  int segundos = int.parse(STRsegundos);
  return DateTime.fromMillisecondsSinceEpoch(segundos);
}

String FormatDate(DateTime date){
  String mes = "0"+date.month.toString();
  mes = mes.substring(mes.length-2,mes.length);
  String dia = "0"+date.day.toString();
  dia = dia.substring(dia.length-2,dia.length);
  return "${date.year}-${mes}-${dia}";
}