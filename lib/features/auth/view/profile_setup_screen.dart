// lib/features/auth/view/profile_setup_screen.dart

// lib/features/auth/view/profile_setup_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:random_avatar/random_avatar.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:ui' as ui;

import '../../../core/services/file_upload/file_upload_service.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/file_picker_util.dart';
import '../../../core/utils/image_compress_util.dart';
import '../../../core/widget/custom_app_text.dart';
import '../../../core/widget/custom_base_widget.dart';
import '../../../core/widget/custom_button.dart';
import '../../../core/widget/custom_text_field.dart';
import '../../../core/widget/custom_image_widget.dart';
import '../../../routes/route_helper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();

  // GlobalKey for capturing avatar as image
  final GlobalKey _avatarKey = GlobalKey();

  File? _selectedImageFile;
  String? _selectedAvatarSeed;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;

  // Generate 500+ unique random avatars
  final List<String> _defaultAvatarSeeds = List.generate(
    500,
        (index) => 'user_${index}_${DateTime.now().millisecondsSinceEpoch}',
  );

  late FileUploadService _fileUploadService;

  @override
  void initState() {
    super.initState();
    _fileUploadService = FileUploadService(
      apiClient: context.read<ApiClient>(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  // Convert widget to image using RepaintBoundary
  Future<File?> _captureAvatarAsImage() async {
    try {
      print('📸 Capturing avatar as image...');

      // Wait for widget to be rendered
      await Future.delayed(const Duration(milliseconds: 100));

      // Get render object
      RenderRepaintBoundary? boundary = _avatarKey.currentContext
          ?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        print('❌ Boundary is null');
        return null;
      }

      // Capture image
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData =
      await image.toByteData(format: ui.ImageByteFormat.png);

      if (byteData == null) {
        print('❌ ByteData is null');
        return null;
      }

      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Save to temporary file
      final tempDir = await getTemporaryDirectory();
      final file = File(
          '${tempDir.path}/avatar_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(pngBytes);

      print('✅ Avatar captured: ${file.path}');
      print('✅ File size: ${(file.lengthSync() / 1024).toStringAsFixed(2)} KB');

      return file;
    } catch (e) {
      print('❌ Error capturing avatar: $e');
      return null;
    }
  }

  // Upload image and complete profile
  Future<void> _onComplete() async {
    if (_formKey.currentState!.validate()) {
      String? avatarUrl;

      setState(() {
        _isUploadingImage = true;
        _uploadProgress = 0.0;
      });

      // If user selected an image file, upload it
      if (_selectedImageFile != null) {
        final uploadResponse = await _fileUploadService.uploadProfileImage(
          file: _selectedImageFile!,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );

        if (uploadResponse.success && uploadResponse.data != null) {
          avatarUrl = uploadResponse.data!.first.url;
          CustomSnackbar.showSuccess(message: 'Image uploaded successfully');
        } else {
          setState(() {
            _isUploadingImage = false;
          });
          CustomSnackbar.showError(
            message: uploadResponse.message ?? 'Failed to upload image',
          );
          return;
        }
      }
      // If user selected an avatar, capture and upload it
      else if (_selectedAvatarSeed != null) {
        CustomSnackbar.showInfo(message: 'Preparing avatar...');

        // Capture avatar as image
        final avatarFile = await _captureAvatarAsImage();

        if (avatarFile != null) {
          // Upload the captured avatar image
          final uploadResponse = await _fileUploadService.uploadProfileImage(
            file: avatarFile,
            onProgress: (progress) {
              setState(() {
                _uploadProgress = progress;
              });
            },
          );

          if (uploadResponse.success && uploadResponse.data != null) {
            avatarUrl = uploadResponse.data!.first.url;
            CustomSnackbar.showSuccess(
                message: 'Avatar uploaded successfully');

            // Clean up temporary file
            try {
              await avatarFile.delete();
            } catch (e) {
              print('⚠️ Failed to delete temp file: $e');
            }
          } else {
            setState(() {
              _isUploadingImage = false;
            });
            CustomSnackbar.showError(
              message: uploadResponse.message ?? 'Failed to upload avatar',
            );
            return;
          }
        } else {
          setState(() {
            _isUploadingImage = false;
          });
          CustomSnackbar.showError(message: 'Failed to prepare avatar');
          return;
        }
      }

      setState(() {
        _isUploadingImage = false;
      });

      // Complete profile with avatar URL
      context.read<AuthBloc>().add(
        CompleteProfileEvent(
          name: _nameController.text.trim(),
          about: _aboutController.text.trim().isNotEmpty
              ? _aboutController.text.trim()
              : null,
          avatar: avatarUrl,
        ),
      );
    }
  }

  // Show bottom sheet for image source selection
  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 12.w,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                CustomAppText(
                  'Select Profile Photo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3.h),
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Use camera to take a photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                  colorScheme: colorScheme,
                ),
                SizedBox(height: 2.h),
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  title: 'Choose from Gallery',
                  subtitle: 'Select from your photos',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                  colorScheme: colorScheme,
                ),
                SizedBox(height: 2.h),
                _buildImageSourceOption(
                  icon: Icons.person,
                  title: 'Choose Avatar',
                  subtitle: 'Select from 500+ avatars',
                  onTap: () {
                    Navigator.pop(context);
                    _showAvatarSelectionBottomSheet();
                  },
                  colorScheme: colorScheme,
                ),
                SizedBox(height: 2.h),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: CustomAppText(
                    'Cancel',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
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

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppText(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  CustomAppText(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 4.w,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  // Show avatar selection bottom sheet
  void _showAvatarSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.5,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SafeArea(
              child: Column(
                children: [
                  Container(
                    width: 12.w,
                    height: 4,
                    margin: EdgeInsets.symmetric(vertical: 1.h),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomAppText(
                          'Choose an Avatar',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 2.w,
                            vertical: 0.5.h,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: CustomAppText(
                            '${_defaultAvatarSeeds.length}+',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Expanded(
                    child: GridView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 2.w,
                        mainAxisSpacing: 1.5.h,
                        childAspectRatio: 1,
                      ),
                      itemCount: _defaultAvatarSeeds.length,
                      itemBuilder: (context, index) {
                        final avatarSeed = _defaultAvatarSeeds[index];
                        final isSelected = _selectedAvatarSeed == avatarSeed;

                        return TweenAnimationBuilder<double>(
                          duration: Duration(
                            milliseconds: 300 + (index % 10) * 50,
                          ),
                          tween: Tween(begin: 0.0, end: 1.0),
                          curve: Curves.easeOutBack,
                          builder: (context, value, child) {
                            final clampedValue = value.clamp(0.0, 1.0);

                            return Transform.scale(
                              scale: clampedValue,
                              child: Opacity(
                                opacity: clampedValue,
                                child: child,
                              ),
                            );
                          },
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAvatarSeed = avatarSeed;
                                _selectedImageFile = null;
                              });
                              Navigator.pop(context);
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                                boxShadow: isSelected
                                    ? [
                                  BoxShadow(
                                    color: colorScheme.primary
                                        .withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  )
                                ]
                                    : null,
                              ),
                              child: ClipOval(
                                child: RandomAvatar(
                                  avatarSeed,
                                  height: 80,
                                  width: 80,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(2.w),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: CustomAppText(
                        'Cancel',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pickImageFromCamera() async {
    final file = await FilePickerUtil.pickImageFromCamera(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (file != null) {
      final compressedFile = await ImageCompressUtil.compressImage(
        file,
        quality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      setState(() {
        _selectedImageFile = compressedFile ?? file;
        _selectedAvatarSeed = null;
      });

      // CustomSnackbar.showSuccess(message: 'Photo captured successfully');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final file = await FilePickerUtil.pickImageFromGallery(
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (file != null) {
        final compressedFile = await ImageCompressUtil.compressImage(
          file,
          quality: 85,
          maxWidth: 1024,
          maxHeight: 1024,
        );

        setState(() {
          _selectedImageFile = compressedFile ?? file;
          _selectedAvatarSeed = null;
        });

        // CustomSnackbar.showSuccess(message: 'Image selected successfully');
      }
    } catch (e) {
      print('❌ Gallery picker error: $e');
      CustomSnackbar.showError(message: 'Failed to pick image from gallery');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomBaseWidget(
      useSafeArea: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            CustomSnackbar.showSuccess(message: 'Profile setup complete!');
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteHelper.getHomeRoute(),
                  (route) => false,
            );
          } else if (state is ProfileSetupError) {
            CustomSnackbar.showError(message: state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileUpdating || _isUploadingImage;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 6.h),
                  CustomAppText(
                    'Complete Your Profile',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  CustomAppText(
                    'Help others recognize you',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Profile Image Picker with RepaintBoundary
                  GestureDetector(
                    onTap: isLoading ? null : _showImageSourceBottomSheet,
                    child: Stack(
                      children: [
                        RepaintBoundary(
                          key: _avatarKey,
                          child: Container(
                            width: 30.w,
                            height: 30.w,
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.1),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: colorScheme.primary,
                                width: 2,
                              ),
                            ),
                            child: ClipOval(
                              child: _selectedImageFile != null
                                  ? CustomImageWidget(
                                imagePath: _selectedImageFile!.path,
                                width: 30.w,
                                height: 30.w,
                                fit: BoxFit.cover,
                              )
                                  : _selectedAvatarSeed != null
                                  ? RandomAvatar(
                                _selectedAvatarSeed!,
                                height: 200,
                                width: 200,
                              )
                                  : Icon(
                                Icons.camera_alt,
                                size: 12.w,
                                color: colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                        if (_isUploadingImage)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      value: _uploadProgress,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 1.h),
                                    CustomAppText(
                                      '${(_uploadProgress * 100).toInt()}%',
                                      style:
                                      theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        if (!_isUploadingImage)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 4.w,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 1.h),
                  CustomAppText(
                    'Tap to add photo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    labelText: 'Full Name *',
                    keyboardType: TextInputType.name,
                    validator: AppValidators.validateName,
                    enabled: !isLoading,
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  CustomTextField(
                    controller: _aboutController,
                    hintText: 'About yourself (Optional)',
                    labelText: 'About',
                    keyboardType: TextInputType.multiline,
                    maxLength: 150,
                    enabled: !isLoading,
                    prefixIcon: Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),

                  CustomButton(
                    onPressed: isLoading ? null : _onComplete,
                    text: _isUploadingImage
                        ? 'Uploading...'
                        : 'Complete Setup',
                    isLoading: isLoading,
                    width: double.infinity,
                  ),
                  SizedBox(height: 2.h),

                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteHelper.getHomeRoute(),
                            (route) => false,
                      );
                    },
                    child: CustomAppText(
                      'Skip for now',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}


/*
// lib/features/auth/view/profile_setup_screen.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/services/file_upload/file_upload_service.dart';
import '../../../core/services/network/api_client.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/utils/file_picker_util.dart';
import '../../../core/utils/image_compress_util.dart';
import '../../../core/widget/custom_app_text.dart';
import '../../../core/widget/custom_base_widget.dart';
import '../../../core/widget/custom_button.dart';
import '../../../core/widget/custom_text_field.dart';
import '../../../routes/route_helper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({Key? key}) : super(key: key);

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _aboutController = TextEditingController();

  File? _selectedImageFile;
  String? _selectedAvatarUrl;
  bool _isUploadingImage = false;
  double _uploadProgress = 0.0;

  // Default avatars (you can add more)
  final List<String> _defaultAvatars = [
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Aneka',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Charlie',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Daisy',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Max',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Sophie',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Oliver',
    'https://api.dicebear.com/7.x/avataaars/svg?seed=Luna',
  ];

  late FileUploadService _fileUploadService;

  @override
  void initState() {
    super.initState();
    _fileUploadService = FileUploadService(
      apiClient: context.read<ApiClient>(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _aboutController.dispose();
    super.dispose();
  }

  // Show bottom sheet for image source selection
  void _showImageSourceBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 12.w,
                  height: 4,
                  margin: EdgeInsets.only(bottom: 2.h),
                  decoration: BoxDecoration(
                    color: colorScheme.onSurface.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Title
                CustomAppText(
                  'Select Profile Photo',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 3.h),

                // Camera Option
                _buildImageSourceOption(
                  icon: Icons.camera_alt,
                  title: 'Take Photo',
                  subtitle: 'Use camera to take a photo',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                  colorScheme: colorScheme,
                ),

                SizedBox(height: 2.h),

                // Gallery Option
                _buildImageSourceOption(
                  icon: Icons.photo_library,
                  title: 'Choose from Gallery',
                  subtitle: 'Select from your photos',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                  colorScheme: colorScheme,
                ),

                SizedBox(height: 2.h),

                // Avatar Option
                _buildImageSourceOption(
                  icon: Icons.person,
                  title: 'Choose Avatar',
                  subtitle: 'Select from default avatars',
                  onTap: () {
                    Navigator.pop(context);
                    _showAvatarSelectionBottomSheet();
                  },
                  colorScheme: colorScheme,
                ),

                SizedBox(height: 2.h),

                // Cancel button
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: CustomAppText(
                    'Cancel',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: colorScheme.error,
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

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: colorScheme.primary,
                size: 6.w,
              ),
            ),
            SizedBox(width: 3.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomAppText(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 0.5.h),
                  CustomAppText(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 4.w,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  // Show avatar selection bottom sheet
  void _showAvatarSelectionBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // 🔥 VERY IMPORTANT
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;

        return SafeArea(
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.7,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Padding(
                padding: EdgeInsets.all(4.w),
                child: Column(
                  children: [
                    // Handle bar
                    Container(
                      width: 12.w,
                      height: 4,
                      margin: EdgeInsets.only(bottom: 2.h),
                      decoration: BoxDecoration(
                        color: colorScheme.onSurface.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Title
                    CustomAppText(
                      'Choose an Avatar',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 2.h),

                    // Avatar Grid (Scrollable)
                    Expanded(
                      child: GridView.builder(
                        controller: scrollController,
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 4,
                          crossAxisSpacing: 3.w,
                          mainAxisSpacing: 2.h,
                        ),
                        itemCount: _defaultAvatars.length,
                        itemBuilder: (context, index) {
                          final avatarUrl = _defaultAvatars[index];
                          final isSelected =
                              _selectedAvatarUrl == avatarUrl;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedAvatarUrl = avatarUrl;
                                _selectedImageFile = null;
                              });
                              Navigator.pop(context);
                              CustomSnackbar.showSuccess(
                                message: 'Avatar selected',
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isSelected
                                      ? colorScheme.primary
                                      : Colors.transparent,
                                  width: 3,
                                ),
                              ),
                              child: ClipOval(
                                child: Image.network(
                                  avatarUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (context, error, stackTrace) {
                                    return Icon(
                                      Icons.person,
                                      size: 10.w,
                                      color: colorScheme.primary,
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    SizedBox(height: 1.h),

                    // Cancel button
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: CustomAppText(
                        'Cancel',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }


  // Pick image from camera
  Future<void> _pickImageFromCamera() async {
    final file = await FilePickerUtil.pickImageFromCamera(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (file != null) {
      // Compress image
      final compressedFile = await ImageCompressUtil.compressImage(
        file,
        quality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      setState(() {
        _selectedImageFile = compressedFile ?? file;
        _selectedAvatarUrl = null; // Clear avatar selection
      });

      CustomSnackbar.showSuccess(message: 'Photo captured successfully');
    }
  }

  // Pick image from gallery
  Future<void> _pickImageFromGallery() async {
    final file = await FilePickerUtil.pickImageFromGallery(
      imageQuality: 85,
      maxWidth: 1024,
      maxHeight: 1024,
    );

    if (file != null) {
      // Compress image
      final compressedFile = await ImageCompressUtil.compressImage(
        file,
        quality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      setState(() {
        _selectedImageFile = compressedFile ?? file;
        _selectedAvatarUrl = null; // Clear avatar selection
      });

      CustomSnackbar.showSuccess(message: 'Image selected successfully');
    }
  }

  // Upload image and complete profile
  Future<void> _onComplete() async {
    if (_formKey.currentState!.validate()) {
      String? avatarUrl;

      // If user selected an image file, upload it first
      if (_selectedImageFile != null) {
        setState(() {
          _isUploadingImage = true;
          _uploadProgress = 0.0;
        });

        final uploadResponse = await _fileUploadService.uploadProfileImage(
          file: _selectedImageFile!,
          onProgress: (progress) {
            setState(() {
              _uploadProgress = progress;
            });
          },
        );

        setState(() {
          _isUploadingImage = false;
        });

        if (uploadResponse.success && uploadResponse.data != null) {
          avatarUrl = uploadResponse.data!.first.url;
          CustomSnackbar.showSuccess(message: 'Image uploaded successfully');
        } else {
          CustomSnackbar.showError(
            message: uploadResponse.message ?? 'Failed to upload image',
          );
          return;
        }
      } else if (_selectedAvatarUrl != null) {
        // Use selected avatar URL
        avatarUrl = _selectedAvatarUrl;
      }

      // Complete profile with avatar URL
      context.read<AuthBloc>().add(
        CompleteProfileEvent(
          name: _nameController.text.trim(),
          about: _aboutController.text.trim().isNotEmpty
              ? _aboutController.text.trim()
              : null,
          avatar: avatarUrl,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomBaseWidget(
      useSafeArea: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            CustomSnackbar.showSuccess(message: 'Profile setup complete!');
            Navigator.pushNamedAndRemoveUntil(
              context,
              RouteHelper.getHomeRoute(),
                  (route) => false,
            );
          } else if (state is ProfileSetupError) {
            CustomSnackbar.showError(message: state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is ProfileUpdating || _isUploadingImage;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 6.h),

                  // Title
                  CustomAppText(
                    'Complete Your Profile',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  CustomAppText(
                    'Help others recognize you',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Profile Image Picker
                  GestureDetector(
                    onTap: isLoading ? null : _showImageSourceBottomSheet,
                    child: Stack(
                      children: [
                        Container(
                          width: 30.w,
                          height: 30.w,
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          child: ClipOval(
                            child: _selectedImageFile != null
                                ? Image.file(
                              _selectedImageFile!,
                              fit: BoxFit.cover,
                            )
                                : _selectedAvatarUrl != null
                                ? Image.network(
                              _selectedAvatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (context, error, stackTrace) {
                                return Icon(
                                  Icons.person,
                                  size: 12.w,
                                  color: colorScheme.primary,
                                );
                              },
                            )
                                : Icon(
                              Icons.camera_alt,
                              size: 12.w,
                              color: colorScheme.primary,
                            ),
                          ),
                        ),

                        // Upload progress indicator
                        if (_isUploadingImage)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircularProgressIndicator(
                                      value: _uploadProgress,
                                      color: Colors.white,
                                    ),
                                    SizedBox(height: 1.h),
                                    CustomAppText(
                                      '${(_uploadProgress * 100).toInt()}%',
                                      style:
                                      theme.textTheme.bodySmall?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        // Edit icon
                        if (!_isUploadingImage)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: colorScheme.surface,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.edit,
                                size: 4.w,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  SizedBox(height: 1.h),

                  CustomAppText(
                    'Tap to add photo',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Name Field (Required)
                  CustomTextField(
                    controller: _nameController,
                    hintText: 'Full Name',
                    labelText: 'Full Name *',
                    keyboardType: TextInputType.name,
                    validator: AppValidators.validateName,
                    enabled: !isLoading,
                    prefixIcon: Icon(
                      Icons.person_outline,
                      color: colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 2.h),

                  // About Field (Optional)
                  CustomTextField(
                    controller: _aboutController,
                    hintText: 'About yourself (Optional)',
                    labelText: 'About',
                    keyboardType: TextInputType.multiline,
                    maxLength: 150,
                    enabled: !isLoading,
                    prefixIcon: Icon(
                      Icons.info_outline,
                      color: colorScheme.primary,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Complete Button
                  CustomButton(
                    onPressed: isLoading ? null : _onComplete,
                    text: _isUploadingImage
                        ? 'Uploading...'
                        : 'Complete Setup',
                    isLoading: isLoading,
                    width: double.infinity,
                  ),

                  SizedBox(height: 2.h),

                  // Skip Button
                  TextButton(
                    onPressed: isLoading
                        ? null
                        : () {
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        RouteHelper.getHomeRoute(),
                            (route) => false,
                      );
                    },
                    child: CustomAppText(
                      'Skip for now',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}*/
