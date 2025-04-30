class ReviewDTO {
  String id;
  String doctorId;
  String patientId;
  int rating; // 1 to 5
  String comment;
  DateTime createdAt;

  ReviewDTO({
    required this.id,
    required this.doctorId,
    required this.patientId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'patientId': patientId,
      'rating': rating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewDTO.fromJson(Map<String, dynamic> json) {
    return ReviewDTO(
      id: json['id'],
      doctorId: json['doctorId'],
      patientId: json['patientId'],
      rating: json['rating'],
      comment: json['comment'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}