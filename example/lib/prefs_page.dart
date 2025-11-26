import 'package:flutter/material.dart';
import 'package:lite_store/lite_store.dart';

class PrefsPage extends StatefulWidget {
  final PreferenceStore preferenceStore;
  const PrefsPage({super.key, required this.preferenceStore});

  @override
  State<PrefsPage> createState() => _PrefsPageState();
}

class _PrefsPageState extends State<PrefsPage> {
  String token = '';

  @override
  void initState() {
    super.initState();
    _loadToken();

    widget.preferenceStore.onPreferenceChanged().listen((key) {
      if (key == 'token') _loadToken();
    });
  }

  Future<void> _loadToken() async {
    final value = widget.preferenceStore.getValue('token') as String?;
    setState(() => token = value ?? '');
  }

  Future<void> _saveToken() async {
    await widget.preferenceStore.saveValue('token', 'prefs_token_123');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PreferenceStore Example')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _saveToken,
              child: const Text('Save Token'),
            ),
            const SizedBox(height: 8),
            Text('Stored Token: $token'),
          ],
        ),
      ),
    );
  }
}
