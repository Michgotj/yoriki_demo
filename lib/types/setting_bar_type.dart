class SettingBarType {
  SettingBarType({
    required this.type,
    required this.icon,
    required this.isVisible,
  });

  final FooterSettingOptions type;
  final String icon;
  final bool isVisible;
}

enum FooterSettingOptions { goBack, urlPrompt, goForward, goHome, goSetting }
