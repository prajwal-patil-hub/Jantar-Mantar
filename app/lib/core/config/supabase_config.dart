/// Supabase connection constants. Both values are PUBLIC BY DESIGN
/// (SECURITY.md): the publishable key grants nothing on its own — every
/// permission is enforced server-side by RLS (deny-by-default) and the
/// SECURITY DEFINER decision functions. Never put a secret key here.
abstract final class SupabaseConfig {
  static const url = 'https://orsqjucexvrefmexztay.supabase.co';
  static const publishableKey =
      'sb_publishable_8MiEskdUG4ySAf-xHTpX6w_1Y8yLXch';
}
