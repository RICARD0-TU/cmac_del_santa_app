part of cmac_del_santa_app;

class BrandHeader extends StatelessWidget {
  const BrandHeader({super.key, required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: compact ? 34 : 54,
          height: compact ? 34 : 54,
          decoration: BoxDecoration(
            color: compact ? Colors.white : AppColors.red,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.account_balance,
            color: compact ? AppColors.red : Colors.white,
            size: compact ? 22 : 32,
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Caja del Santa',
              style: TextStyle(
                color: compact ? Colors.white : AppColors.ink,
                fontSize: compact ? 17 : 25,
                fontWeight: FontWeight.w900,
              ),
            ),
            Text(
              'Impulsamos tus proyectos',
              style: TextStyle(
                color: compact ? Colors.white70 : AppColors.muted,
                fontSize: compact ? 11 : 13,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.saldo,
    required this.deuda,
    required this.cuentas,
    required this.creditos,
  });

  final String saldo;
  final String deuda;
  final String cuentas;
  final String creditos;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: const LinearGradient(colors: [AppColors.red, AppColors.darkRed]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Saldo total disponible', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 8),
          Text(saldo, style: const TextStyle(color: Colors.white, fontSize: 31, fontWeight: FontWeight.w900)),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(child: MiniMetric(label: 'Deuda creditos', value: deuda)),
              Expanded(child: MiniMetric(label: 'Ahorros', value: cuentas)),
              Expanded(child: MiniMetric(label: 'Creditos', value: creditos)),
            ],
          ),
        ],
      ),
    );
  }
}

class MiniMetric extends StatelessWidget {
  const MiniMetric({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800)),
      ],
    );
  }
}

class QuickAction extends StatelessWidget {
  const QuickAction({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Column(
              children: [
                Icon(icon, color: AppColors.red),
                const SizedBox(height: 6),
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SimpleCard extends StatelessWidget {
  const SimpleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: AppColors.red.withAlpha(26),
          child: Icon(icon, color: AppColors.red),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text(subtitle),
        trailing: Text(trailing, style: const TextStyle(fontWeight: FontWeight.w900)),
      ),
    );
  }
}

class MovementTile extends StatelessWidget {
  const MovementTile({super.key, required this.item});

  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    final isCredit = item['tipo'] == 'CRE';
    return SimpleCard(
      icon: isCredit ? Icons.arrow_downward : Icons.arrow_upward,
      title: item['concepto'] ?? 'Movimiento',
      subtitle: dateText(item['fecha_operacion']),
      trailing: '${isCredit ? '+' : '-'} ${money(item['monto'])}',
    );
  }
}

class NotificationTile extends StatelessWidget {
  const NotificationTile({super.key, required this.item, required this.onTap});

  final Map<String, dynamic> item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SimpleCard(
      icon: Icons.notifications_none,
      title: item['titulo'] ?? 'Notificacion',
      subtitle: item['cuerpo'] ?? '',
      trailing: item['leida'] == true ? 'Leida' : 'Nueva',
      onTap: onTap,
    );
  }
}

class ProductGroup extends StatelessWidget {
  const ProductGroup({
    super.key,
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final Iterable<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title),
        ...items.map((item) => SimpleCard(
              icon: icon,
              title: item['nombre'] ?? '',
              subtitle: item['descripcion'] ?? item['segmento'] ?? '',
              trailing: 'Ver',
              onTap: () => openDetail(
                context,
                title: item['nombre'] ?? 'Producto',
                icon: icon,
                rows: {
                  'Categoria': item['categoria'],
                  'Segmento': item['segmento'],
                  'Descripcion': item['descripcion'],
                  'Monto minimo': money(item['monto_min']),
                  'Monto maximo': item['monto_max'] == null ? '-' : money(item['monto_max']),
                  'TEA': item['tea_min'] == null ? '-' : '${item['tea_min']}% - ${item['tea_max']}%',
                  'Plazo': item['plazo_max_meses'] == null ? '-' : '${item['plazo_min_meses']} a ${item['plazo_max_meses']} meses',
                },
              ),
            )),
        const SizedBox(height: 12),
      ],
    );
  }
}

class PromoBand extends StatelessWidget {
  const PromoBand({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.blue,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          Icon(Icons.campaign_outlined, color: AppColors.gold, size: 34),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Creditos, ahorros, pagos de servicios y gestion de tesoreria en un solo lugar.',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  const ContactCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Atencion al cliente', style: TextStyle(fontWeight: FontWeight.w900)),
            SizedBox(height: 8),
            InfoRow(label: 'Oficina principal', value: 'Av. Jose Galvez 602 - Chimbote'),
            InfoRow(label: 'Central', value: '(043) 483 140'),
            InfoRow(label: 'Horario', value: 'Lun a Vie 8:30 a 18:00 - Sab 9:00 a 13:00'),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  const InfoRow({super.key, required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: const TextStyle(color: AppColors.muted)),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w700))),
        ],
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
    );
  }
}

class WarningBox extends StatelessWidget {
  const WarningBox({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.gold.withAlpha(46),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.gold),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: AppColors.darkRed),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  const EmptyState({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            const Icon(Icons.inbox_outlined, color: AppColors.muted),
            const SizedBox(width: 10),
            Expanded(child: Text(text, style: const TextStyle(color: AppColors.muted))),
          ],
        ),
      ),
    );
  }
}
