import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/resource_model.dart';

class ResourcesProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<ResourceModel> _resources = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ResourceModel> get resources => _resources;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchResources() async {
    // Don't re-fetch if already loaded
    if (_resources.isNotEmpty) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('resources')
          .orderBy('order')
          .get();

      _resources = snapshot.docs
          .map((doc) => ResourceModel.fromFirestore(doc.id, doc.data()))
          .toList();
    } catch (e) {
      // orderBy needs an index — fall back without ordering if it fails
      try {
        final snapshot = await _firestore
            .collection('resources')
            .get();
        _resources = snapshot.docs
            .map((doc) => ResourceModel.fromFirestore(doc.id, doc.data()))
            .toList();
      } catch (e2) {
        _errorMessage = 'Could not load resources. Please try again.';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Call this to force a refresh
  Future<void> refresh() async {
    _resources = [];
    await fetchResources();
  }
}