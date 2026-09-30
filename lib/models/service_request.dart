class ServiceRequest {
  const ServiceRequest({
    required this.title,
    required this.client,
    required this.description,
    required this.budget,
    required this.deadline,
    required this.receivedAt,
    required this.category,
  });

  final String title;
  final String client;
  final String description;
  final String budget;
  final String deadline;
  final String receivedAt;
  final String category;
}
