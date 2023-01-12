class ReportSoldQtyModel {
  int itemId;
  String itemName;
  String categoryName;
  double soldQty;
  double disc;
  double serviceValue;
  double itemTax;
  double totalNoTaxAndService;
  double totalNoTax;
  double netTotal;

  ReportSoldQtyModel({
    required this.itemId,
    required this.itemName,
    required this.categoryName,
    required this.soldQty,
    required this.disc,
    required this.serviceValue,
    required this.itemTax,
    required this.totalNoTaxAndService,
    required this.totalNoTax,
    required this.netTotal,
  });
}
