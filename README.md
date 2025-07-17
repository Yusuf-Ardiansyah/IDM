# **Script Aktivasi IDM (Aktivator + Pembersih Registri)**

Skrip Aktivasi IDM adalah alat yang dirancang untuk mengaktifkan Internet Download Manager (IDM) secara gratis, yang memungkinkan pengguna melewati batasan masa uji coba dan menikmati versi lengkap tanpa membeli lisensi.

### 📝 **Versi Terbaru**
- Skrip Aktivasi IDM Coporton 2.5.5
- Dukungan Internet Download Manager 6.42 Build 41

## 💪 **Fitur**

- ✅ Aktifkan Internet Download Manager secara gratis.
- Antarmuka yang sederhana dan mudah digunakan.
- Validasi versi otomatis (skrip dan IDM).
- Kompatibel dengan berbagai versi IDM.
- Ringan dan cepat.

## 🛠️ **Instalasi**

### **Metode 1 (Direkomendasikan)**
1. **Buka PowerShell**:
   - Klik kanan menu Start dan pilih **Windows PowerShell** atau **Windows Terminal**.
   - Jika diminta oleh Kontrol Akun Pengguna (UAC), klik **Ya** untuk mengizinkan PowerShell berjalan dengan hak istimewa administratif.

2. **Jalankan perintah berikut di PowerShell** untuk mengunduh dan menjalankan skrip aktivasi:

   ```powershell
   irm https://coporton.com/ias | iex
   ```

### **Metode 2**
1. **Unduh**: Dapatkan versi terbaru alat dari [halaman rilis](https://github.com/Coporton/IDM-Activation-Script/releases).
2. **Ekstrak**: Ekstrak file yang diunduh ke direktori pilihan Anda.

## 💻 **Penggunaan**

### 1. Jalankan Skrip:
Klik dua kali pada `IASL.cmd` untuk menjalankannya. Skrip akan secara otomatis meminta hak akses administratif jika diperlukan, sehingga Anda tidak perlu lagi memilih "Jalankan sebagai Administrator" secara manual.
- Jika diminta oleh Kontrol Akun Pengguna (UAC), klik **Ya** untuk memberikan izin yang diperlukan.
- Setelah ditinggikan, skrip akan terus berjalan dengan izin yang sesuai untuk operasi file.

### 2. Ikuti petunjuk di layar:
- Pilih opsi dari menu:
  - `1` untuk Mengunduh IDM Versi Terbaru.
  - `2` untuk Mengaktifkan Internet Download Manager.
  - `3` ke Ekstensi Tipe File Ekstra.
  - `4` untuk Melakukan Segalanya (2 + 3).
  - `5` Bersihkan Entri Registri IDM Sebelumnya.
  - `6` untuk keluar.
- Jika Anda memilih `4`, skrip akan menyalin file yang diperlukan ke direktori yang sesuai dan memberikan umpan balik tentang status operasi.

## ✅ **Pemecahan Masalah**

**Hak Administratif**: Jika skrip tidak meminta hak administratif, pastikan Anda menjalankannya dengan izin yang diperlukan dengan mengklik kanan dan memilih "Jalankan sebagai Administrator".
- **Jalur Berkas**: Verifikasi bahwa berkas `data.bin`, `dataHlp.bin`, `Registry.bin`, `extensions.bin`, dan `banner_art.txt` ditempatkan dengan benar di direktori `src`.
**Terdaftar dengan Serial Palsu**: Jangan khawatir! Gunakan uninstaller pihak ketiga tepercaya seperti IObit Uninstaller, lalu gunakan skrip ini [IObit Uninstaller Activation Script](https://github.com/Coporton/IObit-Uninstaller-Activation-Script) untuk mengaktifkannya dan memastikan semua berkas, termasuk entri registri, terhapus.

## 📄 **Berkas BIN**

### File-file ini tidak dienkripsi; Anda dapat mengganti namanya untuk melihat file sumber:

- `data.bin` - Berisi versi IDMan.exe yang diaktifkan.
- `dataHlp.bin` - Berisi versi dukungan bantuan IDMGrHlp.exe.
- `Registry.bin` - Nilai registri untuk mengaktifkan Internet Download Manager.
- `extensions.bin` - Entri registri untuk ekstensi file Internet Download Manager tambahan.

## 📜 **Lisensi**

Proyek ini dilisensikan di bawah Lisensi MIT. Lihat berkas [LICENSE](LICENSE) untuk detailnya.

## ℹ️ **Ucapan Terima Kasih**

- Ucapan terima kasih khusus kepada AI yang berperan penting dalam fungsionalitas skrip ini.

## ❓ **Kontak**

Untuk pertanyaan atau dukungan, silakan buka masalah di repositori GitHub.
