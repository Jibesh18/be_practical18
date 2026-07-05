import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../model/internship.dart';
import '../viewmodel/company_provider.dart';
import '../theme/app_text_styles.dart';

class PostInternshipScreen extends ConsumerStatefulWidget {
  const PostInternshipScreen({super.key});

  @override
  ConsumerState<PostInternshipScreen> createState() => _PostInternshipScreenState();
}

class _PostInternshipScreenState extends ConsumerState<PostInternshipScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers for 20+ Fields
  final _titleController = TextEditingController();
  final _categoryController = TextEditingController();
  final _deptController = TextEditingController();
  final _descController = TextEditingController();
  final _respController = TextEditingController();
  final _qualController = TextEditingController();
  final _reqSkillsController = TextEditingController();
  final _prefSkillsController = TextEditingController();
  final _expController = TextEditingController();
  final _eduController = TextEditingController();
  final _locController = TextEditingController();
  final _durController = TextEditingController();
  final _stipendController = TextEditingController();
  final _openingsController = TextEditingController();
  final _hoursController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _benefitsController = TextEditingController();

  WorkMode _workMode = WorkMode.remote;
  DateTime _deadline = DateTime.now().add(const Duration(days: 30));
  DateTime _joiningDate = DateTime.now().add(const Duration(days: 45));
  
  bool _certificate = true;
  bool _lor = true;
  bool _ppo = false;

  final Color primaryBlue = const Color(0xFF1565C0);

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _deptController.dispose();
    _descController.dispose();
    _respController.dispose();
    _qualController.dispose();
    _reqSkillsController.dispose();
    _prefSkillsController.dispose();
    _expController.dispose();
    _eduController.dispose();
    _locController.dispose();
    _durController.dispose();
    _stipendController.dispose();
    _openingsController.dispose();
    _hoursController.dispose();
    _instructionsController.dispose();
    _benefitsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(companyNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Post Internship', style: TextStyle(fontWeight: FontWeight.w900)),
        elevation: 0, backgroundColor: Colors.white, foregroundColor: Colors.black,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionHeader('1. Core Details'),
                  _inputLabel('Internship Title'),
                  _buildText('e.g. Senior Frontend Developer', _titleController),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildDropdown('Category', ['IT', 'Design', 'Marketing', 'Sales', 'Finance', 'Engineering'], (val) => _categoryController.text = val!)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildText('Department', _deptController)),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _sectionHeader('2. Candidate Requirements'),
                  _buildText('Education Required', _eduController),
                  const SizedBox(height: 16),
                  _buildText('Experience Level', _expController),
                  const SizedBox(height: 16),
                  _buildLargeText('Required Skills (Comma separated)', _reqSkillsController, hint: 'Flutter, Dart, Firebase'),
                  const SizedBox(height: 16),
                  _buildLargeText('Preferred Skills', _prefSkillsController, hint: 'Riverpod, GoRouter'),

                  const SizedBox(height: 32),
                  _sectionHeader('3. Work Logistics'),
                  _buildWorkModeSelector(),
                  const SizedBox(height: 16),
                  _buildText('Specific Location', _locController),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildText('Duration', _durController, hint: 'e.g. 6 Months')),
                      const SizedBox(width: 16),
                      Expanded(child: _buildText('Working Hours', _hoursController, hint: 'e.g. 9 AM - 5 PM')),
                    ],
                  ),

                  const SizedBox(height: 32),
                  _sectionHeader('4. Dates & Openings'),
                  Row(
                    children: [
                      Expanded(child: _buildDatePicker('Application Deadline', _deadline, (date) => setState(() => _deadline = date))),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDatePicker('Joining Date', _joiningDate, (date) => setState(() => _joiningDate = date))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildText('Number of Openings', _openingsController, isNum: true),

                  const SizedBox(height: 32),
                  _sectionHeader('5. Job Description'),
                  _buildLargeText('General Description', _descController, lines: 5),
                  const SizedBox(height: 16),
                  _buildLargeText('Your Responsibilities (One per line)', _respController, lines: 5, hint: 'Write code\nFix bugs\nAttend meetings'),
                  const SizedBox(height: 16),
                  _buildLargeText('Requirements (One per line)', _qualController, lines: 5, hint: 'CS Degree\n2 years experience\nStrong logic'),

                  const SizedBox(height: 32),
                  _sectionHeader('6. Perks & Benefits'),
                  _buildText('Stipend Amount', _stipendController, hint: 'e.g. ₹20,000 / month'),
                  const SizedBox(height: 16),
                  _buildLargeText('Additional Benefits (Comma separated)', _benefitsController, hint: 'Health insurance, Free snacks'),
                  const SizedBox(height: 12),
                  _buildSwitch('Certificate Provided', _certificate, (v) => setState(() => _certificate = v)),
                  _buildSwitch('Letter of Recommendation', _lor, (v) => setState(() => _lor = v)),
                  _buildSwitch('PPO Available', _ppo, (v) => setState(() => _ppo = v)),

                  const SizedBox(height: 32),
                  _sectionHeader('7. Final Instructions'),
                  _buildLargeText('Instructions for Applicants', _instructionsController),

                  const SizedBox(height: 48),
                  _buildActionButtons(isLoading),
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
          if (isLoading) Container(color: Colors.black12, child: const Center(child: CircularProgressIndicator())),
        ],
      ),
    );
  }

  // --- WIDGET BUILDERS ---

  Widget _sectionHeader(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Text(t.toUpperCase(), style: TextStyle(color: primaryBlue, fontWeight: FontWeight.w900, letterSpacing: 1.2, fontSize: 14)),
  );

  Widget _inputLabel(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(t, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black87)),
  );

  Widget _buildText(String label, TextEditingController c, {bool isNum = false, String? hint}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputLabel(label),
      TextFormField(
        controller: c,
        keyboardType: isNum ? TextInputType.number : TextInputType.text,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: _inputDecoration(hint ?? label),
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
    ],
  );

  Widget _buildLargeText(String label, TextEditingController c, {int lines = 3, String? hint}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputLabel(label),
      TextFormField(
        controller: c,
        maxLines: lines,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: _inputDecoration(hint ?? label),
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
    ],
  );

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    filled: true, fillColor: Colors.grey[50],
    contentPadding: const EdgeInsets.all(18),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
  );

  Widget _buildDropdown(String label, List<String> items, Function(String?) onChanged) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputLabel(label),
      DropdownButtonFormField<String>(
        decoration: _inputDecoration('Select'),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
        validator: (v) => v == null ? 'Required' : null,
      ),
    ],
  );

  Widget _buildWorkModeSelector() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputLabel('Work Mode'),
      Row(
        children: WorkMode.values.map((m) => Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _workMode = m),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: _workMode == m ? primaryBlue : Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(child: Text(m.name.toUpperCase(), style: TextStyle(color: _workMode == m ? Colors.white : Colors.black54, fontWeight: FontWeight.bold, fontSize: 11))),
            ),
          ),
        )).toList(),
      ),
    ],
  );

  Widget _buildDatePicker(String label, DateTime current, Function(DateTime) onPicked) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _inputLabel(label),
      InkWell(
        onTap: () async {
          final picked = await showDatePicker(context: context, initialDate: current, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)));
          if (picked != null) onPicked(picked);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(border: Border.all(color: Colors.grey[200]!), borderRadius: BorderRadius.circular(12), color: Colors.grey[50]),
          child: Row(children: [const Icon(Icons.calendar_today, size: 16, color: Colors.black54), const SizedBox(width: 8), Text(DateFormat('MMM dd, yyyy').format(current))]),
        ),
      ),
    ],
  );

  Widget _buildSwitch(String t, bool val, Function(bool) onChanged) => SwitchListTile(
    title: Text(t, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
    value: val, activeColor: primaryBlue,
    onChanged: onChanged,
    contentPadding: EdgeInsets.zero,
  );

  Widget _buildActionButtons(bool loading) => Row(
    children: [
      Expanded(
        child: OutlinedButton(
          onPressed: () => context.pop(),
          style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('SAVE DRAFT', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ),
      const SizedBox(width: 16),
      Expanded(
        child: ElevatedButton(
          onPressed: loading ? null : _submit,
          style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          child: const Text('PUBLISH NOW', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    ],
  );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    final internship = Internship(
      id: '', companyId: '', companyName: 'Be Practical Academy', companyLogo: '',
      title: _titleController.text, category: _categoryController.text, department: _deptController.text,
      description: _descController.text, 
      responsibilities: _respController.text.split('\n').where((s) => s.trim().isNotEmpty).toList(),
      requirements: _qualController.text.split('\n').where((s) => s.trim().isNotEmpty).toList(),
      qualifications: _qualController.text,
      requiredSkills: _reqSkillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      preferredSkills: _prefSkillsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      experienceRequired: _expController.text, education: _eduController.text,
      location: _locController.text, workMode: _workMode, duration: _durController.text,
      type: 'Full-time', stipend: _stipendController.text,
      benefits: _benefitsController.text.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList(),
      certificate: _certificate, letterOfRecommendation: _lor, ppoAvailable: _ppo,
      openings: int.tryParse(_openingsController.text) ?? 1,
      deadline: _deadline, joiningDate: _joiningDate, workingHours: _hoursController.text,
      companyInstructions: _instructionsController.text, attachments: [],
      postedAt: DateTime.now(),
    );

    try {
      await ref.read(companyNotifierProvider.notifier).postInternship(internship);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Internship Published Successfully!')));
        context.pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Publish Failed: $e')));
    }
  }
}

