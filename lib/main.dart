import 'package:flutter/material.dart';

void main() {
  runApp(const AplikasiKeuangan());
}

// =====================================================================
// MODEL DATA
// =====================================================================

class Kategori {
  final String nama;
  final String gambar; // path Image.asset
  final Color warna;

  const Kategori(this.nama, this.gambar, this.warna);
}

class Transaksi {
  final String judul;
  final int nominal;
  final Kategori kategori;
  final String catatan;
  final DateTime tanggal;

  Transaksi({
    required this.judul,
    required this.nominal,
    required this.kategori,
    required this.catatan,
    required this.tanggal,
  });
}

const List<Kategori> daftarKategori = [
  Kategori('Makan', 'assets/images/makan.png', Color(0xFFEF6C00)),
  Kategori('Transportasi', 'assets/images/transportasi.png', Color(0xFF1E88E5)),
  Kategori('Kuliah', 'assets/images/kuliah.png', Color(0xFF43A047)),
  Kategori('Hiburan', 'assets/images/hiburan.png', Color(0xFF8E24AA)),
];

// =====================================================================
// FUNGSI BANTU
// =====================================================================

String formatRupiah(int angka) {
  final s = angka.toString();
  final buffer = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buffer.write('.');
    buffer.write(s[i]);
  }
  return 'Rp $buffer';
}

String formatTanggal(DateTime d) {
  const bulan = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des'
  ];
  final jam = d.hour.toString().padLeft(2, '0');
  final menit = d.minute.toString().padLeft(2, '0');
  return '${d.day} ${bulan[d.month - 1]} ${d.year}, $jam:$menit';
}

// Widget kecil untuk menampilkan ikon kategori (Image.asset)
class GambarKategori extends StatelessWidget {
  final Kategori kategori;
  final double ukuran;

  const GambarKategori({super.key, required this.kategori, this.ukuran = 44});

  @override
  Widget build(BuildContext context) {
    return ClipOval(
      child: Image.asset(
        kategori.gambar,
        width: ukuran,
        height: ukuran,
        fit: BoxFit.cover,
      ),
    );
  }
}

// =====================================================================
// APLIKASI
// =====================================================================

class AplikasiKeuangan extends StatelessWidget {
  const AplikasiKeuangan({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Keuanganku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: const HalamanUtama(),
    );
  }
}

