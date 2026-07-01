import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/internship_model.dart';
import '../../themes/app_colors.dart';
import '../../themes/app_textstyles.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../viewmodels/employer_viewmodel.dart';

class EmployerPostTab extends StatefulWidget {
  final InternshipModel? editing;
  const EmployerPostTab({super.key, this.editing});

  @override
  State<EmployerPostTab> createState() => _EmployerPostTabState();
}

class _EmployerPostTabState extends State<EmployerPostTab> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _companyController = TextEditingController();
  final _locationController = TextEditingController();
  final _durationController = TextEditingController();
  final _stipendController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _requirementsController = TextEditingController();
  final _skillInputController = TextEditingController();

  String _selectedType = 'Remote';
  final List<String> _skills = [];

  @override
  void initState() {
    super.initState();
    final e = widget.editing;
    if (e != null) {
      _titleController.text = e.title;
      _companyController.text = e.company;
      _locationController.text = e.location;
      _durationController.text = e.duration;
      _stipendController.text = e.stipend;
      _descriptionController.text = e.description;
      _requirementsController.text = e.requirements;
      _selectedType = e.type;
      _skills.addAll(e.skills);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _durationController.dispose();
    _stipendController.dispose();
    _descriptionController.dispose();
    _requirementsController.dispose();
    _skillInputController.dispose();
    super.dispose();
  }

  void _addSkill() {
    final skill = _skillInputController.text.trim();
    if (skill.isEmpty || _skills.contains(skill)) return;
    setState(() {
      _skills.add(skill);
      _skillInputController.clear();
    });
  }

  void _removeSkill(String skill) => setState(() => _skills.remove(skill));

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add at least one required skill')),
      );
      return;
    }

    final employerVM = context.read<EmployerViewModel>();
    final authVM = context.read<AuthViewModel>();
    final user = authVM.currentUser;
    if (user == null) return;

    final success = widget.editing == null
        ? await employerVM.postInternship(
      title: _titleController.text,
      company: _companyController.text,
      location: _locationController.text,
      type: _selectedType,
      duration: _durationController.text,
      stipend: _stipendController.text,
      description: _descriptionController.text,
      requirements: _requirementsController.text,
      skills: List.from(_skills),
      postedBy: user.uid,
      employerName: user.displayName ?? '',
    )
        : await employerVM.updateInternship(
      id: widget.editing!.id,
      title: _titleController.text,
      company: _companyController.text,
      location: _locationController.text,
      type: _selectedType,
      duration: _durationController.text,
      stipend: _stipendController.text,
      description: _descriptionController.text,
      requirements: _requirementsController.text,
      skills: List.from(_skills),
      isActive: widget.editing!.isActive,
      postedBy: widget.editing!.postedBy,
      employerName: widget.editing!.employerName,
      postedAt: widget.editing!.postedAt,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.editing == null
              ? 'Internship posted successfully!'
              : 'Internship updated successfully!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(employerVM.postError ?? employerVM.updateError ?? 'Something went wrong'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final employerVM = context.watch<EmployerViewModel>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              widget.editing == null ? 'Post Internship' : 'Edit Internship',
              style: AppTextStyles.headlineMedium,
            ),
            const SizedBox(height: 4),
            Text(
              'Fill in the details to attract the right candidates',
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.lightTextSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: 'Basic Information'),
            const SizedBox(height: 12),
            _Field(controller: _titleController, label: 'Job Title', hint: 'e.g. Flutter Developer Intern', validator: _required),
            const SizedBox(height: 14),
            _Field(controller: _companyController, label: 'Company Name', hint: 'e.g. Tech Solutions Pvt Ltd', validator: _required),
            const SizedBox(height: 14),
            _Field(controller: _locationController, label: 'Location', hint: 'e.g. Bangalore / Work From Home', validator: _required),
            const SizedBox(height: 14),
            Text('Work Type', style: AppTextStyles.labelMedium),
            const SizedBox(height: 8),
            Row(
              children: ['Remote', 'On-site', 'Hybrid'].map((type) {
                final selected = _selectedType == type;
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ChoiceChip(
                    label: Text(type),
                    selected: selected,
                    onSelected: (_) => setState(() => _selectedType = type),
                    selectedColor: AppColors.primary.withOpacity(0.15),
                    labelStyle: AppTextStyles.labelSmall.copyWith(
                      color: selected ? AppColors.primary : null,
                    ),
                    checkmarkColor: AppColors.primary,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _Field(
                    controller: _durationController,
                    label: 'Duration',
                    hint: 'e.g. 3 months',
                    validator: _required,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _Field(
                    controller: _stipendController,
                    label: 'Stipend',
                    hint: 'e.g. ₹5000/month',
                    validator: _required,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: 'Details'),
            const SizedBox(height: 12),
            _Field(
              controller: _descriptionController,
              label: 'Job Description',
              hint: 'Describe the role and responsibilities...',
              maxLines: 4,
              validator: _required,
            ),
            const SizedBox(height: 14),
            _Field(
              controller: _requirementsController,
              label: 'Requirements',
              hint: 'What qualifications do you expect?',
              maxLines: 3,
              validator: _required,
            ),
            const SizedBox(height: 24),
            _SectionLabel(label: 'Required Skills'),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _skillInputController,
                    decoration: InputDecoration(
                      labelText: 'Add a skill',
                      hintText: 'e.g. Flutter, Firebase',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onFieldSubmitted: (_) => _addSkill(),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addSkill,
                  child: const Icon(Icons.add_rounded),
                ),
              ],
            ),
            if (_skills.isNotEmpty) ...[
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _skills
                    .map(
                      (skill) => Chip(
                    label: Text(skill, style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary)),
                    backgroundColor: AppColors.primary.withOpacity(0.08),
                    deleteIcon: const Icon(Icons.close_rounded, size: 14, color: AppColors.primary),
                    onDeleted: () => _removeSkill(skill),
                  ),
                )
                    .toList(),
              ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: employerVM.isPosting || employerVM.isUpdating ? null : _submit,
                child: (widget.editing == null
                    ? employerVM.isPosting
                    : employerVM.isUpdating)
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                )
                    : Text(widget.editing == null ? 'Post Internship' : 'Update Internship'),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  String? _required(String? value) {
    if (value == null || value.trim().isEmpty) return 'This field is required';
    return null;
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label, style: AppTextStyles.titleMedium),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final String? Function(String?)? validator;

  const _Field({
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        alignLabelWithHint: maxLines > 1,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}