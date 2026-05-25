import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/add_movie_provider.dart';

class AddMoviePage extends ConsumerStatefulWidget {
  const AddMoviePage({super.key});

  @override
  ConsumerState<AddMoviePage> createState() => _AddMoviePageState();
}

class _AddMoviePageState extends ConsumerState<AddMoviePage> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _posterController = TextEditingController();
  final _overviewController = TextEditingController();
  final _yearController = TextEditingController();
  final _languageController = TextEditingController();
  final _ratingController = TextEditingController();
  final _genresController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _posterController.dispose();
    _overviewController.dispose();
    _yearController.dispose();
    _languageController.dispose();
    _ratingController.dispose();
    _genresController.dispose();
    super.dispose();
  }

  String _generateId(String title) {
    return title.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final yearText = _yearController.text.trim();
      final year = yearText.isNotEmpty ? int.tryParse(yearText) : null;
      
      final ratingText = _ratingController.text.trim();
      final rating = ratingText.isNotEmpty ? double.tryParse(ratingText) : null;
      
      final genres = _genresController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final movieData = <String, dynamic>{};
      
      final title = _titleController.text.trim();
      if (title.isNotEmpty) {
        movieData['title'] = title;
        movieData['id'] = _generateId(title);
      } else {
        // If title is empty we can't generate an ID, but we have validation now or we can just fall back
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
        return;
      }

      if (_posterController.text.trim().isNotEmpty) {
        var poster = _posterController.text.trim();
        if (!poster.startsWith('/')) {
          poster = '/$poster';
        }
        movieData['poster'] = poster;
      }
      if (_overviewController.text.trim().isNotEmpty) movieData['overview'] = _overviewController.text.trim();
      
      if (year != null) movieData['year'] = year;
      if (_languageController.text.trim().isNotEmpty) movieData['language'] = _languageController.text.trim();
      if (rating != null) movieData['rating'] = rating;

      if (genres.isNotEmpty) movieData['genres'] = genres;

      final success = await ref.read(addMovieProvider.notifier).addMovie(movieData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Movie added successfully!')),
        );
        context.pop(); // Go back
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add movie.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(addMovieProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Movie'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title *', border: OutlineInputBorder()),
                  validator: (value) => value!.trim().isEmpty ? 'Title is required for ID generation' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _posterController,
                  decoration: const InputDecoration(labelText: 'Poster (e.g. premalu.jpg)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _overviewController,
                  decoration: const InputDecoration(labelText: 'Overview', border: OutlineInputBorder()),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _yearController,
                        decoration: const InputDecoration(labelText: 'Year', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _languageController,
                        decoration: const InputDecoration(labelText: 'Language', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ratingController,
                        decoration: const InputDecoration(labelText: 'Rating (e.g. 8.7)', border: OutlineInputBorder()),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _genresController,
                  decoration: const InputDecoration(labelText: 'Genres (comma separated)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Save Movie'),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
