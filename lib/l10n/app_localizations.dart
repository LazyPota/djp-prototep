import 'package:flutter/widgets.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static const supportedLocales = <Locale>[
    Locale('en'),
    Locale('id'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  static AppLocalizations of(BuildContext context) {
    final value = Localizations.of<AppLocalizations>(context, AppLocalizations);
    assert(value != null, 'AppLocalizations not found in context');
    return value!;
  }

  static final Map<String, Map<String, String>> _values = {
    'en': {
      'appTitle': 'Awas!',
      'homeTitle': 'Awas!',
      'start': 'Start',
      'stop': 'Stop',
      'beforeStartTitle': 'Before You Start',
      'beforeStartBody': '1. Enable Accessibility permission in Settings.\n2. Allow Show on other apps permission.\n3. Open a Tokopedia product page first, then tap the floating button.',
      'beforeStartNeedOverlay': 'Allow Show on other apps permission in Settings.',
      'beforeStartNeedAccessibility': 'Enable Accessibility API permission in Settings.',
      'beforeStartNeedProduct': 'Open a Tokopedia product page, then tap the floating button.',
      'onboardingSetupDescription': 'Awas! protects you while shopping by reading the active app/window via Accessibility, then tapping Share -> Copy link and sending it to the fraud-check server.',
      'cancel': 'Cancel',
      'continue': 'Continue',
      'protected': 'Protected',
      'global': 'Global',
      'homeHint': 'Awas! shows a floating button over other apps. Tap it on a product page to auto tap Share then Copy Link for server analysis.',
      'activityTitle': 'Supported App Activity',
      'settingsTitle': 'Settings',
      'language': 'Language',
      'english': 'English',
      'indonesian': 'Indonesian',
      'homeTab': 'Home',
      'activityTab': 'Activity',
      'settingsTab': 'Settings',
      'supportedPackages': 'Supported packages: {apps}',
      'noChecks': 'No checks yet. Open Tokopedia or other apps to record support checks.',
      'lastObserved': 'Last observed: {app}',
      'setupTitle': 'Settings',
      'appearance': 'Appearance',
      'auto': 'Auto',
      'light': 'Light',
      'dark': 'Dark',
      'permissions': 'Permissions',
      'showOnOtherApps': 'Show on other apps',
      'floatingPermission': 'Floating button overlay permission',
      'accessibilityApi': 'Accessibility API',
      'accessibilityNeeded': 'Required to detect app + tap Share/Copy',
      'grant': 'Grant',
      'granted': 'Granted',
      'openSettings': 'Open settings',
      'checking': 'Checking...',
      'enabled': 'Enabled',
      'notEnabled': 'Not enabled',
      'scanSupportedOnly': 'Scanning is only available on supported apps. Open Tokopedia first.',
      'checkingCurrentScreen': 'Checking current screen...',
      'sendingLink': 'Sending link to server...',
      'done': 'Done',
      'openProductThenRefresh': 'Open a product page, then tap refresh.',
      'tapToCheck': 'Tap to check a product page',
    },
    'id': {
      'appTitle': 'Awas!',
      'homeTitle': 'Awas!',
      'start': 'Mulai',
      'stop': 'Berhenti',
      'beforeStartTitle': 'Sebelum Mulai',
      'beforeStartBody': '1. Aktifkan izin Aksesibilitas di Pengaturan.\n2. Izinkan Tampil di atas aplikasi lain.\n3. Buka halaman produk Tokopedia dulu, lalu tekan tombol mengambang.',
      'beforeStartNeedOverlay': 'Izinkan Tampil di atas aplikasi lain di Pengaturan.',
      'beforeStartNeedAccessibility': 'Aktifkan izin API Aksesibilitas di Pengaturan.',
      'beforeStartNeedProduct': 'Buka halaman produk Tokopedia, lalu tekan tombol mengambang.',
      'onboardingSetupDescription': 'Awas! melindungi Anda saat belanja dengan membaca aplikasi/jendela aktif melalui Aksesibilitas, lalu menekan Bagikan -> Salin tautan dan mengirimkannya ke server pemeriksa penipuan.',
      'cancel': 'Batal',
      'continue': 'Lanjut',
      'protected': 'Terlindungi',
      'global': 'Global',
      'homeHint': 'Awas! menampilkan tombol mengambang di aplikasi lain. Tekan saat di halaman produk untuk otomatis tekan Bagikan lalu Salin Tautan untuk analisis server.',
      'activityTitle': 'Aktivitas Aplikasi Didukung',
      'settingsTitle': 'Pengaturan',
      'language': 'Bahasa',
      'english': 'Inggris',
      'indonesian': 'Indonesia',
      'homeTab': 'Beranda',
      'activityTab': 'Aktivitas',
      'settingsTab': 'Pengaturan',
      'supportedPackages': 'Paket didukung: {apps}',
      'noChecks': 'Belum ada pengecekan. Buka Tokopedia atau aplikasi lain untuk mencatat pengecekan dukungan.',
      'lastObserved': 'Terakhir terdeteksi: {app}',
      'setupTitle': 'Pengaturan',
      'appearance': 'Tampilan',
      'auto': 'Otomatis',
      'light': 'Terang',
      'dark': 'Gelap',
      'permissions': 'Izin',
      'showOnOtherApps': 'Tampil di atas aplikasi lain',
      'floatingPermission': 'Izin tombol mengambang',
      'accessibilityApi': 'API Aksesibilitas',
      'accessibilityNeeded': 'Diperlukan untuk deteksi aplikasi + klik Bagikan/Salin',
      'grant': 'Beri Izin',
      'granted': 'Diizinkan',
      'openSettings': 'Buka pengaturan',
      'checking': 'Memeriksa...',
      'enabled': 'Aktif',
      'notEnabled': 'Belum aktif',
      'scanSupportedOnly': 'Pemindaian hanya tersedia untuk aplikasi yang didukung. Buka Tokopedia terlebih dahulu.',
      'checkingCurrentScreen': 'Memeriksa layar saat ini...',
      'sendingLink': 'Mengirim tautan ke server...',
      'done': 'Selesai',
      'openProductThenRefresh': 'Buka halaman produk, lalu tekan segarkan.',
      'tapToCheck': 'Tekan untuk memeriksa halaman produk',
    },
  };

  String _t(String key) {
    final lang = _values.containsKey(locale.languageCode) ? locale.languageCode : 'en';
    return _values[lang]![key] ?? _values['en']![key] ?? key;
  }

  String get appTitle => _t('appTitle');
  String get homeTitle => _t('homeTitle');
  String get start => _t('start');
  String get stop => _t('stop');
  String get beforeStartTitle => _t('beforeStartTitle');
  String get beforeStartBody => _t('beforeStartBody');
  String get beforeStartNeedOverlay => _t('beforeStartNeedOverlay');
  String get beforeStartNeedAccessibility => _t('beforeStartNeedAccessibility');
  String get beforeStartNeedProduct => _t('beforeStartNeedProduct');
  String get onboardingSetupDescription => _t('onboardingSetupDescription');
  String get cancel => _t('cancel');
  String get continueLabel => _t('continue');
  String get protected => _t('protected');
  String get global => _t('global');
  String get homeHint => _t('homeHint');
  String get activityTitle => _t('activityTitle');
  String get settingsTitle => _t('settingsTitle');
  String get language => _t('language');
  String get english => _t('english');
  String get indonesian => _t('indonesian');
  String get homeTab => _t('homeTab');
  String get activityTab => _t('activityTab');
  String get settingsTab => _t('settingsTab');
  String supportedPackages(String apps) => _t('supportedPackages').replaceAll('{apps}', apps);
  String get noChecks => _t('noChecks');
  String lastObserved(String app) => _t('lastObserved').replaceAll('{app}', app);
  String get setupTitle => _t('setupTitle');
  String get appearance => _t('appearance');
  String get auto => _t('auto');
  String get light => _t('light');
  String get dark => _t('dark');
  String get permissions => _t('permissions');
  String get showOnOtherApps => _t('showOnOtherApps');
  String get floatingPermission => _t('floatingPermission');
  String get accessibilityApi => _t('accessibilityApi');
  String get accessibilityNeeded => _t('accessibilityNeeded');
  String get grant => _t('grant');
  String get granted => _t('granted');
  String get openSettings => _t('openSettings');
  String get checking => _t('checking');
  String get enabled => _t('enabled');
  String get notEnabled => _t('notEnabled');
  String get scanSupportedOnly => _t('scanSupportedOnly');
  String get checkingCurrentScreen => _t('checkingCurrentScreen');
  String get sendingLink => _t('sendingLink');
  String get done => _t('done');
  String get openProductThenRefresh => _t('openProductThenRefresh');
  String get tapToCheck => _t('tapToCheck');
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      AppLocalizations.supportedLocales.any((l) => l.languageCode == locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(covariant LocalizationsDelegate<AppLocalizations> old) => false;
}
