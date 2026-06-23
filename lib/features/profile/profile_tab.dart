part of cmac_del_santa_app;

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key, required this.cliente, required this.onLogout});

  final Map<String, dynamic> cliente;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Perfil de usuario'),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.red,
                  child: Icon(Icons.person, color: Colors.white, size: 36),
                ),
                const SizedBox(height: 12),
                Text(
                  '${cliente['nombres'] ?? ''} ${cliente['apellidos'] ?? ''}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                InfoRow(label: 'Documento', value: '${cliente['numero_documento'] ?? '-'}'),
                InfoRow(label: 'Telefono', value: '${cliente['telefono'] ?? '-'}'),
                InfoRow(label: 'Correo', value: '${cliente['email'] ?? '-'}'),
                InfoRow(label: 'Direccion', value: '${cliente['direccion'] ?? '-'}'),
                InfoRow(label: 'Distrito', value: '${cliente['distrito'] ?? '-'}'),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: onLogout,
                  icon: const Icon(Icons.logout),
                  label: const Text('Cerrar sesion'),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const ContactCard(),
      ],
    );
  }
}
