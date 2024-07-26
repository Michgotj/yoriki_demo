class MyToastModel {
  String message;
  ToastType type;

  MyToastModel(this.message, this.type);
}

enum ToastType { success, failed, warning, info }
