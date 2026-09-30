import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final _supabase = Supabase.instance.client;
  RealtimeChannel? _channel;
  
  // Stream controller untuk memberitahu UI jika ada notifikasi baru
  final _controller = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get notificationStream => _controller.stream;

  void init(BuildContext context) {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;

    // Berhenti mendengarkan channel lama jika ada
    _channel?.unsubscribe();

    // Dengarkan tabel notifications hanya untuk user yang sedang login
    _channel = _supabase
        .channel('public:notifications')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'notifications',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'user_id',
            value: userId,
          ),
          callback: (payload) {
            final data = payload.newRecord;
            _controller.add(data);
            
            // Tampilkan Alert Sederhana (Snackbar)
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data['title'], style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(data['message']),
                  ],
                ),
                backgroundColor: const Color(0xFF0D47A1),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 5),
              ),
            );
          },
        )
        .subscribe();
  }

  Future<List<Map<String, dynamic>>> getUnreadNotifications() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return [];
    
    return await _supabase
        .from('notifications')
        .select()
        .eq('user_id', userId)
        .eq('is_read', false)
        .order('created_at', ascending: false);
  }

  void dispose() {
    _channel?.unsubscribe();
    _controller.close();
  }
}
