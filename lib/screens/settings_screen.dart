import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/routes.dart';
import '../core/theme.dart';
import '../services/auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  File? _profileImage;

  bool notificationsEnabled = true;
  bool automaticBackupEnabled = true;

  bool _isLoggingOut = false;

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Future<void> _pickProfileImage(ImageSource source) async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 900,
      );

      if (image == null) return;

      if (!mounted) return;

      setState(() {
        _profileImage = File(image.path);
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select picture: $e'),
        ),
      );
    }
  }

  // ============================================================
  // PROFILE PICTURE OPTIONS
  // ============================================================

  void _showProfilePictureOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 42,
                  height: 5,
                  decoration: BoxDecoration(
                    color: StackFlowColors.border,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Profile picture',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: StackFlowColors.text,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Choose a picture for your StackFlow profile.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: StackFlowColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: _PictureOption(
                        icon: Icons.photo_library_outlined,
                        title: 'Gallery',
                        subtitle: 'Choose photo',
                        onTap: () {
                          Navigator.pop(context);
                          _pickProfileImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PictureOption(
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera',
                        subtitle: 'Take photo',
                        onTap: () {
                          Navigator.pop(context);
                          _pickProfileImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
                if (_profileImage != null) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);

                        if (!mounted) return;

                        setState(() {
                          _profileImage = null;
                        });
                      },
                      icon: const Icon(
                        Icons.delete_outline,
                        color: Colors.redAccent,
                      ),
                      label: const Text(
                        'Remove profile picture',
                        style: TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // OPEN PROFILE
  // ============================================================

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProfileScreen(
          profileImage: _profileImage,
          onImageChanged: (image) {
            if (!mounted) return;

            setState(() {
              _profileImage = image;
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // OPEN BUSINESS INFORMATION
  // ============================================================

  void _openBusinessInformation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const BusinessInformationScreen(),
      ),
    );
  }

  // ============================================================
  // OPEN NOTIFICATIONS
  // ============================================================

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NotificationSettingsScreen(
          enabled: notificationsEnabled,
          onChanged: (value) {
            if (!mounted) return;

            setState(() {
              notificationsEnabled = value;
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // OPEN BACKUP
  // ============================================================

  void _openBackup() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BackupDataScreen(
          automaticBackupEnabled: automaticBackupEnabled,
          onChanged: (value) {
            if (!mounted) return;

            setState(() {
              automaticBackupEnabled = value;
            });
          },
        ),
      ),
    );
  }

  // ============================================================
  // OPEN HELP & SUPPORT
  // ============================================================

  void _openHelpSupport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HelpSupportScreen(),
      ),
    );
  }

  // ============================================================
  // OPEN ABOUT
  // ============================================================

  void _openAbout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AboutStackFlowScreen(),
      ),
    );
  }

  // ============================================================
  // LOG OUT
  // ============================================================

  Future<void> _logout() async {
    if (_isLoggingOut) return;

    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: Colors.redAccent,
              ),
              SizedBox(width: 10),
              Text(
                'Log Out',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Text(
            'Are you sure you want to log out of your StackFlow account?',
            style: TextStyle(
              fontSize: 13,
              height: 1.4,
              color: StackFlowColors.secondaryText,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text(
                'Cancel',
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Log Out',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    if (!mounted) return;

    setState(() {
      _isLoggingOut = true;
    });

    try {
      final AuthService authService = AuthService();

      await authService.logout();

      if (!mounted) return;

      // Remove all previous screens so the user cannot
      // press Back and return to the dashboard.
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.auth,
            (route) => false,
      );
    } catch (e, stackTrace) {
      debugPrint('Logout error: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (!mounted) return;

      setState(() {
        _isLoggingOut = false;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'Unable to log out. Please try again.',
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FB),
        elevation: 0,
        title: const Text(
          'More',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
        children: [
          // ========================================================
          // PROFILE HEADER
          // ========================================================

          _ProfileHeader(
            image: _profileImage,
            onTap: _openProfile,
            onImageTap: _showProfilePictureOptions,
          ),

          const SizedBox(height: 22),

          // ========================================================
          // ACCOUNT
          // ========================================================

          const _SectionTitle(
            title: 'Account',
          ),

          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.person_outline,
                iconColor: StackFlowColors.primary,
                title: 'My Profile',
                subtitle: 'Manage your personal information',
                onTap: _openProfile,
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.business_outlined,
                iconColor: StackFlowColors.blue,
                title: 'Business Information',
                subtitle: 'Business name, address and contact',
                onTap: _openBusinessInformation,
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ========================================================
          // PREFERENCES
          // ========================================================

          const _SectionTitle(
            title: 'Preferences',
          ),

          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.notifications_none,
                iconColor: StackFlowColors.orange,
                title: 'Notifications',
                subtitle: notificationsEnabled
                    ? 'Notifications are enabled'
                    : 'Notifications are disabled',
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                ),
                onTap: _openNotifications,
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ========================================================
          // DATA & SUPPORT
          // ========================================================

          const _SectionTitle(
            title: 'Data & Support',
          ),

          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.cloud_upload_outlined,
                iconColor: StackFlowColors.green,
                title: 'Backup & Data',
                subtitle: automaticBackupEnabled
                    ? 'Automatic backup is enabled'
                    : 'Automatic backup is disabled',
                onTap: _openBackup,
              ),
              const _Divider(),
              _SettingsTile(
                icon: Icons.help_outline,
                iconColor: StackFlowColors.blue,
                title: 'Help & Support',
                subtitle: 'Contact StackFlow support',
                onTap: _openHelpSupport,
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ========================================================
          // ABOUT
          // ========================================================

          const _SectionTitle(
            title: 'About',
          ),

          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.auto_awesome_outlined,
                iconColor: StackFlowColors.primary,
                title: 'About StackFlow',
                subtitle: 'Learn about StackFlow',
                onTap: _openAbout,
              ),
            ],
          ),

          const SizedBox(height: 22),

          // ========================================================
          // LOG OUT
          // ========================================================

          const _SectionTitle(
            title: 'Account',
          ),

          const SizedBox(height: 8),

          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.logout_rounded,
                iconColor: Colors.redAccent,
                title: 'Log Out',
                subtitle: 'Sign out of your StackFlow account',
                trailing: _isLoggingOut
                    ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.redAccent,
                  ),
                )
                    : const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Colors.redAccent,
                ),
                onTap: _isLoggingOut ? () {} : _logout,
              ),
            ],
          ),

          const SizedBox(height: 28),

          // ========================================================
          // APP INFORMATION
          // ========================================================

          Center(
            child: Column(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF087FD1),
                        Color(0xFF08AFA5),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.stacked_bar_chart_rounded,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'StackFlow',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                const Text(
                  'Smart business management',
                  style: TextStyle(
                    color: StackFlowColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                const Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: StackFlowColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// PROFILE HEADER
// ================================================================

class _ProfileHeader extends StatelessWidget {
  final File? image;
  final VoidCallback onTap;
  final VoidCallback onImageTap;

  const _ProfileHeader({
    required this.image,
    required this.onTap,
    required this.onImageTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF087FD1),
            Color(0xFF08AFA5),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF087FD1).withValues(alpha: 0.15),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: onImageTap,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: Colors.white,
                  backgroundImage:
                  image != null ? FileImage(image!) : null,
                  child: image == null
                      ? const Icon(
                    Icons.person,
                    size: 35,
                    color: StackFlowColors.primary,
                  )
                      : null,
                ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Container(
                    width: 25,
                    height: 25,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 13,
                      color: StackFlowColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back!',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Your Profile',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Manage your StackFlow account',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onTap,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white24,
            ),
            icon: const Icon(
              Icons.chevron_right,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// PROFILE SCREEN
// ================================================================

class ProfileScreen extends StatefulWidget {
  final File? profileImage;
  final ValueChanged<File?> onImageChanged;

  const ProfileScreen({
    super.key,
    required this.profileImage,
    required this.onImageChanged,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late File? profileImage;

  final nameController =
  TextEditingController(text: 'StackFlow User');

  final emailController =
  TextEditingController(text: 'user@stackflow.app');

  final phoneController =
  TextEditingController(text: '+91 00000 00000');

  @override
  void initState() {
    super.initState();
    profileImage = widget.profileImage;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  // ============================================================
  // PICK PROFILE IMAGE
  // ============================================================

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();

      final image = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 900,
      );

      if (image == null) return;

      final file = File(image.path);

      if (!mounted) return;

      setState(() {
        profileImage = file;
      });

      widget.onImageChanged(file);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to select picture: $e'),
        ),
      );
    }
  }

  // ============================================================
  // IMAGE PICKER
  // ============================================================

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(22),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Change profile picture',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _PictureOption(
                        icon: Icons.photo_library_outlined,
                        title: 'Gallery',
                        subtitle: 'Choose photo',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _PictureOption(
                        icon: Icons.camera_alt_outlined,
                        title: 'Camera',
                        subtitle: 'Take photo',
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                    ),
                  ],
                ),
                if (profileImage != null)
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);

                      if (!mounted) return;

                      setState(() {
                        profileImage = null;
                      });

                      widget.onImageChanged(null);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Colors.redAccent,
                    ),
                    label: const Text(
                      'Remove picture',
                      style: TextStyle(
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ============================================================
  // SAVE PROFILE
  // ============================================================

  void _saveProfile() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile updated successfully.',
        ),
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Center(
            child: GestureDetector(
              onTap: _showImagePicker,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 52,
                    backgroundColor: const Color(0xFFE6F5F3),
                    backgroundImage: profileImage != null
                        ? FileImage(profileImage!)
                        : null,
                    child: profileImage == null
                        ? const Icon(
                      Icons.person,
                      size: 52,
                      color: StackFlowColors.primary,
                    )
                        : null,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: StackFlowColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text(
              'Tap your picture to change it',
              style: TextStyle(
                color: StackFlowColors.secondaryText,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 26),
          _InputField(
            label: 'Full Name',
            controller: nameController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _InputField(
            label: 'Email',
            controller: emailController,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 14),
          _InputField(
            label: 'Phone Number',
            controller: phoneController,
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: _saveProfile,
              icon: const Icon(Icons.check),
              label: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: StackFlowColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BUSINESS INFORMATION
// ================================================================

class BusinessInformationScreen extends StatefulWidget {
  const BusinessInformationScreen({super.key});

  @override
  State<BusinessInformationScreen> createState() =>
      _BusinessInformationScreenState();
}

class _BusinessInformationScreenState
    extends State<BusinessInformationScreen> {
  final businessNameController =
  TextEditingController(text: 'StackFlow Business');

  final ownerController =
  TextEditingController(text: 'Business Owner');

  final phoneController =
  TextEditingController(text: '+91 00000 00000');

  final emailController =
  TextEditingController(text: 'business@stackflow.app');

  final addressController =
  TextEditingController(text: 'Your business address');

  @override
  void dispose() {
    businessNameController.dispose();
    ownerController.dispose();
    phoneController.dispose();
    emailController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void _save() {
    FocusScope.of(context).unfocus();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Business information saved.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text(
          'Business Information',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoBanner(
            icon: Icons.business_outlined,
            title: 'Your business profile',
            subtitle:
            'Keep your business details updated for invoices and records.',
          ),
          const SizedBox(height: 20),
          _InputField(
            label: 'Business Name',
            controller: businessNameController,
            icon: Icons.storefront_outlined,
          ),
          const SizedBox(height: 14),
          _InputField(
            label: 'Owner Name',
            controller: ownerController,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 14),
          _InputField(
            label: 'Phone Number',
            controller: phoneController,
            icon: Icons.phone_outlined,
          ),
          const SizedBox(height: 14),
          _InputField(
            label: 'Business Email',
            controller: emailController,
            icon: Icons.email_outlined,
          ),
          const SizedBox(height: 14),
          _InputField(
            label: 'Business Address',
            controller: addressController,
            icon: Icons.location_on_outlined,
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: StackFlowColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(13),
                ),
              ),
              child: const Text(
                'Save Business Information',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// NOTIFICATIONS
// ================================================================

class NotificationSettingsScreen extends StatefulWidget {
  final bool enabled;
  final ValueChanged<bool> onChanged;

  const NotificationSettingsScreen({
    super.key,
    required this.enabled,
    required this.onChanged,
  });

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  late bool enabled;

  bool salesAlerts = true;
  bool lowStockAlerts = true;
  bool businessUpdates = true;

  @override
  void initState() {
    super.initState();
    enabled = widget.enabled;
  }

  void _setMainNotification(bool value) {
    setState(() {
      enabled = value;
    });

    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _PreferenceCard(
            icon: Icons.notifications_active_outlined,
            title: 'Notifications',
            subtitle: 'Control StackFlow notifications',
            trailing: Switch(
              value: enabled,
              onChanged: _setMainNotification,
            ),
          ),
          const SizedBox(height: 18),
          const _SectionTitle(
            title: 'Notification types',
          ),
          const SizedBox(height: 8),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.point_of_sale_outlined,
                title: 'Sales alerts',
                subtitle:
                'Get notified when a sale is completed',
                value: salesAlerts && enabled,
                onChanged: enabled
                    ? (value) {
                  setState(() {
                    salesAlerts = value;
                  });
                }
                    : null,
              ),
              const _Divider(),
              _SwitchTile(
                icon: Icons.warning_amber_outlined,
                title: 'Low stock alerts',
                subtitle:
                'Know when products need restocking',
                value: lowStockAlerts && enabled,
                onChanged: enabled
                    ? (value) {
                  setState(() {
                    lowStockAlerts = value;
                  });
                }
                    : null,
              ),
              const _Divider(),
              _SwitchTile(
                icon: Icons.campaign_outlined,
                title: 'Business updates',
                subtitle:
                'Important StackFlow updates',
                value: businessUpdates && enabled,
                onChanged: enabled
                    ? (value) {
                  setState(() {
                    businessUpdates = value;
                  });
                }
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================================================================
// BACKUP & DATA
// ================================================================

class BackupDataScreen extends StatefulWidget {
  final bool automaticBackupEnabled;
  final ValueChanged<bool> onChanged;

  const BackupDataScreen({
    super.key,
    required this.automaticBackupEnabled,
    required this.onChanged,
  });

  @override
  State<BackupDataScreen> createState() =>
      _BackupDataScreenState();
}

class _BackupDataScreenState extends State<BackupDataScreen> {
  late bool automaticBackup;

  bool isBackingUp = false;

  @override
  void initState() {
    super.initState();
    automaticBackup = widget.automaticBackupEnabled;
  }

  Future<void> _backupNow() async {
    if (isBackingUp) return;

    setState(() {
      isBackingUp = true;
    });

    await Future.delayed(
      const Duration(seconds: 2),
    );

    if (!mounted) return;

    setState(() {
      isBackingUp = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Backup completed successfully.',
        ),
      ),
    );
  }

  void _setAutomaticBackup(bool value) {
    setState(() {
      automaticBackup = value;
    });

    widget.onChanged(value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text(
          'Backup & Data',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BackupHero(
            isEnabled: automaticBackup,
            onBackup: _backupNow,
            isBackingUp: isBackingUp,
          ),
          const SizedBox(height: 18),
          _SettingsCard(
            children: [
              _SwitchTile(
                icon: Icons.autorenew,
                title: 'Automatic Backup',
                subtitle:
                'Keep your business data backed up automatically',
                value: automaticBackup,
                onChanged: _setAutomaticBackup,
              ),
            ],
          ),
          const SizedBox(height: 18),
          _InfoBanner(
            icon: Icons.lock_outline,
            title: 'Your data stays protected',
            subtitle:
            'Backups help keep your StackFlow business records safe.',
          ),
        ],
      ),
    );
  }
}

// ================================================================
// HELP & SUPPORT
// ================================================================

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  void _showContactSupport(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.support_agent_outlined,
                color: StackFlowColors.primary,
              ),
              SizedBox(width: 10),
              Text(
                'Contact Support',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Need help with StackFlow?',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Email us at:',
                style: TextStyle(
                  color: StackFlowColors.secondaryText,
                  fontSize: 12,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'support@stackflow.app',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Support hours: Monday - Saturday, 9:00 AM - 6:00 PM',
                style: TextStyle(
                  color: StackFlowColors.secondaryText,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text(
          'Help & Support',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF087FD1),
                  Color(0xFF08AFA5),
                ],
              ),
              borderRadius: BorderRadius.circular(22),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.support_agent_rounded,
                  color: Colors.white,
                  size: 36,
                ),
                SizedBox(height: 16),
                Text(
                  'How can we help?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Our support team is here to help you with StackFlow.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          _SupportActionCard(
            icon: Icons.support_agent_outlined,
            iconColor: StackFlowColors.primary,
            title: 'Contact Support',
            subtitle:
            'Get help from the StackFlow support team',
            buttonText: 'Contact us',
            onTap: () {
              _showContactSupport(context);
            },
          ),
        ],
      ),
    );
  }
}

// ================================================================
// ABOUT STACKFLOW
// ================================================================

class AboutStackFlowScreen extends StatelessWidget {
  const AboutStackFlowScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      appBar: AppBar(
        title: const Text(
          'About StackFlow',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(
              22,
              30,
              22,
              26,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF087FD1),
                  Color(0xFF08AFA5),
                ],
              ),
              borderRadius: BorderRadius.circular(26),
              boxShadow: [
                BoxShadow(
                  color:
                  const Color(0xFF087FD1).withValues(alpha: 0.18),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.stacked_bar_chart_rounded,
                    size: 48,
                    color: StackFlowColors.primary,
                  ),
                ),
                const SizedBox(height: 18),
                const Text(
                  'StackFlow',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Smart business management',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 13,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'VERSION 1.0.0',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Everything your business needs',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: StackFlowColors.text,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'StackFlow is designed to make everyday business management simple, organized and efficient.',
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: StackFlowColors.secondaryText,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _FeatureCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory',
                  subtitle: 'Manage products',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FeatureCard(
                  icon: Icons.point_of_sale_outlined,
                  title: 'Sales',
                  subtitle: 'Create invoices',
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _FeatureCard(
                  icon: Icons.people_outline,
                  title: 'Customers',
                  subtitle: 'Manage customers',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _FeatureCard(
                  icon: Icons.bar_chart_outlined,
                  title: 'Reports',
                  subtitle: 'Understand business',
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: StackFlowColors.border,
              ),
            ),
            child: const Column(
              children: [
                _AboutRow(
                  icon: Icons.speed_outlined,
                  title: 'Simple & Fast',
                  text:
                  'Designed for quick everyday business operations.',
                ),
                SizedBox(height: 16),
                _AboutRow(
                  icon: Icons.security_outlined,
                  title: 'Built with Security',
                  text:
                  'Your business information is handled with care.',
                ),
                SizedBox(height: 16),
                _AboutRow(
                  icon: Icons.auto_awesome_outlined,
                  title: 'Made for Growth',
                  text:
                  'Tools that help your business stay organized.',
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Column(
              children: [
                const Text(
                  'Made with care for modern businesses',
                  style: TextStyle(
                    color: StackFlowColors.secondaryText,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  '© ${DateTime.now().year} StackFlow',
                  style: const TextStyle(
                    color: StackFlowColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ================================================================
// REUSABLE WIDGETS
// ================================================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: StackFlowColors.text,
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;

  const _SettingsCard({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: StackFlowColors.border,
        ),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 13,
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: StackFlowColors.secondaryText,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: StackFlowColors.secondaryText,
              ),
          ],
        ),
      ),
    );
  }
}

class _SwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const _SwitchTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 9,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: StackFlowColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: StackFlowColors.primary,
              size: 21,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: StackFlowColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      indent: 68,
      endIndent: 14,
      color: StackFlowColors.border,
    );
  }
}

class _PictureOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _PictureOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFFF7F9FB),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: StackFlowColors.border,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: StackFlowColors.primary,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: const TextStyle(
                color: StackFlowColors.secondaryText,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;

  const _InputField({
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              size: 20,
              color: StackFlowColors.secondaryText,
            ),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: StackFlowColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: StackFlowColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(13),
              borderSide: const BorderSide(
                color: StackFlowColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFEAF7F5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFCBEDE8),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: StackFlowColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: StackFlowColors.secondaryText,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PreferenceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _PreferenceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: StackFlowColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: StackFlowColors.orange.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: StackFlowColors.orange,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: StackFlowColors.secondaryText,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _BackupHero extends StatelessWidget {
  final bool isEnabled;
  final VoidCallback onBackup;
  final bool isBackingUp;

  const _BackupHero({
    required this.isEnabled,
    required this.onBackup,
    required this.isBackingUp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF087FD1),
            Color(0xFF08AFA5),
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.cloud_done_outlined,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your data is protected',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Keep your StackFlow data backed up.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton.icon(
              onPressed: isBackingUp ? null : onBackup,
              icon: isBackingUp
                  ? const SizedBox(
                width: 17,
                height: 17,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: StackFlowColors.primary,
                ),
              )
                  : const Icon(
                Icons.cloud_upload_outlined,
              ),
              label: Text(
                isBackingUp
                    ? 'Backing up...'
                    : 'Backup Now',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: StackFlowColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                isEnabled
                    ? Icons.check_circle
                    : Icons.info_outline,
                size: 15,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                isEnabled
                    ? 'Automatic backup is ON'
                    : 'Automatic backup is OFF',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SupportActionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;

  const _SupportActionCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: StackFlowColors.border,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 23,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: StackFlowColors.secondaryText,
                    fontSize: 10,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 9),
                InkWell(
                  onTap: onTap,
                  child: Text(
                    buttonText,
                    style: TextStyle(
                      color: iconColor,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            color: StackFlowColors.secondaryText,
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: StackFlowColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: StackFlowColors.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: StackFlowColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: StackFlowColors.secondaryText,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _AboutRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: StackFlowColors.primary.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: StackFlowColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                text,
                style: const TextStyle(
                  color: StackFlowColors.secondaryText,
                  fontSize: 10,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}