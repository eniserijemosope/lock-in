import 'package:flutter/material.dart';

import '../pages/home_page.dart';
import '../pages/profile_page.dart';
import '../pages/task_page.dart';
import '../services/local_account_store.dart';
import '../theme/lock_in_theme.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _index = 0;
  LocalAccount? _account;
  bool _accountLoaded = false;
  bool _loggedIn = false;

  @override
  void initState() {
    super.initState();
    _loadSavedAccount();
  }

  Future<void> _loadSavedAccount() async {
    final account = await LocalAccountStore.load();
    if (!mounted) return;
    setState(() {
      _account = account;
      _accountLoaded = true;
    });
  }

  Future<LocalAccount> _createAccount({
    required String name,
    required String email,
    required String password,
  }) async {
    final account = await LocalAccountStore.create(
      name: name,
      email: email,
      password: password,
    );
    if (mounted) {
      setState(() {
        _account = account;
        _loggedIn = true;
      });
    }
    return account;
  }

  Future<bool> _login(String email, String password) async {
    final account = _account;
    if (account == null ||
        account.email != email.trim().toLowerCase() ||
        !LocalAccountStore.verifyPassword(account, password)) {
      return false;
    }
    setState(() => _loggedIn = true);
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomePage(),
      const TaskPage(),
      ProfilePage(
        account: _account,
        accountLoaded: _accountLoaded,
        loggedIn: _loggedIn,
        onCreateAccount: _createAccount,
        onLogin: _login,
        onLogout: () => setState(() => _loggedIn = false),
      ),
    ];
    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: LockInColors.surface,
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: LockInColors.line),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(0, Icons.home_outlined, Icons.home, 'HOME'),
            _navItem(1, Icons.check_box_outlined, Icons.check_box, 'TASKS'),
            _navItem(2, Icons.person_outline, Icons.person, 'PROFILE'),
          ],
        ),
      ),
    );
  }

  Widget _navItem(int i, IconData icon, IconData activeIcon, String label) {
    final active = _index == i;
    return GestureDetector(
      onTap: () => setState(() => _index = i),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
        decoration: BoxDecoration(
          color: active ? LockInColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Icon(
              active ? activeIcon : icon,
              size: 20,
              color: active ? LockInColors.bg : LockInColors.grey,
            ),
            if (active) ...[
              const SizedBox(width: 8),
              Text(
                label,
                style: dot(10, color: LockInColors.bg, weight: FontWeight.w700),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
