import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
  print('hello and goodbye');

  Interface interfaz = Interface();

  interfaz.start();
}

class WebSocketCliente {
  late WebSocketChannel _channel;
  Future<bool> connect({
    required String endpoint,
    required Map<String, dynamic>? headers,
  }) async {
    try {
      final uri = Uri.parse(endpoint);

      // _channel = IOWebSocketChannel.connect(uri, headers: headers);
      // _channel = IOWebSocketChannel.connect(uri, headers: headers);
      print('el uri es $uri');
      _channel = IOWebSocketChannel.connect(uri);
      print('pase la conexion, se prepara par aocnectar');
      await _channel.ready;
      print('se conecto');

      _channel.stream.listen(
        (message) {
          print('---> $message');
        },
        onDone: () {
          print('---> FINALIZO CONEXION <----');
        },
        onError: (error, stackTrace) {
          print('ERRRORRRRRR: $error');
        },
        cancelOnError: true,
      );
      return true;
    } catch (e) {
      print('Hubo un error $e');
      return false;
    }
  }

  void message(String newMessage) {
    _channel.sink.add('Hollaaaaaaaaaa envio');
    print('se envio mensaje');
  }
}

class Interface {
  late WebSocketCliente websocket;
  void start() async {
    print('Cliente WebSocketCliente \n ingresar endpoint');

    var endpoint = stdin.readLineSync();

    print('ingresar header (omita este paso si no es necesario)');

    var headers = stdin.readLineSync();

    print("eso es headers ${headers} ${headers.runtimeType}");

    if (Validator.presence(endpoint) && Validator.headers(headers)) {
      websocket = WebSocketCliente();

      bool connect = await websocket.connect(
        endpoint: endpoint!,
        headers: headers!.isEmpty ? {} : json.decode(headers),
      );

      if (connect) {
        print('conectado');

        websocket.message('newMessage');
      } else {
        print(
            'Upsss... hubo un error de conexión, verifique url y conexion de internet');
        start();
      }
    } else {
      print('Link y/o header no valido');
      start();
    }
  }
}

class Validator {
  static bool presence(String? text) {
    if (text == null || text.isEmpty) {
      return false;
    }
    return true;
  }

  static bool headers(String? text) {
    try {
      if (text!.isNotEmpty) {
        json.decode(text);
      }

      return true;
    } catch (e) {
      print('error $e');
      return false;
    }
  }
}
