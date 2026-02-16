import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const _brandGreen = Color(0xFF0F8A6A);
const _brandGreenDark = Color(0xFF0A5E48);
const _brandBg = Color(0xFFF4FBF7);
const _logoAsset = 'lib/assets/nivista logo.png';

void main() {
  runApp(const NirvistaAdminApp());
}

class NirvistaAdminApp extends StatelessWidget {
  const NirvistaAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Nirvista Admin',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandGreen,
          primary: _brandGreen,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: _brandBg,
        useMaterial3: true,
        fontFamily: 'Segoe UI',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          foregroundColor: Color(0xFF11261E),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE2EFE8)),
          ),
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD4E6DC)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD4E6DC)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: _brandGreen, width: 1.6),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: _brandGreen,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: _brandGreenDark,
            side: const BorderSide(color: Color(0xFFB8DCCE)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      home: const AdminLoginPage(),
    );
  }
}

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({this.token});

  static const String baseUrl = 'https://nirvista-backend-n8io.onrender.com';
  final String? token;

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login/email'),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('$baseUrl$path').replace(queryParameters: query);
    final response = await http.get(uri, headers: _headers(includeAuth: true));
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(includeAuth: true),
      body: jsonEncode(body ?? <String, dynamic>{}),
    );
    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    required Map<String, dynamic> body,
  }) async {
    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers(includeAuth: true),
      body: jsonEncode(body),
    );
    return _handleResponse(response);
  }

  Map<String, String> _headers({required bool includeAuth}) {
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (includeAuth && token != null && token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    Map<String, dynamic> payload = <String, dynamic>{};

    if (response.body.isNotEmpty) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        payload = decoded;
      } else {
        payload = <String, dynamic>{'data': decoded};
      }
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = payload['message'] is String
          ? payload['message'] as String
          : 'Request failed (${response.statusCode})';
      throw ApiException(message, statusCode: response.statusCode);
    }

    return payload;
  }
}

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorText;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      setState(() {
        _errorText = 'Email and password are required';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorText = null;
    });

    try {
      final client = ApiClient();
      final payload = await client.login(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              AdminShell(apiClient: ApiClient(token: _extractToken(payload))),
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = e.message;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _errorText = 'Unable to connect. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String? _extractToken(Map<String, dynamic> payload) {
    final direct = _readString(payload, const ['token', 'accessToken', 'jwt']);
    if (direct != null) {
      return direct;
    }

    final data = _asMap(payload['data']);
    if (data != null) {
      final nested = _readString(data, const ['token', 'accessToken', 'jwt']);
      if (nested != null) {
        return nested;
      }
    }

    final tokens = _asMap(payload['tokens']);
    if (tokens != null) {
      final nested = _readString(tokens, const ['accessToken', 'token']);
      if (nested != null) {
        return nested;
      }
    }

    return null;
  }

  String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isWide = width > 900;
    final cardWidth = isWide ? 460.0 : width - 36;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE7F7F0), Colors.white, Color(0xFFECFAF3)],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1120),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Wrap(
                spacing: 18,
                runSpacing: 18,
                alignment: WrapAlignment.center,
                children: [
                  if (isWide)
                    Container(
                      width: 420,
                      height: 520,
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [_brandGreen, _brandGreenDark],
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x22359F7F),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _BrandMark(light: true, size: 44),
                          SizedBox(height: 30),
                          Text(
                            'Nirvista Admin Panel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.w700,
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 14),
                          Text(
                            'Secure controls for users, KYC approvals and company wallet operations in one place.',
                            style: TextStyle(
                              color: Color(0xFFD8F5E8),
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: cardWidth),
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(26),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const _BrandMark(size: 40),
                            const SizedBox(height: 14),
                            const Text(
                              'Admin Login',
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF123226),
                              ),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Sign in with admin credentials',
                              style: TextStyle(color: Color(0xFF4B6A5D)),
                            ),
                            const SizedBox(height: 24),
                            TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.mail_outline),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            if (_errorText != null) ...[
                              const SizedBox(height: 14),
                              Text(
                                _errorText!,
                                style: const TextStyle(
                                  color: Color(0xFFB3261E),
                                  fontSize: 13,
                                ),
                              ),
                            ],
                            const SizedBox(height: 24),
                            SizedBox(
                              height: 50,
                              child: FilledButton(
                                onPressed: _isLoading ? null : _login,
                                child: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text('Login'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminShell extends StatefulWidget {
  const AdminShell({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<AdminShell> createState() => _AdminShellState();
}

class _AdminShellState extends State<AdminShell> {
  int _index = 0;

  late final List<Widget> _tabs = [
    DashboardTab(apiClient: widget.apiClient),
    UsersTab(apiClient: widget.apiClient),
    KycTab(apiClient: widget.apiClient),
    WalletTab(apiClient: widget.apiClient),
  ];

  static const List<String> _titles = ['Dashboard', 'Users', 'KYC', 'Wallet'];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 980;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const _BrandMark(size: 26),
            const SizedBox(width: 10),
            Text(_titles[_index]),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const AdminLoginPage()),
              );
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: _brandGreenDark),
            ),
          ),
        ],
      ),
      body: isDesktop
          ? Row(
              children: [
                Container(
                  width: 232,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(right: BorderSide(color: Color(0xFFE0EEE7))),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 18),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 14),
                        child: _BrandMark(size: 30),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: NavigationRail(
                          backgroundColor: Colors.white,
                          selectedIndex: _index,
                          groupAlignment: -0.85,
                          labelType: NavigationRailLabelType.all,
                          onDestinationSelected: (i) =>
                              setState(() => _index = i),
                          destinations: const [
                            NavigationRailDestination(
                              icon: Icon(Icons.dashboard_outlined),
                              label: Text('Dashboard'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.people_outline),
                              label: Text('Users'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.verified_user_outlined),
                              label: Text('KYC'),
                            ),
                            NavigationRailDestination(
                              icon: Icon(Icons.account_balance_wallet_outlined),
                              label: Text('Wallet'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: IndexedStack(
                      key: ValueKey(_index),
                      index: _index,
                      children: _tabs,
                    ),
                  ),
                ),
              ],
            )
          : IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: isDesktop
          ? null
          : NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: (i) => setState(() => _index = i),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.people_outline),
                  label: 'Users',
                ),
                NavigationDestination(
                  icon: Icon(Icons.verified_user_outlined),
                  label: 'KYC',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  label: 'Wallet',
                ),
              ],
            ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _stats = <String, dynamic>{};
  Map<String, dynamic> _count = <String, dynamic>{};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        widget.apiClient.get('/api/admin/stats'),
        widget.apiClient.get('/api/admin/users/count'),
      ]);

      setState(() {
        _stats = results[0];
        _count = results[1];
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load dashboard';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }

    final users = _asMap(_stats['users']) ?? <String, dynamic>{};
    final ico = _asMap(_stats['ico']) ?? <String, dynamic>{};
    final wallet = _asMap(_stats['wallet']) ?? <String, dynamic>{};

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricCard(
                title: 'Total Users',
                value: '${_count['total'] ?? users['total'] ?? '-'}',
              ),
              _MetricCard(
                title: 'KYC Verified',
                value: '${users['kycVerified'] ?? '-'}',
              ),
              _MetricCard(
                title: 'KYC Pending',
                value: '${users['kycPending'] ?? '-'}',
              ),
              _MetricCard(title: 'Token', value: '${ico['symbol'] ?? '-'}'),
              _MetricCard(
                title: 'Token Price',
                value: '${ico['price'] ?? '-'}',
              ),
              _MetricCard(
                title: 'Circulation',
                value: '${ico['circulation'] ?? '-'}',
              ),
              _MetricCard(
                title: 'Buy Volume',
                value: '${ico['buyVolume'] ?? '-'}',
              ),
              _MetricCard(
                title: 'Wallet INR Balance',
                value: '${wallet['totalBalanceInr'] ?? '-'}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _JsonSection(
            title: 'Wallet Volume Map',
            jsonData: wallet['volume'] ?? <String, dynamic>{},
          ),
          const SizedBox(height: 12),
          _JsonSection(title: 'Raw Stats Payload', jsonData: _stats),
        ],
      ),
    );
  }
}

