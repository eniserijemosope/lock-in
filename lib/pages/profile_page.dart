import 'package:flutter/material.dart';

import '../services/local_account_store.dart';
import '../theme/lock_in_theme.dart';
import '../widgets/lock_in_card.dart';
import '../widgets/page_header.dart';

class ProfilePage extends StatefulWidget {
  final LocalAccount? account;
  final bool accountLoaded;
  final bool loggedIn;
  final Future<LocalAccount> Function({
    required String name,
    required String email,
    required String password,
  }) onCreateAccount;
  final Future<bool> Function(String email, String password) onLogin;
  final VoidCallback onLogout;

  const ProfilePage({
    super.key,
    required this.account,
    required this.accountLoaded,
    required this.loggedIn,
    required this.onCreateAccount,
    required this.onLogin,
    required this.onLogout,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future<void> _showAccountDialog({required bool createAccount}) async {
    final formKey = GlobalKey<FormState>();
    var name = '';
    var email = widget.account?.email ?? '';
    var password = '';

    final details = await showDialog<_AccountFormResult>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(createAccount ? 'Create account' : 'Log in'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (createAccount) ...[
                  TextFormField(
                    initialValue: name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(labelText: 'Name'),
                    onChanged: (value) => name = value,
                    validator: (value) =>
                        (value == null || value.trim().isEmpty)
                            ? 'Enter your name.'
                            : null,
                  ),
                  const SizedBox(height: 12),
                ],
                TextFormField(
                  initialValue: email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  onChanged: (value) => email = value,
                  validator: (value) {
                    final email = value?.trim() ?? '';
                    return email.contains('@') && email.contains('.')
                        ? null
                        : 'Enter a valid email address.';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: password,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Password'),
                  onChanged: (value) => password = value,
                  validator: (value) {
                    if (value == null || value.length < 6) {
                      return 'Use at least 6 characters.';
                    }
                    return null;
                  },
                ),
                if (createAccount) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Account details are stored on this device only.',
                    style: dot(9, color: LockInColors.grey),
                  ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          TextButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.pop(
                  dialogContext,
                  _AccountFormResult(
                    name: name.trim(),
                    email: email.trim(),
                    password: password,
                  ),
                );
              }
            },
            child: Text(createAccount ? 'CREATE' : 'LOG IN'),
          ),
        ],
      ),
    );

    if (details == null || !mounted) return;

    try {
      if (createAccount) {
        await widget.onCreateAccount(
          name: details.name,
          email: details.email,
          password: details.password,
        );
      } else {
        final success = await widget.onLogin(details.email, details.password);
        if (!success) {
          _showMessage('Email or password is incorrect.');
        }
      }
    } on StateError catch (error) {
      _showMessage('Account action failed: $error');
    } on Exception catch (error) {
      _showMessage('Account action failed: $error');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = widget.account;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          const PageHeader(title: 'PROFILE.', sub: 'YOUR ACCOUNT'),
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: LockInColors.white, width: 1.5),
                color: LockInColors.surfaceAlt,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 40,
                color: LockInColors.white,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              account?.name.toUpperCase() ?? 'GUEST',
              style: dot(18, weight: FontWeight.w700),
            ),
          ),
          const SizedBox(height: 4),
          Center(
            child: Text(
              account?.email ?? 'No account saved on this device',
              style: dot(10, color: LockInColors.grey),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                LockInCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        !widget.accountLoaded
                            ? 'LOADING ACCOUNT'
                            : widget.loggedIn
                                ? 'SIGNED IN'
                                : account == null
                                    ? 'NOT SIGNED IN'
                                    : 'SAVED ON THIS DEVICE',
                        style: dot(10, color: LockInColors.grey),
                      ),
                      const SizedBox(height: 16),
                      if (widget.loggedIn)
                        _actionButton(
                          label: 'LOG OUT',
                          onPressed: widget.onLogout,
                        )
                      else if (!widget.accountLoaded)
                        const Center(child: CircularProgressIndicator())
                      else if (account == null)
                        _actionButton(
                          label: 'CREATE ACCOUNT',
                          onPressed: () =>
                              _showAccountDialog(createAccount: true),
                        )
                      else
                        _actionButton(
                          label: 'LOG IN',
                          onPressed: () =>
                              _showAccountDialog(createAccount: false),
                        ),
                      if (account == null && widget.accountLoaded) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Create a local account to save your profile on this phone.',
                          style: dot(9, color: LockInColors.grey),
                        ),
                      ],
                    ],
                  ),
                ),
                if (account != null) ...[
                  const SizedBox(height: 16),
                  LockInCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('USERNAME',
                            style: dot(9, color: LockInColors.grey)),
                        const SizedBox(height: 8),
                        _field(account.name),
                        const SizedBox(height: 14),
                        Text('EMAIL', style: dot(9, color: LockInColors.grey)),
                        const SizedBox(height: 8),
                        _field(account.email),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required VoidCallback onPressed,
  }) =>
      SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: onPressed,
          child: Text(label, style: dot(10, weight: FontWeight.w700)),
        ),
      );

  Widget _field(String value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: LockInColors.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: LockInColors.line),
        ),
        child: Text(value, style: dot(12, color: LockInColors.grey)),
      );
}

class _AccountFormResult {
  final String name;
  final String email;
  final String password;

  const _AccountFormResult({
    required this.name,
    required this.email,
    required this.password,
  });
}
