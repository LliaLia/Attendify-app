import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'calendar_page.dart';
import 'profile_page.dart';
import 'jadwal_kerja_page.dart'; // Pastikan file ini sudah dibuat

class AbsensiPage extends StatefulWidget {
  const AbsensiPage({super.key});

  @override
  State<AbsensiPage> createState() => _AbsensiPageState();
}

class _AbsensiPageState extends State<AbsensiPage> {
  final SupabaseClient supabase = Supabase.instance.client;
  String currentTime = DateFormat('HH.mm').format(DateTime.now());
  CameraController? _cameraController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _checkLocationPermission();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        _cameraController = CameraController(
          cameras.firstWhere(
            (cam) => cam.lensDirection == CameraLensDirection.front,
            orElse: () => cameras.first,
          ),
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await _cameraController!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint("Error kamera: $e");
    }
  }

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return;
    }
  }

  Future<void> _prosesAbsensi() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;
    setState(() => _isLoading = true);

    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      
      final String googleMapsUrl = "https://www.google.com/maps/search/?api=1&query=${position.latitude},${position.longitude}";
      
      final XFile image = await _cameraController!.takePicture();
      final bytes = await image.readAsBytes();
      final String fileName = 'absensi_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final String path = 'foto_absen/$fileName';

      await supabase.storage.from('absensi_foto').uploadBinary(
        path, 
        bytes, 
        fileOptions: const FileOptions(contentType: 'image/jpeg')
      );
      
      final String downloadUrl = supabase.storage.from('absensi_foto').getPublicUrl(path);

      await supabase.from('absensi').insert({
        'nama': 'Gojo Satoru',
        'waktu': DateTime.now().toIso8601String(),
        'foto_url': downloadUrl,
        'lat': position.latitude,
        'long': position.longitude,
        'alamat': googleMapsUrl,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Absensi Berhasil!"), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      debugPrint("Detail Error: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: $e"), backgroundColor: Colors.red)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 30),
              Text(
                currentTime,
                style: const TextStyle(fontSize: 80, fontWeight: FontWeight.bold, color: Color(0xFF2D5A27)),
              ),
              const SizedBox(height: 20),
              _buildJadwalCard(), // Widget yang sekarang bisa diklik
              const SizedBox(height: 30),
              _buildCameraPreview(),
              const SizedBox(height: 30),
              _buildAbsenButton(),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildHeader() {
    return Row(
      children: [
        InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfilePage())),
          child: Row(
            children: [
              const CircleAvatar(radius: 30, backgroundColor: Colors.greenAccent),
              const SizedBox(width: 15),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Halo, Gojo Satoru", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF7BA67B))),
                  Text("Staff IT", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        IconButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CalendarPage())),
          icon: Icon(Icons.calendar_month_rounded, size: 40, color: Colors.green[800]),
        ),
      ],
    );
  }

  Widget _buildJadwalCard() {
    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () {
          // Navigasi ke halaman Jadwal Kerja
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const JadwalKerjaPage()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                const Text("Jadwal Hari Ini", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF7BA67B))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), 
                  decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(10)), 
                  child: const Text("Tepat Waktu", style: TextStyle(color: Colors.white, fontSize: 10))
                ),
              ]),
              const Divider(height: 25),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text("Masuk:"), Text("08.00", style: TextStyle(fontWeight: FontWeight.bold))]),
              const SizedBox(height: 5),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: const [Text("Pulang:"), Text("17.00", style: TextStyle(fontWeight: FontWeight.bold))]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      height: 350,
      width: double.infinity,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green, width: 2)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: (_cameraController != null && _cameraController!.value.isInitialized)
            ? CameraPreview(_cameraController!)
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildAbsenButton() {
    return SizedBox(
      width: double.infinity,
      height: 60,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _prosesAbsensi,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF99C499), 
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
        ),
        child: _isLoading 
          ? const CircularProgressIndicator(color: Colors.white) 
          : const Text("ABSEN MASUK", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }
}