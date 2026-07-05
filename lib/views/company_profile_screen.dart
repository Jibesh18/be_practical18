import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/company_provider.dart';
import '../model/company_profile.dart';

class CompanyProfileScreen extends ConsumerStatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  ConsumerState<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends ConsumerState<CompanyProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // 15+ Production Fields
  late TextEditingController _nameController;
  late TextEditingController _descController;
  late TextEditingController _webController;
  late TextEditingController _industryController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _sizeController;
  late TextEditingController _foundedController;
  late TextEditingController _visionController;
  late TextEditingController _missionController;
  late TextEditingController _cultureController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _descController = TextEditingController();
    _webController = TextEditingController();
    _industryController = TextEditingController();
    _addressController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _sizeController = TextEditingController();
    _foundedController = TextEditingController();
    _visionController = TextEditingController();
    _missionController = TextEditingController();
    _cultureController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose(); _descController.dispose(); _webController.dispose();
    _industryController.dispose(); _addressController.dispose(); _emailController.dispose();
    _phoneController.dispose(); _sizeController.dispose(); _foundedController.dispose();
    _visionController.dispose(); _missionController.dispose(); _cultureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(companyProfileProvider);
    final primaryBlue = const Color(0xFF1565C0);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFF),
      appBar: AppBar(
        title: const Text('Company Brand Hub', style: TextStyle(fontWeight: FontWeight.w900)),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(backgroundColor: primaryBlue, foregroundColor: Colors.white),
              child: const Text('SAVE CHANGES'),
            ),
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile != null && _nameController.text.isEmpty) {
            _nameController.text = profile.name;
            _descController.text = profile.description;
            _webController.text = profile.website;
            _industryController.text = profile.industry;
            _addressController.text = profile.address;
            _emailController.text = profile.email;
            _phoneController.text = profile.phone;
            _sizeController.text = profile.size;
            _foundedController.text = profile.foundedYear;
            _visionController.text = profile.vision;
            _missionController.text = profile.mission;
            _cultureController.text = profile.culture;
          }
          
          return Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBrandHeader(profile, primaryBlue),
                  const SizedBox(height: 32),
                  
                  _sectionHeader('Corporate Identity'),
                  _buildTextField('Company Name', _nameController, Icons.business),
                  _buildTextField('Industry', _industryController, Icons.category),
                  _buildTextField('Company Size', _sizeController, Icons.people_outline),
                  _buildTextField('Founded Year', _foundedController, Icons.calendar_today),
                  
                  const SizedBox(height: 32),
                  _sectionHeader('About & Culture'),
                  _buildTextField('Detailed Description', _descController, Icons.info_outline, maxLines: 4),
                  _buildTextField('Our Vision', _visionController, Icons.visibility_outlined, maxLines: 2),
                  _buildTextField('Our Mission', _missionController, Icons.flag_outlined, maxLines: 2),
                  _buildTextField('Company Culture', _cultureController, Icons.favorite_border, maxLines: 2),

                  const SizedBox(height: 32),
                  _sectionHeader('Contact & Connectivity'),
                  _buildTextField('Website', _webController, Icons.language),
                  _buildTextField('Public Email', _emailController, Icons.email_outlined),
                  _buildTextField('Contact Phone', _phoneController, Icons.phone_outlined),
                  _buildTextField('Headquarters Address', _addressController, Icons.location_on_outlined, maxLines: 2),
                  
                  const SizedBox(height: 60),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildBrandHeader(CompanyProfile? profile, Color primary) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(color: primary.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.add_photo_alternate_outlined, color: Colors.black12, size: 40),
            ),
            Positioned(
              bottom: 0,
              child: CircleAvatar(
                radius: 50, backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 46, backgroundColor: primary.withValues(alpha: 0.05),
                  child: const Icon(Icons.business_rounded, size: 40, color: Color(0xFF1565C0)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Text('Company Identity', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black38, fontSize: 12)),
      ],
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Text(title.toUpperCase(), style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: Color(0xFF1565C0), letterSpacing: 1.2)),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20, color: Colors.black45),
          filled: true, fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[200]!)),
        ),
        validator: (v) => v!.isEmpty ? 'Required' : null,
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    final currentProfile = ref.read(companyProfileProvider).value;
    final updatedProfile = (currentProfile ?? CompanyProfile(
      id: '', name: '', logo: '', description: '', website: '', 
      email: '', phone: '', address: '', industry: '', size: '', 
      foundedYear: '', socialLinks: {}
    )).copyWith(
      name: _nameController.text,
      description: _descController.text,
      website: _webController.text,
      industry: _industryController.text,
      address: _addressController.text,
      email: _emailController.text,
      phone: _phoneController.text,
      size: _sizeController.text,
      foundedYear: _foundedController.text,
      vision: _visionController.text,
      mission: _missionController.text,
      culture: _cultureController.text,
    );

    try {
      await ref.read(companyNotifierProvider.notifier).updateCompanyProfile(updatedProfile);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Global Profile Updated! ✨')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Update Failed: $e')));
    }
  }
}

