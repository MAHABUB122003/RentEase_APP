import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rentease_simple/providers/auth_provider.dart';
import 'package:rentease_simple/providers/payment_provider.dart';
import 'package:rentease_simple/screens/landlord/create_bill_screen.dart';
import 'package:rentease_simple/utils/format.dart';
import 'package:rentease_simple/providers/theme_provider.dart';
import 'package:rentease_simple/screens/landlord/view_tenants_screen.dart';
import 'package:rentease_simple/screens/landlord/properties_screen.dart';
import 'package:rentease_simple/screens/landlord/reports_screen.dart';
import 'package:flutter/services.dart';
import 'package:rentease_simple/widgets/custom_button.dart';

class LandlordDashboard extends StatefulWidget {
  const LandlordDashboard({super.key});

  @override
  State<LandlordDashboard> createState() => _LandlordDashboardState();
}

class _LandlordDashboardState extends State<LandlordDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const _LandlordHomeScreen(),
    const CreateBillScreen(),
    const _LandlordProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('RentEase - Landlord'),
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
            icon: Icon(Icons.add_circle),
            label: 'Create Bill',
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

class _LandlordHomeScreen extends StatelessWidget {
  const _LandlordHomeScreen();

  @override
  Widget build(BuildContext context) {
    final paymentProvider = Provider.of<PaymentProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    final totalCollected = paymentProvider.getTotalCollected();
    final activeTenants = paymentProvider.getActiveTenantsCount();
    final propertiesCount = paymentProvider.getPropertiesCount();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome Card
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
                  'Welcome, ${authProvider.currentUser?.name ?? 'Landlord'}!',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Manage your properties and tenants',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Stats
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _buildStatCard(
                title: 'Total Collected',
                value: AppFormat.formatCurrency(totalCollected),
                color: Colors.green,
                icon: Icons.attach_money,
              ),
              _buildStatCard(
                title: 'Active Tenants',
                value: activeTenants.toString(),
                color: Colors.blue,
                icon: Icons.people,
              ),
              _buildStatCard(
                title: 'Pending Bills',
                value: paymentProvider.getPendingBills().length.toString(),
                color: Colors.orange,
                icon: Icons.pending_actions,
              ),
              _buildStatCard(
                title: 'Properties',
                value: propertiesCount.toString(),
                color: Colors.purple,
                icon: Icons.apartment,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Quick Actions
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
                title: 'Create Bill',
                icon: Icons.add_circle,
                color: Colors.green,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CreateBillScreen(),
                    ),
                  );
                },
              ),
              _buildActionCard(
                title: 'View Tenants',
                icon: Icons.people,
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ViewTenantsScreen()),
                  );
                },
              ),
              _buildActionCard(
                title: 'Send Reminder',
                icon: Icons.notifications,
                color: Colors.orange,
                onTap: () async {
                  // show dialog to pick tenant and send reminder
                  final tenants = paymentProvider.tenants;
                  final tenantId = await showDialog<String?>(
                    context: context,
                    builder: (context) {
                      String? selected;
                      return AlertDialog(
                        title: const Text('Send Reminder'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: tenants.length,
                            itemBuilder: (context, index) {
                              final t = tenants[index];
                              return RadioListTile<String>(
                                title: Text(t['name'] ?? ''),
                                subtitle: Text(t['phone'] ?? ''),
                                value: t['id'],
                                groupValue: selected,
                                onChanged: (v) {
                                  selected = v;
                                  // rebuild dialog
                                  (context as Element).markNeedsBuild();
                                },
                              );
                            },
                          ),
                        ),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                          ElevatedButton(onPressed: () => Navigator.pop(context, selected), child: const Text('Send')),
                        ],
                      );
                    },
                  );

                  if (tenantId != null) {
                    await paymentProvider.sendReminder(tenantId, 'Please pay your pending rent.');
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder sent')));
                  }
                },
              ),
              _buildActionCard(
                title: 'Reports',
                icon: Icons.analytics,
                color: Colors.purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReportsScreen()),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Recent Payments
          const Text(
            'Recent Payments',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          if (paymentProvider.payments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Text('No recent payments'),
                ),
              ),
            )
          else
            ...paymentProvider.payments.take(3).map((payment) {
              return _buildPaymentCard(payment);
            }).toList(),
        ],
      ),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
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

  Widget _buildPaymentCard(Map<String, dynamic> payment) {
    final date = payment['date'] is DateTime
        ? AppFormat.formatDate(payment['date'] as DateTime)
        : 'N/A';

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
                  'Payment #${payment['id'].toString().substring(0, 6)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    (payment['method'] as String).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text('Date: $date'),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppFormat.formatCurrency(payment['amount'] as double),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  'Transaction ID: ${payment['transactionId']}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LandlordProfileScreen extends StatelessWidget {
  const _LandlordProfileScreen();

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
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
                    user?.name.substring(0, 1) ?? 'L',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  user?.name ?? 'Landlord',
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
                  leading: const Icon(Icons.business),
                  title: const Text('Role'),
                  subtitle: Text(user?.role.toUpperCase() ?? 'Landlord'),
                ),
                if (user?.inviteCode != null)
                  ListTile(
                    leading: const Icon(Icons.vpn_key),
                    title: const Text('Invite Code'),
                    subtitle: Text(user!.inviteCode ?? ''),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.copy),
                          tooltip: 'Copy invite code',
                          onPressed: () {
                            final code = user.inviteCode ?? '';
                            Clipboard.setData(ClipboardData(text: code));
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Invite code copied')));
                          },
                        ),
                        TextButton(
                          onPressed: () async {
                            try {
                              final newCode = await authProvider.regenerateInviteCode(user.id);
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('New code: $newCode')));
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                            }
                          },
                          child: const Text('Regenerate'),
                        ),
                      ],
                    ),
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
                const SizedBox(height: 12),
                CustomButton(
                  text: 'View Properties',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const PropertiesScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'View Tenants',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ViewTenantsScreen()),
                    );
                  },
                ),
                const SizedBox(height: 12),
                CustomButton(
                  text: 'Logout',
                  onPressed: () {
                    authProvider.logout();
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
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
}