import 'dart:io';
import 'dart:convert';

void main() async {
  final server = await HttpServer.bind('localhost', 8080);
  // ignore: avoid_print
  print('🚀 Simple test server running on http://localhost:8080');
  
  await for (HttpRequest request in server) {
    // Enable CORS
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, PUT, DELETE, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type, Authorization');
    
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      await request.response.close();
      continue;
    }
    
    try {
      final uri = request.uri;
      final method = request.method;
      
      // ignore: avoid_print
      print('${DateTime.now()}: $method ${uri.path}');
      
      // Simple routing
      if (uri.path == '/health') {
        _sendJson(request.response, {'status': 'ok', 'timestamp': DateTime.now().toIso8601String()});
      } else if (uri.path == '/api/articles') {
        _sendJson(request.response, {
          'articles': [
            {
              'id': '1',
              'title': 'Test Article',
              'content': 'This is a test article',
              'author': 'Test Author',
              'createdAt': DateTime.now().toIso8601String(),
            }
          ]
        });
      } else if (uri.path == '/api/posts') {
        _sendJson(request.response, {
          'posts': [
            {
              'id': '1',
              'content': 'Test post content',
              'author': 'Test Author',
              'createdAt': DateTime.now().toIso8601String(),
            }
          ]
        });
      } else if (uri.path == '/api/cryptocurrencies') {
        _sendJson(request.response, {
          'cryptocurrencies': [
            {
              'id': 'bitcoin',
              'name': 'Bitcoin',
              'symbol': 'BTC',
              'price': 45000.00,
              'change24h': 2.5,
            }
          ]
        });
      } else {
        request.response.statusCode = HttpStatus.notFound;
        _sendJson(request.response, {'error': 'Not found'});
      }
    } catch (e) {
      // ignore: avoid_print
      print('Error handling request: $e');
      request.response.statusCode = HttpStatus.internalServerError;
      _sendJson(request.response, {'error': 'Internal server error'});
    }
  }
}

void _sendJson(HttpResponse response, Map<String, dynamic> data) {
  response.headers.contentType = ContentType.json;
  response.write(json.encode(data));
  response.close();
}
