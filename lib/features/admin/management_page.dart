import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/services/bus_service.dart';
import '../../core/models/bus.dart';
import '../../core/models/bus_route.dart';
import '../../core/theme/app_theme.dart';
import '../../shared/widgets/custom_button.dart';
import '../../shared/widgets/custom_text_field.dart';

class ManagementPage extends StatefulWidget {
  const ManagementPage({super.key});

  @override
  State<ManagementPage> createState() => _ManagementPageState();
}

class _ManagementPageState extends State<ManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late BusService _busService;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _busService = Provider.of<BusService>(context, listen: false);
    _busService.initialize();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Management'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.directions_bus), text: 'Buses'),
            Tab(icon: Icon(Icons.route), text: 'Routes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          BusManagementTab(),
          RouteManagementTab(),
        ],
      ),
    );
  }
}

class BusManagementTab extends StatelessWidget {
  const BusManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BusService>(
      builder: (context, busService, child) {
        if (busService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Buses (${busService.buses.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddBusDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Bus'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: busService.buses.isEmpty
                  ? const Center(
                      child: Text(
                        'No buses added yet.\nTap "Add Bus" to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: busService.buses.length,
                      itemBuilder: (context, index) {
                        final bus = busService.buses[index];
                        return _buildBusCard(context, bus);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBusCard(BuildContext context, Bus bus) {
    final busService = Provider.of<BusService>(context, listen: false);
    final route = busService.getRouteById(bus.routeId);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
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
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete')],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditBusDialog(context, bus);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(context, bus);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.person, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Driver: ${bus.driverName}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(bus.driverPhone),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.people, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Capacity: ${bus.capacity} passengers'),
              ],
            ),
            if (route != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.route, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text('Route: ${route.routeName}'),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddBusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddBusDialog(),
    );
  }

  void _showEditBusDialog(BuildContext context, Bus bus) {
    showDialog(
      context: context,
      builder: (context) => AddBusDialog(bus: bus),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Bus bus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Bus'),
        content: Text('Are you sure you want to delete bus ${bus.busNumber}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final busService = Provider.of<BusService>(context, listen: false);
              final success = await busService.deleteBus(bus.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Bus deleted successfully' : 'Failed to delete bus'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddBusDialog extends StatefulWidget {
  final Bus? bus;

  const AddBusDialog({super.key, this.bus});

  @override
  State<AddBusDialog> createState() => _AddBusDialogState();
}

class _AddBusDialogState extends State<AddBusDialog> {
  final _formKey = GlobalKey<FormState>();
  final _busNumberController = TextEditingController();
  final _driverNameController = TextEditingController();
  final _driverPhoneController = TextEditingController();
  final _driverEmailController = TextEditingController();
  final _capacityController = TextEditingController();
  String? _selectedRouteId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.bus != null) {
      _busNumberController.text = widget.bus!.busNumber;
      _driverNameController.text = widget.bus!.driverName;
      _driverPhoneController.text = widget.bus!.driverPhone;
      _driverEmailController.text = widget.bus!.driverEmail;
      _capacityController.text = widget.bus!.capacity.toString();
      _selectedRouteId = widget.bus!.routeId;
    }
  }

  @override
  void dispose() {
    _busNumberController.dispose();
    _driverNameController.dispose();
    _driverPhoneController.dispose();
    _driverEmailController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.bus == null ? 'Add Bus' : 'Edit Bus'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Bus Number',
                  hint: 'e.g., BUS001',
                  controller: _busNumberController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter bus number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Driver Name',
                  hint: 'Enter driver full name',
                  controller: _driverNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter driver name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Driver Phone',
                  hint: 'Enter driver phone number',
                  controller: _driverPhoneController,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter driver phone';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Driver Email',
                  hint: 'Enter driver email',
                  controller: _driverEmailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter driver email';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Capacity',
                  hint: 'Number of passengers',
                  controller: _capacityController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter capacity';
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return 'Please enter a valid number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Consumer<BusService>(
                  builder: (context, busService, child) {
                    return DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Route',
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedRouteId,
                      items: busService.routes.map((route) {
                        return DropdownMenuItem(
                          value: route.id,
                          child: Text(route.routeName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedRouteId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a route';
                        }
                        return null;
                      },
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CustomButton(
          text: widget.bus == null ? 'Add Bus' : 'Update Bus',
          onPressed: _isLoading ? () {} : _handleSubmit,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final busService = Provider.of<BusService>(context, listen: false);
    bool success;

    if (widget.bus == null) {
      // Add new bus
      success = await busService.addBus(
        busNumber: _busNumberController.text.trim(),
        driverName: _driverNameController.text.trim(),
        driverPhone: _driverPhoneController.text.trim(),
        driverEmail: _driverEmailController.text.trim(),
        capacity: int.parse(_capacityController.text),
        routeId: _selectedRouteId!,
      );
    } else {
      // Update existing bus
      final updatedBus = widget.bus!.copyWith(
        busNumber: _busNumberController.text.trim(),
        driverName: _driverNameController.text.trim(),
        driverPhone: _driverPhoneController.text.trim(),
        driverEmail: _driverEmailController.text.trim(),
        capacity: int.parse(_capacityController.text),
        routeId: _selectedRouteId!,
        updatedAt: DateTime.now(),
      );
      success = await busService.updateBus(updatedBus);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? '${widget.bus == null ? 'Bus added' : 'Bus updated'} successfully' 
            : 'Failed to ${widget.bus == null ? 'add' : 'update'} bus'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}

class RouteManagementTab extends StatelessWidget {
  const RouteManagementTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<BusService>(
      builder: (context, busService, child) {
        if (busService.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Routes (${busService.routes.length})',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () => _showAddRouteDialog(context),
                    icon: const Icon(Icons.add),
                    label: const Text('Add Route'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: busService.routes.isEmpty
                  ? const Center(
                      child: Text(
                        'No routes added yet.\nTap "Add Route" to get started.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: busService.routes.length,
                      itemBuilder: (context, index) {
                        final route = busService.routes[index];
                        return _buildRouteCard(context, route);
                      },
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRouteCard(BuildContext context, BusRoute route) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    route.routeName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [Icon(Icons.delete, color: Colors.red), SizedBox(width: 8), Text('Delete')],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditRouteDialog(context, route);
                    } else if (value == 'delete') {
                      _showDeleteRouteConfirmation(context, route);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.green[600]),
                const SizedBox(width: 4),
                Text('From: ${route.pickupLocation}'),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.location_on, size: 16, color: Colors.red[600]),
                const SizedBox(width: 4),
                Text('To: ${route.dropLocation}'),
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
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.straighten, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text('Distance: ${route.distance.toStringAsFixed(1)} km'),
              ],
            ),
            if (route.intermediateStops.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Intermediate Stops (${route.intermediateStops.length}):',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              ...route.intermediateStops.map((stop) => Padding(
                padding: const EdgeInsets.only(left: 16, top: 2),
                child: Row(
                  children: [
                    Icon(Icons.stop_circle, size: 12, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text('${stop.name} - ${stop.estimatedTime}'),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddRouteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const AddRouteDialog(),
    );
  }

  void _showEditRouteDialog(BuildContext context, BusRoute route) {
    showDialog(
      context: context,
      builder: (context) => AddRouteDialog(route: route),
    );
  }

  void _showDeleteRouteConfirmation(BuildContext context, BusRoute route) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Route'),
        content: Text('Are you sure you want to delete route "${route.routeName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final busService = Provider.of<BusService>(context, listen: false);
              final success = await busService.deleteRoute(route.id);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Route deleted successfully' : 'Failed to delete route'),
                    backgroundColor: success ? Colors.green : Colors.red,
                  ),
                );
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class AddRouteDialog extends StatefulWidget {
  final BusRoute? route;

  const AddRouteDialog({super.key, this.route});

  @override
  State<AddRouteDialog> createState() => _AddRouteDialogState();
}

class _AddRouteDialogState extends State<AddRouteDialog> {
  final _formKey = GlobalKey<FormState>();
  final _routeNameController = TextEditingController();
  final _pickupLocationController = TextEditingController();
  final _dropLocationController = TextEditingController();
  final _estimatedDurationController = TextEditingController();
  final _distanceController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.route != null) {
      _routeNameController.text = widget.route!.routeName;
      _pickupLocationController.text = widget.route!.pickupLocation;
      _dropLocationController.text = widget.route!.dropLocation;
      _estimatedDurationController.text = widget.route!.estimatedDuration;
      _distanceController.text = widget.route!.distance.toString();
    }
  }

  @override
  void dispose() {
    _routeNameController.dispose();
    _pickupLocationController.dispose();
    _dropLocationController.dispose();
    _estimatedDurationController.dispose();
    _distanceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.route == null ? 'Add Route' : 'Edit Route'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  label: 'Route Name',
                  hint: 'e.g., Main Campus to City Center',
                  controller: _routeNameController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter route name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Pickup Location',
                  hint: 'Starting point',
                  controller: _pickupLocationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter pickup location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Drop Location',
                  hint: 'Ending point',
                  controller: _dropLocationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter drop location';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Estimated Duration',
                  hint: 'e.g., 45 minutes',
                  controller: _estimatedDurationController,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter estimated duration';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                CustomTextField(
                  label: 'Distance (km)',
                  hint: 'e.g., 15.5',
                  controller: _distanceController,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter distance';
                    }
                    if (double.tryParse(value) == null || double.parse(value) <= 0) {
                      return 'Please enter a valid distance';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        CustomButton(
          text: widget.route == null ? 'Add Route' : 'Update Route',
          onPressed: _isLoading ? () {} : _handleSubmit,
          isLoading: _isLoading,
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    final busService = Provider.of<BusService>(context, listen: false);
    bool success;

    if (widget.route == null) {
      // Add new route
      success = await busService.addRoute(
        routeName: _routeNameController.text.trim(),
        pickupLocation: _pickupLocationController.text.trim(),
        dropLocation: _dropLocationController.text.trim(),
        intermediateStops: [], // For now, we'll add stops later
        estimatedDuration: _estimatedDurationController.text.trim(),
        distance: double.parse(_distanceController.text),
      );
    } else {
      // Update existing route
      final updatedRoute = widget.route!.copyWith(
        routeName: _routeNameController.text.trim(),
        pickupLocation: _pickupLocationController.text.trim(),
        dropLocation: _dropLocationController.text.trim(),
        estimatedDuration: _estimatedDurationController.text.trim(),
        distance: double.parse(_distanceController.text),
        updatedAt: DateTime.now(),
      );
      success = await busService.updateRoute(updatedRoute);
    }

    setState(() {
      _isLoading = false;
    });

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success 
            ? '${widget.route == null ? 'Route added' : 'Route updated'} successfully' 
            : 'Failed to ${widget.route == null ? 'add' : 'update'} route'),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }
}