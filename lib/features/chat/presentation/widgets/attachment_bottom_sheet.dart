import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../core/app_colors.dart';

class AttachmentBottomSheet extends StatelessWidget {
  const AttachmentBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          _buildOption(
            context,
            label: "Open Camera",
            icon: Icons.camera_alt_outlined,
            onTap: () async {
              try {
                if (kDebugMode) print("Opening Camera...");
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.camera);
                if (image != null) {
                  if (kDebugMode) print("Image picked: ${image.path}");
                  if (context.mounted) {
                    Navigator.pop(context, {'type': 'image', 'path': image.path});
                  }
                } else {
                  if (kDebugMode) print("Camera result: null");
                }
              } catch (e) {
                if (kDebugMode) print("Camera error: $e");
              }
            },
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            label: "Choose from Photos",
            icon: Icons.photo_library_outlined,
            onTap: () async {
              try {
                if (kDebugMode) print("Opening Gallery...");
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  if (kDebugMode) print("Photo picked: ${image.path}");
                  if (context.mounted) {
                    Navigator.pop(context, {'type': 'image', 'path': image.path});
                  }
                } else {
                  if (kDebugMode) print("Gallery result: null");
                }
              } catch (e) {
                if (kDebugMode) print("Gallery error: $e");
              }
            },
          ),
          const SizedBox(height: 12),
          _buildOption(
            context,
            label: "Browse Files",
            icon: Icons.folder_open_outlined,
            onTap: () async {
              try {
                if (kDebugMode) print("Opening File Picker...");
                final result = await FilePicker.platform.pickFiles();
                if (result != null && result.files.single.path != null) {
                  if (kDebugMode) print("File picked: ${result.files.single.path}");
                  if (context.mounted) {
                    Navigator.pop(context, {'type': 'file', 'path': result.files.single.path});
                  }
                } else {
                  if (kDebugMode) print("File picker result: null");
                }
              } catch (e) {
                if (kDebugMode) print("File picker error: $e");
              }
            },
          ),
          const SizedBox(height: 16),
          // Cancel Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937), // Dark grey from screenshot
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required String label,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFF9FAFB),
          foregroundColor: AppColors.textBlack,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
