/// 都道府県の1件分のデータ。
class Prefecture {
  final int id;
  final String region;
  final String prefecture;
  final String capital;

  const Prefecture({
    required this.id,
    required this.region,
    required this.prefecture,
    required this.capital,
  });
}

/// 地方区分（全国制覇マップや出題範囲の単位に使う）。
const List<String> regions = [
  '北海道・東北',
  '関東',
  '中部',
  '近畿',
  '中国',
  '四国',
  '九州・沖縄',
];

/// 47都道府県すべてのデータ。handoff.txt の定義に準拠。
const List<Prefecture> prefectures = [
  // 北海道・東北
  Prefecture(id: 1, region: '北海道・東北', prefecture: '北海道', capital: '札幌市'),
  Prefecture(id: 2, region: '北海道・東北', prefecture: '青森県', capital: '青森市'),
  Prefecture(id: 3, region: '北海道・東北', prefecture: '岩手県', capital: '盛岡市'),
  Prefecture(id: 4, region: '北海道・東北', prefecture: '宮城県', capital: '仙台市'),
  Prefecture(id: 5, region: '北海道・東北', prefecture: '秋田県', capital: '秋田市'),
  Prefecture(id: 6, region: '北海道・東北', prefecture: '山形県', capital: '山形市'),
  Prefecture(id: 7, region: '北海道・東北', prefecture: '福島県', capital: '福島市'),

  // 関東
  Prefecture(id: 8, region: '関東', prefecture: '茨城県', capital: '水戸市'),
  Prefecture(id: 9, region: '関東', prefecture: '栃木県', capital: '宇都宮市'),
  Prefecture(id: 10, region: '関東', prefecture: '群馬県', capital: '前橋市'),
  Prefecture(id: 11, region: '関東', prefecture: '埼玉県', capital: 'さいたま市'),
  Prefecture(id: 12, region: '関東', prefecture: '千葉県', capital: '千葉市'),
  Prefecture(id: 13, region: '関東', prefecture: '東京都', capital: '新宿区'),
  Prefecture(id: 14, region: '関東', prefecture: '神奈川県', capital: '横浜市'),

  // 中部
  Prefecture(id: 15, region: '中部', prefecture: '新潟県', capital: '新潟市'),
  Prefecture(id: 16, region: '中部', prefecture: '富山県', capital: '富山市'),
  Prefecture(id: 17, region: '中部', prefecture: '石川県', capital: '金沢市'),
  Prefecture(id: 18, region: '中部', prefecture: '福井県', capital: '福井市'),
  Prefecture(id: 19, region: '中部', prefecture: '山梨県', capital: '甲府市'),
  Prefecture(id: 20, region: '中部', prefecture: '長野県', capital: '長野市'),
  Prefecture(id: 21, region: '中部', prefecture: '岐阜県', capital: '岐阜市'),
  Prefecture(id: 22, region: '中部', prefecture: '静岡県', capital: '静岡市'),
  Prefecture(id: 23, region: '中部', prefecture: '愛知県', capital: '名古屋市'),

  // 近畿
  Prefecture(id: 24, region: '近畿', prefecture: '三重県', capital: '津市'),
  Prefecture(id: 25, region: '近畿', prefecture: '滋賀県', capital: '大津市'),
  Prefecture(id: 26, region: '近畿', prefecture: '京都府', capital: '京都市'),
  Prefecture(id: 27, region: '近畿', prefecture: '大阪府', capital: '大阪市'),
  Prefecture(id: 28, region: '近畿', prefecture: '兵庫県', capital: '神戸市'),
  Prefecture(id: 29, region: '近畿', prefecture: '奈良県', capital: '奈良市'),
  Prefecture(id: 30, region: '近畿', prefecture: '和歌山県', capital: '和歌山市'),

  // 中国
  Prefecture(id: 31, region: '中国', prefecture: '鳥取県', capital: '鳥取市'),
  Prefecture(id: 32, region: '中国', prefecture: '島根県', capital: '松江市'),
  Prefecture(id: 33, region: '中国', prefecture: '岡山県', capital: '岡山市'),
  Prefecture(id: 34, region: '中国', prefecture: '広島県', capital: '広島市'),
  Prefecture(id: 35, region: '中国', prefecture: '山口県', capital: '山口市'),

  // 四国
  Prefecture(id: 36, region: '四国', prefecture: '徳島県', capital: '徳島市'),
  Prefecture(id: 37, region: '四国', prefecture: '香川県', capital: '高松市'),
  Prefecture(id: 38, region: '四国', prefecture: '愛媛県', capital: '松山市'),
  Prefecture(id: 39, region: '四国', prefecture: '高知県', capital: '高知市'),

  // 九州・沖縄
  Prefecture(id: 40, region: '九州・沖縄', prefecture: '福岡県', capital: '福岡市'),
  Prefecture(id: 41, region: '九州・沖縄', prefecture: '佐賀県', capital: '佐賀市'),
  Prefecture(id: 42, region: '九州・沖縄', prefecture: '長崎県', capital: '長崎市'),
  Prefecture(id: 43, region: '九州・沖縄', prefecture: '熊本県', capital: '熊本市'),
  Prefecture(id: 44, region: '九州・沖縄', prefecture: '大分県', capital: '大分市'),
  Prefecture(id: 45, region: '九州・沖縄', prefecture: '宮崎県', capital: '宮崎市'),
  Prefecture(id: 46, region: '九州・沖縄', prefecture: '鹿児島県', capital: '鹿児島市'),
  Prefecture(id: 47, region: '九州・沖縄', prefecture: '沖縄県', capital: '那覇市'),
];

/// id から都道府県を引くためのマップ。
final Map<int, Prefecture> prefectureById = {
  for (final p in prefectures) p.id: p,
};
