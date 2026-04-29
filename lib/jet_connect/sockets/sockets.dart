import 'src/sockets_stub.dart'
    if (dart.library.js_interop) 'src/sockets_html.dart'
    if (dart.library.io) 'src/sockets_io.dart';

class JetSocket extends BaseWebSocket {
  JetSocket(super.url, {super.ping, super.allowSelfSigned});
}
