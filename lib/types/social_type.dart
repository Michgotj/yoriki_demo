enum SocialType {
  twitter,
  facebook,
  instagram,
  tiktok,
  other,
}

SocialType getSocialType(String type) {
  switch (type) {
    case 'twitter':
    case 'x':
      return SocialType.twitter;
    case 'facebook':
      return SocialType.facebook;
    case 'instagram':
      return SocialType.instagram;
    case 'tiktok':
      return SocialType.tiktok;
    default:
      return SocialType.other;
  }
}

String getSocialTypeString(SocialType type) {
  switch (type) {
    case SocialType.twitter:
      return 'twitter';
    case SocialType.facebook:
      return 'facebook';
    case SocialType.instagram:
      return 'instagram';
    case SocialType.tiktok:
      return 'tiktok';
    default:
      throw ArgumentError('Invalid social type: $type');
  }
}
