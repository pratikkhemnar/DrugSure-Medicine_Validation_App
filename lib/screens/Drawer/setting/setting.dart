import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'settings_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _clearingCache = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settings, child) {
        final activeColor = settings.accentColor;
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Scaffold(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.grey.shade50,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: activeColor,
            foregroundColor: Colors.white,
            title: Text(
              _getTranslation(settings.languageCode, "settings_title"),
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            children: [
              // 1. VISUAL PREFERENCES SECTION
              _buildSectionHeader(
                _getTranslation(settings.languageCode, "sec_visual"),
                activeColor,
              ),
              _buildSectionCard(
                context,
                isDark,
                [
                  // Theme Selector
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTranslation(settings.languageCode, "theme_mode"),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildThemeOption(
                              context: context,
                              label: _getTranslation(settings.languageCode, "theme_system"),
                              mode: ThemeMode.system,
                              currentMode: settings.themeMode,
                              activeColor: activeColor,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildThemeOption(
                              context: context,
                              label: _getTranslation(settings.languageCode, "theme_light"),
                              mode: ThemeMode.light,
                              currentMode: settings.themeMode,
                              activeColor: activeColor,
                              isDark: isDark,
                            ),
                            const SizedBox(width: 8),
                            _buildThemeOption(
                              context: context,
                              label: _getTranslation(settings.languageCode, "theme_dark"),
                              mode: ThemeMode.dark,
                              currentMode: settings.themeMode,
                              activeColor: activeColor,
                              isDark: isDark,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  // Accent Color Selector
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTranslation(settings.languageCode, "accent_color"),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildColorOption(context, const Color(0xFF0A5C5A), settings.accentColor, "Teal"),
                            _buildColorOption(context, Colors.blue.shade700, settings.accentColor, "Blue"),
                            _buildColorOption(context, Colors.green.shade700, settings.accentColor, "Green"),
                            _buildColorOption(context, Colors.indigo.shade700, settings.accentColor, "Indigo"),
                            _buildColorOption(context, Colors.purple.shade700, settings.accentColor, "Purple"),
                            _buildColorOption(context, Colors.orange.shade700, settings.accentColor, "Orange"),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  // Font Size Settings
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getTranslation(settings.languageCode, "font_size"),
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isDark ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _buildSizeOption(context, "Small", settings.textSize, activeColor, isDark),
                            const SizedBox(width: 8),
                            _buildSizeOption(context, "Medium", settings.textSize, activeColor, isDark),
                            const SizedBox(width: 8),
                            _buildSizeOption(context, "Large", settings.textSize, activeColor, isDark),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 2. ACCESSIBILITY & AUDIO SECTION
              _buildSectionHeader(
                _getTranslation(settings.languageCode, "sec_accessibility"),
                activeColor,
              ),
              _buildSectionCard(
                context,
                isDark,
                [
                  // Language Selection
                  ListTile(
                    leading: const Icon(Icons.language),
                    title: Text(
                      _getTranslation(settings.languageCode, "app_language"),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _getLanguageLabel(settings.languageCode),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    trailing: DropdownButton<String>(
                      value: settings.languageCode,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down),
                      items: const [
                        DropdownMenuItem(value: 'en', child: Text("English")),
                        DropdownMenuItem(value: 'hi', child: Text("हिंदी (Hindi)")),
                        DropdownMenuItem(value: 'mr', child: Text("मराठी (Marathi)")),
                        DropdownMenuItem(value: 'es', child: Text("Español (Spanish)")),
                      ],
                      onChanged: (lang) {
                        if (lang != null) {
                          settings.setLanguage(lang);
                        }
                      },
                    ),
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  // Voice Assistant Guidance (TTS)
                  SwitchListTile(
                    secondary: const Icon(Icons.volume_up_rounded),
                    title: Text(
                      _getTranslation(settings.languageCode, "voice_guidance"),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _getTranslation(settings.languageCode, "voice_guidance_desc"),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    value: settings.voiceGuidance,
                    onChanged: (val) => settings.setVoiceGuidance(val),
                    activeColor: activeColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 3. HARDWARE & NOTIFICATIONS
              _buildSectionHeader(
                _getTranslation(settings.languageCode, "sec_system"),
                activeColor,
              ),
              _buildSectionCard(
                context,
                isDark,
                [
                  // Notifications Switch
                  SwitchListTile(
                    secondary: const Icon(Icons.notifications_active_outlined),
                    title: Text(
                      _getTranslation(settings.languageCode, "push_notifications"),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _getTranslation(settings.languageCode, "push_notifications_desc"),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    value: settings.notificationsEnabled,
                    onChanged: (val) => settings.setNotificationsEnabled(val),
                    activeColor: activeColor,
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  // Vibration Feedback Switch
                  SwitchListTile(
                    secondary: const Icon(Icons.vibration),
                    title: Text(
                      _getTranslation(settings.languageCode, "vibration_feedback"),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _getTranslation(settings.languageCode, "vibration_feedback_desc"),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    value: settings.vibrationFeedback,
                    onChanged: (val) => settings.setVibrationFeedback(val),
                    activeColor: activeColor,
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 4. PRIVACY & SECURITY
              _buildSectionHeader(
                _getTranslation(settings.languageCode, "sec_security"),
                activeColor,
              ),
              _buildSectionCard(
                context,
                isDark,
                [
                  ListTile(
                    leading: const Icon(Icons.lock_reset_outlined),
                    title: Text(
                      _getTranslation(settings.languageCode, "change_password"),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      _showInfoSnackbar(
                        context,
                        _getTranslation(settings.languageCode, "feature_coming_soon"),
                      );
                    },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  ListTile(
                    leading: const Icon(Icons.security_outlined),
                    title: Text(
                      _getTranslation(settings.languageCode, "privacy_policy"),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () {
                      _showPrivacyPolicyDialog(context, settings.languageCode);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // 5. MAINTENANCE & ADVANCED
              _buildSectionHeader(
                _getTranslation(settings.languageCode, "sec_advanced"),
                activeColor,
              ),
              _buildSectionCard(
                context,
                isDark,
                [
                  // Clear Cache Button
                  ListTile(
                    leading: _clearingCache
                        ? SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
                            ),
                          )
                        : const Icon(Icons.delete_sweep_outlined),
                    title: Text(
                      _getTranslation(settings.languageCode, "clear_cache"),
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      _getTranslation(settings.languageCode, "clear_cache_desc"),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    onTap: _clearingCache
                        ? null
                        : () async {
                            setState(() => _clearingCache = true);
                            await settings.clearCache(context);
                            setState(() => _clearingCache = false);
                            if (context.mounted) {
                              _showSuccessSnackbar(
                                context,
                                _getTranslation(settings.languageCode, "cache_cleared_success"),
                              );
                            }
                          },
                  ),
                  const Divider(height: 1, indent: 16, endIndent: 16),
                  // Reset Settings Button
                  ListTile(
                    leading: const Icon(Icons.restore, color: Colors.red),
                    title: Text(
                      _getTranslation(settings.languageCode, "reset_defaults"),
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                    subtitle: Text(
                      _getTranslation(settings.languageCode, "reset_defaults_desc"),
                      style: GoogleFonts.poppins(fontSize: 12),
                    ),
                    onTap: () {
                      _showResetConfirmationDialog(context, settings);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Bottom Attribution/Version Info
              Center(
                child: Text(
                  "DrugSure Medicine Validation App\nVersion 1.0.0 (Final Year Project)",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Visual option builders
  Widget _buildThemeOption({
    required BuildContext context,
    required String label,
    required ThemeMode mode,
    required ThemeMode currentMode,
    required Color activeColor,
    required bool isDark,
  }) {
    final isSelected = mode == currentMode;
    return Expanded(
      child: GestureDetector(
        onTap: () => Provider.of<SettingsProvider>(context, listen: false).setThemeMode(mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor
                : (isDark ? Colors.grey.shade900 : Colors.grey.shade100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? activeColor
                  : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
              color: isSelected
                  ? Colors.white
                  : (isDark ? Colors.grey.shade300 : Colors.grey.shade700),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(BuildContext context, Color color, Color currentColor, String name) {
    final isSelected = color.value == currentColor.value;
    return Padding(
      padding: const EdgeInsets.only(right: 12.0),
      child: GestureDetector(
        onTap: () => Provider.of<SettingsProvider>(context, listen: false).setAccentColor(color),
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? Colors.white : Colors.transparent,
              width: 3.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected ? color.withOpacity(0.5) : Colors.black12,
                blurRadius: isSelected ? 8 : 3,
                spreadRadius: isSelected ? 2 : 0,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
      ),
    );
  }

  Widget _buildSizeOption(BuildContext context, String size, String currentSize, Color activeColor, bool isDark) {
    final isSelected = size == currentSize;
    return Expanded(
      child: GestureDetector(
        onTap: () => Provider.of<SettingsProvider>(context, listen: false).setTextSize(size),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? activeColor.withOpacity(0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? activeColor : (isDark ? Colors.grey.shade800 : Colors.grey.shade300),
              width: 1.5,
            ),
          ),
          child: Text(
            size,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? activeColor : (isDark ? Colors.grey.shade400 : Colors.grey.shade700),
              fontSize: size == 'Small' ? 12 : (size == 'Large' ? 16 : 14),
            ),
          ),
        ),
      ),
    );
  }

  // Section styling
  Widget _buildSectionHeader(String title, Color activeColor) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: activeColor,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSectionCard(BuildContext context, bool isDark, List<Widget> children) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? Colors.grey.shade800 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      child: Column(
        children: children,
      ),
    );
  }

  // Snackbars
  void _showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.blue.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins(color: Colors.white)),
        backgroundColor: Colors.green.shade700,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // Dialogs
  void _showResetConfirmationDialog(BuildContext context, SettingsProvider settings) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _getTranslation(settings.languageCode, "reset_confirm_title"),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: Text(
          _getTranslation(settings.languageCode, "reset_confirm_desc"),
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              _getTranslation(settings.languageCode, "cancel"),
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              settings.resetToDefault();
              Navigator.pop(ctx);
              _showSuccessSnackbar(
                context,
                _getTranslation(settings.languageCode, "settings_reset_success"),
              );
            },
            child: Text(
              _getTranslation(settings.languageCode, "reset"),
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, String langCode) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          _getTranslation(langCode, "privacy_policy"),
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "1. Data Privacy",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "DrugSure is a medicine validation app. We process details about medicine verification, reports, and search queries locally or securely in Firebase. We do not sell your personal healthcare data.",
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Text(
                "2. System Permissions",
                style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                "The app requests access to the Camera (for scanning barcodes), Location (for locating nearby pharmacies), and Notifications (for drug warnings/pill reminders). You can revoke these anytime via system settings.",
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              _getTranslation(langCode, "close"),
              style: GoogleFonts.poppins(),
            ),
          ),
        ],
      ),
    );
  }

  // Translation helpers
  String _getLanguageLabel(String code) {
    switch (code) {
      case 'hi':
        return "हिंदी (Hindi)";
      case 'mr':
        return "मराठी (Marathi)";
      case 'es':
        return "Español (Spanish)";
      case 'en':
      default:
        return "English";
    }
  }

  // Simple localized strings map
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'settings_title': 'Settings',
      'sec_visual': 'Visual & Themes',
      'sec_accessibility': 'Accessibility',
      'sec_system': 'Hardware & Alerts',
      'sec_security': 'Security & Info',
      'sec_advanced': 'Maintenance & Defaults',
      'theme_mode': 'Theme Mode',
      'theme_system': 'System',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'accent_color': 'Accent Brand Color',
      'font_size': 'App Font Size',
      'app_language': 'App Language',
      'voice_guidance': 'Voice Guidance (TTS)',
      'voice_guidance_desc': 'Audibly reads validated medicine instructions',
      'push_notifications': 'Push Notifications',
      'push_notifications_desc': 'Get updates on reports and medicine status',
      'vibration_feedback': 'Haptic Vibration',
      'vibration_feedback_desc': 'Vibrate on successful barcode scanner scans',
      'change_password': 'Change Password',
      'privacy_policy': 'Privacy Policy',
      'clear_cache': 'Clear App Cache',
      'clear_cache_desc': 'Delete local search index & cached images',
      'cache_cleared_success': 'App cache cleared successfully!',
      'reset_defaults': 'Reset to Default Settings',
      'reset_defaults_desc': 'Revert all application choices to initial values',
      'reset_confirm_title': 'Reset Settings',
      'reset_confirm_desc': 'Are you sure you want to restore all settings to their factory defaults? This action cannot be undone.',
      'cancel': 'Cancel',
      'reset': 'Reset',
      'close': 'Close',
      'feature_coming_soon': 'This feature is coming soon!',
      'settings_reset_success': 'Settings successfully reset!',
    },
    'hi': {
      'settings_title': 'सेटिंग्स',
      'sec_visual': 'दृश्य और थीम',
      'sec_accessibility': 'सुलभता',
      'sec_system': 'हार्डवेयर और अलर्ट',
      'sec_security': 'सुरक्षा और जानकारी',
      'sec_advanced': 'रखरखाव और डिफ़ॉल्ट',
      'theme_mode': 'थीम मोड',
      'theme_system': 'सिस्टम',
      'theme_light': 'लाइट',
      'theme_dark': 'डार्क',
      'accent_color': 'ब्रांड का रंग',
      'font_size': 'फ़ॉन्ट का आकार',
      'app_language': 'ऐप की भाषा',
      'voice_guidance': 'आवाज मार्गदर्शन',
      'voice_guidance_desc': 'दवा के निर्देशों को बोलकर सुनाता है',
      'push_notifications': 'सूचनाएं (Notifications)',
      'push_notifications_desc': 'दवाओं और रिपोर्ट अपडेट प्राप्त करें',
      'vibration_feedback': 'कंपन (Vibration)',
      'vibration_feedback_desc': 'स्कैनर सफल होने पर कंपन करें',
      'change_password': 'पासवर्ड बदलें',
      'privacy_policy': 'गोपनीयता नीति',
      'clear_cache': 'कैश साफ करें',
      'clear_cache_desc': 'खोज सूचकांक और चित्रों को साफ करें',
      'cache_cleared_success': 'ऐप कैश सफलतापूर्वक साफ हो गया!',
      'reset_defaults': 'डिफ़ॉल्ट सेटिंग्स रीसेट करें',
      'reset_defaults_desc': 'सभी ऐप विकल्पों को मूल मान पर पुनर्स्थापित करें',
      'reset_confirm_title': 'सेटिंग्स रीसेट करें',
      'reset_confirm_desc': 'क्या आप वाकई सेटिंग्स को डिफ़ॉल्ट मान पर वापस लाना चाहते हैं? इसे बदला नहीं जा सकता।',
      'cancel': 'रद्द करें',
      'reset': 'रीसेट',
      'close': 'बंद करें',
      'feature_coming_soon': 'यह सुविधा जल्द ही आ रही है!',
      'settings_reset_success': 'सेटिंग्स सफलतापूर्वक रीसेट हो गईं!',
    },
    'mr': {
      'settings_title': 'सेटिंग्ज',
      'sec_visual': 'थीम आणि देखावा',
      'sec_accessibility': 'सुलभता (Accessibility)',
      'sec_system': 'हार्डवेअर आणि अलर्ट',
      'sec_security': 'सुरक्षा आणि माहिती',
      'sec_advanced': 'प्रगत पर्याय',
      'theme_mode': 'थीम मोड',
      'theme_system': 'सिस्टम',
      'theme_light': 'लाइट',
      'theme_dark': 'डार्क',
      'accent_color': 'ब्रँडचा रंग',
      'font_size': 'फॉन्टचा आकार',
      'app_language': 'अ‍ॅपची भाषा',
      'voice_guidance': 'ध्वनी मार्गदर्शन (TTS)',
      'voice_guidance_desc': 'औषधांच्या सूचना आवाजात ऐकवते',
      'push_notifications': 'सूचना (Notifications)',
      'push_notifications_desc': 'औषधे आणि अहवालांचे अपडेट मिळवा',
      'vibration_feedback': 'कंपन फीडबॅक',
      'vibration_feedback_desc': 'स्कॅनर यशस्वी झाल्यावर कंपन करा',
      'change_password': 'पासवर्ड बदला',
      'privacy_policy': 'गोपनीयता धोरण',
      'clear_cache': 'कॅश साफ करा',
      'clear_cache_desc': 'स्थानिक शोध डेटा आणि चित्रे साफ करा',
      'cache_cleared_success': 'अ‍ॅप कॅश यशस्वीरीत्या साफ केली!',
      'reset_defaults': 'डिफॉल्ट सेटिंग्स रीसेट करा',
      'reset_defaults_desc': 'सर्व पर्याय मूळ मूल्यावर आणा',
      'reset_confirm_title': 'सेटिंग्ज रीसेट करा',
      'reset_confirm_desc': 'तुम्हाला खात्री आहे का की सेटिंग्स मूळ मूल्यावर आणायच्या आहेत?',
      'cancel': 'रद्द करा',
      'reset': 'रीसेट',
      'close': 'बंद करा',
      'feature_coming_soon': 'हे वैशिष्ट्य लवकरच येत आहे!',
      'settings_reset_success': 'सेटिंग्ज यशस्वीरीत्या रीसेट झाल्या!',
    },
    'es': {
      'settings_title': 'Configuración',
      'sec_visual': 'Visual y Temas',
      'sec_accessibility': 'Accesibilidad',
      'sec_system': 'Hardware y Alertas',
      'sec_security': 'Seguridad e Info',
      'sec_advanced': 'Mantenimiento',
      'theme_mode': 'Modo de Tema',
      'theme_system': 'Sistema',
      'theme_light': 'Claro',
      'theme_dark': 'Oscuro',
      'accent_color': 'Color de Acento',
      'font_size': 'Tamaño de Letra',
      'app_language': 'Idioma del App',
      'voice_guidance': 'Guía de Voz (TTS)',
      'voice_guidance_desc': 'Lee en voz alta las instrucciones de la medicina',
      'push_notifications': 'Notificaciones Push',
      'push_notifications_desc': 'Reciba alertas sobre medicinas e informes',
      'vibration_feedback': 'Vibración Háptica',
      'vibration_feedback_desc': 'Vibrar al escanear códigos de barras',
      'change_password': 'Cambiar Contraseña',
      'privacy_policy': 'Política de Privacidad',
      'clear_cache': 'Borrar Caché',
      'clear_cache_desc': 'Borrar el índice de búsqueda y las imágenes',
      'cache_cleared_success': '¡Caché del app borrado con éxito!',
      'reset_defaults': 'Restablecer Configuración',
      'reset_defaults_desc': 'Revertir todas las opciones a los valores iniciales',
      'reset_confirm_title': 'Restablecer Configuración',
      'reset_confirm_desc': '¿Está seguro de que desea restablecer todos los valores por defecto? Esta acción no se puede deshacer.',
      'cancel': 'Cancelar',
      'reset': 'Restablecer',
      'close': 'Cerrar',
      'feature_coming_soon': '¡Esta función estará disponible pronto!',
      'settings_reset_success': '¡Configuración restablecida con éxito!',
    }
  };

  String _getTranslation(String code, String key) {
    final langMap = _localizedStrings[code] ?? _localizedStrings['en']!;
    return langMap[key] ?? _localizedStrings['en']![key] ?? key;
  }
}
