part of cmac_del_santa_app;

class ServicesTab extends StatelessWidget {
  const ServicesTab({
    super.key,
    required this.productos,
    required this.solicitudes,
    required this.onCreateCreditRequest,
  });

  final List<Map<String, dynamic>> productos;
  final List<Map<String, dynamic>> solicitudes;
  final Future<void> Function(Map<String, dynamic> data) onCreateCreditRequest;

  @override
  Widget build(BuildContext context) {
    final creditos = productos.where((p) => p['categoria'] == 'credito');
    final ahorros = productos.where((p) => p['categoria'] == 'ahorro');
    final servicios = productos.where((p) => p['categoria'] == 'servicio');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const PromoBand(),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                onPressed: () => openSimulator(context, onCreateCreditRequest),
                icon: const Icon(Icons.calculate_outlined),
                label: const Text('Simulador'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.blue),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => openCreditRequestForm(context, onCreateCreditRequest),
                icon: const Icon(Icons.edit_document),
                label: const Text('Solicitar'),
                style: FilledButton.styleFrom(backgroundColor: AppColors.red),
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        const SectionTitle('Mis solicitudes'),
        if (solicitudes.isEmpty)
          const EmptyState(text: 'Aun no tienes solicitudes de credito.')
        else
          ...solicitudes.map(
            (item) => SimpleCard(
              icon: Icons.assignment_outlined,
              title: '${money(item['monto_solicitado'])} - ${item['plazo_meses']} meses',
              subtitle: '${item['destino_credito'] ?? 'Solicitud'}\n${dateText(item['created_at'])}',
              trailing: '${item['estado'] ?? ''}',
              onTap: () => openDetail(
                context,
                title: 'Solicitud de credito',
                icon: Icons.assignment_outlined,
                rows: {
                  'Monto solicitado': money(item['monto_solicitado']),
                  'Monto aprobado': item['monto_aprobado'] == null ? '-' : money(item['monto_aprobado']),
                  'Plazo': '${item['plazo_meses']} meses',
                  'Destino': item['destino_credito'],
                  'Cuota estimada': money(item['cuota_estimada']),
                  'Estado': item['estado'],
                  'Fecha': dateText(item['created_at']),
                },
              ),
            ),
          ),
        const SizedBox(height: 18),
        ProductGroup(title: 'Creditos', icon: Icons.trending_up, items: creditos),
        ProductGroup(title: 'Ahorra aqui', icon: Icons.savings_outlined, items: ahorros),
        ProductGroup(title: 'Tus servicios', icon: Icons.receipt_long, items: servicios),
      ],
    );
  }
}
