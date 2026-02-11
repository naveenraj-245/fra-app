import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../dashboard/dweller_dashboard.dart'; // Green Dashboard
import '../../screens/officer/officer_dashboard.dart';   // Blue Dashboard
import '../../screens/signup_screen.dart';                  // Registration Screen

class LoginScreen extends StatefulWidget {
  final String userRole; // 'officer' or 'dweller' (Determines the Theme Color)

  const LoginScreen({super.key, required this.userRole});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AuthService _auth = AuthService();

  // Text Controllers
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
    // Determine Color Theme based on the requested Role
    final bool isOfficer = widget.userRole == 'officer';
    final Color themeColor = isOfficer ? const Color(0xFF0D47A1) : const Color(0xFF1B5E20);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("${widget.userRole.toUpperCase()} Login"),
        backgroundColor: themeColor,
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
          // TAB 1: Phone Login
          _buildPhoneTab(themeColor),
          
          // TAB 2: Email Login
          _buildEmailTab(themeColor, isOfficer),
        ],
      ),
    );
  }

  // --- UI: Phone Login Tab ---
  Widget _buildPhoneTab(Color color) {
    return Padding(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.phone_android, size: 80, color: color),
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
              backgroundColor: color,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              // Demo Mode: Direct Login for Phone (Skip Auth for now)
              Navigator.pushReplacement(
                context, 
                MaterialPageRoute(builder: (_) => const DwellerDashboard())
              );
            },
            child: const Text("Send OTP (Demo Mode)"),
          ),
        ],
      ),
    );
  }

  // --- UI: Email Login Tab ---
  Widget _buildEmailTab(Color color, bool isOfficer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(25.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Icon(Icons.admin_panel_settings, size: 80, color: color),
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
            CircularProgressIndicator(color: color)
          else
            Column(
              children: [
                // LOGIN BUTTON
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: _handleLogin,
                  child: const Text("Login"),
                ),
                const SizedBox(height: 15),
                
                // REGISTER BUTTON (Only show for Dwellers)
                // Officers are usually pre-registered by Admins
                if (!isOfficer)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SignUpScreen()),
                      );
                    },
                    child: Text("New User? Register Here", style: TextStyle(color: color)),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  // --- LOGIC: Handle Firebase Login ---
  Future<void> _handleLogin() async {
    // 1. Validate inputs
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 2. Sign In & Get Role from Database
      // The AuthService checks Firestore to see if you are 'officer' or 'dweller'
      String? role = await _auth.signIn(
        email: _emailController.text.trim(), 
        password: _passwordController.text.trim()
      );

      if (mounted) {
         // 3. Navigate based on Database Role (Security Check)
         if (role == 'officer') {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OfficerDashboard()));
         } else {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DwellerDashboard()));
         }
      }

    } catch (e) {
      // Handle Errors
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceAll('Exception:', '').trim()), 
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}