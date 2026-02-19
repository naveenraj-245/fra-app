import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../features/dashboard/dweller_dashboard.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPassController = TextEditingController();

  bool _isLoading = false;

  // --- NEW: Strict Password Validator ---
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a password.';
    }
    
    // Rule: 8+ chars, at least 1 uppercase, at least 1 special char
    RegExp passwordRegex = RegExp(r'^(?=.*[A-Z])(?=.*[!@#\$&*~]).{8,}$');
    
    if (!passwordRegex.hasMatch(value)) {
      return 'Needs 8+ chars, 1 uppercase, and 1 special char.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Account"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Join Satya-Shield", 
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1B5E20)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Enter your details to register as a Forest Dweller",
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),

              // 1. FULL NAME
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Full Name", Icons.person),
                validator: (val) => val!.isEmpty ? "Enter your name" : null,
              ),
              const SizedBox(height: 16),

              // 2. PHONE NUMBER
              TextFormField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: _inputDecoration("Phone Number", Icons.phone),
                validator: (val) => val!.length < 10 ? "Enter valid mobile number" : null,
              ),
              const SizedBox(height: 16),

              // 3. EMAIL
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: _inputDecoration("Email Address", Icons.email),
                validator: (val) => !val!.contains('@') ? "Enter valid email" : null,
              ),
              const SizedBox(height: 16),

              // 4. PASSWORD (Updated with strict validation and hint)
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: _inputDecoration(
                  "Password", 
                  Icons.lock,
                  helperText: "Required: 8+ chars, 1 uppercase, 1 special char", // Added hint
                ),
                validator: _validatePassword, // Added strict validator
              ),
              const SizedBox(height: 16),

              // 5. CONFIRM PASSWORD
              TextFormField(
                controller: _confirmPassController,
                obscureText: true,
                decoration: _inputDecoration("Confirm Password", Icons.lock_outline),
                validator: (val) {
                  if (val != _passwordController.text) return "Passwords do not match";
                  return null;
                },
              ),
              const SizedBox(height: 30),

              // 6. REGISTER BUTTON
              if (_isLoading)
                const Center(child: CircularProgressIndicator(color: Color(0xFF1B5E20)))
              else
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _handleRegister,
                  child: const Text("Register & Login", style: TextStyle(fontSize: 16)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- UPDATED: Added optional helperText parameter ---
  InputDecoration _inputDecoration(String label, IconData icon, {String? helperText}) {
    return InputDecoration(
      labelText: label,
      helperText: helperText, // This shows the text below the box
      prefixIcon: Icon(icon, color: const Color(0xFF1B5E20)),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF1B5E20), width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
      );

      if (mounted) {
        // Clear stack and go to Dashboard
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const DwellerDashboard()),
          (route) => false,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Welcome! Account created successfully.")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}