// =====================================================================
// HALAMAN 1: HALAMAN UTAMA (TabBar: Riwayat & Kategori)
// =====================================================================

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  // Data disimpan sementara di list selama aplikasi berjalan.
  final List<Transaksi> _transaksi = [
    Transaksi(
      judul: 'Nasi goreng kantin',
      nominal: 18000,
      kategori: daftarKategori[0],
      catatan: 'Makan siang setelah praktikum',
      tanggal: DateTime(2026, 10, 30, 12, 15),
    ),
    Transaksi(
      judul: 'Ojek online ke kampus',
      nominal: 22000,
      kategori: daftarKategori[1],
      catatan: 'Berangkat pagi karena ada kuis',
      tanggal: DateTime(2026, 10, 30, 6, 45),
    ),
    Transaksi(
      judul: 'Print laporan praktikum',
      nominal: 15000,
      kategori: daftarKategori[2],
      catatan: '30 lembar + jilid',
      tanggal: DateTime(2026, 10, 29, 16, 20),
    ),
    Transaksi(
      judul: 'Nonton bioskop',
      nominal: 45000,
      kategori: daftarKategori[3],
      catatan: 'Bareng teman kelas',
      tanggal: DateTime(2026, 10, 28, 19, 0),
    ),
    Transaksi(
      judul: 'Kopi dan roti',
      nominal: 27000,
      kategori: daftarKategori[0],
      catatan: 'Sarapan di kafe dekat kampus',
      tanggal: DateTime(2026, 10, 28, 8, 10),
    ),
    Transaksi(
      judul: 'Beli buku catatan',
      nominal: 35000,
      kategori: daftarKategori[2],
      catatan: 'Buku tulis dan pulpen',
      tanggal: DateTime(2026, 10, 27, 14, 30),
    ),
  ];

  int get _totalPengeluaran =>
      _transaksi.fold<int>(0, (jumlah, t) => jumlah + t.nominal);

  // Membuka form dan menunggu data yang dikirim balik lewat Navigator.pop
  Future<void> _bukaFormTambah() async {
    final hasil = await Navigator.push<Transaksi>(
      context,
      MaterialPageRoute(builder: (context) => const HalamanTambah()),
    );

    if (!mounted) return;
    if (hasil != null) {
      setState(() {
        _transaksi.insert(0, hasil); // transaksi terbaru di paling atas
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil ditambahkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Catatan Keuanganku'),
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.history), text: 'Riwayat'),
              Tab(icon: Icon(Icons.category), text: 'Kategori'),
            ],
          ),
        ),
        body: Column(
          children: [
            _kartuTotal(),
            Expanded(
              child: TabBarView(
                children: [
                  _tabRiwayat(),
                  _tabKategori(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _bukaFormTambah,
          icon: const Icon(Icons.add),
          label: const Text('Tambah'),
        ),
      ),
    );
  }

  // Kartu informasi total pengeluaran (gambar dari internet: Image.network)
  Widget _kartuTotal() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: SizedBox(
          height: 130,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                'https://picsum.photos/seed/keuangan/600/260',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(color: Colors.teal),
              ),
              Container(color: Colors.black54),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Pengeluaran',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(_totalPengeluaran),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_transaksi.length} transaksi tercatat',
                      style: const TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // TAB 1: daftar riwayat transaksi (ListView.separated)
  Widget _tabRiwayat() {
    if (_transaksi.isEmpty) {
      return const Center(child: Text('Belum ada transaksi'));
    }
    return ListView.separated(
      padding: const EdgeInsets.only(bottom: 88),
      itemCount: _transaksi.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final t = _transaksi[index];
        return ListTile(
          leading: GambarKategori(kategori: t.kategori),
          title: Text(t.judul),
          subtitle: Text('${t.kategori.nama} • ${formatTanggal(t.tanggal)}'),
          trailing: Text(
            formatRupiah(t.nominal),
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HalamanDetail(transaksi: t),
              ),
            );
          },
        );
      },
    );
  }

  // TAB 2: daftar kategori beserta total (ListView.builder)
  Widget _tabKategori() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 88),
      itemCount: daftarKategori.length,
      itemBuilder: (context, index) {
        final kategori = daftarKategori[index];
        final daftar =
            _transaksi.where((t) => t.kategori == kategori).toList();
        final total = daftar.fold<int>(0, (jumlah, t) => jumlah + t.nominal);

        return Card(
          child: ListTile(
            leading: GambarKategori(kategori: kategori, ukuran: 48),
            title: Text(
              kategori.nama,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text('${daftar.length} transaksi'),
            trailing: Text(
              formatRupiah(total),
              style: TextStyle(
                color: kategori.warna,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HalamanKategori(
                    kategori: kategori,
                    daftar: daftar,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// =====================================================================
// HALAMAN 2: FORM TAMBAH TRANSAKSI
// =====================================================================

class HalamanTambah extends StatefulWidget {
  const HalamanTambah({super.key});

  @override
  State<HalamanTambah> createState() => _HalamanTambahState();
}

class _HalamanTambahState extends State<HalamanTambah> {
  final _formKey = GlobalKey<FormState>();
  final _judulController = TextEditingController();
  final _nominalController = TextEditingController();
  final _catatanController = TextEditingController();
  Kategori _kategoriDipilih = daftarKategori[0];

  @override
  void dispose() {
    _judulController.dispose();
    _nominalController.dispose();
    _catatanController.dispose();
    super.dispose();
  }

  void _simpan() {
    if (_formKey.currentState!.validate()) {
      final transaksiBaru = Transaksi(
        judul: _judulController.text.trim(),
        nominal: int.parse(_nominalController.text.trim()),
        kategori: _kategoriDipilih,
        catatan: _catatanController.text.trim(),
        tanggal: DateTime.now(),
      );
      // Kirim data kembali ke halaman utama
      Navigator.pop(context, transaksiBaru);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Transaksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _judulController,
                decoration: const InputDecoration(
                  labelText: 'Judul transaksi',
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Judul tidak boleh kosong';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nominalController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Nominal (Rp)',
                  prefixIcon: Icon(Icons.payments),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final angka = int.tryParse(value?.trim() ?? '');
                  if (angka == null || angka <= 0) {
                    return 'Masukkan nominal berupa angka lebih dari 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Kategori>(
                value: _kategoriDipilih,
                decoration: const InputDecoration(
                  labelText: 'Kategori',
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
                ),
                items: daftarKategori
                    .map(
                      (k) => DropdownMenuItem<Kategori>(
                        value: k,
                        child: Text(k.nama),
                      ),
                    )
                    .toList(),
                onChanged: (nilai) {
                  if (nilai != null) {
                    setState(() => _kategoriDipilih = nilai);
                  }
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _catatanController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Catatan (opsional)',
                  prefixIcon: Icon(Icons.notes),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _simpan,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// HALAMAN 3: DETAIL TRANSAKSI
// =====================================================================

class HalamanDetail extends StatelessWidget {
  final Transaksi transaksi;

  const HalamanDetail({super.key, required this.transaksi});

  Widget _baris(String label, String isi) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(child: Text(isi)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Transaksi')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GambarKategori(kategori: transaksi.kategori, ukuran: 110),
            const SizedBox(height: 12),
            Text(
              formatRupiah(transaksi.nominal),
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: [
                    _baris('Judul', transaksi.judul),
                    const Divider(height: 1),
                    _baris('Kategori', transaksi.kategori.nama),
                    const Divider(height: 1),
                    _baris('Tanggal', formatTanggal(transaksi.tanggal)),
                    const Divider(height: 1),
                    _baris(
                      'Catatan',
                      transaksi.catatan.isEmpty ? '-' : transaksi.catatan,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================================
// HALAMAN 4: TRANSAKSI PER KATEGORI
// =====================================================================

class HalamanKategori extends StatelessWidget {
  final Kategori kategori;
  final List<Transaksi> daftar;

  const HalamanKategori({
    super.key,
    required this.kategori,
    required this.daftar,
  });

  @override
  Widget build(BuildContext context) {
    final total = daftar.fold<int>(0, (jumlah, t) => jumlah + t.nominal);

    return Scaffold(
      appBar: AppBar(title: Text('Kategori ${kategori.nama}')),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: kategori.warna.withAlpha(30),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GambarKategori(kategori: kategori, ukuran: 56),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total kategori ini'),
                    Text(
                      formatRupiah(total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: daftar.isEmpty
                ? const Center(child: Text('Belum ada transaksi'))
                : ListView.builder(
                    itemCount: daftar.length,
                    itemBuilder: (context, index) {
                      final t = daftar[index];
                      return ListTile(
                        title: Text(t.judul),
                        subtitle: Text(formatTanggal(t.tanggal)),
                        trailing: Text(
                          formatRupiah(t.nominal),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HalamanDetail(transaksi: t),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
