part of cmac_del_santa_app;

class DashboardTab extends StatelessWidget {
  const DashboardTab({
    super.key,
    required this.cliente,
    required this.dashboard,
    required this.movimientos,
    required this.notificaciones,
    required this.onQuickAction,
    required this.onNotificationTap,
  });

  final Map<String, dynamic> cliente;
  final Map<String, dynamic> dashboard;
  final List<Map<String, dynamic>> movimientos;
  final List<Map<String, dynamic>> notificaciones;
  final void Function(int index) onQuickAction;
  final void Function(Map<String, dynamic> item) onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final nombre = '${cliente['nombres'] ?? 'Cliente'}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Hola, $nombre', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 12),
        BalanceCard(
          saldo: money(dashboard['saldo_total_ahorros']),
          deuda: money(dashboard['deuda_total_creditos']),
          cuentas: '${dashboard['cuentas_ahorro'] ?? 0}',
          creditos: '${dashboard['creditos_activos'] ?? 0}',
        ),
        const SizedBox(height: 16),
        const SectionTitle('Accesos rapidos'),
        Row(
          children: [
            QuickAction(icon: Icons.savings_outlined, label: 'Ahorros', onTap: () => onQuickAction(1)),
            QuickAction(icon: Icons.credit_score, label: 'Creditos', onTap: () => onQuickAction(1)),
            QuickAction(icon: Icons.receipt_long, label: 'Pagos', onTap: () => onQuickAction(2)),
            QuickAction(icon: Icons.support_agent, label: 'Ayuda', onTap: () => onQuickAction(4)),
          ],
        ),
        const SizedBox(height: 20),
        const SectionTitle('Ultimos movimientos'),
        ...movimientos.take(4).map((item) => MovementTile(item: item)),
        const SizedBox(height: 20),
        const SectionTitle('Notificaciones'),
        ...notificaciones.take(3).map(
              (item) => NotificationTile(
                item: item,
                onTap: () => onNotificationTap(item),
              ),
            ),
      ],
    );
  }
}
