import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../components/user_tile.dart';
import '../../services/chat/chat_service.dart';

class ReportedUsersPage extends StatelessWidget {
  ReportedUsersPage({super.key});
  final ChatService _chatService = ChatService();

  // Show options when tapping on the user
  void _showOptions(
      BuildContext context, String reportID, Map<String, dynamic> report) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.account_circle),
                title: const Text('Report Details'),
                onTap: () {
                  Navigator.pop(context);
                  _showReportDetails(context, report);
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete_forever),
                title: const Text('Delete Report'),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteBox(context, reportID);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Show Report Details in a dialog
  void _showReportDetails(BuildContext context, Map<String, dynamic> report) {
    final reportData = report['report']; // The report's main data
    final reportedByUser = report['reportedByUser']; // User who reported
    final messageOwnerUser =
        report['messageOwnerUser']; // User who owned the reported message
    final messageContent = report['messageContent']; // Actual message content

    final timestamp = reportData['timestamp'];
    final reportedByEmail = reportedByUser['email'];
    final messageOwnerEmail = messageOwnerUser['email'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Report Details"),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Message Owner: $messageOwnerEmail"),
            SizedBox(height: 10),
            Text(
                "Reported Message: $messageContent"), // Show the actual message
            SizedBox(height: 10),
            Text(
                "Reported on: ${DateFormat('MMMM d, yyyy - h:mm a').format(timestamp.toDate())}"),
            SizedBox(height: 10),
            Text("Reported by: $reportedByEmail"),
          ],
        ),
        actions: [
          // Close the dialog
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Close"),
          ),
        ],
      ),
    );
  }

  // Delete confirmation dialog box
  void _showDeleteBox(BuildContext context, String reportID) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Delete Report"),
        content: Text("Are you sure you want to delete this report?"),
        actions: [
          // Cancel button
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text("Cancel"),
          ),
          // Confirm delete button
          TextButton(
            onPressed: () async {
              try {
                // Call the deleteReport method from ChatService
                await _chatService.deleteReport(reportID);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Report deleted successfully."),
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Failed to delete the report."),
                  ),
                );
              }
            },
            child: Text(
              "Delete",
              style: TextStyle(
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Reported Users"),
        actions: [],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _chatService.getReportedUsersStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: const Text("Error loading reports..."));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data ?? [];

          if (reports.isEmpty) {
            return Center(child: const Text("No Reports Found"));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              final messageOwnerUser = report['messageOwnerUser'];
              final reportID = report['reportID'];

              final userTileText = "${messageOwnerUser['email']}";
              return UserTile(
                text: userTileText,
                onTap: () {
                  _showOptions(
                      context, reportID, report); // Pass the entire report data
                },
              );
            },
          );
        },
      ),
    );
  }
}
