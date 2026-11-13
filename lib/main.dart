import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/theme/app_theme.dart';
import 'core/utils/hive_boxes.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/cart/presentation/cubit/cart_cubit.dart';
import 'features/payment/data/models/payment_model.dart';
import 'features/payment/data/repositories/payment_repository.dart';
import 'features/payment/presentation/cubit/payment_cubit.dart';
import 'features/product/presentation/screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ));

  await Hive.initFlutter();
  Hive.registerAdapter(PaymentModelAdapter());
  final paymentsBox =
      await Hive.openBox<PaymentModel>(HiveBoxes.payments);
  final authBox = await Hive.openBox(HiveBoxes.auth);
  final usersBox = await Hive.openBox(HiveBoxes.users);

  runApp(MyApp(
    paymentsBox: paymentsBox,
    authBox: authBox,
    usersBox: usersBox,
  ));
}

class MyApp extends StatelessWidget {
  final Box<PaymentModel> paymentsBox;
  final Box authBox;
  final Box usersBox;

  const MyApp({
    super.key,
    required this.paymentsBox,
    required this.authBox,
    required this.usersBox,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            authBox: authBox,
            usersBox: usersBox,
          ),
        ),
        BlocProvider<CartCubit>(
          create: (_) => CartCubit(),
        ),
        BlocProvider<PaymentCubit>(
          create: (_) => PaymentCubit(PaymentRepository(paymentsBox)),
        ),
      ],
      // MaterialApp is NOT rebuilt on auth state changes.
      // BlocBuilder is placed as the home widget so only the root
      // screen swaps — the Navigator stack is preserved during payment flows.
      child: MaterialApp(
        title: 'Daily Fresh & Grocery',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: BlocBuilder<AuthCubit, dynamic>(
          builder: (context, state) {
            final isLoggedIn = context.read<AuthCubit>().currentUser != null;
            return isLoggedIn ? const HomeScreen() : const LoginScreen();
          },
        ),
      ),
    );
  }
}
