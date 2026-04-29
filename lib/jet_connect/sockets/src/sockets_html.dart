import 'dart:async';
import 'dart:convert';
import 'dart:js_interop';

import 'package:web/web.dart' as html;

import '../../../jet_core/jet_core.dart';
import 'socket_notifier.dart';

class BaseWebSocket {
  String url;
  html.WebSocket? socket;
  SocketNotifier? socketNotifier = SocketNotifier();
  Duration ping;
  bool isDisposed = false;
  bool allowSelfSigned;

  ConnectionStatus? connectionStatus;
  Timer? _t;
  StreamSubscription? _onOpenSub;
  StreamSubscription? _onMessageSub;
  StreamSubscription? _onCloseSub;
  StreamSubscription? _onErrorSub;

  BaseWebSocket(
    this.url, {
    this.ping = const Duration(seconds: 5),
    this.allowSelfSigned = false,
  }) {
    url = url.startsWith('https')
        ? url.replaceAll('https:', 'wss:')
        : url.replaceAll('http:', 'ws:');
  }

  void close([int? status, String? reason]) {
    // This weird code is fault of web package, they are not using null safety yet
    // See https://github.com/dart-lang/web/blob/main/web/lib/src/dom/websockets.dart#L60
    if (status != null && reason != null) {
      socket?.close(status, reason);
    } else if (status != null) {
      socket?.close(status);
    } else {
      socket?.close();
    }
  }

  Future<void> _cancelStreamSubs() async {
    await _onOpenSub?.cancel();
    await _onMessageSub?.cancel();
    await _onCloseSub?.cancel();
    await _onErrorSub?.cancel();
    _onOpenSub = null;
    _onMessageSub = null;
    _onCloseSub = null;
    _onErrorSub = null;
  }

  // ignore: use_setters_to_change_properties
  void connect() {
    try {
      connectionStatus = ConnectionStatus.connecting;
      if (allowSelfSigned) {
        Jet.log(
          'BaseWebSocket: WARNING - allowSelfSigned=true. '
          'Browsers ignore this flag; TLS validation is enforced by the host '
          'browser. Set up correct certificates for production.',
        );
      }
      // Cancel any prior subscriptions so reconnects don't accumulate listeners.
      _cancelStreamSubs();
      _t?.cancel();
      socket = html.WebSocket(url);
      _onOpenSub = socket!.onOpen.listen((e) {
        socketNotifier?.open();
        _t?.cancel();
        _t = Timer.periodic(ping, (t) {
          socket!.send(''.toJSBox);
        });
        connectionStatus = ConnectionStatus.connected;
      });

      _onMessageSub = socket!.onMessage.listen((event) {
        socketNotifier!.notifyData(event.data);
      });

      _onCloseSub = socket!.onClose.listen((e) {
        _t?.cancel();

        connectionStatus = ConnectionStatus.closed;
        socketNotifier!.notifyClose(Close(e.reason, e.code));
      });
      _onErrorSub = socket!.onError.listen((event) {
        _t?.cancel();
        socketNotifier!.notifyError(Close(event.toString(), 0));
        connectionStatus = ConnectionStatus.closed;
      });
    } on Exception catch (e) {
      _t?.cancel();
      socketNotifier!.notifyError(Close(e.toString(), 500));
      connectionStatus = ConnectionStatus.closed;
      //  close(500, e.toString());
    }
  }

  void dispose() {
    _t?.cancel();
    _t = null;
    _cancelStreamSubs();
    socketNotifier!.dispose();
    socketNotifier = null;
    isDisposed = true;
  }

  void emit(String event, dynamic data) {
    send(jsonEncode({'type': event, 'data': data}));
  }

  void on(String event, MessageSocket message) {
    socketNotifier!.addEvents(event, message);
  }

  void onClose(CloseSocket fn) {
    socketNotifier!.addCloses(fn);
  }

  void onError(CloseSocket fn) {
    socketNotifier!.addErrors(fn);
  }

  void onMessage(MessageSocket fn) {
    socketNotifier!.addMessages(fn);
  }

  // ignore: use_setters_to_change_properties
  void onOpen(OpenSocket fn) {
    socketNotifier!.open = fn;
  }

  void send(Object data) {
    if (connectionStatus == ConnectionStatus.closed) {
      connect();
    }
    if (socket != null && socket!.readyState == html.WebSocket.OPEN) {
      socket!.send(data.toJSBox);
    } else {
      Jet.log('WebSocket not connected, message $data not sent');
    }
  }
}

enum ConnectionStatus {
  connecting,
  connected,
  closed,
}
