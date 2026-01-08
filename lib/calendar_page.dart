import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});

  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final SupabaseClient supabase = Supabase.instance.client;

  // Fungsi untuk mengambil data dari Supabase
  Future<List<Map<String, dynamic>>> _fetchRiwayat() async {
    final response = await supabase
        .from('absensi')
        .select()
        .order('waktu', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // Fungsi untuk membuka Link Google Maps
  Future<void> _openMaps(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("Tidak bisa membuka link");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Absensi", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchRiwayat(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("Belum ada data absensi"));
          }

          final riwayat = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: riwayat.length,
            itemBuilder: (context, index) {
              final item = riwayat[index];
              DateTime waktu = DateTime.parse(item['waktu']);
              String formattedDate = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(waktu);
              String formattedTime = DateFormat('HH:mm').format(waktu);

              return Card(
                margin: const EdgeInsets.only(bottom: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Preview Foto
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          item['foto_url'],
                          width: 80,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 80),
                        ),
                      ),
                      const SizedBox(width: 15),
                      // Detail Data
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(formattedDate,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 16, color: Colors.green),
                                const SizedBox(width: 5),
                                Text("Jam: $formattedTime WIB"),
                              ],
                            ),
                            const SizedBox(height: 5),
                            // Tombol Buka Lokasi
                            InkWell(
                              onTap: () => _openMaps(item['alamat']),
                              child: Row(
                                children: const [
                                  Icon(Icons.location_on, size: 16, color: Colors.red),
                                  SizedBox(width: 5),
                                  Expanded(
                                    child: Text(
                                      "Lihat di Google Maps",
                                      style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                          fontSize: 13),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}