# Game Design Document for Lanting Guard

## Document Information

### Revision History

- 2026/08/08: Major revamp to mechanics and rewrite GDD

## Introduction

### Game Overview

- **Game Title:** Lanting Guard
- **Purpose of the Game:** Memperkenalkan khalayak ramai akan budaya Kalimantan sekaligus mengingatkan dampak sampah yang dibuang ke sungai
- **Engine:** Godot
- **Platform:** Android
- **Orientation:** Portrait
- **Game Mode:** Single-player, PvE
- **Genres:** Strategy, Tower Defense, Roguelike Deckbuilder
- **Target Audience:** Usia 10–40 tahun yang menggemari game strategi, terutama Slay the Spire dan Clash Royale
- **Core Inspiration:** *Slay the Spire*, *Clash Royale*, *Plants vs Zombies*

### High Concept

Lanting Guard adalah game strategi yang menggabungkan aspek Tower Defense dengan Roguelike Deckbuilder dengan form factor mobile portrait, di mana player berupaya menyusuri titik-titik pada peta untuk mempertahankan rumah lanting dari limbah hidup dan menghancurkan sumber limbah menggunakan dek kartu berisi jukung dan barang yang membantu.

### Summary

Climate change has caused river levels to rise in South Kalimantan, while an irresponsible corporate entity dumps toxic industrial waste near the riverhead. A young local resident utilizes *rumah lanting* technology to journey upriver, deploying recycled local boats (*jukung* and *kelotok*) to fend off mutant trash monsters. Defeated trash is salvaged for energy to craft new defenses, heal units, and push toward the pollution source.

## Gameplay & Mechanics

### Goal/Objectives

Player menyusuri peta (graph bercabang) aliran sungai, dari hilir (node terbawah) ke hulu (node teratas). Node dapat berupa Pertarungan (Combat), Pertarungan Bos (Boss Combat), Pasar Terapung (Shop), Dermaga (Campfire), Harta Karun (Treasure), atau Peristiwa (Event).

## Mechanics

### Baseline Numbers

- Angka baseline untuk game ini adalah 5 dan kelipatannya.
- Player memulai game dengan 5 Slot Jukung dan 5 Energi. Slot Jukung dan Energi dapat ditingkatkan melalui opsi upgrade di Dermaga.
- HP rumah lanting adalah 100.
- HP baseline jukung 30.
- HP baseline musuh adalah 20.
- Damage baseline jukung dan musuh adalah 5.
- Player memulai game dengan 100 rongsokan (scrap).

### Cards

- Terdapat dua jenis kartu: kartu jukung (unit card) dan kartu barang (item card).
- Kartu jukung berfungsi seperti plant seed di Plants vs Zombies, dalam artian kita hanya memiliki 1 kartu jukung, tetapi kita bisa menaruh banyak kartu jukung (1:N).
  - Kartu jukung dapat diibaratkan sebagai relic di Slay the Spire. Kita tidak bisa memiliki relic duplikat di Slay the Spire, alias relic bersifat unique, seperti primary key.
  - Kartu jukung di dalam story digambarkan sebagai cetak biru (blueprint), sehingga menjelaskan mengapa kita bisa mendapatkan jukung di dalam peti harta karun atau membelinya dari pedagang di pasar terapung.
- Kartu barang berfungsi seperti troop di Clash Royale, dalam artian kita memiliki jumlah kartu yang tak dapat diubah (8 kartu jika menyesuaikan Clash Royale) layaknya A Match Made in Dungeon. Ketika kita memulai Fase Bertarung, kita diberikan 4 kartu acak dari dek. Jika suatu kartu dimainkan, kartu baru akan menempati posisinya. Kartu kemudian berotasi (cycle). Tidak ada Draw dan Discard Pile layaknya Slay the Spire untuk meminimalisir cognitive load.
  - Kartu barang dapat diibaratkan sebagai card di Slay the Spire atau A Match Made in Dungeon. Walaupun kita hanya memiliki 8 slot kartu di dalam dek, kita dapat memiliki kartu yang sama (duplikat).
  - Kartu barang di dalam story digambarkan sebagai barang nyata. Energi digambarkan sebagai tenaga yang diperlukan untuk memanfaatkan barang tersebut (melempar parang, menjatuhkan jaring, atau melakukan perbaikan jukung).

