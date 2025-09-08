import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/bus.dart';
import '../models/bus_route.dart';

class BusService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<Bus> _buses = [];
  List<BusRoute> _routes = [];
  bool _isLoading = false;

  List<Bus> get buses => _buses;
  List<BusRoute> get routes => _routes;
  bool get isLoading => _isLoading;

  // Bus operations
  Future<bool> addBus({
    required String busNumber,
    required String driverName,
    required String driverPhone,
    required String driverEmail,
    required int capacity,
    required String routeId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final docRef = await _firestore.collection('buses').add({
        'busNumber': busNumber,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'driverEmail': driverEmail,
        'capacity': capacity,
        'routeId': routeId,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Bus added with ID: ${docRef.id}');
      await fetchBuses(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error adding bus: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateBus(Bus bus) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('buses').doc(bus.id).update({
        ...bus.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await fetchBuses(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error updating bus: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteBus(String busId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('buses').doc(busId).delete();
      await fetchBuses(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error deleting bus: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchBuses() async {
    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('buses')
          .orderBy('createdAt', descending: true)
          .get();

      _buses = querySnapshot.docs
          .map((doc) => Bus.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching buses: $e');
      _buses = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Route operations
  Future<bool> addRoute({
    required String routeName,
    required String pickupLocation,
    required String dropLocation,
    required List<BusStop> intermediateStops,
    required String estimatedDuration,
    required double distance,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final docRef = await _firestore.collection('routes').add({
        'routeName': routeName,
        'pickupLocation': pickupLocation,
        'dropLocation': dropLocation,
        'intermediateStops': intermediateStops.map((stop) => stop.toMap()).toList(),
        'estimatedDuration': estimatedDuration,
        'distance': distance,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      debugPrint('Route added with ID: ${docRef.id}');
      await fetchRoutes(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error adding route: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateRoute(BusRoute route) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('routes').doc(route.id).update({
        ...route.toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await fetchRoutes(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error updating route: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteRoute(String routeId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _firestore.collection('routes').doc(routeId).delete();
      await fetchRoutes(); // Refresh the list
      return true;
    } catch (e) {
      debugPrint('Error deleting route: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchRoutes() async {
    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('routes')
          .orderBy('createdAt', descending: true)
          .get();

      _routes = querySnapshot.docs
          .map((doc) => BusRoute.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching routes: $e');
      _routes = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get route by ID
  BusRoute? getRouteById(String routeId) {
    try {
      return _routes.firstWhere((route) => route.id == routeId);
    } catch (e) {
      return null;
    }
  }

  // Get buses for a specific route
  List<Bus> getBusesForRoute(String routeId) {
    return _buses.where((bus) => bus.routeId == routeId && bus.isActive).toList();
  }

  // Initialize data (call this when service is first used)
  Future<void> initialize() async {
    await Future.wait([
      fetchBuses(),
      fetchRoutes(),
    ]);
  }
}