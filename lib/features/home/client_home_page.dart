part of cmac_del_santa_app;

class ClientHomePage extends ConsumerStatefulWidget {
  const ClientHomePage({super.key});

  @override
  ConsumerState<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends ConsumerState<ClientHomePage> {
  SupabaseClient get db => ref.read(supabaseClientProvider);
  int selectedIndex = 0;
  bool loading = true;
  String? error;

  Map<String, dynamic> cliente = {};
  Map<String, dynamic> dashboard = {};
  List<Map<String, dynamic>> cuentas = [];
  List<Map<String, dynamic>> creditos = [];
  List<Map<String, dynamic>> cronograma = [];
  List<Map<String, dynamic>> movimientos = [];
  List<Map<String, dynamic>> tarjetas = [];
  List<Map<String, dynamic>> notificaciones = [];
  List<Map<String, dynamic>> productos = [];
  List<Map<String, dynamic>> operaciones = [];
  List<Map<String, dynamic>> solicitudes = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    try {
      final userId = db.auth.currentUser?.id;
      if (userId == null) throw Exception('Sesion no encontrada');

      final clienteRow = await db
          .from('clientes')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (clienteRow == null) {
        throw Exception('Tu usuario aun no esta vinculado a un cliente.');
      }

      final clienteId = clienteRow['id'];
      final dashboardRow = await db
          .from('vw_cliente_dashboard')
          .select()
          .eq('cliente_id', clienteId)
          .maybeSingle();

      final results = await Future.wait([
        db.from('cr_cuentas_ahorro').select().eq('cliente_id', clienteId),
        db.from('cr_creditos').select().eq('cliente_id', clienteId),
        db.from('cr_movimientos').select().eq('cliente_id', clienteId).order('fecha_operacion', ascending: false).limit(12),
        db.from('tarjetas').select().eq('cliente_id', clienteId),
        db.from('notificaciones').select().eq('cliente_id', clienteId).order('created_at', ascending: false).limit(10),
        db.from('productos_financieros').select().eq('activo', true).order('categoria'),
        db.from('operaciones_cliente').select().eq('cliente_id', clienteId).order('created_at', ascending: false).limit(12),
      ]);

      final creditosData = toMaps(results[1]);
      final cronogramaData = <Map<String, dynamic>>[];
      for (final credito in creditosData) {
        final cuotas = toMaps(await db
            .from('cr_cronograma_pagos')
            .select()
            .eq('credito_id', credito['id'])
            .order('nro_cuota'));
        for (final cuota in cuotas) {
          cuota['credito_producto'] = credito['producto'];
          cuota['credito_codigo'] = credito['cod_cuenta_credito'];
        }
        cronogramaData.addAll(cuotas);
      }

      final solicitudesData = toMaps(await db
          .from('solicitudes_credito')
          .select()
          .eq('cliente_id', clienteId)
          .order('created_at', ascending: false)
          .limit(10));

      setState(() {
        cliente = Map<String, dynamic>.from(clienteRow);
        dashboard = dashboardRow == null ? {} : Map<String, dynamic>.from(dashboardRow);
        cuentas = toMaps(results[0]);
        creditos = creditosData;
        movimientos = toMaps(results[2]);
        tarjetas = toMaps(results[3]);
        notificaciones = toMaps(results[4]);
        productos = toMaps(results[5]);
        operaciones = toMaps(results[6]);
        solicitudes = solicitudesData;
        cronograma = cronogramaData;
        loading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString().replaceFirst('Exception: ', '');
        loading = false;
        cliente = {};
        dashboard = {};
        cuentas = [];
        creditos = [];
        cronograma = [];
        movimientos = [];
        tarjetas = [];
        notificaciones = [];
        productos = [];
        operaciones = [];
        solicitudes = [];
      });
    }
  }

  List<Map<String, dynamic>> toMaps(dynamic value) {
    return List<Map<String, dynamic>>.from(
      (value as List).map((item) => Map<String, dynamic>.from(item)),
    );
  }

  void goToTab(int index) {
    setState(() => selectedIndex = index);
  }

  Future<void> markNotificationRead(Map<String, dynamic> item) async {
    setState(() => item['leida'] = true);
    final id = item['id'];
    if (id == null) return;

    try {
      await db.from('notificaciones').update({'leida': true}).eq('id', id);
    } catch (_) {
      setState(() => item['leida'] = false);
    }
  }

  Future<void> createCreditRequest(Map<String, dynamic> data) async {
    final user = db.auth.currentUser;
    if (user == null || cliente['id'] == null) {
      throw Exception('El usuario no esta vinculado. La solicitud no se envio a Supabase.');
    }

    await db.rpc('enviar_solicitud_cliente', params: {
      'p_monto': data['monto'],
      'p_plazo': data['plazo'],
      'p_destino': data['destino'],
      'p_cuota': data['cuota'],
    });

    await loadData();
  }

  Future<void> logout() async {
    await db.auth.signOut();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      DashboardTab(
        cliente: cliente,
        dashboard: dashboard,
        movimientos: movimientos,
        notificaciones: notificaciones,
        onQuickAction: goToTab,
        onNotificationTap: markNotificationRead,
      ),
      ProductsTab(cuentas: cuentas, creditos: creditos, cronograma: cronograma, tarjetas: tarjetas),
      OperationsTab(
        cuentas: cuentas,
        creditos: creditos,
        cronograma: cronograma,
        operaciones: operaciones,
        onSaved: loadData,
      ),
      ServicesTab(
        productos: productos,
        solicitudes: solicitudes,
        onCreateCreditRequest: createCreditRequest,
      ),
      ProfileTab(cliente: cliente, onLogout: logout),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const BrandHeader(compact: true),
        actions: [
          IconButton(onPressed: loadData, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  if (error != null) WarningBox(message: error!),
                  if (error != null && cliente.isEmpty)
                    EmptyState(
                      text:
                          'No se cargaron datos. Verifica que el usuario de Supabase Auth este vinculado en la tabla clientes.',
                    )
                  else
                    pages[selectedIndex],
                ],
              ),
            ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) => setState(() => selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
          NavigationDestination(icon: Icon(Icons.account_balance_wallet_outlined), selectedIcon: Icon(Icons.account_balance_wallet), label: 'Productos'),
          NavigationDestination(icon: Icon(Icons.swap_horiz), label: 'Operar'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'Servicios'),
          NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
