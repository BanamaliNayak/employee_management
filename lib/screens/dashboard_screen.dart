import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int totalEmployees = 0;
  int pendingCount = 0;
  int approvedCount = 0;
  int rejectedCount = 0;

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    // Total employees
    QuerySnapshot employeeSnapshot =
    await FirebaseFirestore.instance.collection('employees').get();
    // Leave requests breakdown
    QuerySnapshot leaveSnapshot =
    await FirebaseFirestore.instance.collection('leave_request').get();

    int pending = 0, approved = 0, rejected = 0;
    for (var doc in leaveSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      String status = data['status'] ?? 'pending';
      if (status == 'pending') pending++;
      if (status == 'approved') approved++;
      if (status == 'rejected') rejected++;
    }

    setState(() {
      totalEmployees = employeeSnapshot.docs.length;
      pendingCount = pending;
      approvedCount = approved;
      rejectedCount = rejected;
    });
  }

  List<PieChartSectionData> getPieSections() {
    return [
      PieChartSectionData(
          value: approvedCount.toDouble(),
          title: "Approved",
          color: Colors.green,
          radius: 50),
      PieChartSectionData(
          value: pendingCount.toDouble(),
          title: "Pending",
          color: Colors.orange,
          radius: 50),
      PieChartSectionData(
          value: rejectedCount.toDouble(),
          title: "Rejected",
          color: Colors.red,
          radius: 50),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text("Total Employees: $totalEmployees",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            Text("Pending Leave Requests: $pendingCount",
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Expanded(
              child: PieChart(
                PieChartData(sections: getPieSections()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
