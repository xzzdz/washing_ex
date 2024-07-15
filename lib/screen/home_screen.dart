import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final List<Machine> washingMachines = [
    Machine(name: 'เครื่องซักผ้า 1', status: 'ว่าง', color: Colors.green),
    Machine(name: 'เครื่องซักผ้า 2', status: 'ว่าง', color: Colors.green),
    Machine(name: 'เครื่องซักผ้า 3', status: 'ไม่ว่าง', color: Colors.red, time: 70),
    Machine(name: 'เครื่องซักผ้า 4', status: 'ไม่ว่าง', color: Colors.red, time: 1200),
  ];

  final List<Machine> dryers = [
    Machine(name: 'เครื่องอบผ้า 1', status: 'ไม่ว่าง', color: Colors.red, time: 500),
    Machine(name: 'เครื่องอบผ้า 2', status: 'ว่าง', color: Colors.green),
    Machine(name: 'เครื่องอบผ้า 3', status: 'ว่าง', color: Colors.green),
    Machine(name: 'เครื่องอบผ้า 4', status: 'ไม่ว่าง', color: Colors.red, time: 2400),
  ];

  int selectedIndex = 0;
  final String lineNotifyToken = '1cxBLTnVYr4QwtppQ6OGQr08td9HLrTv5pI3gJywhcL';
  final Set<Machine> notifiedMachines = {};

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        for (var machine in washingMachines) {
          if (machine.time != null && machine.time! > 0) {
            machine.time = machine.time! - 1;
            if (machine.time! < 60 && machine.time! > 0 && !notifiedMachines.contains(machine)) {
              sendLineNotification(machine);
              notifiedMachines.add(machine);
            } else if (machine.time == 0) {
              machine.status = 'ว่าง';
              machine.color = Colors.green;
              notifiedMachines.remove(machine);
            }
          }
        }
        for (var dryer in dryers) {
          if (dryer.time != null && dryer.time! > 0) {
            dryer.time = dryer.time! - 1;
            if (dryer.time! < 60 && dryer.time! > 0 && !notifiedMachines.contains(dryer)) {
              sendLineNotification(dryer);
              notifiedMachines.add(dryer);
            } else if (dryer.time == 0) {
              dryer.status = 'ว่าง';
              dryer.color = Colors.green;
              notifiedMachines.remove(dryer);
            }
          }
        }
      });
    });
  }

  Future<void> sendLineNotification(Machine machine) async {
    print('กำลังส่งการแจ้งเตือนสำหรับ ${machine.name} ด้วยโทเค็น: $lineNotifyToken');
    try {
      final response = await http.post(
        Uri.parse('https://notify-api.line.me/api/notify'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Authorization': 'Bearer $lineNotifyToken',
        },
        body: {
          'message': 'เครื่อง ${machine.name} เหลือเวลาน้อยกว่า 1 นาที!',
        },
      );

      if (response.statusCode == 200) {
        print('ส่งการแจ้งเตือนสำเร็จ: ${response.body}');
      } else {
        print('ส่งการแจ้งเตือนไม่สำเร็จ: ${response.body}');
      }
    } catch (e) {
      print('เกิดข้อผิดพลาด: $e');
    }
  }

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60) % 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Washing and Drying App',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 63, 175, 128),
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(10),
              borderColor: Colors.grey,
              selectedBorderColor: const Color.fromARGB(255, 63, 175, 128),
              selectedColor: Colors.white,
              fillColor: const Color.fromARGB(255, 63, 175, 128),
              color: Colors.black,
              constraints: const BoxConstraints(minHeight: 40.0, minWidth: 120.0),
              isSelected: [selectedIndex == 0, selectedIndex == 1],
              onPressed: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              children: const <Widget>[
                Text('เครื่องซักผ้า', style: TextStyle(fontSize: 16)),
                Text('เครื่องอบผ้า', style: TextStyle(fontSize: 16)),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                if (selectedIndex == 0)
                  _buildMachineSection("เครื่องซักผ้า", washingMachines, Icons.local_laundry_service),
                if (selectedIndex == 1)
                  _buildMachineSection("เครื่องอบผ้า", dryers, Icons.local_laundry_service),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMachineSection(String title, List<Machine> machines, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: machines.length,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.all(10),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(icon, size: 100),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(machines[index].name,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Icon(Icons.circle, color: machines[index].color),
                              const SizedBox(width: 5),
                              Text(machines[index].status),
                            ],
                          ),
                          if (machines[index].time != null &&
                              machines[index].time! > 0)
                            Text('เหลือเวลา: ${formatTime(machines[index].time!)}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class Machine {
  final String name;
  String status;
  Color color;
  int? time;

  Machine({
    required this.name,
    required this.status,
    required this.color,
    this.time,
  });
}
