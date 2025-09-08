import 'package:flutter/material.dart';
import '../../core/models/user_type.dart';
import '../../core/theme/app_theme.dart';

class HomePage extends StatelessWidget {
  final UserType userType;

  const HomePage({super.key, required this.userType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${userType.label} Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.account_circle_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.primaryColor,
                    AppTheme.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'You are logged in as ${userType.label}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Quick Actions',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: _getQuickActions(userType),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getQuickActions(UserType userType) {
    switch (userType) {
      case UserType.student:
        return [
          _buildActionCard('Track Bus', Icons.location_on, Colors.blue),
          _buildActionCard('Bus Schedule', Icons.schedule, Colors.green),
          _buildActionCard('Notifications', Icons.notifications, Colors.orange),
          _buildActionCard('Profile', Icons.person, Colors.purple),
        ];
      case UserType.driver:
        return [
          _buildActionCard('Start Route', Icons.play_arrow, Colors.green),
          _buildActionCard('Route Info', Icons.route, Colors.blue),
          _buildActionCard('Students', Icons.group, Colors.orange),
          _buildActionCard('Reports', Icons.assessment, Colors.purple),
        ];
      case UserType.admin:
        return [
          _buildActionCard('Manage Routes', Icons.alt_route, Colors.blue),
          _buildActionCard('Users', Icons.group, Colors.green),
          _buildActionCard('Analytics', Icons.analytics, Colors.orange),
          _buildActionCard('Settings', Icons.settings, Colors.purple),
        ];
    }
  }

  Widget _buildActionCard(String title, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {},
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}