# Solian (Solar Network)

<p align="center">
  <img src="assets/icons/icon.webp" width="120" alt="Solian Logosu">
</p>

<p align="center">
  <b>Huzurlu bir sosyal ağ</b>
</p>

<p align="center">
  <a href="LICENSE.txt"><img src="https://img.shields.io/github/license/Solsynth/HyperNet.Surface" alt="License"></a>
  <a href="https://github.com/Solsynth/HyperNet.Surface/releases"><img src="https://img.shields.io/github/v/release/Solsynth/HyperNet.Surface?include_prereleases" alt="Latest Release"></a>
</p>

---

Solian (Solar Network olarak da bilinir), kendinizi özgürce ifade etmenize ve başkalarıyla bağlantı kurmanıza yardımcı olmak için tasarlanmış bir sosyal ağ platformudur. Herhangi bir büyük platformun yerini almayı hedeflemiyoruz — yalnızca parçası olabileceğiniz başka bir huzurlu topluluk sunuyoruz.

Not: Fediverse desteği şu anda deneysel ve sınırlıdır.

> Dokümantasyon: [Suki - Solar Network](https://kb.solsynth.dev/zh/solar-network) | [English README](./README.md) | [中文 README](./README_CN.md)

---

## İçindekiler

- [Özellikler](#özellikler)
- [Başlarken](#başlarken)
  - [Kullanıcılar İçin](#kullanıcılar-için)
  - [Geliştiriciler İçin](#geliştiriciler-için)
- [Paketler](#paketler)
- [Sunucu](#sunucu)
- [Teknoloji Yığını](#teknoloji-yığını)
- [Katkıda Bulunma](#katkıda-bulunma)

---

## Özellikler

### Şu Anda Kullanılabilir

| Özellik | Durum | Açıklama |
| --------- | -------- | ------------- |
| Zaman Akışı | Tamamlandı | Gönderilerin kronolojik akışı |
| Gönderiler, Makaleler ve Blog | Tamamlandı | Farklı ihtiyaçlar için çoklu içerik türleri |
| Gönderi Zincirleme | Tamamlandı | İlgili gönderileri bir konu dizisinde birleştirin |
| Anlık Mesajlaşma | Tamamlandı | Gruplar, sesli mesajlar, tepkiler ve okundu bilgisiyle gerçek zamanlı sohbet |
| Uçtan Uca Şifreleme | Tamamlandı | MLS şifreli mesajlar |
| Realms | Tamamlandı | Ortak ilgi alanlarına göre düzenlenmiş topluluklar |
| OAuth Entegrasyonu | Tamamlandı | Güvenli üçüncü taraf kimlik doğrulaması |
| Passkeys | Tamamlandı | WebAuthn geçiş anahtarlarıyla parolasız oturum açma |
| Check-in | Tamamlandı | Konum ve durum paylaşımı |
| Geri Sayım | Tamamlandı | Özel tarihleri ve festivalleri takip edin |
| Etkinlik Takvimi | Tamamlandı | Topluluğunuzla etkinlikler planlayın ve paylaşın |
| Hava Durumu | Tamamlandı | Kontrol panelinizde hava durumu tahmini |
| Cüzdan | Tamamlandı | Krediler, takas, siparişler ve faturalandırma |
| Çıkartmalar | Tamamlandı | Özel çıkartmalarla kendinizi ifade edin |
| Zengin Metin Düzenleyici | Tamamlandı | Genişletilmiş sözdizimine sahip Markdown tabanlı düzenleyici |
| Sosyal Özellikler | Tamamlandı | Arkadaşlar, engelleme listesi ve sessize alma yönetimi |
| Dosya Yönetimi | Tamamlandı | Dosya yükleyin ve düzenleyin |
| Destek Talepleri | Tamamlandı | Destek talepleri ve sorun takibi |
| Eklentiler | Tamamlandı | Uygulamayı topluluk eklentileriyle genişletin |
| Pano | Tamamlandı | Profilinizde özel bileşenler |
| Çalışma Alanları | Tamamlandı | İş birliği için paylaşılan alanlar |
| İlerlemeler | Tamamlandı | Solar Network üzerindeki hamlelerinizi unutulmaz kılın |
| Fediverse | Beta | Diğer fediverse örnekleriyle etkileşim kurun |

### Aktarma Rotası (Relay Route)

Trafik, sunucuya doğrudan bağlanmak yerine yakındaki bir **aktarma düğümü (relay node)** üzerinden yönlendirilebilir. Aktarıcılar L4 düzeyindedir: TLS ClientHello içindeki SNI bilgisini okurlar ve TLS'i sonlandırmadan baytları kaynağa kopyalarlar; böylece sertifika, `Host` başlığı ve uçtan uca şifreleme değişmez — yalnızca soket taşınır.

**Settings → Connection → Relay Route** altından birini seçin veya *Direct* olarak bırakın. Liste sunucunun `GET /relays` kataloğundan gelir (bozuk bir aktarıcının kendi seçicisini gizleyememesi için doğrudan bağlantı üzerinden yüklenir). Bir rota seçmek hemen uygulanır: HTTP istemcileri yeniden oluşturulur ve gerçek zamanlı kanal yeniden bağlanır; seçim açılışlar arasında kalıcıdır.

Seçiciyi açmak ayrıca duyurulan her aktarıcıyı ölçer — her düğüm üzerinden gerçek trafiğin yaptığı aynı el sıkışma olan tek bir TLS el sıkışması yapar, böylece sunucunun SNI'sını taşıyamayan bir aktarıcı başarısız olur — ve düğümün yanında gidiş-dönüş süresini gösterir.
**Auto (fastest)** ölçülen en düşük gidiş-dönüş süresini alır ve o rotayı kaydeder; bir kez seçer, kendi kendine yeniden seçim yapmaya devam etmez.

Yeniden kullanılabilir parçalar — katalog istemcisi, modeller, bağlantı fabrikası ve gecikme probu — diğer Solar Network istemcilerinin de aynı aktarıcılar üzerinden yönlendirilebilmesi için [`solar_network_foundation`](socommon/packages/solar_network_foundation) içinde yer alır.

Aktarıcı üzerinden yönlendirilmeyenler: Dart'ın HTTP yığınına hiç dokunmayan yerel aktarımlar (medya oynatma, WebRTC, uygulama içi web görünümleri, platform bildirim/yerel eklentileri) ve tarayıcının kendi yığınıyla bağlanan web derlemesi.

---

## Başlarken

### Kullanıcılar İçin

1. **Uygulamayı İndirin**
   - Platformunuz için en son sürümü indirmek üzere [Solar Network ürün sayfasını](https://solsynth.dev/products/solar-network) ziyaret edin
   - **Sürekli güncellemeler:** Solian sürekli sürümler (rolling releases) kullanır — API sürümleme kullanmıyoruz, bu nedenle kırıcı değişiklikler her an gelebilir. En iyi deneyim için uygulamayı güncel tutun.

2. **Hesap Oluşturun**
   - Solar Network üzerinde kaydolun
   - E-posta adresinizi doğrulayın
   - Keşfetmeye başlayın!

### Geliştiriciler İçin

#### Ön Koşullar

- Kurulu [Flutter SDK](https://flutter.dev)
- Windows geliştirme için [NASM](https://www.nasm.us) kurun (`webcrypto` yerel varlıkları için gereklidir):

  ```powershell
  winget install NASM.NASM
  ```

- macOS geliştirme için Rust `stable` araç zincirini güncel tutun (`rustup update stable`). `stable` 1.98'den eskiyse Xcode'dan arşivleme `E0463: can't find crate for proc_macro_error_attr` hatasıyla başarısız olur — Xcode'un `MACOSX_DEPLOYMENT_TARGET` (13.5) ayarı, bağlayıcının eski rustc'nin okuyamadığı chained-fixups proc-macro dylib'leri üretmesine neden olur.
- Linux geliştirme için ek bağımlılıkları kurun:
- Web için tercih edilen derleme parametreleri: `flutter build web --wasm`

```bash
sudo apt-get update -y
sudo apt-get install -y \
  ninja-build \
  libgtk-3-dev \
  libmpv-dev \
  mpv \
  libayatana-appindicator3-dev \
  keybinder-3.0 \
  libnotify-dev \
  libgstreamer1.0-dev \
  libgstreamer-plugins-base1.0-dev \
  gstreamer-1.0
```

#### Uygulamayı Çalıştırma

```bash
# Paylaşılan paketler alt modülünü getirin (yalnızca ilk indirmede)
git submodule update --init socommon

# Bağımlılıkları yükleyin
flutter pub get

# Hata ayıklama modunda çalıştırın
flutter run

# Sürüm derlemesini oluşturun
flutter build <platform>
```

Daha fazla derleme seçeneği için [Flutter dokümantasyonuna](https://docs.flutter.dev) bakın.

---

## Paketler

Paylaşılan Solsynth paketleri [`socommon`](https://src.solsynth.dev/SoSYS/Socommon) deposunda yer alır ve buraya `socommon` alt modülü olarak eklenmiştir (klonladıktan sonra `git submodule update --init socommon` komutunu çalıştırın).

Solar Network ile geliştirmek ister misiniz? Şunlara göz atın:

- [Dokümantasyon](https://kb.solsynth.dev)
- [API Referansı](https://api.solsynth.dev)
- [`solar_network_sdk`](./socommon/packages/solar_network_sdk) - Resmi Dart SDK

---

## Sunucu

Solar Network'e güç veren arka uç şu adreste mevcuttur:
**[Solsynth/DysonNetwork](https://github.com/Solsynth/DysonNetwork)**

---

## Teknoloji Yığını

| Katman | Teknoloji |
| ------- | ------------ |
| **Ön Uç** | Flutter - Çapraz platform arayüz çerçevesi |
| **Arka Uç** | PostgreSQL veritabanı ile .NET |
| **Protokoller** | ActivityPub (Fediverse), WebSockets, REST API |

---

## Katkıda Bulunma

Katkılarınızı bekliyoruz! Katılmadan önce lütfen [Davranış Kurallarımızı](./CODE_OF_CONDUCT.md) okuyun.

- [Hata bildirin](https://github.com/Solsynth/HyperNet.Surface/issues)
- [Özellik önerin](https://github.com/Solsynth/HyperNet.Surface/discussions)

## Lisanslama

Bu proje GNU Affero General Public License v3.0 (AGPL-3.0) altında lisanslanmıştır.

Bir DysonNetwork örneği dağıtırsanız, Island projesini çatlarsanız (fork) veya bu yazılımın değiştirilmiş sürümlerini yeniden dağıtırsanız, aşağıdakiler dahil olmak üzere AGPL-3.0 lisans koşullarına uymalısınız:

- Orijinal lisansın bir kopyasını dahil etmek
- Mevcut telif hakkı bildirimlerini ve atıfları korumak
- Yaptığınız değişiklikleri açıkça belirtmek
- Bir ağ üzerinden hizmetle etkileşime giren kullanıcılara karşılık gelen kaynak kodunu sağlamak

LittleSheep, Solsynth ve bu deponun katkıda bulunanlarına yapılan orijinal yazarlık ve telif hakkı atıfları uygun olan yerlerde korunmalıdır.

Lütfen AGPL-3.0 lisansının yalnızca yazılım kaynak kodu için geçerli olduğunu unutmayın. Belirli varlıklar, logolar, simgeler, marka materyalleri ve ticari markalar ayrı olarak lisanslanmış olabilir ve otomatik olarak aynı koşullar kapsamında değildir.

Üçüncü taraf dağıtımlar, çatallar ve türev hizmetler, kendilerini Solsynth tarafından işletilen resmi Solar Network hizmeti olarak tanıtmamalı veya taklit etmemelidir.

"Solar Network", "Solian" adları, ilgili logolar ve ilişkili markalar, Solsynth'ten önceden izin alınmaksızın üçüncü taraf dağıtımları pazarlamak, reklamını yapmak veya tanımlamak için kullanılamaz.

Altta yatan DysonNetwork yazılımına veya Island projesine tanımlayıcı veya uyumluluk amaçlı atıfta bulunulmasına izin verilir.

Ayrıca, çatal projeniz Solar Network'ün üçüncü taraf bir istemcisiyse, [Solar Network Geliştirici Sözleşmesini](https://solsynth.dev/en/legal/solar-network-dev/) okuyup anladığınızdan emin olun.

Bakınız:

- [LICENSE.txt](./LICENSE.txt)
- [assets/LICENSE.md](./assets/icons/LICENSE.md) (uygunsa)

---

<p align="center">
  Solar Network Ekibi tarafından sevgiyle yapıldı
</p>
