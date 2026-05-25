import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/add_collection_provider.dart';

class AddCollectionPage extends ConsumerStatefulWidget {
  const AddCollectionPage({super.key});

  @override
  ConsumerState<AddCollectionPage> createState() => _AddCollectionPageState();
}

class _AddCollectionPageState extends ConsumerState<AddCollectionPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bannerController = TextEditingController();
  final _typeController = TextEditingController();
  final _languageController = TextEditingController();
  final _orderController = TextEditingController();
  final _movieIdsController = TextEditingController();

  bool _isFeatured = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _bannerController.dispose();
    _typeController.dispose();
    _languageController.dispose();
    _orderController.dispose();
    _movieIdsController.dispose();
    super.dispose();
  }

  String _generateId(String title) {
    return title.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final orderText = _orderController.text.trim();
      final order = orderText.isNotEmpty ? int.tryParse(orderText) : null;
      
      final movieIds = _movieIdsController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();

      final collectionData = <String, dynamic>{};
      
      final title = _titleController.text.trim();
      if (title.isNotEmpty) {
        collectionData['title'] = title;
        collectionData['id'] = _generateId(title);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Title is required')));
        return;
      }

      if (_descriptionController.text.trim().isNotEmpty) collectionData['description'] = _descriptionController.text.trim();
      
      if (_bannerController.text.trim().isNotEmpty) {
        var banner = _bannerController.text.trim();
        if (!banner.startsWith('http') && !banner.startsWith('/')) {
          banner = '/$banner'; // auto prepend slash if it's just a filename
        }
        collectionData['banner'] = banner;
      }

      if (_typeController.text.trim().isNotEmpty) collectionData['type'] = _typeController.text.trim();
      if (_languageController.text.trim().isNotEmpty) collectionData['language'] = _languageController.text.trim();
      if (order != null) collectionData['order'] = order;
      if (movieIds.isNotEmpty) collectionData['movieIds'] = movieIds;
      
      collectionData['isFeatured'] = _isFeatured;

      final success = await ref.read(addCollectionProvider.notifier).addCollection(collectionData);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Collection added successfully!')),
        );
        context.pop(); // Go back
      } else if (!success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to add collection.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(addCollectionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Collection'),
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
                  decoration: const InputDecoration(labelText: 'Collection Title *', border: OutlineInputBorder()),
                  validator: (value) => value!.trim().isEmpty ? 'Title is required for ID generation' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _bannerController,
                  decoration: const InputDecoration(labelText: 'Banner URL/Path', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _typeController,
                        decoration: const InputDecoration(labelText: 'Type (e.g. feel_good)', border: OutlineInputBorder()),
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
                        controller: _orderController,
                        decoration: const InputDecoration(labelText: 'Order (e.g. 1)', border: OutlineInputBorder()),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _movieIdsController,
                  decoration: const InputDecoration(labelText: 'Movie IDs (comma separated)', border: OutlineInputBorder(), hintText: 'premalu, hridayam, bangalore_days'),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Is Featured'),
                  value: _isFeatured,
                  onChanged: (val) => setState(() => _isFeatured = val),
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
                      : const Text('Save Collection'),
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
