import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../config/app_colors.dart';

class UploadCard extends StatefulWidget {
  final PlatformFile? selectedFile;
  final Function(PlatformFile) onFileSelected;
  final VoidCallback onClear;

  const UploadCard({
    super.key,
    required this.selectedFile,
    required this.onFileSelected,
    required this.onClear,
  });

  @override
  State<UploadCard> createState() => _UploadCardState();
}

class _UploadCardState extends State<UploadCard> {
  int _sheetCount = 0;
  bool _isLoadingSheets = false;

  @override
  void didUpdateWidget(UploadCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFile != oldWidget.selectedFile) {
      if (widget.selectedFile != null) {
        _parseSheetCount();
      } else {
        setState(() => _sheetCount = 0);
      }
    }
  }

  Future<void> _parseSheetCount() async {
    final file = widget.selectedFile;
    if (file == null) return;
    
    setState(() => _isLoadingSheets = true);

    try {
      List<int> bytes;
      if (file.bytes != null) {
        bytes = file.bytes!;
      } else if (file.path != null) {
        final ioFile = File(file.path!);
        bytes = await ioFile.readAsBytes();
      } else {
        bytes = [];
      }

      if (bytes.isNotEmpty) {
        // Fast signature scan to count unique worksheets in the XML zip
        final searchPattern = "xl/worksheets/sheet".codeUnits;
        final sheetIndices = <int>{};

        for (int i = 0; i < bytes.length - searchPattern.length; i++) {
          bool match = true;
          for (int j = 0; j < searchPattern.length; j++) {
            if (bytes[i + j] != searchPattern[j]) {
              match = false;
              break;
            }
          }
          if (match) {
            int numStart = i + searchPattern.length;
            int numEnd = numStart;
            while (numEnd < bytes.length && bytes[numEnd] >= 48 && bytes[numEnd] <= 57) {
              numEnd++;
            }
            if (numEnd > numStart) {
              final sheetNum = int.tryParse(String.fromCharCodes(bytes.sublist(numStart, numEnd)));
              if (sheetNum != null) {
                sheetIndices.add(sheetNum);
              }
            }
          }
        }
        
        setState(() {
          _sheetCount = sheetIndices.isEmpty ? 1 : sheetIndices.length;
          _isLoadingSheets = false;
        });
      } else {
        setState(() {
          _sheetCount = 1;
          _isLoadingSheets = false;
        });
      }
    } catch (e) {
      debugPrint("Error counting sheets: $e");
      setState(() {
        _sheetCount = 1;
        _isLoadingSheets = false;
      });
    }
  }

  String _formatSize(int bytes) {
    if (bytes <= 0) return "0 B";
    if (bytes < 1024) return "$bytes B";
    if (bytes < 1024 * 1024) return "${(bytes / 1024).toStringAsFixed(1)} KB";
    return "${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB";
  }

  Future<void> _pickExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
        withData: true, // required for web and safe for mobile
      );

      if (result != null && result.files.isNotEmpty) {
        widget.onFileSelected(result.files.first);
      }
    } catch (e) {
      debugPrint("Error picking file: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final file = widget.selectedFile;
    final isSelected = file != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isSelected ? Colors.green.shade200 : AppColors.slateGray.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      color: isSelected ? Colors.green.withOpacity(0.02) : AppColors.surface,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.file_present_outlined,
                  color: isSelected ? Colors.green : AppColors.deepNavy,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  "رفع ملف الإجابات",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.deepNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (!isSelected)
              InkWell(
                onTap: _pickExcelFile,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      top: BorderSide(color: AppColors.slateGray.withOpacity(0.1)),
                      bottom: BorderSide(color: AppColors.slateGray.withOpacity(0.1)),
                      left: BorderSide(color: AppColors.slateGray.withOpacity(0.1)),
                      right: BorderSide(color: AppColors.slateGray.withOpacity(0.1)),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: AppColors.slateGray,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        "اختر ملف Excel يحتوي على الحلول",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.deepNavy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "يقبل صيغة .xlsx فقط",
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.slateGray,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.table_chart,
                        color: Colors.green,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            file.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepNavy,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.storage_outlined,
                                size: 14,
                                color: AppColors.slateGray,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatSize(file.size),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.slateGray,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.copy_all_outlined,
                                size: 14,
                                color: AppColors.slateGray,
                              ),
                              const SizedBox(width: 4),
                              _isLoadingSheets
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation(Colors.green),
                                      ),
                                    )
                                  : Text(
                                      "$_sheetCount Sheets",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: AppColors.slateGray,
                                      ),
                                    ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: widget.onClear,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
