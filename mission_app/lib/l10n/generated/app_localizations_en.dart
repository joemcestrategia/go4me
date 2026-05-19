// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Go4Me';

  @override
  String get appTagline => 'Connecting hearts, transforming nations';

  @override
  String get login => 'Sign In';

  @override
  String get signUp => 'Sign Up';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get forgotPassword => 'Forgot password?';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get hasAccount => 'Already have an account?';

  @override
  String get enterPlatform => 'Sign in to the platform';

  @override
  String stepXofY(Object step, Object total) {
    return 'Step $step of $total';
  }

  @override
  String get continueAction => 'Continue';

  @override
  String get save => 'Save';

  @override
  String get search => 'Search';

  @override
  String get explore => 'Explore';

  @override
  String get feed => 'Feed';

  @override
  String get profile => 'Profile';

  @override
  String get donor => 'Sower';

  @override
  String get missionary => 'Missionary';

  @override
  String get home => 'Home';

  @override
  String get impact => 'My Impact';

  @override
  String get totalDonated => 'Total Donated';

  @override
  String get missions => 'Missions';

  @override
  String get livesReached => 'Lives Reached';

  @override
  String get monthlyGoal => 'Monthly Goal';

  @override
  String get prayerWall => 'Prayer Wall';

  @override
  String get pray => 'Pray';

  @override
  String get praying => 'Praying';

  @override
  String get prayed => 'Prayed';

  @override
  String get prayerRequest => 'Prayer Request';

  @override
  String get writePrayerRequest => 'Write your prayer request...';

  @override
  String get sharePraise => 'Share a praise report...';

  @override
  String get searchMissionaries => 'Search missionaries...';

  @override
  String get allCategories => 'All';

  @override
  String get education => 'Education';

  @override
  String get health => 'Health';

  @override
  String get churchPlanting => 'Church Planting';

  @override
  String get bibleTranslation => 'Bible Translation';

  @override
  String get humanitarian => 'Humanitarian Aid';

  @override
  String get discipleship => 'Discipleship';

  @override
  String get streetOutreach => 'Street Outreach';

  @override
  String get orphans => 'Orphanages';

  @override
  String get waterProject => 'Water Projects';

  @override
  String get urbanMission => 'Urban Mission';

  @override
  String get follow => 'Follow';

  @override
  String get following => 'Following';

  @override
  String get followers => 'followers';

  @override
  String get posts => 'posts';

  @override
  String get emptyFeed => 'No updates yet';

  @override
  String get emptyPrayerWall => 'No prayer requests yet';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get stripeSetup => 'Payment Setup';

  @override
  String get createPost => 'Create Post';

  @override
  String get comment => 'Comment';

  @override
  String get donate => 'Donate';

  @override
  String get donationSuccess => 'Donation Successful!';

  @override
  String get donationSecure => 'Secure payment via Stripe';

  @override
  String get supportMonthly => 'Monthly Support';

  @override
  String get logout => 'Logout';

  @override
  String get cancel => 'Cancel';

  @override
  String get confirm => 'Confirm';
}
