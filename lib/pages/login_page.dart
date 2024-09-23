import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _fadeAnimationInverse;
  late Animation<Offset> _slideUpAnimation;
  late Animation<Offset> _slideDownAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
    _fadeAnimationInverse = Tween<double>(begin: 1.0, end: 0.08).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutBack,
      ),
    );

    _slideUpAnimation = Tween<Offset>(
      begin: Offset(0, -0.356),
      end: Offset(0, -0.2),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideDownAnimation = Tween<Offset>(
      begin: Offset(0, 0.48),
      end: Offset(0, 0.2),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onLoginPressed() {
    final String email = _emailController.text;
    final String password = _passwordController.text;

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    context.read<AuthBloc>().add(LoginEvent(email, password));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthLoading) {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) =>
                  const Center(child: CircularProgressIndicator()),
            );
          } else if (state is AuthNeedsSecret) {
            Navigator.pushNamed(context, '/recovery');
          } else if (state is AuthSuccess) {
            Navigator.pop(context);

            Navigator.pushReplacementNamed(context, '/home');
          } else if (state is AuthFailure) {
            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 144),
              Stack(
                alignment: Alignment.center,
                children: [
                  SlideTransition(
                    position: _slideUpAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: Image.asset('assets/images/Vector 14.png'),
                    ),
                  ),
                  SlideTransition(
                    position: _slideDownAnimation,
                    child: FadeTransition(
                      opacity: _fadeAnimationInverse,
                      child: Image.asset('assets/images/Vector 13.png'),
                    ),
                  ),
                  SizedBox(
                    height: 230,
                    child: Image.asset('assets/images/image 2.png'),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(
                  top: 24,
                  left: 14,
                  right: 14,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _emailController,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 20 / 12,
                      ),
                      decoration: InputDecoration(
                        fillColor: Color.fromRGBO(206, 207, 210, 0.2),
                        filled: true,
                        hintText: 'E-mail',
                        hintStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 20 / 12,
                          color: Color.fromRGBO(73, 74, 87, 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        height: 20 / 12,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromRGBO(206, 207, 210, 0.2),
                        hintText: 'Senha',
                        hintStyle: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 20 / 12,
                          color: Color.fromRGBO(73, 74, 87, 1),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: _onLoginPressed,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: const Color(0xFF7A5D3E),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 158),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  'Esqueci a senha',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF7A5D3E),
                    fontSize: 16,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
