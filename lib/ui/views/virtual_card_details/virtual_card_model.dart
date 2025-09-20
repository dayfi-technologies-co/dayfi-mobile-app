class VirtualCardModel {
  final String userId; // Added userId field
  final String cardNumber;
  final String cardHolderName;
  final String expiryDate;
  final String cvv;
  final String streetName;
  final String city;
  final String state;
  final String postcode;

  VirtualCardModel({
    required this.userId, // Added to constructor
    required this.cardNumber,
    required this.cardHolderName,
    required this.expiryDate,
    required this.cvv,
    required this.streetName,
    required this.city,
    required this.state,
    required this.postcode,
  });

  String get fullAddress =>
      '$streetName, $city, $state, $postcode';
}