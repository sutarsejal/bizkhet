import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final supabase = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> fetchProducts() async {
    final response = await supabase
        .from('products')
        .select()
        .order('id');

    return List<Map<String, dynamic>>.from(response);
  }
}
