// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Wasla';

  @override
  String get welcome => 'Welcome back';

  @override
  String get myProfile => 'My Profile';

  @override
  String get displayName => 'Display Name';

  @override
  String get email => 'Email';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get enabled => 'Enabled';

  @override
  String get disabled => 'Disabled';

  @override
  String get logout => 'Logout';

  @override
  String get myOrders => 'MY ORDERS';

  @override
  String get orderHistory => 'ORDER HISTORY (DELIVERED)';

  @override
  String get noOrdersYet => 'No orders yet. Start by creating one!';

  @override
  String get noDeliveredOrders => 'No delivered orders yet';

  @override
  String get createOrder => 'Create Order';

  @override
  String errorLoadingOrders(String error) {
    return 'Error loading orders: $error';
  }

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get arabic => 'Arabic';

  @override
  String get nameCannotBeEmpty => 'Name cannot be empty';

  @override
  String get profileUpdated => 'Profile updated!';

  @override
  String anErrorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get enterYourName => 'Enter your name';

  @override
  String get user => 'User';

  @override
  String get newOrder => 'New Order';

  @override
  String get waslaVendor => 'Wasla Vendor';

  @override
  String get waslaHome => 'Wasla Home';

  @override
  String welcomeBackUser(String name) {
    return 'Welcome back, $name!';
  }

  @override
  String get myActiveOrders => 'MY ACTIVE ORDERS';

  @override
  String get availableForDelivery => 'AVAILABLE FOR DELIVERY';

  @override
  String get noNewOrdersAvailable => 'No new orders available';

  @override
  String get notLoggedIn => 'Not logged in';

  @override
  String get friend => 'Friend';

  @override
  String errorLoadingHistory(String error) {
    return 'Error loading history: $error';
  }

  @override
  String get noActiveOrders => 'No active orders';

  @override
  String get statusPending => 'PENDING';

  @override
  String get statusAccepted => 'ACCEPTED';

  @override
  String get statusDelivered => 'DELIVERED';

  @override
  String get statusUnknown => 'UNKNOWN';

  @override
  String deliveredBy(String name) {
    return 'Delivered by $name';
  }

  @override
  String get provider => 'Provider';

  @override
  String get noOrdersFound => 'No orders found';

  @override
  String get customerLabel => 'CUSTOMER';

  @override
  String get unknownCustomer => 'Unknown Customer';

  @override
  String get errorLoadingName => 'Error loading name';

  @override
  String get acceptOrder => 'Accept Order';

  @override
  String get orderAccepted => 'Order accepted!';

  @override
  String failedToAccept(String error) {
    return 'Failed: $error';
  }

  @override
  String orderIdLabel(String id) {
    return 'ORDER #$id';
  }

  @override
  String get statusPickedUp => 'PICKED UP';

  @override
  String get loading => 'Loading...';

  @override
  String get chat => 'Chat';

  @override
  String get pickUp => 'Pick Up';

  @override
  String get deliver => 'Deliver';

  @override
  String get statusUpdated => 'Status updated!';

  @override
  String failedToUpdateStatus(String error) {
    return 'Failed to update status: $error';
  }

  @override
  String get orderNotFound => 'Order not found';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get trackOrder => 'Track Order';

  @override
  String get chatWithProvider => 'Chat with Provider';

  @override
  String get chatWithSupport => 'Chat with Support';

  @override
  String get updatedJustNow => 'Updated just now';

  @override
  String get newDelivery => 'New Delivery';

  @override
  String get whatCanWeGetYou => 'What can we get for you?';

  @override
  String get itemDescription => 'Item Description';

  @override
  String get supportingPhotos => 'Supporting Photos';

  @override
  String get camera => 'Camera';

  @override
  String get gallery => 'Gallery';

  @override
  String get postMyOrder => 'Post My Order';

  @override
  String get orderCreatedSuccessfully => 'Order created successfully!';

  @override
  String get pleaseEnterWhatYouNeed => 'Please enter what you need';

  @override
  String get customer => 'Customer';

  @override
  String get noMessagesYet => 'No messages yet';

  @override
  String get startConversation => 'Start the conversation!';

  @override
  String get typeAMessage => 'Type a message...';

  @override
  String get price => 'Price';

  @override
  String get deliveryFee => 'Delivery Fee';

  @override
  String get totalEarnings => 'Total Earnings';

  @override
  String get wallet => 'Wallet';

  @override
  String get myEarnings => 'My Earnings';

  @override
  String get estimatedFee => 'Estimated Fee';

  @override
  String get totalPrice => 'Total Price';

  @override
  String get currency => 'EGP';
}
