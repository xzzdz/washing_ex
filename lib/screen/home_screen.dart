import 'package:flutter/material.dart';
import 'dart:async';//

class Homescreen extends StatefulWidget {
  const Homescreen({super.key});

  @override
  State<Homescreen> createState() => _HomescreenState();
}

class _HomescreenState extends State<Homescreen> {
  final List<Map<String, dynamic>> washingMachines = [
    {
      'name': 'เครื่องซักผ้า 1',
      'status': 'ว่าง', 
      'color': Colors.green
      },
    {
      'name': 'เครื่องซักผ้า 2', 
      'status': 'ว่าง', 
      'color': Colors.green
      },
    {
      'name': 'เครื่องซักผ้า 3',
      'status': 'ไม่ว่าง',
      'color': Colors.red,
      'time': 2400
    }, // 40 นาที
    {
      'name': 'เครื่องซักผ้า 4',
      'status': 'ไม่ว่าง',
      'color': Colors.red,
      'time': 1200
    }, // 20 นาที
  ];

  final List<Map<String, dynamic>> dryers = [
    {
      'name': 'เครื่องอบผ้า 1',
      'status': 'ไม่ว่าง',
      'color': Colors.red,
      'time': 1800
    }, // 30 นาที
    {
      'name': 'เครื่องอบผ้า 2', 
      'status': 'ว่าง', 
      'color': Colors.green
      },
    {
      'name': 'เครื่องอบผ้า 3', 
      'status': 'ว่าง', 
      'color': Colors.green
      },
    {
      'name': 'เครื่องอบผ้า 4', 
      'status': 'ไม่ว่าง', 
      'color': Colors.red
      },
  ];

  int selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    startCountdown();
  }

  void startCountdown() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        for (var machine in washingMachines) {
          if (machine['time'] != null && machine['time'] > 0) {
            machine['time']--;
          }
        }
        for (var dryer in dryers) {
          if (dryer['time'] != null && dryer['time'] > 0) {
            dryer['time']--;
          }
        }
      });
    });
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
        title: const Text('Washing and Drying App',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: Color.fromARGB(255, 63, 175, 128),
      ),
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: ToggleButtons(
              borderRadius: BorderRadius.circular(10),
              borderColor: Colors.grey,
              selectedBorderColor: Color.fromARGB(255, 63, 175, 128),
              selectedColor: Colors.white,
              fillColor: Color.fromARGB(255, 63, 175, 128),
              color: Colors.black,
              constraints: BoxConstraints(minHeight: 40.0, minWidth: 120.0),
              isSelected: [selectedIndex == 0, selectedIndex == 1],
              onPressed: (int index) {
                setState(() {
                  selectedIndex = index;
                });
              },
              children: <Widget>[
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
                  _buildMachineSection("เครื่องอบผ้า", dryers, Icons.local_laundry_service,),
              ],
            ),
          ),
        ],
      ),
    );
  }//

  Widget _buildMachineSection(String title, List<Map<String, dynamic>> machines, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Text(title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
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
                    SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(machines[index]['name'],
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                          Row(
                            children: [
                              Icon(Icons.circle,
                                  color: machines[index]['color']),
                              SizedBox(width: 5),
                              Text(machines[index]['status']),
                            ],
                          ),
                          if (machines[index]['time'] != null &&
                              machines[index]['time'] > 0)
                            Text(
                                'เหลือเวลา: ${formatTime(machines[index]['time'])}'),
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