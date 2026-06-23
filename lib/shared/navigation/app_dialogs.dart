part of cmac_del_santa_app;

void openDetail(
  BuildContext context, {
  required String title,
  required IconData icon,
  required Map<String, dynamic> rows,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DetailPage(title: title, icon: icon, rows: rows),
    ),
  );
}

void openCreditDetail(
  BuildContext context,
  Map<String, dynamic> credit,
  List<Map<String, dynamic>> cronograma,
) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => DetailPage(
        title: credit['producto'] ?? 'Credito',
        icon: Icons.business_center_outlined,
        rows: {
          'Codigo': credit['cod_cuenta_credito'],
          'Monto desembolsado': money(credit['monto_desembolsado']),
          'Saldo total': money(credit['saldo_total']),
          'Saldo capital': money(credit['saldo_capital']),
          'Cuota mensual': money(credit['cuota_mensual']),
          'Proximo pago': dateText(credit['fecha_proximo_pago']),
          'Estado': credit['estado'],
          'Dias de mora': '${credit['dias_mora'] ?? 0}',
        },
        extra: [
          const SectionTitle('Cronograma completo'),
          ...cronograma.map(
            (item) => SimpleCard(
              icon: Icons.event_note_outlined,
              title: 'Cuota ${item['nro_cuota']}',
              subtitle: '${dateText(item['fecha_vencimiento'])} - ${item['estado_cuota']}',
              trailing: money(item['monto_cuota']),
            ),
          ),
        ],
      ),
    ),
  );
}

class DetailPage extends StatelessWidget {
  const DetailPage({
    super.key,
    required this.title,
    required this.icon,
    required this.rows,
    this.extra = const [],
  });

  final String title;
  final IconData icon;
  final Map<String, dynamic> rows;
  final List<Widget> extra;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.red.withAlpha(26),
                    child: Icon(icon, color: AppColors.red, size: 32),
                  ),
                  const SizedBox(height: 14),
                  Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  ...rows.entries.map(
                    (row) => InfoRow(label: row.key, value: '${row.value ?? '-'}'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          ...extra,
        ],
      ),
    );
  }
}

void showReceipt(BuildContext context, Map<String, dynamic> operation) {
  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.green,
            child: Icon(Icons.check, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            'Comprobante',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 12),
          InfoRow(label: 'Operacion', value: readableOperation(operation['tipo'])),
          InfoRow(label: 'Destino', value: '${operation['beneficiario'] ?? operation['cuenta_destino_texto'] ?? '-'}'),
          InfoRow(label: 'Monto', value: money(operation['monto'])),
          InfoRow(label: 'Estado', value: '${operation['estado'] ?? 'pendiente'}'),
          InfoRow(label: 'Fecha', value: dateText(operation['created_at'] ?? DateTime.now())),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.done),
            label: const Text('Entendido'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
          ),
        ],
      ),
    ),
  );
}

Future<bool> confirmOperation(BuildContext context, Map<String, dynamic> data) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (_) => AlertDialog(
      title: const Text('Confirmar operacion'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InfoRow(label: 'Tipo', value: readableOperation(data['tipo'])),
          InfoRow(label: 'Cuenta', value: '${data['cuenta'] ?? '-'}'),
          InfoRow(label: 'Destino', value: '${data['destino'] ?? '-'}'),
          InfoRow(label: 'Monto', value: money(data['monto'])),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          style: FilledButton.styleFrom(backgroundColor: AppColors.red),
          child: const Text('Confirmar'),
        ),
      ],
    ),
  );
  return result ?? false;
}
