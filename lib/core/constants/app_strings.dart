class AppStrings {
  AppStrings._();

  // Auth strings
  static const String createAccount = 'Create Account';
  static const String createAccountDescription =
      'Join QuoteVault to start your personal collection of wisdom.';
  static const String fullName = 'Full Name';
  static const String fullNamePlaceholder = 'Enter your full name';
  static const String emailAddress = 'Email Address';
  static const String emailPlaceholder = 'name@example.com';
  static const String password = 'Password';
  static const String passwordPlaceholder = 'Create a password';
  static const String confirmPassword = 'Confirm Password';
  static const String confirmPasswordPlaceholder = 'Confirm your password';
  static const String signUp = 'Sign Up';
  static const String alreadyHaveAccount = 'Already have an account?';
  static const String logIn = 'Log in';
  static const String login = 'Login';
  static const String welcomeBack = 'Welcome Back';
  static const String signInToAccount = 'Sign in to your account';
  static const String forgotPassword = 'Forgot Password?';
  static const String forgotPasswordDescription =
      "Enter the email address associated with your account and we'll send you a link to reset your password.";
  static const String sendResetLink = 'Send Reset Link';
  static const String rememberedIt = 'Remembered it?';
  static const String backToLogin = 'Back to Login';
  static const String dontHaveAccount = "Don't have an account?";
  static const String joinQuoteVault = 'Join QuoteVault';
  static const String passwordPlaceholderLogin = 'Enter your password';
  static const String logout = 'Logout';
  static const String logoutConfirmTitle = 'Log out?';
  static const String logoutConfirmMessage =
      'Are you sure you want to log out?';
  static const String cancel = 'Cancel';
  static const String resetPassword = 'Reset Password';
  static const String resetPasswordDescription =
      'Enter your new password below to complete the reset process.';
  static const String newPassword = 'New Password';
  static const String newPasswordPlaceholder = 'Enter your new password';
  static const String confirmNewPassword = 'Confirm New Password';
  static const String confirmNewPasswordPlaceholder =
      'Confirm your new password';
  static const String resetPasswordButton = 'Reset Password';

  // App name
  static const String appName = 'QuoteVault';

  // Bottom navigation
  static const String navHome = 'Home';
  static const String navFavorites = 'Favorites';
  static const String navCollections = 'Collections';
  static const String navSettings = 'Settings';

  // Common UI
  static const String somethingWentWrong = 'Something went wrong.';
  static const String loading = 'Loading…';
  static const String retry = 'Retry';
  static const String refreshedSuccessfully = 'Refreshed Successfully.';
  static const String youReachedTheEnd = 'You reached the end.';
  static const String quoteOfTheDay = 'Quote of the Day';
  static const String dailyReminders = 'DAILY REMINDERS';
  static const String appearance = 'APPEARANCE';
  static const String darkMode = 'Dark Mode';
  static const String accentColor = 'Accent Color';
  static const String fontSize = 'Font Size';
  static const String notificationTime = 'Notification Time';
  static const String defaultNotificationTime = '08:30 AM';

  // Settings (non-UI keys)
  static const String accentKeyTeal = 'teal';
  static const String accentKeyRed = 'red';
  static const String accentKeyIndigo = 'indigo';

  // Favorites
  static const String noFavouritesFound = 'No Favourites found';
  static const String failedToLoadFavourites = 'Failed to load favourites';

  // Quotes
  static const String createQuote = 'Create Quote';
  static const String dailyQuoteFallback =
      'Discover new quotes powered by Supabase every day.';
  static const String dailyAuthorFallback = 'QuoteVault Daily';
  static const String quoteCopiedToClipboard = 'Quote copied to clipboard';
  static const String share = 'Share';
  static const String shareSubject = 'Quote';
  static const String shareModeText = 'Text';
  static const String shareModeImage = 'Image';
  static const String shareTextButton = 'Share Text';
  static const String shareImageButton = 'Share Image';
  static const String saveImageButton = 'Save';
  static const String shareStyleLabel = 'Style';
  static const String shareSuccess = 'Quote shared successfully';
  static const String saveSuccess = 'Saved to gallery';
  static const String permissionDeniedMessage =
      'Permission denied. Please allow Photos/Storage permission in Settings and try again.';
  static const String saveFailedMessage = 'Could not save image to gallery.';

  // Notifications
  static const String dailyQuoteReminder = 'Daily quote reminder';
  static const String dailyQuoteReminderSubtitle =
      'Get a quote notification every day';
  static const String notificationTimeSaved = 'Notification time saved';
  static const String notificationsPermissionDenied =
      'Notifications permission denied.';
  static const String notificationScheduleFailed =
      'Could not schedule notifications. Please try again.';
  static const String dailyQuoteNotificationFallbackBody =
      'Open QuoteVault for today’s quote.';

  static const String quoteStyleGradient = 'Gradient';
  static const String quoteStyleBordered = 'Bordered';
  static const String quoteStyleMinimal = 'Minimal';
  static const String favorited = 'Favorited';
  static const String addToFavorites = 'Add to favorites';
  static const String searchHint = 'Search for authors or words';
  static const String unableToLoadQuotes =
      'Unable to load quotes at this time.';
  static const String noQuotesMatchSearch = 'No quotes match your search.';

  // Profile
  static const String profile = 'Profile';
  static const String user = 'User';
  static const String addProfilePicture = 'Add profile picture';
  static const String changeProfilePicture = 'Change profile picture';
  static const String profilePictureUpdated = 'Profile picture updated.';
  static const String unableToUpdatePicture = 'Unable to update picture.';

  // Collections
  static const String addToCollection = 'Add to Collection';
  static const String createNewCollection = 'Create New Collection';
  static const String collectionName = 'Collection name';
  static const String create = 'Create';
  static const String creating = 'Creating...';
  static const String yourCollections = 'Your Collections';
  static const String noCollectionsYet = 'No collections yet.';
  static const String noCollectionsYetCreateOne =
      'No collections yet. Create one above.';
  static const String noQuotesAddedYet = 'No quotes added yet';
  static const String removedFromCollection = 'Removed from collection';

  // Placeholder pages (until fully implemented)
  static const String settingsPagePlaceholder = 'Settings Page';
}
