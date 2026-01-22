class AppStrings {
  AppStrings._(); // Private constructor to prevent instantiation

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
  static const String quoteOfTheDay = 'Quote of the Day';

  // Favorites
  static const String noFavoritesYet = 'You have no favorites yet.';

  // Quotes
  static const String dailyQuoteFallback =
      'Discover new quotes powered by Supabase every day.';
  static const String dailyAuthorFallback = 'QuoteVault Daily';
  static const String quoteCopiedToClipboard = 'Quote copied to clipboard';
  static const String share = 'Share';
  static const String favorited = 'Favorited';
  static const String addToFavorites = 'Add to favorites';
  static const String searchHint = 'Search for authors or words';
  static const String unableToLoadQuotes =
      'Unable to load quotes at this time.';
  static const String noQuotesMatchSearch = 'No quotes match your search.';

  // Placeholder pages (until fully implemented)
  static const String collectionsPagePlaceholder = 'Collections Page';
  static const String settingsPagePlaceholder = 'Settings Page';
}
