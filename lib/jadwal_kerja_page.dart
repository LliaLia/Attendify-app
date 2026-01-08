import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';

class JadwalKerjaPage extends StatefulWidget {
  const JadwalKerjaPage({super.key});

  @override
  State<JadwalKerjaPage> createState() => _JadwalKerjaPageState();
}

class _JadwalKerjaPageState extends State<JadwalKerjaPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Jadwal", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Bagian Kalender
          TableCalendar(
            locale: 'id_ID', // Pastikan sudah inisialisasi di main.dart
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: _calendarFormat,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });
            },
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(color: Colors.greenAccent, shape: BoxShape.circle),
              selectedDecoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle),
              markerDecoration: BoxDecoration(color: Colors.red, shape: BoxShape.circle),
            ),
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
            ),
          ),
          const SizedBox(height: 10),
          const Divider(thickness: 5, color: Color(0xFFF5F5F5)),
          
          // Bagian Detail Jadwal (Bottom Detail)
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Jadwal Kerja", style: TextStyle(color: Colors.grey, fontSize: 14)),
                  const Text("Jumat, 09 Januari", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildDetailCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(5)),
          child: const Text("Office", style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Pemrograman mobile app", style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            const Text("Offline - Kantor dev", style: TextStyle(color: Colors.orange, fontSize: 12)),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: const [
            Icon(Icons.people_outline, size: 18, color: Colors.grey),
            SizedBox(width: 5),
            Text("Front end", style: TextStyle(color: Colors.grey)),
          ],
        ),
        Row(
          children: const [
            Icon(Icons.access_time, size: 18, color: Colors.grey),
            SizedBox(width: 5),
            Text("08:00 - 12:10", style: TextStyle(color: Colors.grey)),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Sesi documentasi. -", style: TextStyle(color: Colors.grey)),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: const Text("Lihat Detail", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ],
    );
  }
}