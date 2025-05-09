import 'package:flutter/material.dart';
// Purpose: Manages the state for the home screen, fetching banners, categories, restaurants, and popular food items.

import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import '../config.dart';
import '../services/location_service.dart';
import '../mainScreens/search_screen.dart';
import '../providers/auth_provider.dart';

class HomeProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  bool isLoading = true;
  String? error;
  List<Map<String, dynamic>> banners = [];
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> nearbyRestaurants = [];
  List<Map<String, dynamic>> topRatedRestaurants = [];
  List<Map<String, dynamic>> popularFoodItems = [];

  HomeProvider() {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));

    // Configure Dio to not throw on 404 errors
    _dio.options.validateStatus = (status) {
      return status! < 500;
    };
  }

  Future<void> initializeHomeScreen(BuildContext context) async {
    try {
      debugPrint('(HomeProvider) Starting data initialization...');
      isLoading = true;
      error = null;
      notifyListeners();

      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final token = authProvider.token;
      debugPrint('[HomeProvider] initializeHomeScreen using token: \u001b[32m$token\u001b[0m');
      if (token == null) {
        error = 'Authentication required.';
        debugPrint('[HomeProvider] ERROR: No token found, authentication required.');
        isLoading = false;
        notifyListeners();
        return;
      }
      // Fetch all data concurrently for better performance
      debugPrint('(HomeProvider) Fetching data concurrently...');
      final results = await Future.wait([
        fetchBanners(token).then((_) => 'banners'),
        fetchCategories(token).then((_) => 'categories'),
        fetchNearbyRestaurants(token).then((_) => 'nearby'),
        fetchTopRatedRestaurants(token).then((_) => 'top-rated'),
        fetchPopularFoodItems(token).then((_) => 'popular'),
      ], eagerError: false);

      // Check if any data is missing
      final missingData = results.where((result) => result == null).toList();
      if (missingData.isNotEmpty) {
        error = 'Some data could not be loaded. Please try again.';
        debugPrint('(HomeProvider) Missing data: $missingData');
      }

      debugPrint('(HomeProvider) Data fetch complete');
      debugPrint('Banners: ${banners.length}');
      debugPrint('Categories: ${categories.length}');
      debugPrint('Nearby restaurants: ${nearbyRestaurants.length}');
      debugPrint('Top-rated restaurants: ${topRatedRestaurants.length}');
      debugPrint('Popular food items: ${popularFoodItems.length}');

    } catch (e) {
      debugPrint('(HomeProvider) Error during initialization: $e');
      error = 'Failed to load data. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> requestLocation() async {
    try {
      // final location = await LocationService.getCurrentLocation();
      // if (location == null) {
      //   debugPrint('Location not available or permissions denied');
      //   return;
      // }
      // debugPrint('User location: $location');
      // Check delivery availability here if needed
    } catch (e) {
      debugPrint('Error fetching location: $e');
    }
  }

  Future<void> fetchBanners(String token) async {
    debugPrint('[HomeProvider] fetchBanners using token: \u001b[32m$token\u001b[0m');
    try {
      debugPrint('(HomeProvider) Fetching banners...');
      final response = await _dio.get('${AppConfig.baseUrl}/banners/', options: Options(headers: {'Authorization': 'Bearer $token'}));
      debugPrint('(HomeProvider) Banners API Response: ${response.data}');
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          final List<dynamic> data = response.data;
          banners = data.map((item) {
            if (item is Map<String, dynamic>) {
              // Assuming the banner image URL is in the 'image' key
              // Ensure the image value is treated as a string
              final bannerData = Map<String, dynamic>.from(item);
              if (bannerData['image'] == null || bannerData['image'].toString().isEmpty) {
                // Provide a default placeholder if image is missing
                bannerData['image'] = 'https://placehold.co/600x200/EAEAEA/6D6D6D.png?text=Banner'; 
              }
              return bannerData;
            } else {
              // Handle cases where item is not a map, return an empty map or default
              debugPrint('(HomeProvider) Unexpected item type in banners list: ${item.runtimeType}');
              return <String, dynamic>{'image': 'https://placehold.co/600x200/EAEAEA/6D6D6D.png?text=Invalid+Banner'}; 
            }
          }).toList();
        } else {
          debugPrint('(HomeProvider) Unexpected response format for banners');
          banners = [];
        }
      } else {
        debugPrint('(HomeProvider) Failed to fetch banners: ${response.statusCode}');
        banners = [];
      }
      debugPrint('(HomeProvider) Banners fetched: ${banners.length}');
    } catch (e, stacktrace) {
      debugPrint('(HomeProvider) Error fetching banners: $e\n$stacktrace'); 
      banners = [];
      rethrow;
    }
  }

  Future<void> fetchCategories(String token) async {
    debugPrint('[HomeProvider] fetchCategories using token: \u001b[32m$token\u001b[0m');
    final String url = '${AppConfig.baseUrl}/categories/';
    try {
      debugPrint('(HomeProvider) Fetching categories from URL: $url');
      final response = await _dio.get(url, options: Options(headers: {'Authorization': 'Bearer $token'}));
      debugPrint('(HomeProvider) Categories API Response: ${response.data}');
      
      if (response.statusCode == 200) {
        if (response.data is List) {
          categories = List<Map<String, dynamic>>.from(
            (response.data as List).where((item) => 
              item is Map<String, dynamic> && 
              item.containsKey('name') &&
              item['name'] != null
            ).map((item) {
              final categoryMap = Map<String, dynamic>.from(item);
              categoryMap['image_url'] = categoryMap['image_url']?.toString() ?? '';
              return categoryMap;
            })
          );
          
          if (categories.isNotEmpty && categories.first['name'] != 'All') {
            categories.insert(0, {'name': 'All', 'image_url': ''});
          }
        } else {
          debugPrint('(HomeProvider) Categories API did not return a list');
          categories = [];
        }
      } else {
        debugPrint('(HomeProvider) Categories API returned status ${response.statusCode}');
        categories = [];
      }
      debugPrint('(HomeProvider) Categories fetched: ${categories.length}');
    } catch (e) {
      debugPrint('(HomeProvider) Error fetching categories: $e');
      categories = [];
      rethrow;
    }
  }

  Future<void> fetchNearbyRestaurants(String token) async {
    debugPrint('[HomeProvider] fetchNearbyRestaurants using token: \u001b[32m$token\u001b[0m');
    try {
      debugPrint('(HomeProvider) Fetching nearby restaurants...');
      final response = await _dio.get('${AppConfig.baseUrl}/nearby-restaurants/', options: Options(headers: {'Authorization': 'Bearer $token'}));
      debugPrint('(HomeProvider) Nearby restaurants API response: ${response.data}');
      
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        nearbyRestaurants = data.map((item) {
          if (item is Map<String, dynamic>) {
            final restaurant = Map<String, dynamic>.from(item);
            if (restaurant['image'] == null || restaurant['image'].toString().isEmpty) {
              restaurant['image'] = 'https://placehold.co/150x150/EAEAEA/6D6D6D.png?text=${Uri.encodeComponent(restaurant['name']?.toString() ?? 'Restaurant')}';
            }
            return restaurant;
          }
          return <String, dynamic>{};
        }).where((item) => item.isNotEmpty).toList();
      } else {
        debugPrint('(HomeProvider) Unexpected response format for nearby restaurants');
        nearbyRestaurants = [];
      }
      debugPrint('(HomeProvider) Nearby restaurants fetched: ${nearbyRestaurants.length}');
    } catch (e) {
      debugPrint('(HomeProvider) Error fetching nearby restaurants: $e');
      nearbyRestaurants = [];
      rethrow;
    }
  }

  Future<void> fetchTopRatedRestaurants(String token) async {
    debugPrint('[HomeProvider] fetchTopRatedRestaurants using token: \u001b[32m$token\u001b[0m');
    try {
      debugPrint('(HomeProvider) Fetching top-rated restaurants...');
      final response = await _dio.get('${AppConfig.baseUrl}/top-rated-restaurants/', options: Options(headers: {'Authorization': 'Bearer $token'}));
      debugPrint('(HomeProvider) Top-rated restaurants API response: ${response.data}');
      
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        topRatedRestaurants = data.map((item) {
          if (item is Map<String, dynamic>) {
            final restaurant = Map<String, dynamic>.from(item);
            if (restaurant['image'] == null || restaurant['image'].toString().isEmpty) {
              restaurant['image'] = 'https://placehold.co/150x150/EAEAEA/6D6D6D.png?text=${Uri.encodeComponent(restaurant['name']?.toString() ?? 'Restaurant')}';
            }
            return restaurant;
          }
          return <String, dynamic>{};
        }).where((item) => item.isNotEmpty).toList();
      } else {
        debugPrint('(HomeProvider) Unexpected response format for top-rated restaurants');
        topRatedRestaurants = [];
      }
      debugPrint('(HomeProvider) Top-rated restaurants fetched: ${topRatedRestaurants.length}');
    } catch (e) {
      debugPrint('(HomeProvider) Error fetching top-rated restaurants: $e');
      topRatedRestaurants = [];
      rethrow;
    }
  }

  Future<void> fetchPopularFoodItems(String token) async {
    debugPrint('[HomeProvider] fetchPopularFoodItems using token: \u001b[32m$token\u001b[0m');
    try {
      debugPrint('(HomeProvider) Fetching popular food items...');
      final response = await _dio.get('${AppConfig.baseUrl}/popular-foods/', options: Options(headers: {'Authorization': 'Bearer $token'}));
      debugPrint('(HomeProvider) Popular food items API response: ${response.data}');
      
      if (response.statusCode == 200 && response.data is List) {
        final List<dynamic> data = response.data;
        popularFoodItems = data.map((item) {
          if (item is Map<String, dynamic>) {
            final food = Map<String, dynamic>.from(item);
            if (food['image'] == null || food['image'].toString().isEmpty) {
              food['image'] = 'https://placehold.co/150x150/EAEAEA/6D6D6D.png?text=${Uri.encodeComponent(food['name']?.toString() ?? 'Food')}';
            }
            return food;
          }
          return <String, dynamic>{};
        }).where((item) => item.isNotEmpty).toList();
      } else {
        debugPrint('(HomeProvider) Unexpected response format for popular food items');
        popularFoodItems = [];
      }
      debugPrint('(HomeProvider) Popular food items fetched: ${popularFoodItems.length}');
    } catch (e) {
      debugPrint('(HomeProvider) Error fetching popular food items: $e');
      popularFoodItems = [];
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> searchRestaurantsAndFood(String query, String token) async {
    if (query.trim().isEmpty) {
      return [];
    }

    try {
      debugPrint('(HomeProvider) Searching for: $query');
      final response = await _dio.get(
        '${AppConfig.baseUrl}/search/',
        queryParameters: {'q': query.trim()},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.statusCode == 200) {
        final List<dynamic> results = response.data is List 
          ? response.data 
          : response.data['results'] as List? ?? [];

        return results.where((item) => item is Map<String, dynamic>).map((item) => Map<String, dynamic>.from(item)).toList();
      }
      
      debugPrint('(HomeProvider) Search API returned status ${response.statusCode}');
      return [];
    } catch (e) {
      debugPrint('(HomeProvider) Error searching: $e');
      return [];
    }
  }

  // Add methods for recent searches
  List<String> _recentSearches = [];

  Future<List<String>> getRecentSearches() async {
    return _recentSearches;
  }

  Future<void> addRecentSearch(String query) async {
    if (!_recentSearches.contains(query)) {
      _recentSearches.insert(0, query);
      if (_recentSearches.length > 10) {
        _recentSearches.removeLast();
      }
      notifyListeners();
    }
  }

  Future<void> removeRecentSearch(String query) async {
    _recentSearches.remove(query);
    notifyListeners();
  }

  Future<List<String>> getSearchSuggestions(String query, String token) async {
    try {
      final response = await _dio.get(
        '${AppConfig.baseUrl}/search-suggestions/',
        queryParameters: {'q': query},
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (response.data is List) {
        return List<String>.from(response.data);
      } else if (response.data['suggestions'] is List) {
        return List<String>.from(response.data['suggestions']);
      }
      return [];
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      return [];
    }
  }

  List<Map<String, dynamic>> searchRestaurants(String query) {
    query = query.toLowerCase();
    return [...nearbyRestaurants, ...topRatedRestaurants]
        .where((restaurant) => 
            restaurant['name']?.toString().toLowerCase().contains(query) == true ||
            restaurant['cuisine_type']?.toString().toLowerCase().contains(query) == true)
        .toList();
  }
}