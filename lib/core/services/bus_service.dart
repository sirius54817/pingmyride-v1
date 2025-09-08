import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/bus.dart';
import '../models/bus_route.dart';
import '../models/booking.dart';

class BusService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Bus> _buses = [];
  List<BusRoute> _routes = [];
  List<Booking> _userBookings = [];
  bool _isLoading = false;

  List<Bus> get buses => _buses;
  List<BusRoute> get routes => _routes;
  List<Booking> get userBookings => _userBookings;
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
      fetchUserBookings(),
    ]);
  }

  // Booking operations
  Future<bool> bookBus(Bus bus, BusRoute route) async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        debugPrint('User not authenticated');
        return false;
      }

      if (!bus.hasAvailableSeats) {
        debugPrint('No available seats on bus ${bus.busNumber}');
        return false;
      }

      _isLoading = true;
      notifyListeners();

      // Check if user already has a booking for this bus
      final existingBooking = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .where('busId', isEqualTo: bus.id)
          .where('status', isEqualTo: BookingStatus.confirmed.name)
          .get();

      if (existingBooking.docs.isNotEmpty) {
        debugPrint('User already has a booking for this bus');
        return false;
      }

      // Get user profile for booking details
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};

      // Create booking
      final booking = Booking(
        id: '', // Will be set by Firestore
        userId: user.uid,
        userName: userData['name'] ?? 'Unknown',
        userEmail: user.email ?? '',
        busId: bus.id,
        routeId: route.id,
        busNumber: bus.busNumber,
        routeName: route.routeName,
        bookingDate: DateTime.now(),
        pickupLocation: route.pickupLocation,
        dropLocation: route.dropLocation,
        driverName: bus.driverName,
        driverPhone: bus.driverPhone,
        createdAt: DateTime.now(),
      );

      // Use a transaction to ensure data consistency
      await _firestore.runTransaction((transaction) async {
        // Check bus capacity again within transaction
        final busRef = _firestore.collection('buses').doc(bus.id);
        final busSnapshot = await transaction.get(busRef);
        
        if (!busSnapshot.exists) {
          throw Exception('Bus not found');
        }
        
        final currentBus = Bus.fromMap(busSnapshot.data()!, busSnapshot.id);
        if (!currentBus.hasAvailableSeats) {
          throw Exception('No available seats');
        }

        // Create booking document
        final bookingRef = _firestore.collection('bookings').doc();
        transaction.set(bookingRef, booking.toMap());

        // Update bus booked seats count
        transaction.update(busRef, {
          'bookedSeats': currentBus.bookedSeats + 1,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      // Refresh data
      await Future.wait([
        fetchBuses(),
        fetchUserBookings(),
      ]);

      return true;
    } catch (e) {
      debugPrint('Error booking bus: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(Booking booking) async {
    try {
      final user = _auth.currentUser;
      if (user == null || user.uid != booking.userId) {
        debugPrint('Unauthorized to cancel this booking');
        return false;
      }

      _isLoading = true;
      notifyListeners();

      // Use a transaction to ensure data consistency
      await _firestore.runTransaction((transaction) async {
        // Update booking status
        final bookingRef = _firestore.collection('bookings').doc(booking.id);
        transaction.update(bookingRef, {
          'status': BookingStatus.cancelled.name,
          'cancelledAt': FieldValue.serverTimestamp(),
        });

        // Update bus booked seats count
        final busRef = _firestore.collection('buses').doc(booking.busId);
        final busSnapshot = await transaction.get(busRef);
        
        if (busSnapshot.exists) {
          final currentBus = Bus.fromMap(busSnapshot.data()!, busSnapshot.id);
          transaction.update(busRef, {
            'bookedSeats': (currentBus.bookedSeats - 1).clamp(0, currentBus.capacity),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });

      // Refresh data
      await Future.wait([
        fetchBuses(),
        fetchUserBookings(),
      ]);

      return true;
    } catch (e) {
      debugPrint('Error cancelling booking: $e');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserBookings() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        _userBookings = [];
        return;
      }

      final querySnapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .get();

      _userBookings = querySnapshot.docs
          .map((doc) => Booking.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      debugPrint('Error fetching user bookings: $e');
      _userBookings = [];
    }
  }

  // Get confirmed bookings for current user
  List<Booking> get confirmedBookings => _userBookings
      .where((booking) => booking.status == BookingStatus.confirmed)
      .toList();

  // Check if user has booking for a specific bus
  bool hasBookingForBus(String busId) {
    return _userBookings.any((booking) =>
        booking.busId == busId && booking.status == BookingStatus.confirmed);
  }

  // Get bus by ID
  Bus? getBusById(String busId) {
    try {
      return _buses.firstWhere((bus) => bus.id == busId);
    } catch (e) {
      return null;
    }
  }
}