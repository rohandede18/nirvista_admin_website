import 'dart:convert';

import 'package:flutter/material.dart';

import '../models/admin_endpoint.dart';
import '../services/admin_api_service.dart';

class AdminDashboardPage extends StatefulWidget {
  const AdminDashboardPage({super.key});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  final _signupName = TextEditingController();
  final _signupEmail = TextEditingController();
  final _signupMobile = TextEditingController();
  final _signupPassword = TextEditingController();

  final _loginIdentifier = TextEditingController();
  final _loginOtp = TextEditingController();

  final _kycId = TextEditingController();
  final _kycReason = TextEditingController();

  bool _busy = false;
  String _decision = 'verified';
  String _resultText = 'No request yet.';
  String _tokenState = 'Checking session...';

  @override
  void initState() {
    super.initState();
    _refreshTokenState();
  }

  @override
  void dispose() {
    _signupName.dispose();
    _signupEmail.dispose();
    _signupMobile.dispose();
    _signupPassword.dispose();
    _loginIdentifier.dispose();
    _loginOtp.dispose();
    _kycId.dispose();
    _kycReason.dispose();
    super.dispose();
  }

  Future<void> _refreshTokenState() async {
    final token = await AdminApiService.token();
    if (!mounted) {
      return;
    }

    setState(() {
      _tokenState = (token != null && token.isNotEmpty)
          ? 'Authenticated (token saved)'
          : 'Not authenticated';
    });
  }

