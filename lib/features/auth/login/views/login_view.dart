import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:onebank/features/auth/login/vm/login_viewmodel.dart';

class LoginView extends StatefulHookConsumerWidget {
  const LoginView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _LoginViewState();
}

class _LoginViewState extends ConsumerState<LoginView> {
  @override
  Widget build(BuildContext context) {
    final loginViewModel = ref.watch(loginViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Login View')),
      body: Container(alignment: Alignment.center, child: Text('Login View ${loginViewModel.getUserName()}')),
    );
  }
}
