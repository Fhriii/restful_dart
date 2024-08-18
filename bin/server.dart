import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// Data in-memory
final List<Map<String, dynamic>> _items = [];

// GET All Items
Response _getAllItems(Request request) {
  return Response.ok(jsonEncode(_items), headers: {'Content-Type': 'application/json'});
}

// GET Single Item
Response _getItem(Request request, String id) {
  final item = _items.firstWhere(
    (item) => item['id'] == id,
    orElse: ()=>{}, 
  );
  if (item == null) {
    return Response.notFound('Item not found');
  }
  return Response.ok(jsonEncode(item), headers: {'Content-Type': 'application/json'});
}

// POST Create Item
Future<Response> _createItem(Request request) async {
  final payload = await request.readAsString();
  final data = jsonDecode(payload);

  if (data['id'] == null || data['name'] == null) {
    return Response(400, body: 'Invalid data');
  }

  _items.add(data);
  return Response(201, body: jsonEncode(data), headers: {'Content-Type': 'application/json'});
}

// PUT Update Item
Future<Response> _updateItem(Request request, String id) async {
  final itemIndex = _items.indexWhere((item) => item['id'] == id);
  if (itemIndex == -1) {
    return Response.notFound('Item not found');
  }

  final payload = await request.readAsString();
  final data = jsonDecode(payload);

  if (data['name'] == null) {
    return Response(400, body: 'Invalid data');
  }

  _items[itemIndex]['name'] = data['name'];
  return Response.ok(jsonEncode(_items[itemIndex]), headers: {'Content-Type': 'application/json'});
}

// DELETE Item
Response _deleteItem(Request request, String id) {
  final itemIndex = _items.indexWhere((item) => item['id'] == id);
  if (itemIndex == -1) {
    return Response.notFound('Item not found');
  }

  _items.removeAt(itemIndex);
  return Response.ok('Item deleted');
}

void main() async {
  final app = Router();

  app.get('/items', _getAllItems);
  app.get('/items/<id>', _getItem);
  app.post('/items', _createItem);
  app.put('/items/<id>', _updateItem);
  app.delete('/items/<id>', _deleteItem);

  final handler = Pipeline().addHandler(app);

  final server = await io.serve(handler, 'localhost', 8080);
  print('Server running on localhost:${server.port}');
}
