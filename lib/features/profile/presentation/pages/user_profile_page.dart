import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/core/services/user_profile_local_service.dart';
import 'package:quote_vault/core/utils/snackbar_utils.dart';
import 'package:quote_vault/features/auth/presentation/bloc/auth_bloc.dart';

class UserProfilePage extends StatefulWidget {
  final String userId;

  const UserProfilePage({super.key, required this.userId});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String? _avatarPath;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final path = await UserProfileLocalService.getAvatarPath(widget.userId);
    if (!mounted) return;
    setState(() => _avatarPath = path);
  }

  Future<void> _pickAndSaveAvatar() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (picked == null) return;

      final dir = await getApplicationDocumentsDirectory();
      final destPath = '${dir.path}/profile_avatar_${widget.userId}.jpg';
      final destFile = File(destPath);
      if (await destFile.exists()) {
        await destFile.delete();
      }
      final savedImage = await File(picked.path).readAsBytes();
      final saved = await destFile.writeAsBytes(savedImage);
      await UserProfileLocalService.setAvatarPath(widget.userId, saved.path);

      if (!mounted) return;
      final provider = FileImage(File(saved.path));
      await provider.evict();
      setState(() => _avatarPath = saved.path);
      if (mounted) {
        SnackbarUtils.showSuccess(context, AppStrings.profilePictureUpdated);
      }
    } catch (e) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        '${AppStrings.unableToUpdatePicture} $e',
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final fullName = authState is AuthAuthenticated
        ? authState.user.fullName
        : null;
    final email = authState is AuthAuthenticated ? authState.user.email : null;

    final avatarFile = (_avatarPath != null && File(_avatarPath!).existsSync())
        ? File(_avatarPath!)
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.profile)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: avatarFile != null
                      ? FileImage(avatarFile)
                      : null,
                  child: avatarFile == null
                      ? const Icon(Icons.person, size: 40)
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (fullName == null || fullName.trim().isEmpty)
                            ? AppStrings.user
                            : fullName.trim(),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (email != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _isSaving ? null : _pickAndSaveAvatar,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_camera),
              label: Text(
                _avatarPath == null
                    ? AppStrings.addProfilePicture
                    : AppStrings.changeProfilePicture,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
