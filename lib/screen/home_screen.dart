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
  final String lineNotifyToken = 'mn1ol4axwYxkZfT3foNpG74txt7TBNnzbV9td4BKxC6';
  final Set<Machine> notifiedMachines = {};

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        updateMachineTimers(washingMachines);
        updateMachineTimers(dryers);
      });
    });
  }

  void updateMachineTimers(List<Machine> machines) {
    for (var machine in machines) {
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
          'message': '${machine.name} เหลือเวลาน้อยกว่า 1 นาที!',
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

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
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
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: selectedIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.local_laundry_service),
            label: 'เครื่องซักผ้า',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.local_laundry_service),
            label: 'เครื่องอบผ้า',
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
          child: Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: machines.length,
          itemBuilder: (context, index) {
            return _buildMachineCard(machines[index], icon);
          },
        ),
      ],
    );
  }

  Widget _buildMachineCard(Machine machine, IconData icon) {
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
                  Text(machine.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      Icon(Icons.circle, color: machine.color),
                      const SizedBox(width: 5),
                      Text(machine.status),
                    ],
                  ),
                  if (machine.time != null && machine.time! > 0)
                    Text('เหลือเวลา: ${formatTime(machine.time!)}'),
                ],
              ),
            ),
          ],
        ),
      ),
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
