import 'package:flutter/material.dart';
import 'package:financebook/screens/history.dart';
import 'package:financebook/screens/home_screen.dart';
import 'package:financebook/screens/login_screen.dart';
import 'package:financebook/screens/add_transaction_screen.dart';
import 'package:financebook/screens/setting_screen.dart';
import 'package:financebook/services/authentication_service.dart';
import 'package:financebook/db/database.dart';
import 'package:financebook/services/data_service.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await dotenv.load();

  final databaseHelper = HiveDatabaseHelper();
  await databaseHelper.initDatabase();

  final authService = AuthenticationService(databaseHelper);
  final dataService = DataService(databaseHelper);
  final isLoggedIn = await authService.isUserLoggedIn();
  runApp(
    MainApp(
        authService: authService,
        dataService: dataService,
        isLoggedIn: isLoggedIn),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({
    Key? key,
    required this.authService,
    required this.dataService,
    required this.isLoggedIn,
  }) : super(key: key);

  final AuthenticationService authService;
  final DataService dataService;
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Finance Book',
      theme: ThemeData.light(), // Use ThemeData.light() for the light theme
      darkTheme: ThemeData.dark(), // Use ThemeData.dark() for the dark theme
      themeMode: ThemeMode.dark, 
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(isLoggedIn: isLoggedIn),
        '/login': (context) => LoginScreen(authService: authService),
        '/home': (context) =>
            HomeScreen(authService: authService, dataService: dataService),
        '/add_transaction': (context) => AddTransactionScreen(
              transactionType: ModalRoute.of(context)!.settings.arguments,
              dataService: dataService,
            ),
        '/history': (context) => HistoryScreen(dataService: dataService),
        '/settings': (context) => SettingScreen(authService: authService),
      },
    );
  }
}
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key, required this.isLoggedIn}) : super(key: key);
  final bool isLoggedIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Finance Book',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    const Text(
                      'Selamat datang di Finance Book di mana Anda dapat dengan mudah melacak aliran kas Anda. Siap? Silakan login untuk memulai.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                )),
            
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (isLoggedIn) {
                  Navigator.of(context).pushNamed('/home');
                } else {
                  Navigator.of(context).pushNamed('/login');
                }
              },
              child: Text(isLoggedIn ? 'Continue' : 'Login'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purpleAccent,

                elevation: 5,
                padding: EdgeInsets.all(24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                minimumSize:
                    Size(200, 50), // Set the width and height of the button
              ),
            ),
          ],
        ),
      ),
    );
  }
}
