import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'bluetooth_app.dart'; // Import FlutterBlueApp từ file hiện tại

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String currentMode = "Select Mode"; // Biến để lưu trạng thái chế độ hiện tại
  late MqttServerClient mqttClient;

  @override
  void initState() {
    super.initState();
    _connectToMqtt();
  }

  Future<void> _connectToMqtt() async {
    mqttClient = MqttServerClient('f69f6416905b4890a65c0d638608cfff.s1.eu.hivemq.cloud', '');
    mqttClient.port = 8883;
    mqttClient.secure = true;
    mqttClient.logging(on: true);
    mqttClient.keepAlivePeriod = 20;
    mqttClient.onDisconnected = _onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier('flutter_client')
        .authenticateAs('test', '1')
        .startClean();
    mqttClient.connectionMessage = connMessage;

    try {
      await mqttClient.connect();
      print('Connected to MQTT broker');
    } catch (e) {
      print('Error connecting to MQTT broker: $e');
      mqttClient.disconnect();
    }
  }

  void _onDisconnected() {
    print('Disconnected from MQTT broker');
  }

  void _publishMessage(String mode) {
    const topic = 'connect_mode';
    final builder = MqttClientPayloadBuilder();
    builder.addString(mode);
    try {
      mqttClient.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!);
      print('Message "$mode" published to topic "$topic"');
    } catch (e) {
      print('Error publishing message: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(currentMode),
        backgroundColor: Colors.lightBlue,
      ),
      body: Center(
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            fixedSize: const Size(200, 200),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            backgroundColor: Colors.blueAccent,
            foregroundColor: Colors.white,
          ),
          onPressed: () => _showModeSelector(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.settings, size: 60),
              SizedBox(height: 10),
              Text("Select Mode", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  void _showModeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.wifi, color: Colors.blue),
                title: const Text("Access Point Mode"),
                onTap: () {
                  setState(() {
                    currentMode = "Access Point Mode";
                  });
                  _publishMessage('apmode');
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AccessPointScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.cable, color: Colors.green),
                title: const Text("LAN Mode"),
                onTap: () {
                  setState(() {
                    currentMode = "LAN Mode";
                  });
                  _publishMessage('lanmode');
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const LanScreen()),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.bluetooth, color: Colors.teal),
                title: const Text("BLE Mode"),
                onTap: () {
                  setState(() {
                    currentMode = "BLE Mode";
                  });
                  _publishMessage('blemode');
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const FlutterBlueApp()),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class AccessPointScreen extends StatelessWidget {
  const AccessPointScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Access Point Mode")),
      body: const Center(child: Text("Access Point Mode Active")),
    );
  }
}

class LanScreen extends StatelessWidget {
  const LanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LAN Mode")),
      body: const Center(child: Text("LAN Mode Active")),
    );
  }
}
