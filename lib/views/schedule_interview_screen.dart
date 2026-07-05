import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../model/interview.dart';
import '../model/application.dart';
import '../viewmodel/company_provider.dart';

class ScheduleInterviewScreen extends ConsumerStatefulWidget {
  final Application application;
  const ScheduleInterviewScreen({super.key, required this.application});

  @override
  ConsumerState<ScheduleInterviewScreen> createState() => _ScheduleInterviewScreenState();
}

class _ScheduleInterviewScreenState extends ConsumerState<ScheduleInterviewScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  InterviewMode _mode = InterviewMode.online;
  final _linkController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final primaryBlue = const Color(0xFF1565C0);
    final isLoading = ref.watch(companyNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Schedule Interview', style: TextStyle(fontWeight: FontWeight.w900)),
        elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _candidateInfo(),
              const SizedBox(height: 32),
              _sectionTitle('Date & Time'),
              _buildDateTimePicker(),
              const SizedBox(height: 24),
              _sectionTitle('Interview Mode'),
              _buildModeSelector(),
              const SizedBox(height: 24),
              if (_mode == InterviewMode.online)
                _buildTextField('Meeting Link', _linkController, Icons.link, 'e.g. Google Meet or Zoom link')
              else
                _buildTextField('Office Address', _locationController, Icons.location_on_outlined, 'Full location details'),
              const SizedBox(height: 24),
              _buildTextField('Notes for Candidate', _notesController, Icons.note_alt_outlined, 'Add preparation instructions...', maxLines: 3),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryBlue,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: isLoading ? null : _submit,
                  child: isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('CONFIRM SCHEDULE', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _candidateInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          CircleAvatar(child: Text(widget.application.studentName[0])),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.application.studentName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text(widget.application.internshipTitle, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
  );

  Widget _buildDateTimePicker() {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(context: context, initialDate: _selectedDate, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 90)));
              if (date != null) setState(() => _selectedDate = date);
            },
            child: _dateTimeBox(Icons.calendar_today, DateFormat('MMM dd, yyyy').format(_selectedDate)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () async {
              final time = await showTimePicker(context: context, initialTime: _selectedTime);
              if (time != null) setState(() => _selectedTime = time);
            },
            child: _dateTimeBox(Icons.access_time, _selectedTime.format(context)),
          ),
        ),
      ],
    );
  }

  Widget _dateTimeBox(IconData icon, String text) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
    child: Row(children: [Icon(icon, size: 16, color: const Color(0xFF1565C0)), const SizedBox(width: 8), Text(text, style: const TextStyle(fontWeight: FontWeight.bold))]),
  );

  Widget _buildModeSelector() {
    return Row(
      children: InterviewMode.values.map((m) => Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _mode = m),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: _mode == m ? const Color(0xFF1565C0) : Colors.grey[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: Text(m.name.toUpperCase(), style: TextStyle(color: _mode == m ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 12))),
          ),
        ),
      )).toList(),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, String hint, {int maxLines = 1}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(label),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, size: 20),
            filled: true, fillColor: Colors.grey[50],
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
          validator: (v) => v!.isEmpty ? 'Required' : null,
        ),
      ],
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dateTime = DateTime(
      _selectedDate.year, _selectedDate.month, _selectedDate.day,
      _selectedTime.hour, _selectedTime.minute,
    );

    final interview = Interview(
      id: widget.application.id, // Link to application ID
      studentId: widget.application.studentId,
      studentName: widget.application.studentName,
      internshipId: widget.application.internshipId,
      internshipTitle: widget.application.internshipTitle,
      companyId: widget.application.companyId,
      dateTime: dateTime,
      mode: _mode,
      meetingLink: _linkController.text,
      location: _locationController.text,
      notes: _notesController.text,
    );

    try {
      await ref.read(companyNotifierProvider.notifier).scheduleInterview(interview);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Interview Scheduled & Student Notified!')));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e')));
    }
  }
}

