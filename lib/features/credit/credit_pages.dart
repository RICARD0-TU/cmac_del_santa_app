part of cmac_del_santa_app;

void openSimulator(
  BuildContext context,
  Future<void> Function(Map<String, dynamic> data) onCreateCreditRequest,
) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => SimulatorPage(onCreateCreditRequest: onCreateCreditRequest)),
  );
}

class SimulatorPage extends StatefulWidget {
  const SimulatorPage({super.key, required this.onCreateCreditRequest});

  final Future<void> Function(Map<String, dynamic> data) onCreateCreditRequest;

  @override
  State<SimulatorPage> createState() => _SimulatorPageState();
}

class _SimulatorPageState extends State<SimulatorPage> {
  final amountController = TextEditingController(text: '5000');
  final rateController = TextEditingController(text: '32');
  int months = 12;

  @override
  void dispose() {
    amountController.dispose();
    rateController.dispose();
    super.dispose();
  }

  double get cuota {
    final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
    final tea = double.tryParse(rateController.text.replaceAll(',', '.')) ?? 0;
    final monthlyRate = tea / 100 / 12;
    if (months <= 0) return 0;
    if (monthlyRate == 0) return amount / months;
    final factor = powSimple(1 + monthlyRate, months);
    return amount * monthlyRate * factor / (factor - 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simulador de credito')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Monto solicitado', prefixText: 'S/ '),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: rateController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'TEA referencial', suffixText: '%'),
          ),
          const SizedBox(height: 18),
          Text('Plazo: $months meses', style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(
            value: months.toDouble(),
            min: 3,
            max: 36,
            divisions: 33,
            label: '$months',
            onChanged: (value) => setState(() => months = value.round()),
          ),
          const SizedBox(height: 12),
          BalanceCard(
            saldo: money(cuota),
            deuda: money((double.tryParse(amountController.text) ?? 0) + (cuota * months - (double.tryParse(amountController.text) ?? 0))),
            cuentas: '$months',
            creditos: '${rateController.text}%',
          ),
          const SizedBox(height: 8),
          const Text(
            'La cuota es referencial. La evaluacion final depende del historial, score y documentos.',
            style: TextStyle(color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: () => openCreditRequestForm(
              context,
              widget.onCreateCreditRequest,
              initialAmount: double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0,
              initialMonths: months,
              initialDestination: 'Capital de trabajo',
            ),
            icon: const Icon(Icons.edit_document),
            label: const Text('Solicitar con estos datos'),
            style: FilledButton.styleFrom(backgroundColor: AppColors.red),
          ),
        ],
      ),
    );
  }
}

void openCreditRequestForm(
  BuildContext context,
  Future<void> Function(Map<String, dynamic> data) onSubmit, {
  double? initialAmount,
  int? initialMonths,
  String? initialDestination,
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => CreditRequestPage(
        onSubmit: onSubmit,
        initialAmount: initialAmount,
        initialMonths: initialMonths,
        initialDestination: initialDestination,
      ),
    ),
  );
}

class CreditRequestPage extends StatefulWidget {
  const CreditRequestPage({
    super.key,
    required this.onSubmit,
    this.initialAmount,
    this.initialMonths,
    this.initialDestination,
  });

  final Future<void> Function(Map<String, dynamic> data) onSubmit;
  final double? initialAmount;
  final int? initialMonths;
  final String? initialDestination;

  @override
  State<CreditRequestPage> createState() => _CreditRequestPageState();
}

class _CreditRequestPageState extends State<CreditRequestPage> {
  late final TextEditingController amountController;
  late final TextEditingController destinationController;
  late int months;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: (widget.initialAmount ?? 5000).toStringAsFixed(0));
    destinationController = TextEditingController(text: widget.initialDestination ?? 'Capital de trabajo');
    months = widget.initialMonths ?? 12;
  }

  @override
  void dispose() {
    amountController.dispose();
    destinationController.dispose();
    super.dispose();
  }

  double get cuota {
    final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
    const tea = 32.0;
    final monthlyRate = tea / 100 / 12;
    final factor = powSimple(1 + monthlyRate, months);
    return amount * monthlyRate * factor / (factor - 1);
  }

  Future<void> submit() async {
    final amount = double.tryParse(amountController.text.replaceAll(',', '.')) ?? 0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un monto valido.')),
      );
      return;
    }

    setState(() => saving = true);
    try {
      await widget.onSubmit({
        'monto': amount,
        'plazo': months,
        'destino': destinationController.text.trim(),
        'cuota': cuota,
      });
      if (!mounted) return;
      showReceipt(context, {
        'tipo': 'solicitud_credito',
        'beneficiario': 'CMAC Del Santa',
        'monto': amount,
        'estado': 'enviado',
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo registrar: $e')),
      );
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva solicitud')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Monto solicitado', prefixText: 'S/ '),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: destinationController,
            decoration: const InputDecoration(labelText: 'Destino del credito'),
          ),
          const SizedBox(height: 18),
          Text('Plazo: $months meses', style: const TextStyle(fontWeight: FontWeight.w800)),
          Slider(
            value: months.toDouble(),
            min: 3,
            max: 36,
            divisions: 33,
            label: '$months',
            onChanged: (value) => setState(() => months = value.round()),
          ),
          SimpleCard(
            icon: Icons.calculate_outlined,
            title: 'Cuota estimada',
            subtitle: 'TEA referencial 32%',
            trailing: money(cuota),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: saving ? null : submit,
            icon: const Icon(Icons.send_outlined),
            label: Text(saving ? 'Enviando...' : 'Enviar solicitud'),
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(50),
              backgroundColor: AppColors.red,
            ),
          ),
        ],
      ),
    );
  }
}
