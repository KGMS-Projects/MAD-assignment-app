// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Import existing providers
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/products_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/battery_provider.dart';
import 'providers/network_provider.dart'; // 👈 NEW: Network provider

// Import screens
import 'screens/home_screen.dart';
import 'screens/women_screen.dart';
import 'screens/men_screen.dart';
import 'screens/accessories_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/contact_screen.dart';
import 'screens/login_screen.dart';

// Import widgets
import 'widgets/battery_status_indicator.dart';
import 'widgets/network_status_widget.dart'; // 👈 NEW: Network status widget

void main() {
  runApp(const PearlPrestigeApp());
}

class PearlPrestigeApp extends StatelessWidget {
  const PearlPrestigeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductsProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => BatteryProvider()),
        ChangeNotifierProvider(
            create: (_) => NetworkProvider()), // 👈 NEW: Network provider
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          // Initialize battery and network monitoring when app starts
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.read<BatteryProvider>().initialize();
            // Network provider initializes automatically in its constructor
          });

          return MaterialApp(
            title: 'Pearl & Prestige',
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            theme: ThemeProvider.lightTheme,
            darkTheme: ThemeProvider.darkTheme,
            home: const MainScreen(),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/cart': (context) => const CartScreen(),
            },
          );
        },
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    const HomeScreen(),
    const WomenScreen(),
    const MenScreen(),
    const AccessoriesScreen(),
    const ContactScreen(),
  ];

  final List<String> _titles = [
    'Pearl & Prestige',
    'Women',
    'Men',
    'Accessories',
    'Contact',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_currentIndex]),
        centerTitle: true,
        elevation: 0,
        actions: [
          // 👈 NEW: Network status indicator
          const NetworkStatusIndicator(showOnlyWhenOffline: true),

          // Battery status indicator
          const CompactBatteryIndicator(),

          // Cart icon with badge
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart_outlined),
                    onPressed: () => Navigator.pushNamed(context, '/cart'),
                  ),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF8B4513),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),

          // User menu
          Consumer<AuthProvider>(
            builder: (context, auth, child) {
              return PopupMenuButton<String>(
                icon: Icon(
                  auth.isAuthenticated
                      ? Icons.account_circle
                      : Icons.account_circle_outlined,
                ),
                onSelected: (value) async {
                  switch (value) {
                    case 'login':
                      Navigator.pushNamed(context, '/login');
                      break;
                    case 'logout':
                      await auth.logout();
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Logged out successfully'),
                            backgroundColor: Color(0xFF8B4513),
                          ),
                        );
                      }
                      break;
                    case 'battery':
                      _showBatteryInfo(context);
                      break;
                    case 'network': // 👈 NEW: Network info option
                      _showNetworkInfo(context);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  if (!auth.isAuthenticated)
                    const PopupMenuItem(
                      value: 'login',
                      child: Row(
                        children: [
                          Icon(Icons.login),
                          SizedBox(width: 8),
                          Text('Login'),
                        ],
                      ),
                    ),
                  if (auth.isAuthenticated) ...[
                    PopupMenuItem(
                      value: 'profile',
                      child: Row(
                        children: [
                          const Icon(Icons.person),
                          const SizedBox(width: 8),
                          Text(auth.user?['name'] ?? 'Profile'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Logout'),
                        ],
                      ),
                    ),
                  ],
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'battery',
                    child: Row(
                      children: [
                        Icon(Icons.battery_std),
                        SizedBox(width: 8),
                        Text('Battery Status'),
                      ],
                    ),
                  ),
                  // 👈 NEW: Network status menu item
                  const PopupMenuItem(
                    value: 'network',
                    child: Row(
                      children: [
                        Icon(Icons.wifi),
                        SizedBox(width: 8),
                        Text('Network Status'),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 👈 NEW: Network status banner at the top
          const NetworkStatusBanner(),

          // Battery warning widget
          Consumer<BatteryProvider>(
            builder: (context, batteryProvider, child) {
              if (!batteryProvider.shouldShowWarning) {
                return const SizedBox.shrink();
              }
              return Container(
                width: double.infinity,
                color: batteryProvider.isCriticallyLow
                    ? Colors.red.shade100
                    : Colors.orange.shade100,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      batteryProvider.getBatteryIcon(),
                      color: batteryProvider.getBatteryColor(),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Battery ${batteryProvider.batteryLevel}% - Your cart is safely saved',
                        style: TextStyle(
                          color: batteryProvider.isCriticallyLow
                              ? Colors.red.shade800
                              : Colors.orange.shade800,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        batteryProvider.markWarningShown();
                      },
                      child:
                          const Text('Dismiss', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            },
          ),

          // 👈 NEW: Network warning widget (shows when offline)
          const NetworkWarningWidget(),

          // Main content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              children: _screens,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF8B4513),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.woman),
            label: 'Women',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.man),
            label: 'Men',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.diamond),
            label: 'Accessories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: 'Contact',
          ),
        ],
      ),
    );
  }

  // Existing battery info dialog
  void _showBatteryInfo(BuildContext context) {
    final batteryProvider = context.read<BatteryProvider>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              batteryProvider.getBatteryIcon(),
              color: batteryProvider.getBatteryColor(),
            ),
            const SizedBox(width: 12),
            const Text('Battery Information'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.battery_std),
              title: const Text('Battery Level'),
              trailing: Text(
                '${batteryProvider.batteryLevel}%',
                style: TextStyle(
                  color: batteryProvider.getBatteryColor(),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Status'),
              trailing: Text(batteryProvider.getStatusMessage()),
            ),
            if (batteryProvider.isBatteryLow)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Don\'t worry! Your cart items are automatically saved locally.',
                  style: TextStyle(fontSize: 14),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  // 👈 NEW: Network info dialog
  void _showNetworkInfo(BuildContext context) {
    final networkProvider = context.read<NetworkProvider>();

    showDialog(
      context: context,
      builder: (context) =>
          NetworkDetailsDialog(networkProvider: networkProvider),
    );
  }
}
