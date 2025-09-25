import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadTile extends StatefulWidget {
  final String description;
  final void Function(File file)? onImagePicked;
  final double maxMegabytes;
  final List<String> allowedExtensions;
  // Where to pick the image from. Use ImageSource.camera to capture.
  final ImageSource imageSource;
  // If using camera, choose which camera to open.
  final CameraDevice preferredCameraDevice;

  const ImageUploadTile({
    super.key,
    required this.description,
    this.onImagePicked,
    this.maxMegabytes = 10.0,
    this.allowedExtensions = const ["jpg", "jpeg", "png"],
    this.imageSource = ImageSource.gallery,
    this.preferredCameraDevice = CameraDevice.rear,
  });

  @override
  State<ImageUploadTile> createState() => _ImageUploadTileState();
}

class _ImageUploadTileState extends State<ImageUploadTile> {
  File? _selectedFile;
  String? _error;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    setState(() {
      _error = null;
    });

    final XFile? picked = await _picker.pickImage(
      source: widget.imageSource,
      preferredCameraDevice: widget.preferredCameraDevice,
    );
    if (picked == null) return;

    final File file = File(picked.path);
    final int bytes = await file.length();
    final double sizeMb = bytes / (1024 * 1024);

    final String ext = picked.path.split('.').last.toLowerCase();
    if (!widget.allowedExtensions.contains(ext)) {
      setState(() {
        _error = "Unsupported format. Allowed: ${widget.allowedExtensions.join(', ').toUpperCase()}";
      });
      return;
    }

    if (sizeMb > widget.maxMegabytes) {
      setState(() {
        _error = "File too large. Max ${widget.maxMegabytes.toStringAsFixed(0)} MB";
      });
      return;
    }

    setState(() {
      _selectedFile = file;
    });
    widget.onImagePicked?.call(file);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color borderColor = theme.dividerColor.withOpacity(0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(12),
              color: theme.colorScheme.surface,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.camera_alt_outlined, size: 28, color: theme.hintColor),
                const SizedBox(height: 8),
                Text(
                  widget.description,
                  style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  "JPEG, JPG and PNG formats, up to ${widget.maxMegabytes.toStringAsFixed(0)} MB.",
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
                  textAlign: TextAlign.center,
                ),
                if (_selectedFile != null) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedFile!,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(
            _error!,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }
}


