class SupabaseConfig {
  const SupabaseConfig._();

  static const url = String.fromEnvironment('SUPABASE_URL');
  static const anonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// True once both --dart-define values are supplied. When false, the app
  /// falls back to the local-only demo repositories instead of trying (and
  /// failing) to reach a Supabase project that hasn't been configured.
  static bool get isConfigured => url.isNotEmpty && anonKey.isNotEmpty;
}
