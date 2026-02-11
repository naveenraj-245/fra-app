import 'package:flutter/material.dart';

class LanguageProvider extends ChangeNotifier {
  // Default language is English
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  // Function to change language and notify the app
  void changeLanguage(String languageCode) {
    _currentLocale = Locale(languageCode);
    notifyListeners();
  }

  // THE BIG DICTIONARY 📖
  String translate(String key) {
    final Map<String, Map<String, String>> localizedValues = {
      // ================= ENGLISH =================
      'en': {
        // Role Selection
        'app_name': 'Satya-Shield',
        'who_are_you': 'Who are you?',
        'select_role': 'Select your role to continue.',
        'dweller': 'Forest Dweller',
        'officer': 'Govt. Officer',
        'ngo': 'NGO / Social Worker',

        // Dashboard
        'good_morning': 'Good Morning,',
        'welcome_back': 'Welcome back to VanAdhikar',
        'quick_actions': 'Quick Actions',
        'claim_status': 'Your Claim Status',
        'notifications': 'Alerts & Notifications',
        'resources': 'Resources',
        
        // Dashboard Tiles
        'apply_rights': 'Apply for Rights',
        'track_status': 'Track Status',
        'file_grievance': 'File Grievance',
        'get_help': 'Get Help',
        
        // Status Cards
        'land_claim': 'Land Claim - Forest Land',
        'forest_produce': 'Forest Produce Permit',
        'status_active': 'Active',
        'status_review': 'Under Review',
        'status_pending': 'Pending',
        'status_approved': 'Approved',

        // Tracking Screen
        'track_title': 'Track Application',
        'step_submitted': 'Application Submitted',
        'step_satellite': 'Satellite Verification (AI)',
        'step_review': 'Official Review (SDLC)',
        'step_approved': 'Final Approval (DLC)',
        'ai_report': 'AI Analysis Report:',
      },

      // ================= TAMIL (தமிழ்) =================
      'ta': {
        // Role Selection
        'app_name': 'சத்யா-ஷீல்ட்',
        'who_are_you': 'நீங்கள் யார்?',
        'select_role': 'தொடர உங்கள் பங்கைத் தேர்ந்தெடுக்கவும்.',
        'dweller': 'வனவாசி',
        'officer': 'அரசு அதிகாரி',
        'ngo': 'சமூக சேவகர்',

        // Dashboard
        'good_morning': 'காலை வணக்கம்,',
        'welcome_back': 'வன அதிகாரிற்கு மீண்டும் வருக',
        'quick_actions': 'விரைவான செயல்கள்',
        'claim_status': 'உங்கள் உரிமைகோரல் நிலை',
        'notifications': 'அறிவிப்புகள்',
        'resources': 'வளங்கள்',

        // Dashboard Tiles
        'apply_rights': 'உரிமை கோருங்கள்',
        'track_status': 'நிலையை கண்காணிக்கவும்',
        'file_grievance': 'புகார் அளிக்கவும்',
        'get_help': 'உதவி பெறுங்கள்',

        // Status Cards
        'land_claim': 'நில உரிமை கோரல்',
        'forest_produce': 'வன விளைபொருள் அனுமதி',
        'status_active': 'செயலில்',
        'status_review': 'மதிப்பாய்வில்',
        'status_pending': 'நிலுவையில்',
        'status_approved': 'ஒப்புதல் அளிக்கப்பட்டது',

        // Tracking Screen
        'track_title': 'விண்ணப்ப தடம்',
        'step_submitted': 'விண்ணப்பம் சமர்ப்பிக்கப்பட்டது',
        'step_satellite': 'செயற்கைக்கோள் சரிபார்ப்பு (AI)',
        'step_review': 'அதிகாரப்பூர்வ ஆய்வு',
        'step_approved': 'இறுதி ஒப்புதல்',
        'ai_report': 'AI ஆய்வு அறிக்கை:',
      },

      // ================= HINDI (हिन्दी) =================
      'hi': {
        // Role Selection
        'app_name': 'सत्या-शील्ड',
        'who_are_you': 'आप कौन हैं?',
        'select_role': 'आगे बढ़ने के लिए अपनी भूमिका चुनें।',
        'dweller': 'वन निवासी',
        'officer': 'सरकारी अधिकारी',
        'ngo': 'एनजीओ / सामाजिक कार्यकर्ता',

        // Dashboard
        'good_morning': 'सुप्रभात,',
        'welcome_back': 'वनअधिकार में आपका स्वागत है',
        'quick_actions': 'त्वरित कार्य',
        'claim_status': 'आपकी दावा स्थिति',
        'notifications': 'सूचनाएं',
        'resources': 'संसाधन',

        // Dashboard Tiles
        'apply_rights': 'अधिकारों के लिए आवेदन',
        'track_status': 'स्थिति ट्रैक करें',
        'file_grievance': 'शिकायत दर्ज करें',
        'get_help': 'मदद प्राप्त करें',

        // Status Cards
        'land_claim': 'भूमि दावा - वन भूमि',
        'forest_produce': 'वन उपज परमिट',
        'status_active': 'सक्रिय',
        'status_review': 'समीक्षा के अंतर्गत',
        'status_pending': 'लंबित',
        'status_approved': 'स्वीकृत',

        // Tracking Screen
        'track_title': 'आवेदन ट्रैक करें',
        'step_submitted': 'आवेदन जमा किया गया',
        'step_satellite': 'उपग्रह सत्यापन (AI)',
        'step_review': 'अधिकारी समीक्षा',
        'step_approved': 'अंतिम अनुमोदन',
        'ai_report': 'AI विश्लेषण रिपोर्ट:',
      }
    };

    // Return the translation or the key itself if not found
    return localizedValues[_currentLocale.languageCode]?[key] ?? key;
  }
}
