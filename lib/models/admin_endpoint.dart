import '../constants/api_constants.dart';

class AdminEndpoint {
  const AdminEndpoint({
    required this.title,
    required this.method,
    required this.path,
    this.requiresAuth = true,
    this.defaultPathVars = '{}',
    this.defaultQuery = '{}',
    this.defaultBody = '{}',
  });

  final String title;
  final String method;
  final String path;
  final bool requiresAuth;
  final String defaultPathVars;
  final String defaultQuery;
  final String defaultBody;
}

const List<AdminEndpoint> adminEndpoints = [
  AdminEndpoint(
    title: 'Admin Signup',
    method: 'POST',
    path: ApiConstants.adminSignup,
    requiresAuth: false,
    defaultBody:
        '{"name":"Admin User","email":"admin@example.com","mobile":"9999999999","password":"Password@123"}',
  ),
  AdminEndpoint(
    title: 'Admin Login OTP Init',
    method: 'POST',
    path: ApiConstants.adminLoginOtpInit,
    requiresAuth: false,
    defaultBody: '{"identifier":"admin@example.com"}',
  ),
  AdminEndpoint(
    title: 'Admin Login OTP Verify',
    method: 'POST',
    path: ApiConstants.adminLoginOtpVerify,
    requiresAuth: false,
    defaultBody: '{"identifier":"admin@example.com","otp":"123456"}',
  ),
  AdminEndpoint(title: 'Admin Stats', method: 'GET', path: ApiConstants.adminStats),
  AdminEndpoint(
      title: 'Admin Total Users', method: 'GET', path: ApiConstants.adminUsersCount),
  AdminEndpoint(
      title: 'Admin Latest Users', method: 'GET', path: ApiConstants.adminUsersLatest),
  AdminEndpoint(title: 'Admin ICO Price Get', method: 'GET', path: ApiConstants.adminIcoPrice),
  AdminEndpoint(
    title: 'Admin ICO Price Update',
    method: 'POST',
    path: ApiConstants.adminIcoPrice,
    defaultBody: '{"price": 1.2}',
  ),
  AdminEndpoint(title: 'Admin Users List', method: 'GET', path: ApiConstants.adminUsers),
  AdminEndpoint(
      title: 'Admin Users Details', method: 'GET', path: ApiConstants.adminUsersDetails),
  AdminEndpoint(
    title: 'Admin User + KYC + Wallet Snapshot',
    method: 'GET',
    path: '${ApiConstants.baseUrl}/api/admin/users/:id',
    defaultPathVars: '{"id":"userId"}',
  ),
  AdminEndpoint(
    title: 'Admin Update User Status',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/admin/users/:id/status',
    defaultPathVars: '{"id":"userId"}',
    defaultBody: '{"status":"active"}',
  ),
  AdminEndpoint(
    title: 'Admin Update User Email',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/admin/users/:id/email',
    defaultPathVars: '{"id":"userId"}',
    defaultBody: '{"email":"new@example.com"}',
  ),
  AdminEndpoint(
    title: 'Admin Update User PIN',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/admin/users/:id/pin',
    defaultPathVars: '{"id":"userId"}',
    defaultBody: '{"pin":"1234"}',
  ),
  AdminEndpoint(title: 'Admin KYC List', method: 'GET', path: ApiConstants.adminKyc),
  AdminEndpoint(
    title: 'Admin KYC by ID',
    method: 'GET',
    path: '${ApiConstants.baseUrl}/api/admin/kyc/:kycId',
    defaultPathVars: '{"kycId":"kycId"}',
  ),
  AdminEndpoint(
    title: 'Admin KYC Approve/Reject',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/admin/kyc/:kycId/status',
    defaultPathVars: '{"kycId":"kycId"}',
    defaultBody: '{"decision":"verified"}',
  ),
  AdminEndpoint(
      title: 'Admin ICO Transactions',
      method: 'GET',
      path: ApiConstants.adminIcoTransactions),
  AdminEndpoint(
      title: 'Admin Recent Transactions',
      method: 'GET',
      path: ApiConstants.adminTransactionsRecent),
  AdminEndpoint(
      title: 'Admin Referral Earnings',
      method: 'GET',
      path: ApiConstants.adminReferralsEarnings),
  AdminEndpoint(
    title: 'Admin Update Referral Earnings',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/admin/referrals/earnings/:id',
    defaultPathVars: '{"id":"earningId"}',
    defaultBody: '{"status":"paid"}',
  ),
  AdminEndpoint(
    title: 'Admin Referral Tree',
    method: 'GET',
    path: '${ApiConstants.baseUrl}/api/admin/referrals/tree/:userId',
    defaultPathVars: '{"userId":"userId"}',
  ),
  AdminEndpoint(
      title: 'Admin Referral Search',
      method: 'GET',
      path: ApiConstants.adminReferralsSearch),
  AdminEndpoint(
      title: 'Admin Bank Requests',
      method: 'GET',
      path: ApiConstants.adminBankRequests),
  AdminEndpoint(
    title: 'Admin Update Bank Request',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/admin/bank/requests/:id',
    defaultPathVars: '{"id":"requestId"}',
    defaultBody: '{"status":"approved"}',
  ),
  AdminEndpoint(
      title: 'Admin Mobile Requests',
      method: 'GET',
      path: ApiConstants.adminMobileRequests),
  AdminEndpoint(
    title: 'Admin Update Mobile Request',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/admin/mobile/requests/:id',
    defaultPathVars: '{"id":"requestId"}',
    defaultBody: '{"status":"approved"}',
  ),
  AdminEndpoint(
      title: 'Admin Wallet Transactions',
      method: 'GET',
      path: ApiConstants.adminWalletTransactions),
  AdminEndpoint(
    title: 'Admin Update Wallet Transaction',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/admin/wallet/transactions/:transactionId',
    defaultPathVars: '{"transactionId":"transactionId"}',
    defaultBody: '{"status":"approved"}',
  ),
  AdminEndpoint(
      title: 'Admin Notifications List',
      method: 'GET',
      path: ApiConstants.adminNotifications),
  AdminEndpoint(
    title: 'Admin Create Notification',
    method: 'POST',
    path: ApiConstants.adminNotifications,
    defaultBody: '{"title":"Notice","message":"System update"}',
  ),
  AdminEndpoint(
      title: 'Admin Categories List',
      method: 'GET',
      path: ApiConstants.adminCategories),
  AdminEndpoint(
    title: 'Admin Create Category',
    method: 'POST',
    path: ApiConstants.adminCategories,
    defaultBody: '{"name":"Category A"}',
  ),
  AdminEndpoint(
    title: 'Admin Update Category',
    method: 'PUT',
    path: '${ApiConstants.baseUrl}/api/admin/categories/:id',
    defaultPathVars: '{"id":"categoryId"}',
    defaultBody: '{"name":"Category Updated"}',
  ),
  AdminEndpoint(
    title: 'Admin Delete Category',
    method: 'DELETE',
    path: '${ApiConstants.baseUrl}/api/admin/categories/:id',
    defaultPathVars: '{"id":"categoryId"}',
  ),
  AdminEndpoint(
      title: 'Admin Products List', method: 'GET', path: ApiConstants.adminProducts),
  AdminEndpoint(
    title: 'Admin Create Product',
    method: 'POST',
    path: ApiConstants.adminProducts,
    defaultBody: '{"name":"Product A","price":100}',
  ),
  AdminEndpoint(
    title: 'Admin Update Product',
    method: 'PUT',
    path: '${ApiConstants.baseUrl}/api/admin/products/:id',
    defaultPathVars: '{"id":"productId"}',
    defaultBody: '{"name":"Product Updated","price":120}',
  ),
  AdminEndpoint(
    title: 'Admin Delete Product',
    method: 'DELETE',
    path: '${ApiConstants.baseUrl}/api/admin/products/:id',
    defaultPathVars: '{"id":"productId"}',
  ),
  AdminEndpoint(
      title: 'Wallet Admin Transactions',
      method: 'GET',
      path: ApiConstants.walletAdminTransactions),
  AdminEndpoint(
    title: 'Wallet Admin Transaction Update',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/wallet/admin/transactions/:transactionId',
    defaultPathVars: '{"transactionId":"transactionId"}',
    defaultBody: '{"status":"approved"}',
  ),
  AdminEndpoint(title: 'Orders Admin List', method: 'GET', path: ApiConstants.ordersAdmin),
  AdminEndpoint(
    title: 'Orders Admin Update',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/orders/admin/:id',
    defaultPathVars: '{"id":"orderId"}',
    defaultBody: '{"status":"completed"}',
  ),
  AdminEndpoint(
    title: 'KYC Status Update (outside admin)',
    method: 'PATCH',
    path: '${ApiConstants.baseUrl}/api/kyc/:kycId/status',
    defaultPathVars: '{"kycId":"kycId"}',
    defaultBody: '{"decision":"verified"}',
  ),
];
