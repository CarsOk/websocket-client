import 'dart:convert';
import 'dart:io';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

void main() {
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
      print('Conectando a $endpoint con headers $headers');
      _channel = IOWebSocketChannel.connect(uri, headers: headers);
      await _channel.ready;

      _channel.stream.listen(
        (message) {
          print('---> $message');
        },
        onDone: () {
          print('---> FINALIZO CONEXION <----');
        },
        onError: (error, stackTrace) {
          print('Hubo un error inesperado: $error');
          exit(0);
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
    _channel.sink.add(newMessage);
    print('ENVIADO');
  }

  void close() {
    _channel.sink.close();
  }
}

class Interface {
  late WebSocketCliente websocket;
  void start() async {
    print('Cliente WebSocketCliente \nIngresar endpoint:');

    var endpoint = stdin.readLineSync();

    print('ingresar header (omita este paso si no es necesario):');

    var headers = stdin.readLineSync();

    print("eso es headers ${headers} ${headers.runtimeType}");

    if (Validator.presence(endpoint) && Validator.headers(headers)) {
      websocket = WebSocketCliente();

      bool connect = await websocket.connect(
        endpoint: endpoint!,
        headers: headers!.isEmpty ? {} : json.decode(headers),
      );

      if (connect) {
        print(
            'Se ha conectado correctamente, para salir del programa escriba "exit"');

        sendMessage();
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

  void sendMessage() async {
    print('Ingresa un mensaje');
    String? newMessage = stdin.readLineSync();
    if (newMessage == 'exit') {
      websocket.close();
      print('Saliendo del programa...');
      exit(0);
    }

    websocket.message(newMessage!);
    await Future.delayed(Duration(seconds: 3));
    sendMessage();
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
