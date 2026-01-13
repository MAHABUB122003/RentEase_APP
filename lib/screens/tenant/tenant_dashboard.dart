import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/models/bill.dart';
import 'package:rentease_simple/providers/auth_provider.dart';
import 'package:rentease_simple/providers/theme_provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/screens/tenant/payment_screen.dart';
import 'package:rentease_simple/screens/tenant/history_screen.dart';
// contact_screen removed in favor of landlord profile / messaging
import 'package:rentease_simple/screens/tenant/tenant_landlord_profile.dart';
import 'package:rentease_simple/screens/tenant/help_screen.dart';
import 'package:rentease_simple/screens/auth/login_screen.dart';
import 'package:rentease_simple/utils/format.dart';
import 'package:rentease_simple/widgets/custom_button.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  int _selectedIndex = 0;

  Widget _buildHomeScreen(AuthProvider authProvider, PaymentProvider paymentProvider) {
    // Get ONLY this tenant's bills
    final currentTenantId = authProvider.currentUser?.id ?? '';
    final pendingBills = paymentProvider.getPendingBillsForSpecificTenant(currentTenantId);
    final totalPending = paymentProvider.getTotalPendingAmountForTenant(currentTenantId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF2C3E50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello, ${authProvider.currentUser?.name ?? 'Tenant'}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Welcome to RentEase',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: 'Pending Bills',
                  value: pendingBills.length.toString(),
                  color: Colors.orange,
                  icon: Icons.pending_actions,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  title: 'Total Due',
                  value: AppFormat.formatCurrency(totalPending),
                  color: Colors.red,
                  icon: Icons.attach_money,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
                  _buildActionCard(
                    title: 'Pay Now',
                    icon: Icons.payment,
                    color: Colors.green,
                    onTap: () {
                      if (pendingBills.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PaymentScreen(
                              billId: pendingBills.first.id,
                              amount: pendingBills.first.totalAmount,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  _buildActionCard(
                    title: 'View History',
                    icon: Icons.history,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HistoryScreen()),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Landlord',
                    icon: Icons.person_search,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => TenantLandlordProfile()),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Help',
                    icon: Icons.help,
                    color: Colors.orange,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const HelpScreen()),
                      );
                    },
                  ),
            ],
          ),
          const SizedBox(height: 20),

          // Pending Bills Section
          const Text(
            'Pending Bills',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Builder(builder: (context) {
            // Get only THIS tenant's pending bills
            final currentTenantId = authProvider.currentUser?.id ?? '';
            final pendingBillsList = paymentProvider.getPendingBillsForSpecificTenant(currentTenantId);
            if (pendingBillsList.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 48),
                        const SizedBox(height: 10),
                        const Text(
                          'No Pending Bills',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        const SizedBox(height: 5),
                        const Text(
                          'All your bills are paid! Great job.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Column(
              children: pendingBillsList.map((bill) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Icon(
                      Icons.receipt_long,
                      color: Colors.orange,
                    ),
                    title: Text('Bill #${bill.id.substring(0, 8)}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text('Due: ${AppFormat.formatDate(bill.dueDate)}'),
                        Text('Amount: ${AppFormat.formatCurrency(bill.totalAmount)}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PAY NOW',
                        style: TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(billId: bill.id, amount: bill.totalAmount),
                        ),
                      );
                    },
                  ),
                );
              }).toList(),
            );
          }),

          const SizedBox(height: 20),

          // Paid Bills Section
          const Text(
            'Payment History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Builder(builder: (context) {
            // Get only THIS tenant's paid bills
            final currentTenantId = authProvider.currentUser?.id ?? '';
            final paidBillsList = paymentProvider.getPaidBillsForSpecificTenant(currentTenantId);
            if (paidBillsList.isEmpty) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Center(
                    child: Text('No paid bills yet'),
                  ),
                ),
              );
            }

            return Column(
              children: paidBillsList.map((bill) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
                    leading: Icon(
                      Icons.check_circle,
                      color: Colors.green,
                    ),
                    title: Text('Bill #${bill.id.substring(0, 8)} - Paid'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text('Paid on: ${AppFormat.formatDate(bill.paidDate ?? DateTime.now())}'),
                        Text('Amount: ${AppFormat.formatCurrency(bill.totalAmount)}'),
                      ],
                    ),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'PAID',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildBillsScreen(PaymentProvider paymentProvider) {
    final allBills = paymentProvider.bills;

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: allBills.length,
      itemBuilder: (context, index) {
        final bill = allBills[index];
        return _buildBillCard(bill, showActions: true);
      },
    );
  }

  Widget _buildProfileScreen(AuthProvider authProvider) {
    final user = authProvider.currentUser;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF2C3E50),
                  child: Text(
                    (user?.name ?? 'T').substring(0, 1),
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user?.name ?? 'Tenant',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  user?.email ?? 'No email',
                  style: const TextStyle(
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 20),
                ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text('Phone'),
                  subtitle: Text(user?.phone ?? 'Not provided'),
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('Role'),
                  subtitle: Text(user?.role.toUpperCase() ?? 'Tenant'),
                ),
                const SizedBox(height: 12),
                Consumer<ThemeProvider>(builder: (context, theme, child) {
                  return SwitchListTile(
                    title: const Text('Dark Mode'),
                    value: theme.isDark,
                    onChanged: (_) => theme.toggle(),
                    secondary: const Icon(Icons.dark_mode),
                  );
                }),
                const SizedBox(height: 8),
                CustomButton(
                  text: 'Logout',
                  onPressed: () {
                    authProvider.logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                  color: Colors.red,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color),
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 10),
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBillCard(Bill bill, {bool showActions = false}) {
    final isOverdue = bill.dueDate.isBefore(DateTime.now()) && bill.status == 'pending';

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bill #${bill.id}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? Colors.red.withOpacity(0.1)
                        : bill.status == 'paid'
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOverdue
                        ? 'OVERDUE'
                        : bill.status.toUpperCase(),
                    style: TextStyle(
                      color: isOverdue
                          ? Colors.red
                          : bill.status == 'paid'
                              ? Colors.green
                              : Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Due Date: ${AppFormat.formatDate(bill.dueDate)}'),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rent: ${AppFormat.formatCurrency(bill.rentAmount)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Electricity: ${AppFormat.formatCurrency(bill.electricityBill)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Water: ${AppFormat.formatCurrency(bill.waterBill)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      Text(
                        'Gas: ${AppFormat.formatCurrency(bill.gasBill)}',
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  AppFormat.formatCurrency(bill.totalAmount),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (showActions && bill.status == 'pending')
              Column(
                children: [
                  const SizedBox(height: 15),
                  CustomButton(
                    text: 'Pay Now',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PaymentScreen(
                            billId: bill.id,
                            amount: bill.totalAmount,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final paymentProvider = Provider.of<PaymentProvider>(context);

    final List<Widget> _screens = [
      _buildHomeScreen(authProvider, paymentProvider),
      _buildBillsScreen(paymentProvider),
      _buildProfileScreen(authProvider),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('RentEase - Tenant'),
        backgroundColor: const Color(0xFF2C3E50),
        foregroundColor: Colors.white,
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt),
            label: 'Bills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}