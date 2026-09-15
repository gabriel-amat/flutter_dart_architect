import 'package:flutter/material.dart';
import 'models/crypto_models.dart';
import 'services/i_native_crypto_service.dart';
import 'services/native_crypto_service_impl.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const NativeCryptoApp());
}

class NativeCryptoApp extends StatelessWidget {
  const NativeCryptoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dart FFI Native C Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0D47A1),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const FfiBenchmarkPage(),
    );
  }
}

class FfiBenchmarkPage extends StatefulWidget {
  const FfiBenchmarkPage({
    super.key,
    this.cryptoService,
  });

  final INativeCryptoService? cryptoService;

  @override
  State<FfiBenchmarkPage> createState() => _FfiBenchmarkPageState();
}

class _FfiBenchmarkPageState extends State<FfiBenchmarkPage> {
  late final INativeCryptoService _cryptoService;
  final TextEditingController _hashInputController =
      TextEditingController(text: 'Antigravity High Performance C FFI');
  final TextEditingController _seedController =
      TextEditingController(text: 'user_secure_wallet_007');

  String _computedHash = '';
  CryptoKeyPair? _keyPair;
  BenchmarkResult? _benchmarkResult;
  bool _isBenchmarking = false;

  @override
  void initState() {
    super.initState();
    _cryptoService = widget.cryptoService ?? NativeCryptoServiceImpl();
  }

  @override
  void dispose() {
    _hashInputController.dispose();
    _seedController.dispose();
    super.dispose();
  }

  void _onHashPressed() {
    final text = _hashInputController.text;
    if (text.isEmpty) return;
    final hash = _cryptoService.hashString(text);
    setState(() {
      _computedHash = hash;
    });
  }

  void _onGenerateKeyPairPressed() {
    final seed = _seedController.text;
    if (seed.isEmpty) return;
    final pair = _cryptoService.generateKeyPair(seed);
    setState(() {
      _keyPair = pair;
    });
  }

  Future<void> _onRunBenchmarkPressed() async {
    setState(() {
      _isBenchmarking = true;
    });

    // Short microtask yield to allow UI to render the loading indicator
    await Future<void>.delayed(const Duration(milliseconds: 50));

    final result = _cryptoService.runBenchmark(iterations: 5000000);

    if (!mounted) return;
    setState(() {
      _benchmarkResult = result;
      _isBenchmarking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dart FFI High Performance Engine'),
        backgroundColor: theme.colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildInfoBanner(theme),
          const SizedBox(height: 16),
          _buildBenchmarkCard(theme),
          const SizedBox(height: 16),
          _buildHashingCard(theme),
          const SizedBox(height: 16),
          _buildStructCard(theme),
        ],
      ),
    );
  }

  Widget _buildInfoBanner(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.colorScheme.primary),
      ),
      child: Row(
        children: [
          Icon(Icons.memory, color: theme.colorScheme.primary, size: 28),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Direct C-ABI In-Process Execution. Zero message serialization overhead, zero-copy memory via Pointers & Arenas.',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenchmarkCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '⚡ Native C Benchmark (5,000,000 Iterations)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Executes intensive bit manipulation loop inside compiled C binary directly on the current thread.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            if (_benchmarkResult != null) ...[
              Text(
                'Elapsed Time: ${_benchmarkResult!.elapsedMs.toStringAsFixed(3)} ms',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 16,
                ),
              ),
              Text(
                'Calculated Checksum: ${_benchmarkResult!.checksum}',
                style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
              ),
              const SizedBox(height: 12),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isBenchmarking ? null : _onRunBenchmarkPressed,
                icon: _isBenchmarking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.speed),
                label: Text(_isBenchmarking ? 'Computing...' : 'Run 5M Native Iterations'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHashingCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔒 Arena Memory Scoped Hashing',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _hashInputController,
              decoration: const InputDecoration(
                labelText: 'Input String',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onHashPressed,
                icon: const Icon(Icons.tag),
                label: const Text('Hash via C Pointer with Arena'),
              ),
            ),
            if (_computedHash.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text('Computed Hash (Hex):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              SelectableText(
                _computedHash,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.blueAccent),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStructCard(ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '🔑 Native C Structs (KeyPairStruct)',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _seedController,
              decoration: const InputDecoration(
                labelText: 'Entropy Seed',
                border: OutlineInputBorder(),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _onGenerateKeyPairPressed,
                icon: const Icon(Icons.vpn_key),
                label: const Text('Generate C Heap Struct & Free'),
              ),
            ),
            if (_keyPair != null) ...[
              const SizedBox(height: 12),
              const Text('Public Key:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              SelectableText(
                _keyPair!.publicKey,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.teal),
              ),
              const SizedBox(height: 6),
              const Text('Private Key:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
              SelectableText(
                _keyPair!.privateKey,
                style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.deepOrange),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
