import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:http/http.dart' as http;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isBiometricEnabled = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final bool canCheckBiometrics = await _localAuth.canCheckBiometrics;
    if (canCheckBiometrics) {
      final List<BiometricType> availableBiometrics =
          await _localAuth.getAvailableBiometrics();
      if (availableBiometrics.contains(BiometricType.fingerprint)) {
        setState(() {
          _isBiometricEnabled = true;
        });
      }
    }
  }

  Future<void> _authenticate() async {
    final bool isAuthenticated = await _localAuth.authenticateWithBiometrics(
      localizedReason: 'Please authenticate to log in',
    );

    if (isAuthenticated) {
      final String username = _usernameController.text;
      final String password = _passwordController.text;
      final response = await http.post(
        Uri.parse('https://your-api.com/login'),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        Navigator.of(context).pushReplacementNamed('/main');
      } else {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Error'),
            content: Text('Invalid username or password'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
