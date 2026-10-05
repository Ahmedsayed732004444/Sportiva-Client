class CourtOccupancy {
  const CourtOccupancy({
    required this.name,
    required this.bookedHours,
    required this.availableHours,
    required this.rate,
  });

  final String name;
  final double bookedHours;
  final double availableHours;
  final double rate;

  factory CourtOccupancy.fromJson(Map<String, dynamic> json) => CourtOccupancy(
    name: json['courtName'] as String,
    bookedHours: (json['bookedHours'] as num).toDouble(),
    availableHours: (json['availableHours'] as num).toDouble(),
    rate: (json['occupancyRate'] as num).toDouble(),
  );
}

class PeakHour {
  const PeakHour({required this.dayOfWeek, required this.hour, required this.bookedHours});

  // 0 = Sunday ... 6 = Saturday.
  final int dayOfWeek;
  final int hour;
  final double bookedHours;

  factory PeakHour.fromJson(Map<String, dynamic> json) {
    const names = ['Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'];
    final day = json['dayOfWeek'];
    return PeakHour(
      dayOfWeek: day is int ? day : names.indexOf(day.toString()).clamp(0, 6),
      hour: json['hour'] as int,
      bookedHours: (json['bookedHours'] as num).toDouble(),
    );
  }
}

class CustomerStat {
  const CustomerStat({required this.name, required this.count, this.phone});

  final String name;
  final int count;
  final String? phone;

  factory CustomerStat.fromJson(Map<String, dynamic> json) =>
      CustomerStat(name: json['name'] as String? ?? '', count: json['count'] as int, phone: json['phone'] as String?);
}

class SourceStat {
  const SourceStat({required this.source, required this.count, required this.revenuePiasters});

  final String source;
  final int count;
  final int revenuePiasters;

  factory SourceStat.fromJson(Map<String, dynamic> json) => SourceStat(
    source: json['source'].toString(),
    count: json['count'] as int,
    revenuePiasters: (json['revenuePiasters'] as num).toInt(),
  );
}

class ClubReport {
  const ClubReport({
    required this.revenuePiasters,
    required this.total,
    required this.pending,
    required this.confirmed,
    required this.completed,
    required this.cancelled,
    required this.noShow,
    required this.occupancy,
    required this.peakHours,
    required this.noShowRate,
    required this.sources,
    required this.topCustomers,
    this.averageRating,
    this.reviewsCount = 0,
  });

  final int revenuePiasters;
  final int total;
  final int pending;
  final int confirmed;
  final int completed;
  final int cancelled;
  final int noShow;
  final List<CourtOccupancy> occupancy;
  final List<PeakHour> peakHours;
  final double noShowRate;
  final List<SourceStat> sources;
  final List<CustomerStat> topCustomers;
  final double? averageRating;
  final int reviewsCount;

  factory ClubReport.fromJson(Map<String, dynamic> json) {
    final counts = json['counts'] as Map<String, dynamic>;
    final ratings = json['ratings'] as Map<String, dynamic>?;
    List<T> list<T>(String key, T Function(Map<String, dynamic>) parse) =>
        (json[key] as List? ?? const []).cast<Map<String, dynamic>>().map(parse).toList();

    return ClubReport(
      revenuePiasters: (json['revenuePiasters'] as num).toInt(),
      total: counts['total'] as int,
      pending: counts['pending'] as int,
      confirmed: counts['confirmed'] as int,
      completed: counts['completed'] as int,
      cancelled: counts['cancelled'] as int,
      noShow: counts['noShow'] as int,
      occupancy: list('occupancy', CourtOccupancy.fromJson),
      peakHours: list('peakHours', PeakHour.fromJson),
      noShowRate: (json['noShowRate'] as num).toDouble(),
      sources: list('sources', SourceStat.fromJson),
      topCustomers: list('topCustomers', CustomerStat.fromJson),
      averageRating: (ratings?['averageRating'] as num?)?.toDouble(),
      reviewsCount: ratings?['reviewsCount'] as int? ?? 0,
    );
  }
}