class UsersTab extends StatefulWidget {
  const UsersTab({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final TextEditingController _searchController = TextEditingController();
  String _role = '';
  String _kycStatus = '';
  bool _loading = true;
  String? _error;
  List<dynamic> _users = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final query = <String, String>{'page': '1', 'limit': '20'};

      if (_searchController.text.trim().isNotEmpty) {
        query['search'] = _searchController.text.trim();
      }
      if (_role.isNotEmpty) {
        query['role'] = _role;
      }
      if (_kycStatus.isNotEmpty) {
        query['kycStatus'] = _kycStatus;
      }

      final payload = await widget.apiClient.get(
        '/api/admin/users',
        query: query,
      );
      setState(() {
        _users = _asList(payload['data']);
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load users';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _openUserDetail(String id) async {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final detail = await widget.apiClient.get('/api/admin/users/$id');
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      await _showJsonDialog(context, 'User Detail', detail);
    } on ApiException catch (e) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      _showSnack(context, e.message);
    } catch (_) {
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      _showSnack(context, 'Failed to load user detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 240,
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(labelText: 'Search'),
                ),
              ),
              SizedBox(
                width: 160,
                child: DropdownButtonFormField<String>(
                  value: _role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(value: 'admin', child: Text('admin')),
                    DropdownMenuItem(value: 'user', child: Text('user')),
                  ],
                  onChanged: (v) => setState(() => _role = v ?? ''),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  value: _kycStatus,
                  decoration: const InputDecoration(labelText: 'KYC Status'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('pending')),
                    DropdownMenuItem(
                      value: 'verified',
                      child: Text('verified'),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text('rejected'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _kycStatus = v ?? ''),
                ),
              ),
              FilledButton(onPressed: _load, child: const Text('Apply')),
            ],
          ),
          const SizedBox(height: 16),
          if (_users.isEmpty)
            const Text('No users found')
          else
            ..._users.map((item) {
              final user = _asMap(item) ?? <String, dynamic>{};
              final id = '${user['_id'] ?? user['id'] ?? ''}';
              return Card(
                child: ListTile(
                  title: Text(
                    '${user['name'] ?? user['email'] ?? 'Unknown User'}',
                  ),
                  subtitle: Text(
                    'Email: ${user['email'] ?? '-'}\nRole: ${user['role'] ?? '-'} | KYC: ${user['kycStatus'] ?? '-'}',
                  ),
                  isThreeLine: true,
                  trailing: id.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.open_in_new),
                          onPressed: () => _openUserDetail(id),
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class KycTab extends StatefulWidget {
  const KycTab({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<KycTab> createState() => _KycTabState();
}

class _KycTabState extends State<KycTab> {
  String _status = 'pending';
  bool _loading = true;
  String? _error;
  List<dynamic> _items = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final payload = await widget.apiClient.get(
        '/api/admin/kyc',
        query: {'status': _status, 'page': '1', 'limit': '20'},
      );
      setState(() {
        _items = _asList(payload['data']);
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load KYC items';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _changeStatus({
    required String id,
    required String decision,
  }) async {
    String reason = '';
    if (decision == 'rejected') {
      reason = await _askText(context, 'Reject Reason') ?? '';
      if (reason.isEmpty) {
        return;
      }
    }

    try {
      await widget.apiClient.patch(
        '/api/admin/kyc/$id/status',
        body: {'decision': decision, if (reason.isNotEmpty) 'reason': reason},
      );
      _showSnack(context, 'KYC updated: $decision');
      _load();
    } on ApiException catch (e) {
      _showSnack(context, e.message);
    } catch (_) {
      _showSnack(context, 'Failed to update KYC');
    }
  }

  Future<void> _viewDetail(String id) async {
    try {
      final detail = await widget.apiClient.get('/api/admin/kyc/$id');
      if (!mounted) {
        return;
      }
      await _showJsonDialog(context, 'KYC Detail', detail);
    } on ApiException catch (e) {
      _showSnack(context, e.message);
    } catch (_) {
      _showSnack(context, 'Failed to load KYC detail');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: 'pending', child: Text('pending')),
                    DropdownMenuItem(
                      value: 'verified',
                      child: Text('verified'),
                    ),
                    DropdownMenuItem(
                      value: 'rejected',
                      child: Text('rejected'),
                    ),
                  ],
                  onChanged: (v) {
                    setState(() {
                      _status = v ?? 'pending';
                    });
                    _load();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_items.isEmpty)
            const Text('No KYC records found')
          else
            ..._items.map((item) {
              final kyc = _asMap(item) ?? <String, dynamic>{};
              final id = '${kyc['_id'] ?? kyc['id'] ?? ''}';
              final user = _asMap(kyc['user']);

              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'KYC ID: $id',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Text('User: ${user?['name'] ?? user?['email'] ?? '-'}'),
                      Text('Status: ${kyc['status'] ?? '-'}'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          OutlinedButton(
                            onPressed: id.isEmpty
                                ? null
                                : () => _viewDetail(id),
                            child: const Text('View'),
                          ),
                          FilledButton(
                            onPressed: id.isEmpty
                                ? null
                                : () => _changeStatus(
                                    id: id,
                                    decision: 'verified',
                                  ),
                            child: const Text('Approve'),
                          ),
                          FilledButton.tonal(
                            onPressed: id.isEmpty
                                ? null
                                : () => _changeStatus(
                                    id: id,
                                    decision: 'rejected',
                                  ),
                            child: const Text('Reject'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class WalletTab extends StatefulWidget {
  const WalletTab({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<WalletTab> createState() => _WalletTabState();
}

class _WalletTabState extends State<WalletTab> {
  final _userIdController = TextEditingController();
  String _status = '';
  String _type = '';
  String _category = '';
  bool _loading = true;
  String? _error;
  Map<String, dynamic> _companyWallet = <String, dynamic>{};
  Map<String, dynamic> _walletStats = <String, dynamic>{};
  Map<String, dynamic> _walletSummary = <String, dynamic>{};
  List<dynamic> _transactions = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _userIdController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final query = <String, String>{'page': '1', 'limit': '20'};
      if (_userIdController.text.trim().isNotEmpty) {
        query['userId'] = _userIdController.text.trim();
      }
      if (_status.isNotEmpty) {
        query['status'] = _status;
      }
      if (_type.isNotEmpty) {
        query['type'] = _type;
      }
      if (_category.isNotEmpty) {
        query['category'] = _category;
      }

      final responses = await Future.wait([
        widget.apiClient.get('/api/admin/stats'),
        _safeGet('/api/admin/wallet/stats'),
        _safeGet('/api/admin/wallet/summary'),
        widget.apiClient.get('/api/admin/wallet/transactions', query: query),
      ]);

      final adminStats = _asMap(responses[0]) ?? <String, dynamic>{};
      final statsWallet = _asMap(adminStats['wallet']) ?? <String, dynamic>{};
      final txPayload = _asMap(responses[3]) ?? <String, dynamic>{};

      setState(() {
        _companyWallet = statsWallet;
        _walletStats = _asMap(responses[1]) ?? <String, dynamic>{};
        _walletSummary = _asMap(responses[2]) ?? <String, dynamic>{};
        _transactions = _asList(txPayload['transactions']);
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load wallet transactions';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<Map<String, dynamic>> _safeGet(String path) async {
    try {
      return await widget.apiClient.get(path);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _readValue(List<String> keys) {
    dynamic value;
    for (final key in keys) {
      value = _walletSummary[key];
      if (value == null) {
        value = _walletStats[key];
      }
      if (value == null) {
        value = _companyWallet[key];
      }
      if (value != null && '$value'.trim().isNotEmpty) {
        return '$value';
      }
    }
    return '-';
  }

  Widget _balanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_brandGreen, _brandGreenDark],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Total Company Wallet Balance',
            style: TextStyle(color: Color(0xFFDDF7EB), fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            _readValue(const [
              'totalCompanyBalanceInr',
              'totalBalanceInr',
              'balanceInr',
              'totalBalance',
            ]),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 34,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _walletBadge(
                'Credits',
                _readValue(const ['totalCredits', 'creditVolume', 'credits']),
              ),
              _walletBadge(
                'Debits',
                _readValue(const ['totalDebits', 'debitVolume', 'debits']),
              ),
              _walletBadge(
                'Pending',
                _readValue(const ['pendingAmount', 'pendingVolume', 'pending']),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _walletBadge(String title, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0x2EFFFFFF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        '$title: $value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _operationsSummary() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricCard(title: 'Transactions', value: '${_transactions.length}'),
        _MetricCard(
          title: 'Processed',
          value: _readValue(const ['processedCount']),
        ),
        _MetricCard(
          title: 'Completed',
          value: _readValue(const ['completedCount']),
        ),
        _MetricCard(title: 'Failed', value: _readValue(const ['failedCount'])),
      ],
    );
  }

  Future<void> _updateTransaction(String id) async {
    final status = await _selectFromList(
      context,
      title: 'Update Status',
      options: const [
        'initiated',
        'pending',
        'processed',
        'completed',
        'failed',
        'cancelled',
      ],
    );
    if (status == null) {
      return;
    }

    final note = await _askText(context, 'Admin Note (optional)') ?? '';

    try {
      await widget.apiClient.patch(
        '/api/admin/wallet/transactions/$id',
        body: {
          'status': status,
          if (note.trim().isNotEmpty) 'adminNote': note.trim(),
        },
      );
      _showSnack(context, 'Transaction updated');
      _load();
    } on ApiException catch (e) {
      _showSnack(context, e.message);
    } catch (_) {
      _showSnack(context, 'Failed to update transaction');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _balanceCard(),
          const SizedBox(height: 14),
          _operationsSummary(),
          const SizedBox(height: 16),
          const Text(
            'Wallet Operations',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(labelText: 'User ID'),
                ),
              ),
              SizedBox(
                width: 180,
                child: DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Status'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(
                      value: 'initiated',
                      child: Text('initiated'),
                    ),
                    DropdownMenuItem(value: 'pending', child: Text('pending')),
                    DropdownMenuItem(
                      value: 'processed',
                      child: Text('processed'),
                    ),
                    DropdownMenuItem(
                      value: 'completed',
                      child: Text('completed'),
                    ),
                    DropdownMenuItem(value: 'failed', child: Text('failed')),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('cancelled'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? ''),
                ),
              ),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(value: 'credit', child: Text('credit')),
                    DropdownMenuItem(value: 'debit', child: Text('debit')),
                  ],
                  onChanged: (v) => setState(() => _type = v ?? ''),
                ),
              ),
              SizedBox(
                width: 190,
                child: DropdownButtonFormField<String>(
                  value: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(value: 'topup', child: Text('topup')),
                    DropdownMenuItem(
                      value: 'purchase',
                      child: Text('purchase'),
                    ),
                    DropdownMenuItem(
                      value: 'withdrawal',
                      child: Text('withdrawal'),
                    ),
                    DropdownMenuItem(value: 'refund', child: Text('refund')),
                    DropdownMenuItem(
                      value: 'adjustment',
                      child: Text('adjustment'),
                    ),
                    DropdownMenuItem(
                      value: 'referral',
                      child: Text('referral'),
                    ),
                    DropdownMenuItem(value: 'swap', child: Text('swap')),
                    DropdownMenuItem(value: 'staking', child: Text('staking')),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? ''),
                ),
              ),
              FilledButton(onPressed: _load, child: const Text('Apply')),
            ],
          ),
          const SizedBox(height: 16),
          if (_walletStats.isNotEmpty) ...[
            _JsonSection(title: 'Wallet Stats API', jsonData: _walletStats),
            const SizedBox(height: 12),
          ],
          if (_walletSummary.isNotEmpty) ...[
            _JsonSection(title: 'Wallet Summary API', jsonData: _walletSummary),
            const SizedBox(height: 12),
          ],
          if (_transactions.isEmpty)
            const Text('No transactions found')
          else
            ..._transactions.map((item) {
              final tx = _asMap(item) ?? <String, dynamic>{};
              final id = '${tx['_id'] ?? tx['id'] ?? ''}';
              return Card(
                child: ListTile(
                  title: Text('Txn: $id'),
                  subtitle: Text(
                    'Amount: ${tx['amount'] ?? '-'} | Status: ${tx['status'] ?? '-'}\n'
                    'Type: ${tx['type'] ?? '-'} | Category: ${tx['category'] ?? '-'}',
                  ),
                  isThreeLine: true,
                  trailing: id.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _updateTransaction(id),
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class OrdersTab extends StatefulWidget {
  const OrdersTab({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<OrdersTab> createState() => _OrdersTabState();
}

class _OrdersTabState extends State<OrdersTab> {
  String _status = '';
  bool _loading = true;
  String? _error;
  List<dynamic> _orders = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final query = <String, String>{};
      if (_status.isNotEmpty) {
        query['status'] = _status;
      }
      final payload = await widget.apiClient.get(
        '/api/orders/admin',
        query: query.isEmpty ? null : query,
      );
      setState(() {
        _orders = _asList(payload['orders']);
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load orders';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _updateOrder(String id) async {
    final status = await _selectFromList(
      context,
      title: 'Order Status',
      options: const [
        'pending',
        'confirmed',
        'processing',
        'shipped',
        'delivered',
        'cancelled',
      ],
      includeSkip: true,
    );
    if (!mounted) {
      return;
    }

    final paymentStatus = await _selectFromList(
      context,
      title: 'Payment Status',
      options: const ['pending', 'initiated', 'paid', 'failed', 'refunded'],
      includeSkip: true,
    );

    final body = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      body['status'] = status;
    }
    if (paymentStatus != null && paymentStatus.isNotEmpty) {
      body['paymentStatus'] = paymentStatus;
    }

    if (body.isEmpty) {
      return;
    }

    try {
      await widget.apiClient.patch('/api/orders/admin/$id', body: body);
      _showSnack(context, 'Order updated');
      _load();
    } on ApiException catch (e) {
      _showSnack(context, e.message);
    } catch (_) {
      _showSnack(context, 'Failed to update order');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<String>(
                  value: _status,
                  decoration: const InputDecoration(labelText: 'Order Status'),
                  items: const [
                    DropdownMenuItem(value: '', child: Text('All')),
                    DropdownMenuItem(value: 'pending', child: Text('pending')),
                    DropdownMenuItem(
                      value: 'confirmed',
                      child: Text('confirmed'),
                    ),
                    DropdownMenuItem(
                      value: 'processing',
                      child: Text('processing'),
                    ),
                    DropdownMenuItem(value: 'shipped', child: Text('shipped')),
                    DropdownMenuItem(
                      value: 'delivered',
                      child: Text('delivered'),
                    ),
                    DropdownMenuItem(
                      value: 'cancelled',
                      child: Text('cancelled'),
                    ),
                  ],
                  onChanged: (v) => setState(() => _status = v ?? ''),
                ),
              ),
              FilledButton(onPressed: _load, child: const Text('Apply')),
            ],
          ),
          const SizedBox(height: 16),
          if (_orders.isEmpty)
            const Text('No orders found')
          else
            ..._orders.map((item) {
              final order = _asMap(item) ?? <String, dynamic>{};
              final id = '${order['_id'] ?? order['id'] ?? ''}';
              final user = _asMap(order['user']);
              return Card(
                child: ListTile(
                  title: Text('Order: $id'),
                  subtitle: Text(
                    'User: ${user?['email'] ?? user?['name'] ?? '-'}\n'
                    'Status: ${order['status'] ?? '-'} | Payment: ${order['paymentStatus'] ?? '-'}',
                  ),
                  isThreeLine: true,
                  trailing: id.isEmpty
                      ? null
                      : IconButton(
                          icon: const Icon(Icons.edit_outlined),
                          onPressed: () => _updateOrder(id),
                        ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class NotificationsTab extends StatefulWidget {
  const NotificationsTab({required this.apiClient, super.key});

  final ApiClient apiClient;

  @override
  State<NotificationsTab> createState() => _NotificationsTabState();
}

class _NotificationsTabState extends State<NotificationsTab> {
  final _typeFilterController = TextEditingController();
  final _audienceFilterController = TextEditingController();
  final _userIdFilterController = TextEditingController();

  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _typeController = TextEditingController();
  final _userIdController = TextEditingController();
  final _metadataController = TextEditingController();

  bool _loading = true;
  String? _error;
  bool _creating = false;
  List<dynamic> _items = <dynamic>[];

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _typeFilterController.dispose();
    _audienceFilterController.dispose();
    _userIdFilterController.dispose();
    _titleController.dispose();
    _messageController.dispose();
    _typeController.dispose();
    _userIdController.dispose();
    _metadataController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final query = <String, String>{'page': '1', 'limit': '20'};
      if (_typeFilterController.text.trim().isNotEmpty) {
        query['type'] = _typeFilterController.text.trim();
      }
      if (_audienceFilterController.text.trim().isNotEmpty) {
        query['audience'] = _audienceFilterController.text.trim();
      }
      if (_userIdFilterController.text.trim().isNotEmpty) {
        query['userId'] = _userIdFilterController.text.trim();
      }

      final payload = await widget.apiClient.get(
        '/api/admin/notifications',
        query: query,
      );
      setState(() {
        _items = _asList(payload['data']);
      });
    } on ApiException catch (e) {
      setState(() {
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _error = 'Failed to load notifications';
      });
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _createNotification() async {
    if (_titleController.text.trim().isEmpty ||
        _messageController.text.trim().isEmpty) {
      _showSnack(context, 'Title and message are required');
      return;
    }

    Map<String, dynamic>? metadata;
    if (_metadataController.text.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(_metadataController.text.trim());
        if (decoded is Map<String, dynamic>) {
          metadata = decoded;
        } else {
          _showSnack(context, 'Metadata must be JSON object');
          return;
        }
      } catch (_) {
        _showSnack(context, 'Invalid metadata JSON');
        return;
      }
    }

    setState(() {
      _creating = true;
    });

    try {
      await widget.apiClient.post(
        '/api/admin/notifications',
        body: {
          'title': _titleController.text.trim(),
          'message': _messageController.text.trim(),
          if (_typeController.text.trim().isNotEmpty)
            'type': _typeController.text.trim(),
          if (_userIdController.text.trim().isNotEmpty)
            'userId': _userIdController.text.trim(),
          if (metadata != null) 'metadata': metadata,
        },
      );

      _titleController.clear();
      _messageController.clear();
      _typeController.clear();
      _userIdController.clear();
      _metadataController.clear();

      _showSnack(context, 'Notification created');
      _load();
    } on ApiException catch (e) {
      _showSnack(context, e.message);
    } catch (_) {
      _showSnack(context, 'Failed to create notification');
    } finally {
      if (mounted) {
        setState(() {
          _creating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return _ErrorState(message: _error!, onRetry: _load);
    }

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Create Notification',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageController,
            decoration: const InputDecoration(labelText: 'Message'),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: 'Type (optional)',
                  ),
                ),
              ),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _userIdController,
                  decoration: const InputDecoration(
                    labelText: 'User ID (optional)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _metadataController,
            decoration: const InputDecoration(
              labelText: 'Metadata JSON (optional)',
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 150,
            child: FilledButton(
              onPressed: _creating ? null : _createNotification,
              child: _creating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Create'),
            ),
          ),
          const Divider(height: 30),
          const Text(
            'Notifications List',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _typeFilterController,
                  decoration: const InputDecoration(labelText: 'Filter type'),
                ),
              ),
              SizedBox(
                width: 200,
                child: TextField(
                  controller: _audienceFilterController,
                  decoration: const InputDecoration(
                    labelText: 'Filter audience',
                  ),
                ),
              ),
              SizedBox(
                width: 220,
                child: TextField(
                  controller: _userIdFilterController,
                  decoration: const InputDecoration(labelText: 'Filter userId'),
                ),
              ),
              FilledButton(onPressed: _load, child: const Text('Apply')),
            ],
          ),
          const SizedBox(height: 12),
          if (_items.isEmpty)
            const Text('No notifications found')
          else
            ..._items.map((item) {
              final n = _asMap(item) ?? <String, dynamic>{};
              return Card(
                child: ListTile(
                  title: Text('${n['title'] ?? '-'}'),
                  subtitle: Text(
                    '${n['message'] ?? '-'}\n'
                    'Type: ${n['type'] ?? '-'} | Audience: ${n['audience'] ?? '-'} | User: ${n['userId'] ?? '-'}',
                  ),
                  isThreeLine: true,
                  trailing: Text(
                    '${n['createdAt'] ?? ''}',
                    style: const TextStyle(fontSize: 11),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _BrandMark extends StatelessWidget {
  const _BrandMark({this.size = 34, this.light = false});

  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Image.asset(_logoAsset, height: size),
        const SizedBox(width: 8),
        Text(
          'NIRVISTA',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: size * 0.48,
            letterSpacing: 0.8,
            color: light ? Colors.white : _brandGreenDark,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 220,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 13, color: Color(0xFF446457)),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _JsonSection extends StatelessWidget {
  const _JsonSection({required this.title, required this.jsonData});

  final String title;
  final dynamic jsonData;

  @override
  Widget build(BuildContext context) {
    final pretty = const JsonEncoder.withIndent('  ').convert(jsonData);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            SelectableText(
              pretty,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 10),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

Map<String, dynamic>? _asMap(dynamic value) {
  return value is Map<String, dynamic> ? value : null;
}

List<dynamic> _asList(dynamic value) {
  return value is List ? value : <dynamic>[];
}

void _showSnack(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
}

Future<void> _showJsonDialog(
  BuildContext context,
  String title,
  dynamic payload,
) async {
  final pretty = const JsonEncoder.withIndent('  ').convert(payload);
  await showDialog<void>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: SelectableText(
          pretty,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

Future<String?> _askText(BuildContext context, String title) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: TextField(controller: controller),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: const Text('Submit'),
        ),
      ],
    ),
  );
  controller.dispose();
  return result;
}

Future<String?> _selectFromList(
  BuildContext context, {
  required String title,
  required List<String> options,
  bool includeSkip = false,
}) async {
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(title),
      content: SizedBox(
        width: 300,
        child: ListView(
          shrinkWrap: true,
          children: [
            if (includeSkip)
              ListTile(
                title: const Text('Skip'),
                onTap: () => Navigator.of(context).pop(''),
              ),
            ...options.map(
              (option) => ListTile(
                title: Text(option),
                onTap: () => Navigator.of(context).pop(option),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
