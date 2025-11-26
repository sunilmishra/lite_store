import 'package:flutter/material.dart';
import 'package:lite_store/lite_store.dart';

class SecureStoragePage extends StatefulWidget {
  final SecureStorageImpl secureStore;
  const SecureStoragePage({super.key, required this.secureStore});

  @override
  State<SecureStoragePage> createState() => _SecureStoragePageState();
}

class _SecureStoragePageState extends State<SecureStoragePage> {
  String secureToken = '';

  Future<void> _saveSecureToken() async {
    await widget.secureStore.write('secure_token', 'secure_secret_123');
    final stored = await widget.secureStore.read('secure_token');
    setState(() => secureToken = stored ?? '');
  }

  Future<void> _deleteSecureToken() async {
    await widget.secureStore.delete('secure_token');
    setState(() => secureToken = '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('SecureStorage Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _saveSecureToken,
              child: const Text('Save Secure Token'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _deleteSecureToken,
              child: const Text('Delete Secure Token'),
            ),
            const SizedBox(height: 16),
            Text('Secure Token: $secureToken'),
          ],
        ),
      ),
    );
  }
}
