import 'package:flutter/material.dart';

class AccountBalanceTile extends StatelessWidget {
  const AccountBalanceTile({
    required this.accountName,
    required this.balance,
    super.key,
  });

  final String accountName;
  final String balance;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(accountName),
      subtitle: const Text('Saldo disponible'),
      trailing: Text(balance, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}