### List of Cards

#### Unit Cards

- **Jukung Striker:**
- **Jukung AoE:** Splash damage for swarms.
- **Jukung Wall:** High health, blocks enemy progress.

#### Item Cards

- **Heal/Repair:** Restores health to active units or the base.
- **Direct Damage:** Environmental or explosive strikes on trash monsters.
- **Crowd Control:** Slows down incoming monster progression.

### Player Stats

- **Health Points (HP):** Melambangkan seberapa "sehat" rumah lanting milik player. Player memulai game dengan 100 HP. HP dapat ditingkatkan dari Peristiwa (Event) tertentu.
- **Slot Jukung:** Melambangkan berapa banyak jukung yang dapat dikerahkan oleh player pada suatu waktu. Player memulai game dengan 5 slot. Slot ini dapat ditingkatkan dengan memilih opsi upgrade slot di Dermaga (Campfire) atau Peristiwa tertentu atau membelinya di Pasar Terapung (Shop).
  - Misalnya, Jukung A menempati 1 slot, Jukung B menempati 2 slot, dan Jukung C menempati 3 slot. Player bisa memilih untuk menaruh 5 buah Jukung A; 2 buah Jukung B dan 1 buah jukung A; atau 1 buah Jukung B dan 1 buah Jukung C. Slot ini BUKAN merupakan posisi pada sungai, melainkan batasan numerik.
- **Energi:** Melambangkan banyak tenaga yang perlu dikeluarkan untuk menggunakan kartu barang. Player memulai game dengan 5 energi. Jumlah energi dapat ditingkatkan dengan memilih opsi upgrade energi di Dermaga atau Peristiwa tertentu atau membelinya di Pasar Terapung.
- **Slot Kartu:** Seberapa banyak kartu barang yang dapat dimiliki player. Jumlah kartu jukung tidak dibatasi. Player hanya dapat memiliki 8 kartu barang, dan ketika memperoleh kartu barang baru, player diharuskan mengganti kartu yang sudah ada.
- **Rongsokan (Scrap)**: Mata uang di dalam game. Diperoleh sebagai reward memenangkan Pertarungan atau dari Peristiwa tertentu. Player memulai game dengan 100 rongsokan. Player dapat menghabiskan rongsokan di Pasar Terapung untuk membeli kartu atau upgrade stat.

### Enemies

### Progression

- Player harus melalui TEPAT 10 node (tidak lebih dan tidak kurang) untuk memenangkan game.
- Rute yang dipilih player memiliki tepat 1 Harta Karun, 1-2 Pasar Terapung, 2-3 Dermaga, 0-2 Peristiwa, 2-4 Pertarungan, dan tepat 1 Pertarungan Bos.
- Urutan pencapaian node dapat berubah, kecuali sebagai berikut:
  - Salah satu Pertarungan selalu berada pada barisan node 1.
  - Harta Karun selalu berada pada barisan node 6.
  - Salah satu Dermaga selalu berada pada barisan node 9 untuk mengizinkan player heal/upgrade sebelum Pertarungan Bos.
  - Pertarungan Bos selalu berada pada node 10.

#### Map Structure Example

```py
10. Pertarungan Bos # berakhir di sini
    |
9. Dermaga 2 # heal ATAU upgrade untuk terakhir kalinya
    |
8. Pertarungan 4
    |
7. Pasar Terapung # membeli kartu jukung atau barang
    |
6. Harta Karun # mendapatkan kartu jukung secara cuma-cuma
    |
5. Pertarungan 3
    |
4. Peristiwa # skenario singkat berupa pilihan
    | 
3. Dermaga 1 # memperbaiki (heal) rumah lanting ATAU meng-upgrade stat
    |
2. Pertarungan 2
    |
1. Pertarungan 1 # mulai di sini
```

#### Map Nodes

Node diberi ikon saja, tetapi terdapat legenda peta yang menjelaskan maksud dari ikon.

