import 'package:flutter/material.dart';
import 'models/device_security_status.dart';
import 'services/i_security_bridge.dart';
import 'services/security_bridge_impl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MethodChannelExampleApp());
}

class MethodChannelExampleApp extends StatelessWidget {
  const MethodChannelExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MethodChannel & EventChannel Demo',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0F766E)),
      ),
      home: const SecurityAuditPage(
        securityBridge: SecurityBridgeImpl(),
      ),
    );
  }
}

class SecurityAuditPage extends StatefulWidget {
  final ISecurityBridge securityBridge;

  const SecurityAuditPage({super.key, required this.securityBridge});

  @override
  State<SecurityAuditPage> createState() => _SecurityAuditPageState();
}

class _SecurityAuditPageState extends State<SecurityAuditPage> {
  DeviceSecurityStatus? _status;
  String? _errorMessage;
  bool _isLoading = false;

  Future<void> _checkSecurity() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final status = await widget.securityBridge.getSecurityStatus();
      setState(() {
        _status = status;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _triggerBiometrics() async {
    try {
      final authenticated = await widget.securityBridge.verifyBiometrics(
        promptReason: 'Please authenticate to authorize corporate operations',
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authenticated ? 'Biometrics Verified!' : 'Authentication Cancelled'),
            backgroundColor: authenticated ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bridge Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Native Bridge Security Demo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.phonelink_lock, size: 70, color: Color(0xFF0F766E)),
            const SizedBox(height: 16),
            const Text(
              'Hardware & OS Security Bridge',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Demonstrates typed MethodChannel calls and live EventChannel streaming '
              'with decoupled interfaces and native Kotlin/Swift implementations.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.security),
              label: const Text('Run Native Security Audit (MethodChannel)'),
              onPressed: _isLoading ? null : _checkSecurity,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.fingerprint),
              label: const Text('Request Biometric Auth (MethodChannel)'),
              onPressed: _triggerBiometrics,
            ),
            const SizedBox(height: 24),
            if (_isLoading) const Center(child: CircularProgressIndicator()),
            if (_errorMessage != null)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            if (_status != null) _SecurityStatusCard(status: _status!),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              'Live Native Hardware Events (EventChannel):',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StreamBuilder<String>(
              stream: widget.securityBridge.hardwareEventStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Text('Stream Error: ${snapshot.error}', style: const TextStyle(color: Colors.red));
                }
                if (!snapshot.hasData) {
                  return const Text('Listening for native broadcast events...', style: TextStyle(color: Colors.grey));
                }
                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Event received: ${snapshot.data}',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: Color(0xFF0F766E)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SecurityStatusCard extends StatelessWidget {
  final DeviceSecurityStatus status;
  const _SecurityStatusCard({required this.status});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  status.isCompromised ? Icons.warning_amber : Icons.verified,
                  color: status.isCompromised ? Colors.red : Colors.green,
                ),
                const SizedBox(width: 8),
                Text(
                  status.isCompromised ? 'Device Compromised (Rooted/Jailbroken)' : 'Device Integrity Verified',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: status.isCompromised ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text('OS Version: ${status.osVersion}'),
            Text('Security Patch Level: ${status.securityPatchLevel}'),
            Text('Hardware Keystore Present: ${status.hasSecureHardware ? "Yes" : "No"}'),
          ],
        ),
      ),
    );
  }
}
