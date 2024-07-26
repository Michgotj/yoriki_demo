String getDomain(String url) {
  var domain = Uri.parse(url).host;
  var domainParts = domain.split('.');
  if (domainParts.length > 1) {
    return (domainParts[domainParts.length - 2]);
  }
  return '';
}
