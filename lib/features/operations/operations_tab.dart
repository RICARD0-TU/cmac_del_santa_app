part of cmac_del_santa_app;

class OperationsTab extends ConsumerStatefulWidget {
  const OperationsTab({
    super.key,
    required this.cuentas,
    required this.creditos,
    required this.cronograma,
    required this.operaciones,
    required this.onSaved,
  });

  final List<Map<String, dynamic>> cuentas;
  final List<Map<String, dynamic>> creditos;
  final List<Map<String, dynamic>> cronograma;
  final List<Map<String, dynamic>> operaciones;
  final Future<void> Function() onSaved;

  @override
  ConsumerState<OperationsTab> createState() => _OperationsTabState();
}

class _OperationsTabState extends ConsumerState<OperationsTab> {
  final montoController = TextEditingController();
  final destinoController = TextEditingController();
  String tipo = 'transferencia';
  String? cuentaId;
  String? creditoId;
  String? cuotaId;
  bool saving = false;
  String? message;

  @override
  void dispose() {
    montoController.dispose();
    destinoController.dispose();
    super.dispose();
  }

  Future<void> saveOperation() async {
    final db = ref.read(supabaseClientProvider);
    final user = db.auth.currentUser;
    final cuenta = selectedCuenta;
    final cuota = selectedCuota;
    final monto = tipo == 'pago_cuota'
        ? amountValue(cuota?['monto_cuota'])
        : double.tryParse(montoController.text.replaceAll(',', '.')) ?? 0;

    if (cuenta == null) {
      setState(() => message = 'Selecciona una cuenta origen.');
      return;
    }

    if (tipo == 'pago_cuota' && cuota == null) {
      setState(() => message = 'Selecciona una cuota pendiente.');
      return;
    }

    if (tipo != 'pago_cuota' && destinoController.text.trim().isEmpty) {
      setState(() => message = 'Ingresa destino o servicio.');
      return;
    }

    if (monto <= 0) {
      setState(() => message = 'Ingresa un monto valido.');
      return;
    }

    if (amountValue(cuenta['saldo_disponible']) < monto) {
      setState(() => message = 'Saldo insuficiente en la cuenta origen.');
      return;
    }

    final confirmed = await confirmOperation(context, {
      'tipo': tipo,
      'cuenta': cuenta['alias'] ?? cuenta['cod_cuenta_ahorro'],
      'destino': tipo == 'pago_cuota'
          ? 'Cuota ${cuota?['nro_cuota']} - ${cuota?['credito_producto'] ?? 'Credito'}'
          : destinoController.text.trim(),
      'monto': monto,
    });

    if (!confirmed) return;

    if (user == null) {
      setState(() => message = 'Debes iniciar sesion para registrar operaciones.');
      return;
    }

    setState(() {
      saving = true;
      message = null;
    });

    try {
      final saved = tipo == 'pago_cuota'
          ? await db.rpc('pagar_cuota_cliente', params: {
              'p_cuenta_origen_id': cuenta['id'],
              'p_credito_id': creditoId ?? cuota?['credito_id'],
              'p_cuota_id': cuotaId ?? cuota?['id'],
            })
          : await db.rpc('registrar_transferencia_cliente', params: {
              'p_cuenta_origen_id': cuenta['id'],
              'p_destino': destinoController.text.trim(),
              'p_monto': monto,
              'p_tipo': tipo,
            });

      montoController.clear();
      destinoController.clear();
      if (mounted) showReceipt(context, Map<String, dynamic>.from(saved));
      await widget.onSaved();
      setState(() => message = 'Operacion enviada correctamente.');
    } catch (e) {
      setState(() => message = 'No se pudo guardar: $e');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Map<String, dynamic>? get selectedCuenta {
    if (widget.cuentas.isEmpty) return null;
    final id = cuentaId ?? widget.cuentas.first['id'];
    return widget.cuentas.firstWhere((item) => item['id'] == id, orElse: () => widget.cuentas.first);
  }

  List<Map<String, dynamic>> get cuotasPendientes {
    return widget.cronograma
        .where((item) => item['estado_cuota'] == 'pendiente' || item['estado_cuota'] == 'vencida')
        .toList();
  }

  Map<String, dynamic>? get selectedCuota {
    final cuotas = creditoId == null
        ? cuotasPendientes
        : cuotasPendientes.where((item) => item['credito_id'] == creditoId).toList();
    if (cuotas.isEmpty) return null;
    final id = cuotaId ?? cuotas.first['id'];
    return cuotas.firstWhere((item) => item['id'] == id, orElse: () => cuotas.first);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Transferencias y pagos'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'transferencia', icon: Icon(Icons.swap_horiz), label: Text('Transferir')),
                      ButtonSegment(value: 'pago_cuota', icon: Icon(Icons.payments_outlined), label: Text('Pagar cuota')),
                      ButtonSegment(value: 'pago_servicio', icon: Icon(Icons.receipt_long), label: Text('Servicio')),
                    ],
                    selected: {tipo},
                    onSelectionChanged: (value) => setState(() {
                      tipo = value.first;
                      message = null;
                    }),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedCuenta?['id'],
                  decoration: const InputDecoration(
                    labelText: 'Cuenta origen',
                    prefixIcon: Icon(Icons.account_balance_wallet_outlined, size: 20),
                    prefixIconConstraints: BoxConstraints(minWidth: 38),
                  ),
                  items: widget.cuentas
                      .map(
                        (item) => DropdownMenuItem<String>(
                          value: item['id'],
                          child: dropdownText('${item['alias'] ?? item['tipo_cuenta']} - ${money(item['saldo_disponible'])}'),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setState(() => cuentaId = value),
                ),
                const SizedBox(height: 14),
                if (tipo == 'pago_cuota') ...[
                  DropdownButtonFormField<String>(
                    initialValue: creditoId,
                    decoration: const InputDecoration(
                      labelText: 'Credito',
                      prefixIcon: Icon(Icons.business_center_outlined, size: 20),
                      prefixIconConstraints: BoxConstraints(minWidth: 38),
                    ),
                    items: widget.creditos
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item['id'],
                            child: dropdownText('${item['producto']} - ${money(item['saldo_total'])}'),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() {
                      creditoId = value;
                      cuotaId = null;
                    }),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCuota?['id'],
                    decoration: const InputDecoration(
                      labelText: 'Cuota pendiente',
                      prefixIcon: Icon(Icons.event_note_outlined, size: 20),
                      prefixIconConstraints: BoxConstraints(minWidth: 38),
                    ),
                    items: cuotasPendientes
                        .where((item) => creditoId == null || item['credito_id'] == creditoId)
                        .map(
                          (item) => DropdownMenuItem<String>(
                            value: item['id'],
                            child: dropdownText(
                              'Cuota ${item['nro_cuota']} - ${dateText(item['fecha_vencimiento'])} - ${money(item['monto_cuota'])}',
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) => setState(() => cuotaId = value),
                  ),
                  if (selectedCuota != null) ...[
                    const SizedBox(height: 10),
                    SimpleCard(
                      icon: Icons.payments_outlined,
                      title: 'Monto a pagar',
                      subtitle: 'Se pagara la cuota seleccionada',
                      trailing: money(selectedCuota?['monto_cuota']),
                    ),
                  ],
                ] else ...[
                  TextField(
                    controller: destinoController,
                    decoration: InputDecoration(
                      labelText: tipo == 'pago_servicio' ? 'Servicio o codigo de recibo' : 'Cuenta o beneficiario',
                      prefixIcon: const Icon(Icons.person_search_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: montoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Monto',
                      prefixText: 'S/ ',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                FilledButton.icon(
                  onPressed: saving ? null : saveOperation,
                  icon: const Icon(Icons.send_outlined),
                  label: Text(saving ? 'Enviando...' : 'Registrar operacion'),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(50),
                    backgroundColor: AppColors.red,
                  ),
                ),
                if (message != null) ...[
                  const SizedBox(height: 10),
                  Text(message!, textAlign: TextAlign.center),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        const SectionTitle('Historial de operaciones'),
        if (widget.operaciones.isEmpty)
          const EmptyState(text: 'Aun no tienes operaciones registradas.')
        else
          ...widget.operaciones.map(
            (item) => SimpleCard(
              icon: item['tipo'] == 'pago_cuota' ? Icons.payments_outlined : Icons.swap_horiz,
              title: readableOperation(item['tipo']),
              subtitle: '${item['beneficiario'] ?? item['cuenta_destino_texto'] ?? 'Operacion'}\n${dateText(item['created_at'])}',
              trailing: '${money(item['monto'])}\n${item['estado'] ?? ''}',
              onTap: () => showReceipt(context, item),
            ),
          ),
      ],
    );
  }
}
