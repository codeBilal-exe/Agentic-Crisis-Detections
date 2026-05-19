class AlertModel {
  final String alertId;
  final String crisisId;
  final String createdAt;
  final String severity;
  final String title;
  final String body;
  final String urduBody;
  final List<String> channelsSent;
  final bool acknowledged;

  AlertModel({
    required this.alertId, required this.crisisId, required this.createdAt,
    required this.severity, required this.title, required this.body,
    required this.urduBody, required this.channelsSent, required this.acknowledged,
  });

  factory AlertModel.fromMap(String id, Map<dynamic, dynamic> map) {
    return AlertModel(
      alertId: id,
      crisisId: map['crisis_id'] ?? '',
      createdAt: map['created_at'] ?? '',
      severity: map['severity'] ?? 'LOW',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      urduBody: map['urdu_body'] ?? '',
      channelsSent: List<String>.from(map['channels_sent'] ?? []),
      acknowledged: map['acknowledged'] ?? false,
    );
  }
}
