library cmac_del_santa_app;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'app/app.dart';
part 'features/auth/login_page.dart';
part 'features/home/client_home_page.dart';
part 'features/home/dashboard_tab.dart';
part 'features/products/products_tab.dart';
part 'features/operations/operations_tab.dart';
part 'features/services/services_tab.dart';
part 'features/profile/profile_tab.dart';
part 'features/credit/credit_pages.dart';
part 'shared/widgets/app_widgets.dart';
part 'shared/navigation/app_dialogs.dart';
part 'core/providers.dart';
part 'core/formatters.dart';

const supabaseUrl = 'https://xlxnnijvjidiozzmqddx.supabase.co';
const supabaseKey = 'sb_publishable_Fu3i08lzdrgQCILg-BIYfg_0Z2JcYTj';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);
  runApp(const ProviderScope(child: CmacSantaApp()));
}
