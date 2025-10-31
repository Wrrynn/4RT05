import 'package:supabase_flutter/supabase_flutter.dart';

class DBService{
  // Inisialisasi Supabase client
  final SupabaseClient supabase = SupabaseClient(
    'https://xszsnzmwltkoyfxrobgn.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InhzenNuem13bHRrb3lmeHJvYmduIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjE4ODkzNjQsImV4cCI6MjA3NzQ2NTM2NH0.m0Y9-Qs1DoNJdMf-TjSyQq8E5Z9RmkkXK_ycrPCtNt8',
  );
}