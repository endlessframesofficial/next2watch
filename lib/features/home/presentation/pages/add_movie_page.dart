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
  final _moodsController = TextEditingController();
  final _collectionsController = TextEditingController();
  final _ottPlatformController = TextEditingController();
  final _ottReleaseDateController = TextEditingController();

  bool _isTrending = false;
  bool _isEditorsPick = false;

  @override
  void dispose() {
    _titleController.dispose();
    _posterController.dispose();
    _overviewController.dispose();
    _yearController.dispose();
    _languageController.dispose();
    _ratingController.dispose();
    _genresController.dispose();
    _moodsController.dispose();
    _collectionsController.dispose();
    _ottPlatformController.dispose();
    _ottReleaseDateController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    // Form is always valid since all fields are optional
    if (_formKey.currentState!.validate()) {
      final yearText = _yearController.text.trim();
      final year = yearText.isNotEmpty ? int.tryParse(yearText) : null;
      
      final ratingText = _ratingController.text.trim();
      final rating = ratingText.isNotEmpty ? double.tryParse(ratingText) : null;
      
      // Parse comma separated lists
      final genres = _genresController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final moods = _moodsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      final collections = _collectionsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final movieData = <String, dynamic>{};

      if (_titleController.text.trim().isNotEmpty) movieData['title'] = _titleController.text.trim();
      if (_posterController.text.trim().isNotEmpty) movieData['poster'] = _posterController.text.trim();
      if (_overviewController.text.trim().isNotEmpty) movieData['overview'] = _overviewController.text.trim();
      
      if (year != null) movieData['year'] = year;
      if (_languageController.text.trim().isNotEmpty) movieData['language'] = _languageController.text.trim();
      if (rating != null) movieData['rating'] = rating;

      if (genres.isNotEmpty) movieData['genres'] = genres;
      if (moods.isNotEmpty) movieData['moods'] = moods;
      if (collections.isNotEmpty) movieData['collections'] = collections;

      if (_ottPlatformController.text.trim().isNotEmpty) movieData['ottPlatform'] = _ottPlatformController.text.trim();
      if (_ottReleaseDateController.text.trim().isNotEmpty) movieData['ottReleaseDate'] = _ottReleaseDateController.text.trim();

      movieData['isTrending'] = _isTrending;
      movieData['isEditorsPick'] = _isEditorsPick;

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
                  decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _posterController,
                  decoration: const InputDecoration(labelText: 'Poster (e.g. /premalu.jpg)', border: OutlineInputBorder()),
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
                const SizedBox(height: 16),
                TextFormField(
                  controller: _moodsController,
                  decoration: const InputDecoration(labelText: 'Moods (comma separated)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _collectionsController,
                  decoration: const InputDecoration(labelText: 'Collections (comma separated)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _ottPlatformController,
                        decoration: const InputDecoration(labelText: 'OTT Platform', border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _ottReleaseDateController,
                        decoration: const InputDecoration(labelText: 'OTT Release Date', border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Is Trending'),
                  value: _isTrending,
                  onChanged: (val) => setState(() => _isTrending = val),
                  contentPadding: EdgeInsets.zero,
                ),
                SwitchListTile(
                  title: const Text('Is Editor\'s Pick'),
                  value: _isEditorsPick,
                  onChanged: (val) => setState(() => _isEditorsPick = val),
                  contentPadding: EdgeInsets.zero,
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
