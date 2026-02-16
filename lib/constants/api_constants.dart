class ApiConstants {
  static const String baseUrl = 'https://nirvista-backend-n8io.onrender.com';

  // Admin auth
  static const String adminSignup = '$baseUrl/api/admin/auth/signup';
  static const String adminLoginOtpInit = '$baseUrl/api/admin/auth/login/otp-init';
  static const String adminLoginOtpVerify =
      '$baseUrl/api/admin/auth/login/otp-verify';

  // Admin core
  static const String adminStats = '$baseUrl/api/admin/stats';
  static const String adminUsersCount = '$baseUrl/api/admin/users/count';
  static const String adminUsersLatest = '$baseUrl/api/admin/users/latest';
  static const String adminIcoPrice = '$baseUrl/api/admin/ico/price';
  static const String adminUsers = '$baseUrl/api/admin/users';
  static const String adminUsersDetails = '$baseUrl/api/admin/users/details';
  static const String adminKyc = '$baseUrl/api/admin/kyc';
  static const String adminIcoTransactions = '$baseUrl/api/admin/ico/transactions';
  static const String adminTransactionsRecent =
      '$baseUrl/api/admin/transactions/recent';
  static const String adminReferralsEarnings =
      '$baseUrl/api/admin/referrals/earnings';
  static const String adminReferralsSearch = '$baseUrl/api/admin/referrals/search';
  static const String adminBankRequests = '$baseUrl/api/admin/bank/requests';
  static const String adminMobileRequests = '$baseUrl/api/admin/mobile/requests';
  static const String adminWalletTransactions =
      '$baseUrl/api/admin/wallet/transactions';
  static const String adminNotifications = '$baseUrl/api/admin/notifications';
  static const String adminCategories = '$baseUrl/api/admin/categories';
  static const String adminProducts = '$baseUrl/api/admin/products';

  // Additional admin outside /api/admin
  static const String walletAdminTransactions =
      '$baseUrl/api/wallet/admin/transactions';
  static const String ordersAdmin = '$baseUrl/api/orders/admin';

  static String adminUserById(String id) => '$baseUrl/api/admin/users/$id';

  static String adminUserStatusById(String id) =>
      '$baseUrl/api/admin/users/$id/status';

  static String adminUserEmailById(String id) => '$baseUrl/api/admin/users/$id/email';

  static String adminUserPinById(String id) => '$baseUrl/api/admin/users/$id/pin';

  static String adminKycById(String kycId) => '$baseUrl/api/admin/kyc/$kycId';

  static String adminKycStatusById(String kycId) =>
      '$baseUrl/api/admin/kyc/$kycId/status';

  static String adminReferralsEarningById(String id) =>
      '$baseUrl/api/admin/referrals/earnings/$id';

  static String adminReferralsTreeByUserId(String userId) =>
      '$baseUrl/api/admin/referrals/tree/$userId';

  static String adminBankRequestById(String id) =>
      '$baseUrl/api/admin/bank/requests/$id';

  static String adminMobileRequestById(String id) =>
      '$baseUrl/api/admin/mobile/requests/$id';

  static String adminWalletTransactionById(String transactionId) =>
      '$baseUrl/api/admin/wallet/transactions/$transactionId';

  static String adminCategoryById(String id) => '$baseUrl/api/admin/categories/$id';

  static String adminProductById(String id) => '$baseUrl/api/admin/products/$id';

  static String walletAdminTransactionById(String transactionId) =>
      '$baseUrl/api/wallet/admin/transactions/$transactionId';

  static String ordersAdminById(String id) => '$baseUrl/api/orders/admin/$id';

  static String kycStatusById(String kycId) => '$baseUrl/api/kyc/$kycId/status';
}
