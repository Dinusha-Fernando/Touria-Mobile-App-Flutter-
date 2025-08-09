import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:touria/constant/colors.dart';

class TripForm extends StatelessWidget {
  final TextEditingController tripTitleController;
  final DateTime? startDate;
  final DateTime? endDate;
  final VoidCallback onCreateTrip;
  final Function(DateTime) onStartDatePicked;
  final Function(DateTime) onEndDatePicked;

  const TripForm({
    super.key,
    required this.tripTitleController,
    this.startDate,
    this.endDate,
    required this.onCreateTrip,
    required this.onStartDatePicked,
    required this.onEndDatePicked,
  });

  @override
  Widget build(BuildContext context) {
    //final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;
    final formatter = DateFormat('yyyy-MM-dd');
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: tripTitleController,
            decoration: InputDecoration(labelText: 'Trip Title'),
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cardBackground,
                    foregroundColor: primaryColor,
                  ),
                  icon: Icon(Icons.date_range),
                  label: Text(
                    startDate == null
                        ? 'Start Date'
                        : formatter.format(startDate!),
                  ),

                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2040),
                    );
                    if (picked != null) onStartDatePicked(picked);
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: cardBackground,
                    foregroundColor: primaryColor,
                  ),
                  icon: Icon(Icons.date_range),
                  label: Text(
                    endDate == null ? 'End Date' : formatter.format(endDate!),
                  ),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2024),
                      lastDate: DateTime(2040),
                    );
                    if (picked != null) onEndDatePicked(picked);
                  },
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: cardBackground,
              foregroundColor: primaryColor,
            ),
            onPressed: onCreateTrip,
            child: Text('Create Itinerary'),
          ),
        ],
      ),
    );
  }
}
