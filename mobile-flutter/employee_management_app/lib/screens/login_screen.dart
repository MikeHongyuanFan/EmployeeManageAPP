import 'package:flutter/material.dart';
import '../services/api_service_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  final ApiServiceInterface apiService;
  
  const LoginScreen({Key? key, required this.apiService}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverUrlController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _showAdvancedOptions = false;

  @override
  void initState() {
    super.initState();
    _checkSavedServerUrl();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _serverUrlController.dispose();
    super.dispose();
  }
  
  Future<void> _checkSavedServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final savedUrl = prefs.getString('api_base_url');
    if (savedUrl != null && savedUrl.isNotEmpty) {
      setState(() {
        _serverUrlController.text = savedUrl;
      });
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    // TEMPORARY FIX: Skip actual connection test for development
    await Future.delayed(Duration(milliseconds: 500)); // Simulate a short delay
    
    setState(() {
      _isLoading = false;
      // No error means success
    });
    
    // Show a message that we're bypassing the connection test
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Connection test bypassed for development'),
        duration: Duration(seconds: 3),
      )
    );
  }

  Future<void> _updateServerUrl() async {
    final url = _serverUrlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _error = 'Please enter a server URL';
      });
      return;
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', url);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Server URL updated')),
    );
  }

  Future<void> _login() async {
    if (_formKey.currentState?.validate() != true) {
      return;
    }
    
    setState(() {
      _isLoading = true;
      _error = null;
    });
    
    // TEMPORARY FIX: Skip actual login for development
    // Simulate a successful login after a short delay
    await Future.delayed(Duration(milliseconds: 800));
    
    try {
      final result = await widget.apiService.login(
        _usernameController.text,
        _passwordController.text,
      );
      
      setState(() {
        _isLoading = false;
      });
      
      if (widget.apiService.isManager ?? false) {
        Navigator.of(context).pushReplacementNamed('/manager_dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/employee_dashboard');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = 'Login failed. Please check your credentials and server connection.';
      });
      print('Login error: ${e.toString()}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Management'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const FlutterLogo(size: 100),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _showAdvancedOptions = !_showAdvancedOptions;
                        });
                      },
                      child: Text(
                        _showAdvancedOptions ? 'Hide Advanced Options' : 'Show Advanced Options',
                      ),
                    ),
                  ],
                ),
                if (_showAdvancedOptions) ...[
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _serverUrlController,
                    decoration: const InputDecoration(
                      labelText: 'Server URL',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.link),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _updateServerUrl,
                          child: const Text('Update Server URL'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _testConnection,
                          child: const Text('Test Connection'),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(8),
                    color: Colors.red.shade100,
                    child: Text(
                      _error!,
                      style: TextStyle(color: Colors.red.shade900),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
