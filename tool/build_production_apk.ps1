param(
  [Parameter(Mandatory = $true)]
  [string]$BackendUrl,
  [string]$SupabaseUrl = '',
  [string]$SupabaseAnonKey = ''
)

$ErrorActionPreference = 'Stop'
$base = $BackendUrl.TrimEnd('/')
$uri = $null
if (-not [uri]::TryCreate($base, [UriKind]::Absolute, [ref]$uri) -or
    $uri.Scheme -ne 'https' -or
    -not $uri.Host -or
    $uri.AbsolutePath -ne '/' -or
    $uri.Query -or
    $uri.Fragment -or
    $uri.UserInfo) {
  throw 'BackendUrl must be the HTTPS origin of the deployed Vercel backend.'
}

$env:KWC_BACKEND_HEALTH_URL = "$base/health"
try {
  node -e "(async()=>{const r=await fetch(process.env.KWC_BACKEND_HEALTH_URL,{signal:AbortSignal.timeout(20000)});const j=await r.json();if(!r.ok||j.status!=='ok'||j.roboflowConfigured!==true)process.exitCode=1})().catch(()=>{process.exitCode=1})"
  if ($LASTEXITCODE -ne 0) {
    throw 'The deployed backend health check did not confirm Roboflow configuration.'
  }
} finally {
  Remove-Item Env:KWC_BACKEND_HEALTH_URL
}

$dartDefines = @("--dart-define=API_BASE_URL=$base")
if ($SupabaseUrl -and $SupabaseAnonKey) {
  $dartDefines += "--dart-define=SUPABASE_URL=$SupabaseUrl"
  $dartDefines += "--dart-define=SUPABASE_ANON_KEY=$SupabaseAnonKey"
} elseif ($SupabaseUrl -or $SupabaseAnonKey) {
  throw 'Pass both -SupabaseUrl and -SupabaseAnonKey together, or neither (to build in local-only demo mode).'
}

flutter build apk --release @dartDefines
if ($LASTEXITCODE -ne 0) {
  throw 'Flutter release APK build failed.'
}
