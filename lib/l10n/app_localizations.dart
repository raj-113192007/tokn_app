import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
  ];

  /// The title of the settings page
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for the language selection option
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Title of the language selection dialog
  ///
  /// In en, this message translates to:
  /// **'Select Language'**
  String get selectLanguage;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @hindi.
  ///
  /// In en, this message translates to:
  /// **'Hindi'**
  String get hindi;

  /// No description provided for @biometricLogin.
  ///
  /// In en, this message translates to:
  /// **'Biometric Login'**
  String get biometricLogin;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Turn on Reminders'**
  String get reminders;

  /// No description provided for @editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// No description provided for @manageFamily.
  ///
  /// In en, this message translates to:
  /// **'Manage Family Members'**
  String get manageFamily;

  /// No description provided for @helpCenter.
  ///
  /// In en, this message translates to:
  /// **'Help Center'**
  String get helpCenter;

  /// No description provided for @aboutTokn.
  ///
  /// In en, this message translates to:
  /// **'About TokN'**
  String get aboutTokn;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @completeProfile.
  ///
  /// In en, this message translates to:
  /// **'Complete Profile'**
  String get completeProfile;

  /// No description provided for @medicalRecords.
  ///
  /// In en, this message translates to:
  /// **'MEDICAL RECORDS'**
  String get medicalRecords;

  /// No description provided for @finalizeIdentity.
  ///
  /// In en, this message translates to:
  /// **'Finalize your clinical identity.'**
  String get finalizeIdentity;

  /// No description provided for @accurateInfoDesc.
  ///
  /// In en, this message translates to:
  /// **'Accurate information helps our specialists provide better care tailored to your specific needs.'**
  String get accurateInfoDesc;

  /// No description provided for @age.
  ///
  /// In en, this message translates to:
  /// **'Age'**
  String get age;

  /// No description provided for @bloodGroup.
  ///
  /// In en, this message translates to:
  /// **'Blood Group'**
  String get bloodGroup;

  /// No description provided for @houseNo.
  ///
  /// In en, this message translates to:
  /// **'House / Building No.'**
  String get houseNo;

  /// No description provided for @district.
  ///
  /// In en, this message translates to:
  /// **'District'**
  String get district;

  /// No description provided for @pinCode.
  ///
  /// In en, this message translates to:
  /// **'Pin Code'**
  String get pinCode;

  /// No description provided for @state.
  ///
  /// In en, this message translates to:
  /// **'State'**
  String get state;

  /// No description provided for @country.
  ///
  /// In en, this message translates to:
  /// **'Country'**
  String get country;

  /// No description provided for @privacyNotice.
  ///
  /// In en, this message translates to:
  /// **'This information will be visible to authorized medical staff only. Please ensure all details are verified against your official ID.'**
  String get privacyNotice;

  /// No description provided for @saveProfile.
  ///
  /// In en, this message translates to:
  /// **'Save Profile'**
  String get saveProfile;

  /// No description provided for @familyMembersTitle.
  ///
  /// In en, this message translates to:
  /// **'Family Members'**
  String get familyMembersTitle;

  /// No description provided for @careCircle.
  ///
  /// In en, this message translates to:
  /// **'Your Care Circle'**
  String get careCircle;

  /// No description provided for @careCircleDesc.
  ///
  /// In en, this message translates to:
  /// **'Manage healthcare access and booking permissions for your registered family members.'**
  String get careCircleDesc;

  /// No description provided for @addFamilyMember.
  ///
  /// In en, this message translates to:
  /// **'Add Family Member'**
  String get addFamilyMember;

  /// No description provided for @privacyAndConsent.
  ///
  /// In en, this message translates to:
  /// **'Privacy & Consent'**
  String get privacyAndConsent;

  /// No description provided for @privacyDesc.
  ///
  /// In en, this message translates to:
  /// **'By adding a family member, you confirm that you have obtained their consent to manage their healthcare records. All data is encrypted and handled according to clinical privacy standards.'**
  String get privacyDesc;

  /// No description provided for @viewDataPolicy.
  ///
  /// In en, this message translates to:
  /// **'View Data Policy'**
  String get viewDataPolicy;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @editProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfileTitle;

  /// No description provided for @personalInfo.
  ///
  /// In en, this message translates to:
  /// **'Personal Information'**
  String get personalInfo;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @emailAddress.
  ///
  /// In en, this message translates to:
  /// **'Email Address'**
  String get emailAddress;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @updateProfile.
  ///
  /// In en, this message translates to:
  /// **'Update Profile'**
  String get updateProfile;

  /// No description provided for @mother.
  ///
  /// In en, this message translates to:
  /// **'Mother'**
  String get mother;

  /// No description provided for @spouse.
  ///
  /// In en, this message translates to:
  /// **'Spouse'**
  String get spouse;

  /// No description provided for @child.
  ///
  /// In en, this message translates to:
  /// **'Child'**
  String get child;

  /// No description provided for @bookingAccess.
  ///
  /// In en, this message translates to:
  /// **'Booking Access'**
  String get bookingAccess;

  /// No description provided for @limitedAccess.
  ///
  /// In en, this message translates to:
  /// **'Limited Access'**
  String get limitedAccess;

  /// No description provided for @addFamilyMemberTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Family Member'**
  String get addFamilyMemberTitle;

  /// No description provided for @newProfile.
  ///
  /// In en, this message translates to:
  /// **'NEW PROFILE'**
  String get newProfile;

  /// No description provided for @addMore.
  ///
  /// In en, this message translates to:
  /// **'+ ADD MORE'**
  String get addMore;

  /// No description provided for @expandCareCircle.
  ///
  /// In en, this message translates to:
  /// **'Expand your care circle.'**
  String get expandCareCircle;

  /// No description provided for @expandCareCircleDesc.
  ///
  /// In en, this message translates to:
  /// **'Connect your family members to streamline medical appointments and token bookings.'**
  String get expandCareCircleDesc;

  /// No description provided for @gender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// No description provided for @enableBookingAccess.
  ///
  /// In en, this message translates to:
  /// **'Enable Booking Access'**
  String get enableBookingAccess;

  /// No description provided for @enableBookingAccessDesc.
  ///
  /// In en, this message translates to:
  /// **'Allow this member to book tokens and manage their own medical appointments within the app.'**
  String get enableBookingAccessDesc;

  /// No description provided for @saveMember.
  ///
  /// In en, this message translates to:
  /// **'Save Member'**
  String get saveMember;

  /// No description provided for @addAnotherMember.
  ///
  /// In en, this message translates to:
  /// **'Add Another Member'**
  String get addAnotherMember;

  /// No description provided for @termsOfServiceAgreement.
  ///
  /// In en, this message translates to:
  /// **'By adding a member, you agree to our Terms of Service.'**
  String get termsOfServiceAgreement;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @years.
  ///
  /// In en, this message translates to:
  /// **'Years'**
  String get years;

  /// No description provided for @hospitalWallet.
  ///
  /// In en, this message translates to:
  /// **'Hospital Wallet'**
  String get hospitalWallet;

  /// No description provided for @viewHistory.
  ///
  /// In en, this message translates to:
  /// **'View History'**
  String get viewHistory;

  /// No description provided for @availableBalance.
  ///
  /// In en, this message translates to:
  /// **'AVAILABLE BALANCE'**
  String get availableBalance;

  /// No description provided for @addMoney.
  ///
  /// In en, this message translates to:
  /// **'Add Money'**
  String get addMoney;

  /// No description provided for @recentTransactions.
  ///
  /// In en, this message translates to:
  /// **'RECENT TRANSACTIONS'**
  String get recentTransactions;

  /// No description provided for @emergencyContact.
  ///
  /// In en, this message translates to:
  /// **'Emergency Contact'**
  String get emergencyContact;

  /// No description provided for @deleteAccount.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteAccount;

  /// No description provided for @deleteConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get deleteConfirmTitle;

  /// No description provided for @deleteConfirmDesc.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to permanently delete your account? This action cannot be undone.'**
  String get deleteConfirmDesc;

  /// No description provided for @verifyOTP.
  ///
  /// In en, this message translates to:
  /// **'Verify OTP'**
  String get verifyOTP;

  /// No description provided for @enterOTP.
  ///
  /// In en, this message translates to:
  /// **'Enter 6-digit OTP sent to your phone'**
  String get enterOTP;

  /// No description provided for @sendOTP.
  ///
  /// In en, this message translates to:
  /// **'Send OTP'**
  String get sendOTP;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
