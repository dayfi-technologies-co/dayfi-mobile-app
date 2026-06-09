import 'open_external_url_stub.dart'
    if (dart.library.html) 'open_external_url_web.dart' as impl;

void openExternalUrl(String url) => impl.openExternalUrl(url);
