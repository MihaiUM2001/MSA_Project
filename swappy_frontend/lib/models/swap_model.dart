class Swap {
  final int id;
  final String swapDetail;

  Swap({required this.id, required this.swapDetail});

  factory Swap.fromJson(Map<String, dynamic> json) {
    return Swap(
      id: json['id'],
      swapDetail: json['swapDetail'],
    );
  }
}
