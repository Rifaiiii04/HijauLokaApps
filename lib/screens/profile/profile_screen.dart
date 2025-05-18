import 'package:flutter/material.dart';
import 'package:hijauloka/config/theme.dart';
import 'package:hijauloka/models/shipping_address.dart';
import 'package:hijauloka/models/user.dart';
import 'package:hijauloka/services/address_service.dart';
import 'package:hijauloka/services/auth_service.dart';
import 'package:hijauloka/services/order_service.dart';
import 'package:hijauloka/widgets/app_header.dart';
import 'package:hijauloka/screens/profile/widgets/profile_card.dart';
import 'package:hijauloka/screens/profile/widgets/order_status_section.dart';
import 'package:hijauloka/screens/profile/widgets/main_address_section.dart';
import 'package:hijauloka/screens/profile/widgets/shipping_addresses_section.dart';
import 'package:hijauloka/screens/profile/widgets/order_history_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final AddressService _addressService = AddressService();
  final OrderService _orderService = OrderService();

  User? _user;
  List<ShippingAddress> _addresses = [];
  Map<String, int> _orderCounts = {
    'pending': 0,
    'processing': 0,
    'shipped': 0,
    'delivered': 0,
  };
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload data when screen becomes visible again
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Change from instance method to static method call
      final isLoggedIn = await AuthService.isLoggedIn();

      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        List<ShippingAddress> addresses = [];

        if (user != null) {
          try {
            addresses = await _addressService.getShippingAddresses();
            // Fetch order counts
            final orderCounts = await _orderService.getOrderCounts();
            if (orderCounts['success'] == true) {
              _orderCounts = Map<String, int>.from(orderCounts['data'] ?? {});
            }
            print("User logged in: ${user.name}"); // Debug print
          } catch (e) {
            print("Error fetching data: $e");
            addresses = [];
          }
        } else {
          print("User is null despite isLoggedIn being true"); // Debug print
          await _authService.logout();
        }

        if (mounted) {
          setState(() {
            _user = user;
            _addresses = addresses;
            _isLoading = false;
          });
        }
      } else {
        print("User is not logged in"); // Debug print
        if (mounted) {
          setState(() {
            _user = null;
            _addresses = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Error in _loadUserData: $e"); // Debug print
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = "Error loading profile: ${e.toString()}";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: const AppHeader(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: const AppHeader(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
      );
    }

    // Jika user belum login, hanya tampil tombol Sign In dan Sign Up
    if (_user == null) {
      return Scaffold(
        appBar: const AppHeader(),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/register');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primaryColor,
                  side: BorderSide(color: AppTheme.primaryColor),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 32,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Jika user sudah login, tampilkan data user seperti biasa
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: const AppHeader(),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Card
              ProfileCard(user: _user!),

              // Order Status
              OrderStatusSection(orderCounts: _orderCounts),

              // Main Address
              MainAddressSection(user: _user!),

              // Shipping Addresses
              ShippingAddressesSection(
                addresses: _addresses,
                onAddressDeleted: (int addressId) async {
                  try {
                    final result = await _addressService.deleteShippingAddress(
                      addressId,
                    );
                    if (result['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Address deleted successfully'),
                        ),
                      );
                      _loadUserData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? 'Failed to delete address',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                onSetPrimary: (int addressId) async {
                  try {
                    final result = await _addressService.setPrimaryAddress(
                      addressId,
                    );
                    if (result['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Address set as primary')),
                      );
                      _loadUserData();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            result['message'] ?? 'Failed to set as primary',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                onAddressAdded: _loadUserData,
              ),

              // Order History
              const OrderHistorySection(),

              // Login/Logout Button
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 24,
                ),
                width: double.infinity,
                child:
                    _user == null
                        ? ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                        : ElevatedButton(
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Logout'),
                                    content: const Text(
                                      'Are you sure you want to logout?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Cancel'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('Logout'),
                                      ),
                                    ],
                                  ),
                            );

                            if (confirmed == true) {
                              await _authService.logout();
                              if (!mounted) return;

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Logged out successfully'),
                                ),
                              );

                              // Refresh the screen to show login button
                              setState(() {
                                _user = null;
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
              ),

              const SizedBox(height: 80), // Space for bottom navigation
            ],
          ),
        ),
      ),
    );
  }
}
