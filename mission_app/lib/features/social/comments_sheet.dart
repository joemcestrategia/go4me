import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/features/donor/data/feed_provider.dart';
import 'package:go4me/core/models/social_models.dart';
import 'package:go4me/core/services/social_repository.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;
  const CommentsSheet({super.key, required this.postId});

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsProvider(widget.postId));
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Comentários',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: AppTheme.textDark,
              ),
            ),
          ),

          Divider(height: 1, color: Colors.grey[200]),

          Expanded(
            child: commentsAsync.when(
              data: (comments) => comments.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      itemCount: comments.length,
                      itemBuilder: (context, index) => _buildCommentRow(comments[index]),
                    ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(child: Text('Erro ao carregar: $err')),
            ),
          ),

          // Input Area
          Container(
            padding: EdgeInsets.fromLTRB(12, 8, 12, bottomInset + 12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: Colors.grey[200]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(24),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      decoration: const InputDecoration(
                        hintText: 'Adicione um comentário...',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _submitComment(),
                    ),
                  ),
                ),
                if (_isSubmitting)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                  )
                else
                  TextButton(
                    onPressed: _submitComment,
                    child: Text(
                      'Publicar',
                      style: GoogleFonts.inter(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: Colors.grey[200]),
          const SizedBox(height: 12),
          Text('Nenhum comentário ainda.', style: GoogleFonts.inter(color: Colors.grey[400])),
        ],
      ),
    );
  }

  Widget _buildCommentRow(SocialComment comment) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: comment.author?.avatarUrl != null 
                ? NetworkImage(comment.author!.avatarUrl!) 
                : null,
            child: comment.author?.avatarUrl == null ? const Icon(Icons.person, size: 20) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: GoogleFonts.inter(color: AppTheme.textDark, fontSize: 13),
                    children: [
                      TextSpan(
                        text: '${comment.author?.fullName ?? 'Usuário'} ',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: comment.content),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Ontem', // Simplificado por enquanto ou usar diff real
                  style: GoogleFonts.inter(color: Colors.grey[400], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isSubmitting) return;

    setState(() => _isSubmitting = true);
    
    try {
      final repository = ref.read(socialRepositoryProvider);
      await repository.addComment(widget.postId, text);
      _controller.clear();
      _focusNode.unfocus();
      // Invalida o provider para recarregar os comentários
      ref.invalidate(commentsProvider(widget.postId));
      // Invalida o feed para atualizar a contagem de comentários (opcional, mas bom)
      ref.invalidate(feedProvider);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao comentar: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }
}
