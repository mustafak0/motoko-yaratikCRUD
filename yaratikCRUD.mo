import List "mo:base/List";
import Option "mo:base/Option";
import Trie "mo:base/Trie";
import Nat32 "mo:base/Nat32";
import Text "mo:base/Text";

actor SihirliYaratikKayitDefteri {
  public type YaratikKimligi = Nat32;
  public type SihirliYaratik = {
    isim: Text;
    tur: Text;
    sihirliYetenekler: List.List<Text>;
    buyuSeviyesi: Nat8;
    koken: Text;
  };

  private stable var sonrakiKimlik: YaratikKimligi = 0;
  private stable var yaratiklar: Trie.Trie<YaratikKimligi, SihirliYaratik> = Trie.empty();

  // Kayit defterine yeni bir sihirli yaratik cagir
  public func yaratikCagir(yaratik: SihirliYaratik): async YaratikKimligi {
    let yaratikKimligi = sonrakiKimlik;
    sonrakiKimlik += 1;
    
    yaratiklar := Trie.replace(
      yaratiklar,
      anahtar(yaratikKimligi),
      Nat32.equal,
      ?yaratik
    ).0;
    
    return yaratikKimligi;
  };

  // Sihirli kimligine gore yaratigim detaylarini inceleme
  public query func yaratikIncele(yaratikKimligi: YaratikKimligi): async ?SihirliYaratik {
    return Trie.find(yaratiklar, anahtar(yaratikKimligi), Nat32.equal);
  };

  // Yarat??in sihirli ozelliklerini guncelleme
  public func yaratikGuclendir(yaratikKimligi: YaratikKimligi, guncelYaratik: SihirliYaratik): async Bool {
    let sonuc = Trie.find(yaratiklar, anahtar(yaratikKimligi), Nat32.equal);
    if (Option.isSome(sonuc)) {
      yaratiklar := Trie.replace(
        yaratiklar,
        anahtar(yaratikKimligi),
        Nat32.equal,
        ?guncelYaratik
      ).0;
      return true;
    };
    return false;
  };

  // Yarat??i kayit defterinden silme
  public func yaratikSurme(yaratikKimligi: YaratikKimligi): async Bool {
    let sonuc = Trie.find(yaratiklar, anahtar(yaratikKimligi), Nat32.equal);
    if (Option.isSome(sonuc)) {
      yaratiklar := Trie.replace(
        yaratiklar,
        anahtar(yaratikKimligi),
        Nat32.equal,
        null
      ).0;
      return true;
    };
    return false;
  };

  // Tum sihirli yaratiklari listeleme (biraz sihirle!)
  public query func sihirliAlemListesi(): async [(YaratikKimligi, SihirliYaratik)] {
  Trie.toArray<YaratikKimligi, SihirliYaratik, (YaratikKimligi, SihirliYaratik)>(
    yaratiklar, 
    func(k, v) { (k, v) }
  );
};

  // Bir yarat??in gercekten efsanevi olup olmadigini belirleme
  public query func efsaneYaratikMi(yaratikKimligi: YaratikKimligi): async Bool {
    switch (Trie.find(yaratiklar, anahtar(yaratikKimligi), Nat32.equal)) {
      case (null) false;
      case (?yaratik) yaratik.buyuSeviyesi >= 8;
    };
  };

  private func anahtar(x: YaratikKimligi): Trie.Key<YaratikKimligi> {
    return {hash = x; key = x};
  };
}
