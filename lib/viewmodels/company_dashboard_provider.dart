import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';

class CompanyDashboardState {
  final int totalInternships;
  final int activeInternships;
  final int totalApplications;
  final int hiredInterns;
  final double conversionRate;
  final int avgTimeToHire;

  CompanyDashboardState({
    this.totalInternships = 15,
    this.activeInternships = 8,
    this.totalApplications = 284,
    this.hiredInterns = 42,
    this.conversionRate = 14.8,
    this.avgTimeToHire = 12,
  });
}

class CompanyDashboardNotifier extends StateNotifier<CompanyDashboardState> {
  CompanyDashboardNotifier() : super(CompanyDashboardState());

  // In a real app, you would fetch this data from Firestore here
  void refresh() {
    // Fetch logic
  }
}

final companyDashboardProvider = StateNotifierProvider<CompanyDashboardNotifier, CompanyDashboardState>((ref) {
  return CompanyDashboardNotifier();
});

