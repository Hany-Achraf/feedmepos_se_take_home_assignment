enum Status { PENDING, PROCESSING, COMPLETE }

class Order {
  int id;
  bool isVip;
  Status status = Status.PENDING;

  Order({required this.id, required this.isVip});
}
