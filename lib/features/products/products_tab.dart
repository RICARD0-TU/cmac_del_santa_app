part of cmac_del_santa_app;

class ProductsTab extends StatelessWidget {
  const ProductsTab({
    super.key,
    required this.cuentas,
    required this.creditos,
    required this.cronograma,
    required this.tarjetas,
  });

  final List<Map<String, dynamic>> cuentas;
  final List<Map<String, dynamic>> creditos;
  final List<Map<String, dynamic>> cronograma;
  final List<Map<String, dynamic>> tarjetas;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Cuentas de ahorro'),
        ...cuentas.map((item) => SimpleCard(
              icon: Icons.savings_outlined,
              title: item['alias'] ?? item['tipo_cuenta'] ?? 'Cuenta',
              subtitle: '${item['cod_cuenta_ahorro'] ?? ''}\nTEA ${item['tea'] ?? '-'}% - ${item['estado'] ?? ''}',
              trailing: money(item['saldo_disponible']),
              onTap: () => openDetail(
                context,
                title: item['alias'] ?? 'Cuenta de ahorro',
                icon: Icons.savings_outlined,
                rows: {
                  'Codigo': item['cod_cuenta_ahorro'],
                  'Tipo': item['tipo_cuenta'],
                  'Saldo disponible': money(item['saldo_disponible']),
                  'Saldo contable': money(item['saldo_contable'] ?? item['saldo_disponible']),
                  'CCI': item['cci'] ?? '-',
                  'TEA': '${item['tea'] ?? '-'}%',
                  'Estado': item['estado'],
                },
              ),
            )),
        const SizedBox(height: 16),
        const SectionTitle('Creditos activos'),
        ...creditos.map((item) => SimpleCard(
              icon: Icons.business_center_outlined,
              title: item['producto'] ?? 'Credito',
              subtitle: 'Cuota ${money(item['cuota_mensual'])} - vence ${dateText(item['fecha_proximo_pago'])}\nMora: ${item['dias_mora'] ?? 0} dias',
              trailing: money(item['saldo_total']),
              onTap: () => openCreditDetail(context, item, cronograma),
            )),
        const SizedBox(height: 16),
        const SectionTitle('Cronograma'),
        ...cronograma.take(6).map((item) => SimpleCard(
              icon: Icons.event_note_outlined,
              title: 'Cuota ${item['nro_cuota']}',
              subtitle: '${dateText(item['fecha_vencimiento'])} - ${item['estado_cuota']}',
              trailing: money(item['monto_cuota']),
            )),
        const SizedBox(height: 16),
        const SectionTitle('Tarjetas'),
        ...tarjetas.map((item) => SimpleCard(
              icon: Icons.credit_card,
              title: '${item['marca'] ?? 'Tarjeta'} ${item['tipo'] ?? ''}',
              subtitle: item['numero_enmascarado'] ?? '',
              trailing: '${item['estado'] ?? ''}',
              onTap: () => openDetail(
                context,
                title: 'Tarjeta ${item['marca'] ?? ''}',
                icon: Icons.credit_card,
                rows: {
                  'Numero': item['numero_enmascarado'],
                  'Tipo': item['tipo'],
                  'Estado': item['estado'],
                  'Linea': money(item['linea_credito']),
                  'Utilizado': money(item['saldo_utilizado']),
                  'Fecha de corte': dateText(item['fecha_corte']),
                  'Fecha de pago': dateText(item['fecha_pago']),
                },
              ),
            )),
      ],
    );
  }
}
