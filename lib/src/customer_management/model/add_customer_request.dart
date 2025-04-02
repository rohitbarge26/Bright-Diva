class CustomerAddRequest {
  String? customerName;
  String? companyName;
  String? address;
  String? contactPersonName;
  String? mobileNumber;
  String? emailId;
  String? businessRegistrationNumber;
  String? city;
  String? country;

  CustomerAddRequest(
      {required this.customerName,
      required this.companyName,
        required this.address,
        required this.contactPersonName,
        required this.mobileNumber,
        this.emailId,
        required this.businessRegistrationNumber,
        required this.city,
        required this.country});

  CustomerAddRequest.fromJson(Map<String, dynamic> json) {
    customerName = json['customerName'];
    customerName = json['companyName'];
    address = json['address'];
    contactPersonName = json['contactPersonName'];
    mobileNumber = json['mobileNumber'];
    emailId = json['emailId'];
    businessRegistrationNumber = json['businessRegistrationNumber'];
    city = json['city'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['customerName'] = this.customerName;
    data['companyName'] = this.companyName;
    data['address'] = this.address;
    data['contactPersonName'] = this.contactPersonName;
    data['mobileNumber'] = this.mobileNumber;
    data['emailId'] = this.emailId;
    data['businessRegistrationNumber'] = this.businessRegistrationNumber;
    data['city'] = this.city;
    data['country'] = this.country;
    return data;
  }

  @override
  String toString() {
    return 'CustomerAddRequest{customerName: $customerName, companyName: $companyName, address: $address, contactPersonName: $contactPersonName, mobileNumber: $mobileNumber, emailId: $emailId, businessRegistrationNumber: $businessRegistrationNumber, city: $city, country: $country}';
  }
}