  Map<String, dynamic>? _parseMap(String raw) {
    final clean = raw.trim();
    if (clean.isEmpty) {
      return {};
    }
    final decoded = jsonDecode(clean);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }
    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }
    throw const FormatException('JSON must be an object');
  }

  String _resolvePath(String path, Map<String, dynamic>? vars) {
    var resolved = path;
    if (vars != null) {
      for (final entry in vars.entries) {
        final replacement = Uri.encodeComponent(entry.value.toString());
        resolved = resolved.replaceAll(':${entry.key}', replacement);
        resolved = resolved.replaceAll('{${entry.key}}', replacement);
      }
    }
    return resolved;
  }

  Future<void> _runRequest(Future<Map<String, dynamic>> Function() operation) async {
    if (_busy) {
      return;
    }

    setState(() {
      _busy = true;
    });

    try {
      final data = await operation();
      if (!mounted) {
        return;
      }
      setState(() {
        _resultText = const JsonEncoder.withIndent('  ').convert(data);
      });
      await _refreshTokenState();
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _resultText = 'Request failed: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
        });
      }
    }
  }

  Future<void> _openEndpointRunner(AdminEndpoint endpoint) async {
    final varsCtrl = TextEditingController(text: endpoint.defaultPathVars);
    final queryCtrl = TextEditingController(text: endpoint.defaultQuery);
    final bodyCtrl = TextEditingController(text: endpoint.defaultBody);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  endpoint.title,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
                ),
                const SizedBox(height: 8),
                Text('${endpoint.method} ${endpoint.path}'),
                const SizedBox(height: 12),
                _jsonField('Path vars JSON', varsCtrl),
                const SizedBox(height: 10),
                _jsonField('Query JSON', queryCtrl),
                const SizedBox(height: 10),
                _jsonField('Body JSON', bodyCtrl, maxLines: 5),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final vars = _parseMap(varsCtrl.text);
                        final query = _parseMap(queryCtrl.text);
                        final body = _parseMap(bodyCtrl.text);
                        final url = _resolvePath(endpoint.path, vars);

                        Navigator.of(context).pop();
                        await _runRequest(() => AdminApiService.request(
                              method: endpoint.method,
                              url: url,
                              requiresAuth: endpoint.requiresAuth,
                              query: query,
                              body: body,
                            ));
                      } catch (e) {
                        if (!mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(this.context).showSnackBar(
                          SnackBar(content: Text('Invalid JSON or path values: $e')),
                        );
                      }
                    },
                    child: const Text('Run API'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    varsCtrl.dispose();
    queryCtrl.dispose();
    bodyCtrl.dispose();
  }

  Widget _jsonField(String label, TextEditingController controller, {int maxLines = 3}) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildAuthCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Admin Auth', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Text('Session: $_tokenState'),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(width: 220, child: TextField(controller: _signupName, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder()))),
                SizedBox(width: 220, child: TextField(controller: _signupEmail, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()))),
                SizedBox(width: 220, child: TextField(controller: _signupMobile, decoration: const InputDecoration(labelText: 'Mobile', border: OutlineInputBorder()))),
                SizedBox(width: 220, child: TextField(controller: _signupPassword, decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()))),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                ElevatedButton(
                  onPressed: _busy
                      ? null
                      : () => _runRequest(
                            () => AdminApiService.request(
                              method: 'POST',
                              url: adminEndpoints[0].path,
                              requiresAuth: false,
                              body: {
                                'name': _signupName.text.trim(),
                                'email': _signupEmail.text.trim(),
                                'mobile': _signupMobile.text.trim(),
                                'password': _signupPassword.text.trim(),
                              },
                            ),
                          ),
                  child: const Text('Signup'),
                ),
                SizedBox(
                  width: 220,
                  child: TextField(
                    controller: _loginIdentifier,
                    decoration: const InputDecoration(labelText: 'Login identifier', border: OutlineInputBorder()),
                  ),
                ),
                ElevatedButton(
                  onPressed: _busy
                      ? null
                      : () => _runRequest(
                            () => AdminApiService.request(
                              method: 'POST',
                              url: adminEndpoints[1].path,
                              requiresAuth: false,
                              body: {'identifier': _loginIdentifier.text.trim()},
                            ),
                          ),
                  child: const Text('OTP Init'),
                ),
                SizedBox(
                  width: 150,
                  child: TextField(
                    controller: _loginOtp,
                    decoration: const InputDecoration(labelText: 'OTP', border: OutlineInputBorder()),
                  ),
                ),
                ElevatedButton(
                  onPressed: _busy
                      ? null
                      : () => _runRequest(
                            () => AdminApiService.request(
                              method: 'POST',
                              url: adminEndpoints[2].path,
                              requiresAuth: false,
                              body: {
                                'identifier': _loginIdentifier.text.trim(),
                                'otp': _loginOtp.text.trim(),
                              },
                            ),
                          ),
                  child: const Text('OTP Verify'),
                ),
                OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          await AdminApiService.clearToken();
                          await _refreshTokenState();
                          if (!mounted) return;
                          setState(() {
                            _resultText = 'Admin session cleared.';
                          });
                        },
                  child: const Text('Logout/Clear Token'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKycCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('KYC Approval Quick Action',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                SizedBox(
                  width: 240,
                  child: TextField(
                    controller: _kycId,
                    decoration: const InputDecoration(
                      labelText: 'KYC ID',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(
                  width: 180,
                  child: DropdownButtonFormField<String>(
                    initialValue: _decision,
                    isExpanded: true,
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                    items: const [
                      DropdownMenuItem(value: 'verified', child: Text('verified')),
                      DropdownMenuItem(value: 'rejected', child: Text('rejected')),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => _decision = value);
                    },
                  ),
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _kycReason,
                    decoration: const InputDecoration(
                      labelText: 'Reason (required for rejected)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: _busy
                      ? null
                      : () => _runRequest(
                            () => AdminApiService.request(
                              method: 'PATCH',
                              url: adminEndpoints[16].path
                                  .replaceAll(':kycId', _kycId.text.trim()),
                              body: {
                                'decision': _decision,
                                if (_decision == 'rejected' && _kycReason.text.trim().isNotEmpty)
                                  'reason': _kycReason.text.trim(),
                              },
                            ),
                          ),
                  child: const Text('Submit Decision'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEndpointList() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('All Admin APIs', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Text('Tap Run on any endpoint to send request with optional path/query/body JSON.'),
            const Divider(height: 20),
            ...adminEndpoints.map((endpoint) => ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(endpoint.title),
                  subtitle: Text('${endpoint.method} ${endpoint.path}'),
                  trailing: ElevatedButton(
                    onPressed: _busy ? null : () => _openEndpointRunner(endpoint),
                    child: const Text('Run'),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsePanel() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Latest Response', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                if (_busy) const CircularProgressIndicator(strokeWidth: 2),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF3FAF5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFCFE8D7)),
              ),
              child: SelectableText(
                _resultText,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FCF7),
      appBar: AppBar(
        title: const Text('Nirvista Admin Website'),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 980;
          if (isDesktop) {
            return Row(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildAuthCard(),
                      const SizedBox(height: 12),
                      _buildKycCard(),
                      const SizedBox(height: 12),
                      _buildResponsePanel(),
                    ],
                  ),
                ),
                SizedBox(
                  width: constraints.maxWidth * 0.45,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                    children: [_buildEndpointList()],
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              _buildAuthCard(),
              const SizedBox(height: 10),
              _buildKycCard(),
              const SizedBox(height: 10),
              _buildEndpointList(),
              const SizedBox(height: 10),
              _buildResponsePanel(),
            ],
          );
        },
      ),
    );
  }
}
