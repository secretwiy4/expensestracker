import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const ExpenseApp());
}

class ExpenseApp extends StatelessWidget {
  const ExpenseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        scaffoldBackgroundColor: const Color(0xFF1B2E2E),
      ),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (snapshot.hasData) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}


BoxDecoration customGradient() {
  return const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFF3D7A7A), Color(0xFF1B2E2E)],
    ),
  );
}


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future login() async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        width: double.infinity,
        decoration: customGradient(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet, size: 80, color: Colors.white70),
            const SizedBox(height: 20),
            const Text("Welcome Back", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Text("Login to continue", style: TextStyle(color: Colors.white60)),
            const SizedBox(height: 40),
            _inputField("Email", _emailController),
            const SizedBox(height: 15),
            _inputField("Password", _passwordController, isPass: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5CE1E6),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                ),
                onPressed: login,
                child: const Text("Login", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen())),
              child: const Text("Don't have an account? Register", style: TextStyle(color: Colors.white70)),
            )
          ],
        ),
      ),
    );
  }
}

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  Future register() async {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(30),
        width: double.infinity,
        decoration: customGradient(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            _inputField("Email", _emailController),
            const SizedBox(height: 15),
            _inputField("Password", _passwordController, isPass: true),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5CE1E6), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                onPressed: register,
                child: const Text("Register", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            ),
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Already have an account? Login", style: TextStyle(color: Colors.white70)))
          ],
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: const Color(0xFF3D7A7A),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF5CE1E6),
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AddExpenseScreen())),
      ),
      body: Container(
        width: double.infinity,
        decoration: customGradient(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Hi, Adawiyah", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text("Here's your summary", style: TextStyle(color: Colors.white60)),
                      ],
                    ),
                    IconButton(onPressed: () => FirebaseAuth.instance.signOut(), icon: const Icon(Icons.logout, color: Colors.white70))
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                padding: const EdgeInsets.all(25),
                width: double.infinity,
                decoration: BoxDecoration(color: const Color(0xFFD9E8E8), borderRadius: BorderRadius.circular(20)),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Total Spending", style: TextStyle(color: Colors.black54)),
                    Text("RM 450.00", style: TextStyle(color: Colors.black, fontSize: 32, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))
                  ),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('expenses')
                        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser?.uid)
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        padding: const EdgeInsets.all(25),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(data['date'] ?? '', style: const TextStyle(color: Colors.grey, fontSize: 10)),
                                    const SizedBox(height: 4),
                                    Text(data['note'] ?? 'No Note', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                                Text("RM ${data['amount']}", style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}


class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _dateController = TextEditingController(text: "10 May 2026");

  Future saveExpense() async {
    if (_amountController.text.isEmpty) return;
    try {
      await FirebaseFirestore.instance.collection('expenses').add({
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'amount': _amountController.text.trim(),
        'note': _noteController.text.trim(),
        'date': _dateController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Add Expense"), backgroundColor: const Color(0xFF3D7A7A)),
      body: Container(
        padding: const EdgeInsets.all(30),
        width: double.infinity,
        decoration: customGradient(),
        child: Column(
          children: [
            _inputField("Amount (RM)", _amountController),
            const SizedBox(height: 15),
            _inputField("Note", _noteController),
            const SizedBox(height: 15),
            _inputField("Date", _dateController),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF5CE1E6)),
                onPressed: saveExpense,
                child: const Text("Save", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }
}

Widget _inputField(String hint, TextEditingController controller, {bool isPass = false}) {
  return TextField(
    controller: controller,
    obscureText: isPass,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white.withOpacity(0.1),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white54),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    ),
  );
}