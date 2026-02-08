import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../dashboard/dweller_dashboard.dart';

class LoginScreen extends StatefulWidget {
  final String userRole; // Stores if the user is a dweller, officer, or ngo

  const LoginScreen({super.key, required this.userRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _auth = AuthService();

  // Text Controllers to capture input
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Login: ${widget.userRole}"),
        backgroundColor: const Color(0xFF1B5E20),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Phone Number", icon: Icon(Icons.phone)),
            Tab(text: "Email / ID", icon: Icon(Icons.email)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // TAB 1: Phone Login (Currently a UI Demo)
          _buildPhoneTab(),
          
          // TAB 2: Email Login (Fully Functional with Firebase)
          _buildEmailTab(),
        ],
      ),
    );
  }

  // --- UI: Phone Login Tab ---
  Widget _buildPhoneTab() {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.phone_android, size: 80, color: Color(0xFF1B5E20)),
          const SizedBox(height: 20),
          const Text(
            "Enter Mobile Number", 
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              prefixText: "+91 ",
              border: OutlineInputBorder(),
              labelText: "Mobile Number",
              hintText: "10-digit number"
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: const Color(0xFF1B5E20),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Temporary bypass until SHA-1 is set up for Phone Auth
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (context) => const DwellerDashboard())
              );
            },
            child: const Text("Send OTP (Demo Mode)"),
          ),
        ],
      ),
    );
  }

  // --- UI: Email Login Tab ---
  Widget _buildEmailTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF1B5E20)),
          const SizedBox(height: 20),
          Text(
            "${widget.userRole.toUpperCase()} Login", 
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)
          ),
          const SizedBox(height: 20),
          // Email Field
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Email Address",
              prefixIcon: Icon(Icons.email),
            ),
          ),
          const SizedBox(height: 15),
          // Password Field
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: "Password",
              prefixIcon: Icon(Icons.lock),
            ),
          ),
          const SizedBox(height: 25),
          
          if (_isLoading)
            const CircularProgressIndicator()
          else
            Column(
              children: [
                // LOGIN BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: const Color(0xFF1B5E20),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _handleEmailAuth(isLogin: true),
                  child: const Text("Login"),
                ),
                const SizedBox(height: 15),
                
                // REGISTER BUTTON
                TextButton(
                  onPressed: () => _handleEmailAuth(isLogin: false),
                  child: const Text("New User? Register Here", style: TextStyle(color: Colors.green)),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // --- LOGIC: Handle Firebase Email Authentication ---
  Future<void> _handleEmailAuth({required bool isLogin}) async {
    // 1. Validate inputs aren't empty
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      if (isLogin) {
        // Sign In using .trim() to fix the "badly formatted" error
        await _auth.signIn(
          email: _emailController.text.trim(), 
          password: _passwordController.text.trim()
        );
      } else {
        // Register new account
        await _auth.signUp(
          email: _emailController.text.trim(), 
          password: _passwordController.text.trim()
        );
      }

      // If successful, the Auth Gate in main.dart will handle navigation,
      // but we add this for extra safety.
      if (mounted) {
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => const DwellerDashboard())
        );
      }
    } catch (e) {
      // Show Error (like "invalid-email" or "wrong-password")
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: ${e.toString()}"), 
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}