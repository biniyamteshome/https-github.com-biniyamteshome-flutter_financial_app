import 'package:flutter/material.dart';

void main() => runApp(const GlobalFinancialApp());

class GlobalFinancialApp extends StatelessWidget {
  const GlobalFinancialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Global Multi-Currency Financial App',
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const GlobalTransactionScreen(),
    );
  }
}

class GlobalTransactionScreen extends StatefulWidget {
  const GlobalTransactionScreen({super.key});

  @override
  _GlobalTransactionScreenState createState() => _GlobalTransactionScreenState();
}

class _GlobalTransactionScreenState extends State<GlobalTransactionScreen> {
  int _currentStep = 0;

  // Controllers
  final TextEditingController _senderController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _receiverController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Selection variables
  String _selectedBankOrWallet = 'Commercial Bank of Ethiopia (CBE) & All Banks';
  String _selectedCurrency = 'ETB (Birr)';
  String _transactionType = 'Transit (مشتريات/ዝውውር)';

  // Mock Daily Exchange Rates (በዕለቱ የገበያ ተመን በራሱ የሚሰራ)
  final Map<String, double> _dailyExchangeRates = {
    'USD (ዶላር)': 125.50, // ဥပማ ተመን
    'SAR (ሳውዲ ሪያል)': 33.40,
    'QAR (ኳተር ሪያል)': 34.20,
    'AED (ድሀም)': 34.15,
    'ETB (Birr)': 1.0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Global Multi-Currency & Bank App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.admin_panel_settings),
            onPressed: () => _showAdminWalletLogin(context),
          )
        ],
      ),
      body: Stepper(
        type: StepperType.vertical,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 3) {
            setState(() => _currentStep += 1);
          } else {
            _processGlobalTransaction();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          }
        },
        steps: [
          // Step 1: Sender & Currency Selection
          Step(
            title: const Text('1. ላኪ እና የገንዘብ ዓይነት (Sender & Currency)'),
            content: Column(
              children: [
                TextField(
                  controller: _senderController,
                  decoration: const InputDecoration(
                    labelText: 'የላኪ ስልክ ወይም አካውንት (ဥፍ. 0919212112)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _selectedCurrency,
                  items: ['ETB (Birr)', 'USD (ዶላር)', 'SAR (ሳውዲ ሪያል)', 'QAR (ኳተር ሪያል)', 'AED (ድሀም)']
                      .map((cur) => DropdownMenuItem(value: cur, child: Text(cur)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedCurrency = val!),
                  decoration: const InputDecoration(
                    labelText: 'የመገበያያ ገንዘብ ዓይነት (Currency)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          // Step 2: All Banks, Transaction Type & Amount
          Step(
            title: const Text('2. ባንክ፣ የግብይት ዓይነት እና መጠን'),
            content: Column(
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedBankOrWallet,
                  items: [
                    'Commercial Bank of Ethiopia (CBE) & All Banks',
                    'Telebirr / M-Pesa / Wallets',
                    'Awash Bank / Abyssinia / Dashen',
                    'Global & International Banks'
                  ]
                      .map((bank) => DropdownMenuItem(value: bank, child: Text(bank)))
                      .toList(),
                  onChanged: (val) => setState(() => _selectedBankOrWallet = val!),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  value: _transactionType,
                  items: ['Transit (መደበኛ ዝውውር)', 'Loan (ብድር)']
                      .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                      .toList(),
                  onChanged: (val) => setState(() => _transactionType = val!),
                  decoration: const InputDecoration(border: OutlineInputBorder()),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'የብር/የውጭ ምንዛሬ መጠን ($_selectedCurrency)',
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),

          // Step 3: Recipient Account / Phone
          Step(
            title: const Text('3. ተቀባይ አካውንት (Recipient Account)'),
            content: TextField(
              controller: _receiverController,
              decoration: const InputDecoration(
                labelText: 'የተቀባይ አካውንት ወይም ስልክ ቁጥር',
                border: OutlineInputBorder(),
              ),
            ),
          ),

          // Step 4: Secure Cybersecurity Password Confirmation
          Step(
            title: const Text('4. የደህንነት ማረጋገጫ (Cybersecurity Password)'),
            content: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'ሚስጥራዊ የይለፍ ቃል (Text Password Only)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _processGlobalTransaction() {
    // Automatic Currency Rate Calculation & Conversion to ETB
    double enteredAmount = double.tryParse(_amountController.text) ?? 0.0;
    double rate = _dailyExchangeRates[_selectedCurrency] ?? 1.0;
    double convertedToBirr = enteredAmount * rate;

    // Automatic hidden commission for App Owner Wallet
    // Transit vs Loan different cuts calculation happens securely on server.

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ግብይቱ በተሳካ ሁኔታ ተከናውኗል!'),
        content: Text(
          'የገባው ገንዘብ: $enteredAmount $_selectedCurrency\n'
          'የዕለቱ ተመን: $rate\n'
          'ወደ ብር ተቀይሮ የተላከው: ${convertedToBirr.toStringAsFixed(2)} ETB\n\n'
          'ማስታወሻ፡ የኮሚሽን ቅናሽ እና የባንክ ዝውውር በአስተማማኝ ሁኔታ አልቋል።',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('እሺ'),
          ),
        ],
      ),
    );
  }

  void _showAdminWalletLogin(BuildContext context) {
    TextEditingController adminPassCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('የአፕ ባለቤት መቆጣጠሪያ (Admin Wallet & Rates)'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('የዕለቱን የምንዛሬ ተመን እና የተከማቸ የኮሚሽን ቦርሳ ለማየት ያስችላል።'),
            const SizedBox(height: 10),
            TextField(
              controller: adminPassCtrl,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Strong Admin Password',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ግባ (Login)'),
          ),
        ],
      ),
    );
  }
}a
