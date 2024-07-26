import 'package:lightmachine/types/social_type.dart';

class AddressBarItemDataType {
  AddressBarItemDataType({
    required this.type,
    required this.icon,
    required this.activeIcon,
    required this.link,
    required this.isVisible,
  });

  final SocialType type;
  final String icon;
  final String activeIcon;
  final String link;
  final bool isVisible;
}
