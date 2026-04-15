// ignore_for_file: unused_element, no_leading_underscores_for_local_identifiers, unnecessary_nullable_for_final_variable_declarations, avoid_print

import 'package:cjb/pages/main/home/home_page.dart';
import 'package:cjb/services/cloudinary_upload_service.dart';
import 'package:cjb/services/jobs_service.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';

class CreatePostPage extends StatefulWidget {
  final VoidCallback? onPostSuccess;

  const CreatePostPage({Key? key, this.onPostSuccess}) : super(key: key);

  @override
  _CreatePostPageState createState() => _CreatePostPageState();
}

class _CreatePostPageState extends State<CreatePostPage> {
  final _descriptionController = TextEditingController();
  List<String> postImages = [];
  File? videoFile;
  bool _submitting = false;

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickPostImage() async {
    final ImagePicker _picker = ImagePicker();
    final List<XFile>? selectedImages = await _picker.pickMultiImage();

    if (selectedImages != null) {
      for (var image in selectedImages) {
        setState(() {
          postImages.add(image.path);
        });
      }
      print('Selected images: $postImages');
    }
  }

  Future<void> _pickPostVideo() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? selectedVideo =
        await _picker.pickVideo(source: ImageSource.gallery);

    if (selectedVideo != null) {
      setState(() {
        videoFile = File(selectedVideo.path);
      });
      print('Selected video: ${videoFile!.path}');
    }
  }

  Future<void> _submitPost() async {
    if (_submitting) return;

    final description = _descriptionController.text.trim();
    if (description.isEmpty && postImages.isEmpty && videoFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please add some content to your post.')),
      );
      return;
    }

    setState(() => _submitting = true);

    try {
      List<String> mediaUrls = [];

      // Upload images
      for (String imagePath in postImages) {
        final imageUrl = await CloudinaryUploadService.uploadFile(
          filePath: imagePath,
          folder: 'posts',
        );
        mediaUrls.add(imageUrl);
      }

      // Upload video if any
      if (videoFile != null) {
        final videoUrl = await CloudinaryUploadService.uploadFile(
          filePath: videoFile!.path,
          folder: 'posts',
        );
        mediaUrls.add(videoUrl);
      }

      // Use the first media URL as the main image URL for the job/post
      final mainImageUrl = mediaUrls.isNotEmpty ? mediaUrls.first : '';

      // Create a job/post
      await JobsService.instance.createJob(
        title: description.length > 50
            ? '${description.substring(0, 50)}...'
            : description,
        company: 'Campus Community', // Or get from user profile
        location: 'Campus',
        category: 'Post',
        description: description,
        requirements: '',
        employmentType: 'General',
        imageUrl: mainImageUrl,
      );

      // Clear the form
      _descriptionController.clear();
      setState(() {
        postImages.clear();
        videoFile = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Post created successfully!')),
      );

      // Navigate back or to home
      widget.onPostSuccess?.call();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
        (route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to create post: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9F9F9),
      appBar: AppBar(
        title: Text(
          'Create Post',
          style: GoogleFonts.dmSans(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF150B3D),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Color(0xFF150B3D)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : _submitPost,
            child: _submitting
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Post',
                    style: GoogleFonts.dmSans(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Color(0xFF0066CC),
                    ),
                  ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Description input
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'What\'s on your mind?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Color(0xFF0066CC)),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 20),

            // Media selection buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickPostImage,
                    icon: Icon(Icons.photo_library),
                    label: Text('Add Photos'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF150B3D),
                      elevation: 0,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _pickPostVideo,
                    icon: Icon(Icons.video_library),
                    label: Text('Add Video'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Color(0xFF150B3D),
                      elevation: 0,
                      side: BorderSide(color: Colors.grey.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Selected images preview
            if (postImages.isNotEmpty) ...[
              Text(
                'Selected Images (${postImages.length})',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF150B3D),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: postImages.map((imagePath) {
                  return Stack(
                    children: [
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          image: DecorationImage(
                            image: FileImage(File(imagePath)),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              postImages.remove(imagePath);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // Selected video preview
            if (videoFile != null) ...[
              Text(
                'Selected Video',
                style: GoogleFonts.dmSans(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: Color(0xFF150B3D),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade200,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.video_file,
                        size: 48,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Video selected',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            videoFile = null;
                          });
                        },
                        child: Text('Remove'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