- **Pertarungan (Combat):** Berisi Gelombang (Wave) yang harus dilewati oleh player. Memenangkan Pertarungan akan memberikan player sejumlah rongsokan dan opsi kartu barang (kartu jukung tidak bisa didapatkan dari sini).
- **Dermaga (Campfire):** Berisi 3 opsi, yaitu Perbaiki Rumah (Heal) yang mengembalikan 30% HP; Tingkatkan Slot Jukung yang menambahkan 1 slot; dan Tingkatkan Energi yang menambahkan 1 energi. Gratis.
- **Pasar Terapung (Shop):** Berisi sekumpulan opsi kartu yang dapat dibeli (anggaplah 4 kartu barang dan 2 kartu jukung) dan upgrade slot jukung atau energi.
- **Harta Karun (Treasure):** Berisi opsi 1 dari 3 kartu jukung. Gratis.
- **Peristiwa (Event):** Berisi skenario singkat yang menjelaskan apa yang terjadi dan apa opsi yang dapat dilakukan player. Umumnya berupa tradeoff (contoh: meningkatkan HP tapi mengurangi energi).
- **Pertarungan Bos (Boss Combat):** Juga berisi Gelombang layaknya Pertarungan biasa, tetapi Gelombang juga berfungsi sebagai "boss phases".

### Combat Structure

Pertarungan terdiri dari 1 atau lebih Gelombang (Wave). Suatu Gelombang terdiri dari 2 Fase, yaitu Fase Bersiap dan Fase Bertarung.

#### Fase Bersiap (Pre-Wave)

- Player diberikan SELURUH kartu jukung yang mereka miliki.
- Player dapat menaruh jukung di sungai dengan cara drag-and-drop ATAU klik kartu kemudian klik lokasi untuk menaruh jukung (untuk mempersingkat penjelasan, cara ini akan disebut point-and-click).
- Player dapat menaruh jukung di area yang ditentukan (area akan di-highlight ketika drag-and-drop atau mengeklik kartu).
  - Batas area tersebut adalah di depan rumah lanting (yang terletak di bagian bawah layar) hingga bagian atas layar.
- Player dapat memindahkan jukung yang sudah ditaruh dengan cara yang sama dengan menaruhnya (drag-and-drop atau point-and-click).
- Player dapat menarik kembali jukung dari sungai dengan cara drag-and-drop atau point-and-click menjauh dari sungai dan menjatuhkannya di hand.
- Jika merupakan Fase Bersiap untuk Gelombang 2 dst., HP jukung akan kembali seperti semula (full).
- Tiap jukung akan menempati sejumlah slot tertentu.
  - [Penjelasan mengenai Slot Jukung](#player-stats).
- Player dapat menggeser (scroll) layar ke atas untuk melihat seluruh musuh yang akan menyerang pada fase berikutnya.

#### Fase Bertarung (Mid-Wave)

- Musuh muncul (spawn) off-screen pada bagian atas layar dan bergerak ke bawah secara real-time.
- Penempatan jukung tidak dapat diubah. Jukung juga tidak bisa ditarik.
- Pada fase ini, player diberikan 4 kartu barang secara acak dari dek mereka. Memainkan kartu akan memakan Energi sesuai dengan yang tertera pada informasi kartu.
  - Energi hampir sama dengan Elixir di Clash Royale.
    - Artinya, energi beregenerasi tiap beberapa detik dan memiliki batas maksimal energi.
  - Player memulai game dengan 5 energi.
  - Tiap kali fase ini dimulai, energi dihitung dari 0. Tiap beberapa detik, player akan mendapat 1 energi.
- Jika ada jukung yang hancur (HP-nya menjadi 0 akibat serangan musuh) pada fase ini, Slot Jukung player akan berkurang sesuai jumlah slot yang digunakan jukung UNTUK SEMENTARA WAKTU (temporarily) hingga Pertarungan selesai (player menang).

## Technical Specs

- **Game Resolution:** 90x200 pixel, tetapi di-upscale menyesuaikan resolusi HP player. Misalnya, upscale 8 kali lipat = 720x1600 pixel (720p). Walaupun begitu, viewport game harus tetap responsif.
