class BeritaModel {
  String? source;
  String? keyword;
  String? title;
  String? cleanTitle;
  String? link;
  String? publishedDate;
  String? scrapedAt;

  BeritaModel({
    this.source,
    this.keyword,
    this.title,
    this.cleanTitle,
    this.link,
    this.publishedDate,
    this.scrapedAt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      source: json['source'] as String?,
      keyword: json['keyword'] as String?,
      title: json['title'] as String?,
      cleanTitle: json['clean_title'] as String?,
      link: json['link'] as String?,
      publishedDate: json['published_date'] as String?,
      scrapedAt: json['scraped_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'source': source,
      'keyword': keyword,
      'title': title,
      'clean_title': cleanTitle,
      'link': link,
      'published_date': publishedDate,
      'scraped_at': scrapedAt,
    };
  }
}
