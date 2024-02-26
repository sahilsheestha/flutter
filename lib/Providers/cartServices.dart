import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:freelance_booking_app/Models/Cart.dart';

class CartService with ChangeNotifier {
  Map<String, Cart> _services = {}; // change this

  Map<String, Cart> get services {
    return {..._services};
  }

  void addServices(String serviceId, String serviceName, int price, int min,
      String shopName, String customerName, String address) {
    if (_services.containsKey(serviceId)) {
      _services.update(serviceId,
          (existing) => existing.addService(serviceName, price, min));
    } else {
      _services.putIfAbsent(
        serviceId,
        () => Cart(
            id: FirebaseAuth.instance.currentUser.uid,
            serviceName: ["$serviceName"],
            price: [price],
            timeList: [min],
            subtotal: price,
            name: customerName,
            shopName: shopName,
            address: address,
            time: min),
      );
    }
    notifyListeners();
  }

  void updateOtp(String serviceId, String otp) {
    _services.update(serviceId, (value) => value.addOtp(otp));
    notifyListeners();
  }

  void updateDay(String serviceId, DateTime day) {
    _services.update(serviceId, (value) => value.addDay(day));
    notifyListeners();
  }

  void updateTimeSlot(String serviceId, String slot) {
    _services.update(serviceId, (value) => value.addSlot(slot));
    notifyListeners();
  }

  void removeServices(String serviceId, String serviceName) {
    _services.update(
        serviceId, (existing) => existing.removeService(serviceName));
    notifyListeners();
  }

  void removeAllServices(String serviceId) {
    _services.remove(serviceId);
    notifyListeners();
  }
}
