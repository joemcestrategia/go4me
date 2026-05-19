import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/features/donor/data/feed_provider.dart';
import 'package:go4me/core/services/social_repository.dart';

class CreatePostPage extends ConsumerStatefulWidget {
  const CreatePostPage({super.key});

  @override
  ConsumerState<CreatePostPage> createState() => _CreatePostPageState();
}

class _CreatePostPageState extends ConsumerState<CreatePostPage> {
  final _textController = TextEditingController();
  final List<XFile> _selectedImages = [];
  bool _isPosting = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final picked = await picker.pickMultiImage(
      imageQuality: 70,
      maxWidth: 1080,
    );

    if (picked.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(picked);
        if (_selectedImages.length > 5) {
          _selectedImages.removeRange(5, _selectedImages.length);
        }
      });
    }
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 70,
      maxWidth: 1080,
    );
    if (picked != null) {
      setState(() {
        if (_selectedImages.length < 5) {
          _selectedImages.add(picked);
        }
      });
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _publishPost() async {
    final text = _textController.text.trim();
    if (text.isEmpty && _selectedImages.isEmpty) return;

    setState(() => _isPosting = true);

    try {
      final repository = ref.read(socialRepositoryProvider);
      
      List<String> mediaUrls = [];
      if (_selectedImages.isNotEmpty) {
        // Na Web passamos os XFiles diretamente ou o path universal
        mediaUrls = await repository.uploadPostImages(_selectedImages);
      }

      await repository.createPost(text, mediaUrls);

      if (mounted) {
        ref.invalidate(feedProvider);
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Publicado com sucesso!")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erro ao publicar: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final canPost = _textController.text.trim().isNotEmpty || _selectedImages.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text("Nova Publicação", style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isPosting || !canPost ? null : _publishPost,
            child: _isPosting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
              : Text("Publicar", style: GoogleFonts.inter(color: canPost ? AppTheme.primaryGreen : Colors.grey)),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _textController,
                    maxLines: null,
                    minLines: 5,
                    decoration: const InputDecoration(
                      hintText: "O que está acontecendo no campo missionário?",
                      border: InputBorder.none,
                    ),
                  ),
                  if (_selectedImages.isNotEmpty)
                    SizedBox(
                      height: 120,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _selectedImages.length,
                        itemBuilder: (context, index) => _buildImagePreview(index),
                      ),
                    ),
                ],
              ),
            ),
          ),
          _buildToolbar(),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          IconButton(onPressed: _pickImages, icon: Icon(Icons.photo_library, color: AppTheme.primaryGreen)),
          IconButton(onPressed: _takePhoto, icon: Icon(Icons.camera_alt, color: AppTheme.primaryGreen)),
        ],
      ),
    );
  }

  Widget _buildImagePreview(int index) {
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            image: DecorationImage(
              image: kIsWeb 
                ? NetworkImage(_selectedImages[index].path) as ImageProvider
                : const AssetImage('assets/images/placeholder.png'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 0,
          right: 8,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
