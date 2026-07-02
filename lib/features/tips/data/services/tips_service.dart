import '../models/tip.dart';

// Şimdilik hardcoded — Firestore'a geçişte bu liste koleksiyon sorgusuyla değiştirilecek
class TipsService {
  TipsService._();

  static List<Tip> getAll() => _tips;

  static Tip getDailyTip() => _tips.first;

  static final List<Tip> _tips = [
    Tip(
      id: 'tip_colyak',
      category: 'Çölyak',
      imageAsset: 'assets/images/ipucu.jpg',
      title: 'Çölyak Hastalığı Nedir?\nBelirtileri ve Glutensiz Yaşam Rehberi',
      summary:
          'Çölyak hastalığı, glutene karşı oluşan otoimmün bir hastalıktır. İnce bağırsakta hasar oluşturarak besin emilimini etkiler. Erken teşhis ve glutensiz diyet ile sağlıklı bir yaşam mümkündür.',
      author: 'Dr. Ayşe Yılmaz',
      date: DateTime(2026, 6, 23),
      likes: 24,
      dislikes: 2,
      commentCount: 5,
      sections: [
        const TipSection(
          heading: 'Çölyak Hastalığı Nedir?',
          body:
              'Çölyak hastalığı, gluten adı verilen proteine karşı bağışıklık sisteminin yanlış tepki verdiği kalıtsal bir otoimmün hastalıktır. Hastalık tetiklendiğinde bağışıklık sistemi ince bağırsağın iç yüzeyine zarar verir; bu da besinlerin kana geçişini engeller.',
        ),
        const TipSection(
          heading: 'Belirtileri Nelerdir?',
          body:
              'Belirtiler kişiden kişiye çok farklılık gösterir. En sık görülenler: karın ağrısı, şişkinlik, ishal veya kabızlık, kilo kaybı, yorgunluk, demir eksikliği anemisi ve ciltte döküntü (dermatitis herpetiformis). Bazı hastalarda sindirim belirtisi olmadan sadece anemi veya osteoporoz görülebilir.',
        ),
        const TipSection(
          heading: 'Tanı ve Tedavi',
          body:
              'Tanı için önce kan testleri (Anti-tTG IgA) yapılır; ardından kesin tanı için ince bağırsak biyopsisi gerekir. Hastalığın tek tedavisi ömür boyu sıkı glutensiz diyettir. Diyete uyulduğunda bağırsak iyileşir ve yaşam kalitesi belirgin şekilde artar.',
        ),
      ],
    ),
    Tip(
      id: 'tip_gluten',
      category: 'Gluten',
      imageAsset: 'assets/images/ipucu.jpg',
      title: 'Gluten Nedir ve Nerede Bulunur?',
      summary:
          'Gluten; buğday, arpa ve çavdarda doğal olarak bulunan bir protein grubudur. Hamura elastikiyet kazandırır ancak çölyak hastalarında bağırsak hasarına yol açar.',
      author: 'Dr. Ayşe Yılmaz',
      date: DateTime(2026, 6, 20),
      likes: 18,
      dislikes: 1,
      commentCount: 3,
      sections: [
        const TipSection(
          heading: 'Gluten Nedir?',
          body:
              'Gluten; gliadin ve glutenin adlı iki proteinin birleşiminden oluşur. Hamura yapışkanlık ve esneklik kazandırdığı için ekmek ve pasta yapımında kritik bir rol üstlenir.',
        ),
        const TipSection(
          heading: 'Nerede Bulunur?',
          body:
              'Gluten başlıca buğday (un, irmik, bulgur, makarna, ekmek), arpa (bira, malt, arpa çayı) ve çavdarda bulunur. Yulaf doğası gereği glutensizdir ancak işleme sırasında çapraz bulaşma riski taşır.',
        ),
        const TipSection(
          heading: 'Gizli Gluten Kaynakları',
          body:
              'Soya sosu, hazır çorba, kıvam arttırıcılar, tatlandırıcılar ve bazı ilaçlar gizli gluten içerebilir. Etiketlerde "nişasta", "buğday proteini", "hidrolize bitkisel protein" ve "malt" ibarelerine dikkat edin.',
        ),
      ],
    ),
    Tip(
      id: 'tip_capraz',
      category: 'Çapraz Bulaşma',
      imageAsset: 'assets/images/ipucu.jpg',
      title: 'Çapraz Bulaşmadan Nasıl Korunulur?',
      summary:
          'Glutensiz ürünlerin gluten içeren gıdalarla temas etmesi "çapraz bulaşma" olarak adlandırılır. Birkaç basit önlemle bu riski önemli ölçüde azaltmak mümkündür.',
      author: 'Dr. Mehmet Kaya',
      date: DateTime(2026, 6, 18),
      likes: 31,
      dislikes: 0,
      commentCount: 8,
      sections: [
        const TipSection(
          heading: 'Çapraz Bulaşma Nedir?',
          body:
              'Glutensiz kabul edilen bir yiyeceğin, gluten içeren yiyecek, yüzey veya mutfak aleti ile temas etmesi sonucu gluten ile kirlenme durumudur. Miligram düzeyindeki bulaşma bile çölyak hastalarında bağırsak hasarına neden olabilir.',
        ),
        const TipSection(
          heading: 'Mutfakta Korunma Yöntemleri',
          body:
              'Ayrı kesme tahtası, ekmek bıçağı ve kevgir kullanın. Glutenli unun havada asılı kalabileceğini unutmayın; pişirme sırasını önce glutensiz tarif yapacak şekilde planlayın. Ortak yağ ve su kapları kullanmayın.',
        ),
        const TipSection(
          heading: 'Dışarıda Yemek Yerken',
          body:
              'Restoranı önceden arayın, mutfakta ayrı tencere/tava kullanılıp kullanılmadığını sorun. "Glutensiz seçenek" sunan mekanlar bile çapraz bulaşma riski taşıyabilir; sertifikalı mutfakları tercih edin.',
        ),
      ],
    ),
    Tip(
      id: 'tip_belediye',
      category: 'Belediye',
      imageAsset: 'assets/images/ipucu.jpg',
      title: 'Belediyelerin Çölyak Yardımları',
      summary:
          'Pek çok belediye, çölyak tanısı almış düşük gelirli vatandaşlara aylık glutensiz ürün yardımı ve sosyal destek sunmaktadır. Başvuru süreci ve şartları öğrenmek için yakınınızdaki sosyal hizmetler müdürlüğüne başvurun.',
      author: 'GluFree Editörü',
      date: DateTime(2026, 6, 15),
      likes: 47,
      dislikes: 3,
      commentCount: 12,
      sections: [
        const TipSection(
          heading: 'Sosyal Yardım Programları',
          body:
              'İstanbul, Ankara ve İzmir başta olmak üzere birçok büyükşehir belediyesi, çölyak tanısı alan ve sosyoekonomik açıdan dezavantajlı vatandaşlara aylık glutensiz ürün paketi (un, makarna, bisküvi) temin etmektedir.',
        ),
        const TipSection(
          heading: 'Başvuru Koşulları',
          body:
              'Başvurular için genellikle gastroenteroloji uzmanından alınmış çölyak tanı belgesi, gelir durumunu gösteren belge ve nüfus cüzdanı fotokopisi gereklidir. Başvurular ilçe sosyal hizmetler müdürlükleri veya belediyenin e-devlet portalı üzerinden yapılabilir.',
        ),
        const TipSection(
          heading: 'Dikkat Edilmesi Gerekenler',
          body:
              'Yardım programları belediyeden belediyeye farklılık gösterir; miktarlar ve ürün çeşitleri değişebilir. Güncel bilgiye ulaşmak için belediyenin sosyal yardım hattını veya web sitesini düzenli takip etmenizi öneririz.',
        ),
      ],
    ),
  ];
}
