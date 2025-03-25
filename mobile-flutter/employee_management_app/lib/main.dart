import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/api_service.dart';
import 'services/mock_api_service.dart';
import 'services/api_service_interface.dart';
import 'screens/login_screen.dart';
import 'screens/employee_dashboard.dart';
import 'screens/manager_dashboard.dart';

// Set this to true to use mock data instead of real API
const bool USE_MOCK_API = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize API service
  final ApiServiceInterface apiService = USE_MOCK_API 
      ? MockApiService() 
      : ApiService();
  
  // Check for saved API URL
  final prefs = await SharedPreferences.getInstance();
  final savedUrl = prefs.getString('api_base_url');
  if (savedUrl != null && savedUrl.isNotEmpty && !USE_MOCK_API) {
    ApiService.setBaseUrl(savedUrl);
  }
  
  await apiService.initFromPrefs();
  
  runApp(MyApp(
    apiService: apiService,
  ));
}

class MyApp extends StatelessWidget {
  final ApiServiceInterface apiService;
  
  const MyApp({
    Key? key, 
    required this.apiService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Employee Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder<SharedPreferences>(
        future: SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          
          final prefs = snapshot.data!;
          final token = prefs.getString('auth_token');
          
          if (token == null) {
            return LoginScreen(apiService: apiService);
          } else {
            final isManager = prefs.getBool('is_manager') ?? false;
            
            if (isManager) {
              return ManagerDashboard(
                apiService: apiService,
              );
            } else {
              return EmployeeDashboard(
                apiService: apiService,
              );
            }
          }
        },
      ),
      routes: {
        '/login': (context) => LoginScreen(apiService: apiService),
        '/employee_dashboard': (context) => EmployeeDashboard(
          apiService: apiService,
        ),
        '/manager_dashboard': (context) => ManagerDashboard(
          apiService: apiService,
        ),
      },
    );
  }
}
