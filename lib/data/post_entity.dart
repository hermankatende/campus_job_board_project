class PostEntity {
  final int? jobId;
  final String? jobTitle;
  final String? location;
  final String? employmentType;
  final String? requirements;
  final String? username;
  final String? description;
  final String? imageUrl;
  final String? email;
  final DateTime? timestamp;

  PostEntity({
    this.jobId,
    this.jobTitle,
    this.location,
    this.employmentType,
    this.requirements,
    this.username,
    this.description,
    this.imageUrl,
    this.email,
    this.timestamp,
  });

  factory PostEntity.fromJson(Map<String, dynamic> data) {
    return PostEntity(
      jobId: data['jobId'] as int? ?? data['id'] as int? ?? 0,
      jobTitle: data['jobTitle'] as String? ?? data['title'] as String? ?? '',
      location: data['location'] as String? ?? '',
      employmentType: data['employmentType'] as String? ??
          data['employment_type'] as String? ??
          '',
      requirements: data['requirements'] as String? ?? '',
      username: data['username'] as String? ?? '',
      description: data['description'] as String? ?? '',
      imageUrl: data['imageUrl'] as String? ?? '',
      email: data['email'] as String? ?? '',
      timestamp: data['timestamp'] != null
          ? DateTime.tryParse(data['timestamp'].toString())
          : null,
    );
  }
}
