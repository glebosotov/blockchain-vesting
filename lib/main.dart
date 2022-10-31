import 'dart:developer';
import 'dart:js' as js;

import 'package:blockchain_week6_ex1/meta.dart';
import 'package:flutter/material.dart';
import 'package:flutter_web3/flutter_web3.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: Builder(builder: (context) {
          return Column(
            children: [
              const Text('Please use the SOKOL testnet'),
              GestureDetector(
                onTap: () {
                  js.context.callMethod(
                      'open', ['https://blockscout.com/poa/sokol/']);
                },
                child: const Text('Link to the testnet (click)'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const EmployeePage())),
                child: const Text(
                    'I am an employee (or I am the manager and I want to withdraw)'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ManagerPage())),
                child: const Text('I am the manageer'),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class EmployeePage extends StatefulWidget {
  const EmployeePage({super.key});

  @override
  State<EmployeePage> createState() => _EmployeePageState();
}

class _EmployeePageState extends State<EmployeePage> {
  Future<void> setupEth({required String customContractAddress}) async {
    // From RPC
    final web3provider = Web3Provider(ethereum!);

    busd = Contract(
      customContractAddress,
      Interface(walletAbi),
      web3provider.getSigner(),
    );

    try {
      // Prompt user to connect to the provider, i.e. confirm the connection modal
      final accs =
          await ethereum!.requestAccount(); // Get all accounts in node disposal
      accs;
    } on EthereumUserRejected {
      log('User rejected the modal');
    }
  }

  Future<String> callReadOnlyMethod(String method, List<dynamic> args) async {
    try {
      final result = await busd.call(method, args);
      showToast(result.toString());
      return result.toString();
    } catch (e) {
      log(e.toString());
      showToast(e.toString());
      return e.toString();
    }
  }

  Future<void> callPayableMethod(
      String method, List<dynamic> args, TransactionOverride override) async {
    final navigator = Navigator.of(context);
    try {
      final send = await busd.send(method, args, override);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
                child: SizedBox(
                  height: 10,
                  width: 300,
                  child: LinearProgressIndicator(),
                ),
              ));
      final result = await send.wait();
      navigator.pop();
      showToast(result.logs.toString());
    } catch (e) {
      showToast(e.toString());
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  late Contract busd;
  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LimitedBox(
          maxWidth: MediaQuery.of(context).size.width * 0.5,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  hintText: 'Enter your wallet address',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller2,
                decoration: const InputDecoration(
                  hintText: 'Enter the token address you want to withdraw',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await setupEth(customContractAddress: _controller.text);
                  await callReadOnlyMethod('withdrawEth', []);
                },
                child: const Text('Withdraw ETH (manager only)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await setupEth(customContractAddress: _controller.text);
                  await callReadOnlyMethod(
                      'withdrawToken', [_controller2.text]);
                },
                child: const Text('Withdraw Token (manager only)'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await setupEth(customContractAddress: _controller.text);
                  await callReadOnlyMethod('release', [_controller2.text]);
                },
                child: const Text(
                    'Release Token (don\'t forget to enter token address)'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await setupEth(customContractAddress: _controller.text);
                  await callReadOnlyMethod('release', []);
                },
                child: const Text('Release Eth'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ManagerPage extends StatefulWidget {
  const ManagerPage({super.key});

  @override
  State<ManagerPage> createState() => _ManagerPageState();
}

class _ManagerPageState extends State<ManagerPage> {
  Future<void> setupEth({String? customContractAddress}) async {
    // From RPC
    final web3provider = Web3Provider(ethereum!);

    busd = Contract(
      customContractAddress ?? contractAddress,
      Interface(generatorAbi),
      web3provider.getSigner(),
    );

    try {
      // Prompt user to connect to the provider, i.e. confirm the connection modal
      final accs =
          await ethereum!.requestAccount(); // Get all accounts in node disposal
      accs; // [foo,bar]
    } on EthereumUserRejected {
      log('User rejected the modal');
    }
  }

  Future<String> callReadOnlyMethod(String method, List<dynamic> args) async {
    try {
      final result = await busd.call(method, args);
      showToast(result.toString());
      return result.toString();
    } catch (e) {
      showToast(e.toString());
      return e.toString();
    }
  }

  Future<void> callPayableMethod(
      String method, List<dynamic> args, TransactionOverride override) async {
    final navigator = Navigator.of(context);
    try {
      final send = await busd.send(method, args, override);
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => const Center(
                child: SizedBox(
                  height: 10,
                  width: 300,
                  child: LinearProgressIndicator(),
                ),
              ));
      final result = await send.wait();
      navigator.pop();
      showToast(result.logs.toString());
    } catch (e) {
      showToast(e.toString());
    }
  }

  void showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  late Contract busd;

  final TextEditingController _controller = TextEditingController();
  final TextEditingController _controller2 = TextEditingController();
  final TextEditingController _controller3 = TextEditingController();
  final TextEditingController _controller4 = TextEditingController();
  String wallets = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LimitedBox(
          maxWidth: MediaQuery.of(context).size.width * 0.3,
          child: Column(
            children: [
              const SizedBox(height: 20),
              TextField(
                controller: _controller,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Enter the address of the employee',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller2,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Enter the start date',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller3,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Enter the duration',
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _controller4,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  hintText: 'Enter amount of eth to transfer for the employee',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _controller.text.isNotEmpty &&
                        _controller2.text.isNotEmpty &&
                        _controller3.text.isNotEmpty &&
                        _controller4.text.isNotEmpty
                    ? () async {
                        await setupEth();
                        await callPayableMethod(
                          'createWallet',
                          [
                            _controller.text,
                            _controller2.text,
                            _controller3.text
                          ],
                          TransactionOverride(
                            value: BigInt.from(int.parse(_controller4.text)) *
                                BigInt.parse(
                                    '1000000000000000000' /*10^16 + 1*/),
                          ),
                        );
                      }
                    : null,
                child: const Text('Create wallet'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await setupEth();
                  wallets = await callReadOnlyMethod('getWallets', []);
                  setState(() {});
                },
                child: const Text(
                  'Get all wallet addresses',
                ),
              ),
              const SizedBox(height: 20),
              SelectableText(wallets),
            ],
          ),
        ),
      ),
    );
  }
}
