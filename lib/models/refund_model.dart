class RefundModel {
  String posNo;
  String originalDate;
  String originalTime;
  String tableNo;
  String customer;
  List<Item> items;

  RefundModel({
    required this.posNo,
    required this.originalDate,
    required this.originalTime,
    required this.tableNo,
    required this.customer,
    required this.items,
  });

  factory RefundModel.init() => RefundModel(
        posNo: '',
        originalDate: '',
        originalTime: '',
        tableNo: '',
        customer: '',
        items: [],
      );
}

class Item {
  String serial;
  String name;
  double qty;
  double price;

  Item({
    required this.serial,
    required this.name,
    required this.qty,
    required this.price,
  });
}
