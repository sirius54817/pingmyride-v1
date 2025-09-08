

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/models/user_type.dart';
import '../../core/models/bus.dart';
import '../../core/models/bus_route.dart';
import '../../core/services/bus_service.dart';
import '../../core/theme/app_theme.dart';

class HomePage extends StatefulWidget {
  final UserType userType;

  const HomePage({super.key, required this.userType});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    // Initialize bus service data when page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BusService>(context, listen: false).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.userType.label} Dashboard'),
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
      body: widget.userType == UserType.student 
        ? _buildStudentDashboard() 
        : _buildOtherUserDashboard(),
    );
  }

  Widget _buildStudentDashboard() {
    return Consumer<BusService>(
      builder: (context, busService, child) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWelcomeCard(),
              const SizedBox(height: 24),
              Text(
                'Available Buses',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: busService.isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : busService.buses.isEmpty
                    ? const Center(
                        child: Text(
                          'No buses available at the moment.\nPlease check back later.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: busService.buses.length,
                        itemBuilder: (context, index) {
                          final bus = busService.buses[index];
                          final route = busService.getRouteById(bus.routeId);
                          return _buildBusCard(bus, route);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOtherUserDashboard() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeCard(),
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
              children: _getQuickActions(widget.userType),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeCard() {
    return Container(
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
            'You are logged in as ${widget.userType.label}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBusCard(Bus bus, BusRoute? route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: bus.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    bus.busNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  bus.isActive ? Icons.check_circle : Icons.pause_circle,
                  color: bus.isActive ? Colors.green : Colors.grey,
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (route != null) ...[
              Row(
                children: [
                  Icon(Icons.route, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Expanded(child: Text(route.routeName, style: const TextStyle(fontWeight: FontWeight.w500))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.green[600]),
                  const SizedBox(width: 4),
                  Expanded(child: Text('From: ${route.pickupLocation}')),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.red[600]),
                  const SizedBox(width: 4),
                  Expanded(child: Text('To: ${route.dropLocation}')),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.access_time, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('Duration: ${route.estimatedDuration}'),
                ],
              ),
              if (route.intermediateStops.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  'Stops: ${route.intermediateStops.map((s) => s.name).join(', ')}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Driver: ${bus.driverName}'),
                const Spacer(),
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('${bus.capacity} seats'),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: bus.isActive ? () {
                  // TODO: Implement bus tracking/booking
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Bus tracking feature coming soon!')),
                  );
                } : null,
                icon: const Icon(Icons.location_on),
                label: Text(bus.isActive ? 'Track Bus' : 'Bus Inactive'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: bus.isActive ? AppTheme.primaryColor : Colors.grey,
                ),
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