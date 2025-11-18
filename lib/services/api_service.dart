import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String url =
      "https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple";

  static Future<List> fetchQuestions() async {
    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);
    return data["results"];
  }
}
