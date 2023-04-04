class BooleanString {
  bool status = false;
  String message = '';

  bool get statusReply => status;
  String get statusMessage => message;

  BooleanString(this.status, this.message) ;
}