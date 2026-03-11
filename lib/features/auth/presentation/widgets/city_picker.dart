import 'package:flutter/material.dart';
import '../../../../core/app_colors.dart';

class CityPickerView extends StatefulWidget {
  final List<Map<String, dynamic>> cities;
  final Function(String) onSelect;

  const CityPickerView({super.key, required this.cities, required this.onSelect});

  static void show(
    BuildContext context,
    List<Map<String, dynamic>> cities,
    Function(String) onSelect,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CityPickerView(cities: cities, onSelect: onSelect),
    );
  }

  @override
  State<CityPickerView> createState() => _CityPickerViewState();
}

class _CityPickerViewState extends State<CityPickerView> {
  List<Map<String, dynamic>> _filteredCities = [];
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredCities = widget.cities;
  }

  void _filterCities(String query) {
    setState(() {
      _filteredCities = widget.cities.where((item) {
        final displayName = (item['displayName'] ?? item['name'] ?? '').toString();
        return displayName.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(40),
          topRight: Radius.circular(40),
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            "Select City",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textBlack,
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: TextField(
              controller: _searchController,
              onChanged: _filterCities,
              decoration: InputDecoration(
                hintText: "City",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          _filterCities("");
                        },
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(
                    color: AppColors.primaryRed,
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = (_filteredCities[index]['displayName'] ?? _filteredCities[index]['name'] ?? '').toString();
                final query = _searchController.text.toLowerCase();

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  title: RichText(text: _highlightMatch(city, query)),
                  onTap: () {
                    widget.onSelect(city);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  TextSpan _highlightMatch(String text, String query) {
    if (query.isEmpty || !text.toLowerCase().contains(query)) {
      return TextSpan(
        text: text,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textBlack),
      );
    }
    final int matchStart = text.toLowerCase().indexOf(query);
    final int matchEnd = matchStart + query.length;

    return TextSpan(
      children: [
        TextSpan(
          text: text.substring(0, matchStart),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textBlack),
        ),
        TextSpan(
          text: text.substring(matchStart, matchEnd),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primaryRed),
        ),
        TextSpan(
          text: text.substring(matchEnd),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textBlack),
        ),
      ],
    );
  }
}
