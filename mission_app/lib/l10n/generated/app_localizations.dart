import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('es'),
    Locale('pt'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'Go4Me'**
  String get appTitle;

  /// No description provided for @appTagline.
  ///
  /// In pt, this message translates to:
  /// **'Conectando corações, transformando nações'**
  String get appTagline;

  /// No description provided for @login.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get login;

  /// No description provided for @signUp.
  ///
  /// In pt, this message translates to:
  /// **'Cadastrar'**
  String get signUp;

  /// No description provided for @email.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get email;

  /// No description provided for @password.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueceu a senha?'**
  String get forgotPassword;

  /// No description provided for @noAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tem uma conta?'**
  String get noAccount;

  /// No description provided for @hasAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tem uma conta?'**
  String get hasAccount;

  /// No description provided for @enterPlatform.
  ///
  /// In pt, this message translates to:
  /// **'Entre na plataforma'**
  String get enterPlatform;

  /// No description provided for @stepXofY.
  ///
  /// In pt, this message translates to:
  /// **'Passo {step} de {total}'**
  String stepXofY(Object step, Object total);

  /// No description provided for @continueAction.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueAction;

  /// No description provided for @save.
  ///
  /// In pt, this message translates to:
  /// **'Salvar'**
  String get save;

  /// No description provided for @search.
  ///
  /// In pt, this message translates to:
  /// **'Buscar'**
  String get search;

  /// No description provided for @explore.
  ///
  /// In pt, this message translates to:
  /// **'Explorar'**
  String get explore;

  /// No description provided for @feed.
  ///
  /// In pt, this message translates to:
  /// **'Feed'**
  String get feed;

  /// No description provided for @profile.
  ///
  /// In pt, this message translates to:
  /// **'Perfil'**
  String get profile;

  /// No description provided for @donor.
  ///
  /// In pt, this message translates to:
  /// **'Semeador'**
  String get donor;

  /// No description provided for @missionary.
  ///
  /// In pt, this message translates to:
  /// **'Missionário'**
  String get missionary;

  /// No description provided for @home.
  ///
  /// In pt, this message translates to:
  /// **'Início'**
  String get home;

  /// No description provided for @impact.
  ///
  /// In pt, this message translates to:
  /// **'Meu Impacto'**
  String get impact;

  /// No description provided for @totalDonated.
  ///
  /// In pt, this message translates to:
  /// **'Total Doado'**
  String get totalDonated;

  /// No description provided for @missions.
  ///
  /// In pt, this message translates to:
  /// **'Missões'**
  String get missions;

  /// No description provided for @livesReached.
  ///
  /// In pt, this message translates to:
  /// **'Vidas Alcançadas'**
  String get livesReached;

  /// No description provided for @monthlyGoal.
  ///
  /// In pt, this message translates to:
  /// **'Meta Mensal'**
  String get monthlyGoal;

  /// No description provided for @prayerWall.
  ///
  /// In pt, this message translates to:
  /// **'Mural de Oração'**
  String get prayerWall;

  /// No description provided for @pray.
  ///
  /// In pt, this message translates to:
  /// **'Orar'**
  String get pray;

  /// No description provided for @praying.
  ///
  /// In pt, this message translates to:
  /// **'Orando'**
  String get praying;

  /// No description provided for @prayed.
  ///
  /// In pt, this message translates to:
  /// **'Já orei'**
  String get prayed;

  /// No description provided for @prayerRequest.
  ///
  /// In pt, this message translates to:
  /// **'Pedido de Oração'**
  String get prayerRequest;

  /// No description provided for @writePrayerRequest.
  ///
  /// In pt, this message translates to:
  /// **'Escreva seu pedido de oração...'**
  String get writePrayerRequest;

  /// No description provided for @sharePraise.
  ///
  /// In pt, this message translates to:
  /// **'Compartilhe uma gratidão...'**
  String get sharePraise;

  /// No description provided for @searchMissionaries.
  ///
  /// In pt, this message translates to:
  /// **'Buscar missionários...'**
  String get searchMissionaries;

  /// No description provided for @allCategories.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get allCategories;

  /// No description provided for @education.
  ///
  /// In pt, this message translates to:
  /// **'Educação'**
  String get education;

  /// No description provided for @health.
  ///
  /// In pt, this message translates to:
  /// **'Saúde'**
  String get health;

  /// No description provided for @churchPlanting.
  ///
  /// In pt, this message translates to:
  /// **'Plantação de Igrejas'**
  String get churchPlanting;

  /// No description provided for @bibleTranslation.
  ///
  /// In pt, this message translates to:
  /// **'Tradução Bíblica'**
  String get bibleTranslation;

  /// No description provided for @humanitarian.
  ///
  /// In pt, this message translates to:
  /// **'Ajuda Humanitária'**
  String get humanitarian;

  /// No description provided for @discipleship.
  ///
  /// In pt, this message translates to:
  /// **'Discipulado'**
  String get discipleship;

  /// No description provided for @streetOutreach.
  ///
  /// In pt, this message translates to:
  /// **'Missão de Rua'**
  String get streetOutreach;

  /// No description provided for @orphans.
  ///
  /// In pt, this message translates to:
  /// **'Orfanatos'**
  String get orphans;

  /// No description provided for @waterProject.
  ///
  /// In pt, this message translates to:
  /// **'Projetos de Água'**
  String get waterProject;

  /// No description provided for @urbanMission.
  ///
  /// In pt, this message translates to:
  /// **'Missão Urbana'**
  String get urbanMission;

  /// No description provided for @follow.
  ///
  /// In pt, this message translates to:
  /// **'Seguir'**
  String get follow;

  /// No description provided for @following.
  ///
  /// In pt, this message translates to:
  /// **'Seguindo'**
  String get following;

  /// No description provided for @followers.
  ///
  /// In pt, this message translates to:
  /// **'seguidores'**
  String get followers;

  /// No description provided for @posts.
  ///
  /// In pt, this message translates to:
  /// **'posts'**
  String get posts;

  /// No description provided for @emptyFeed.
  ///
  /// In pt, this message translates to:
  /// **'Nenhuma novidade ainda'**
  String get emptyFeed;

  /// No description provided for @emptyPrayerWall.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum pedido de oração ainda'**
  String get emptyPrayerWall;

  /// No description provided for @editProfile.
  ///
  /// In pt, this message translates to:
  /// **'Editar Perfil'**
  String get editProfile;

  /// No description provided for @stripeSetup.
  ///
  /// In pt, this message translates to:
  /// **'Configurar Pagamentos'**
  String get stripeSetup;

  /// No description provided for @createPost.
  ///
  /// In pt, this message translates to:
  /// **'Criar Post'**
  String get createPost;

  /// No description provided for @comment.
  ///
  /// In pt, this message translates to:
  /// **'Comentar'**
  String get comment;

  /// No description provided for @donate.
  ///
  /// In pt, this message translates to:
  /// **'Doar'**
  String get donate;

  /// No description provided for @donationSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Doação Realizada!'**
  String get donationSuccess;

  /// No description provided for @donationSecure.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento seguro via Stripe'**
  String get donationSecure;

  /// No description provided for @supportMonthly.
  ///
  /// In pt, this message translates to:
  /// **'Suporte Mensal'**
  String get supportMonthly;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get logout;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @confirm.
  ///
  /// In pt, this message translates to:
  /// **'Confirmar'**
  String get confirm;
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
      <String>['en', 'es', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
