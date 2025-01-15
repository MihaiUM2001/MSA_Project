import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:swappy_frontend/components/product_card_search.dart';
import '../components/custom_app_bar.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../components/product_card.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final ProductService productService = ProductService();
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  List<String> _searchHistory = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchController.addListener(_handleTypingSearch);
  }

  @override
  void dispose() {
    _searchController.removeListener(_handleTypingSearch);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  Future<void> _saveSearchQuery(String query) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_searchHistory.contains(query)) {
      _searchHistory.insert(0, query); // Insert at the top of the list
      await prefs.setStringList('searchHistory', _searchHistory);
    }
  }

  void _performSearch(String query, {bool addToHistory = false}) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await productService.searchProducts(query);

      if (addToHistory) {
        await _saveSearchQuery(query);
      }

      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error during search: $e');
    }
  }

  void _handleTypingSearch() {
    if (_searchController.text.isNotEmpty) {
      _performSearch(_searchController.text, addToHistory: false);
    }
  }

  void _clearSearch() {
    setState(() {
      _searchController.clear();
      _searchResults = [];
    });
  }

  void _deleteHistoryItem(String query) async {
    final prefs = await SharedPreferences.getInstance();
    _searchHistory.remove(query);
    await prefs.setStringList('searchHistory', _searchHistory);
    setState(() {});
  }

  void _handleSearchHistoryTap(String query) {
    _searchController.text = query;
    _performSearch(query, addToHistory: false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Search bar with "X" button
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (query) {
                      if (query.isNotEmpty) {
                        _performSearch(query, addToHistory: true);
                      }
                    },
                    decoration: const InputDecoration(
                      labelText: 'Search',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _clearSearch,
                  tooltip: 'Clear search',
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Show search history if no search is in progress
            if (_searchController.text.isEmpty && _searchHistory.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchHistory.length,
                  itemBuilder: (context, index) {
                    final query = _searchHistory[index];
                    return ListTile(
                      title: Text(query),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => _deleteHistoryItem(query),
                      ),
                      onTap: () => _handleSearchHistoryTap(query),
                    );
                  },
                ),
              ),
            // Show search results
            if (_searchController.text.isNotEmpty || _searchResults.isNotEmpty)
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _searchResults.isEmpty
                    ? const Center(child: Text('No results found'))
                    : ListView.builder(
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    return ProductCardSearch(product: product);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
