import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';

class FirestoreSeeder {
  static const Map<int, String> _genreMap = {
    28: 'Action',
    12: 'Adventure',
    16: 'Animation',
    35: 'Comedy',
    80: 'Crime',
    99: 'Documentary',
    18: 'Drama',
    10751: 'Family',
    14: 'Fantasy',
    36: 'History',
    27: 'Horror',
    10402: 'Music',
    9648: 'Mystery',
    10749: 'Romance',
    878: 'Science Fiction',
    10770: 'TV Movie',
    53: 'Thriller',
    10752: 'War',
    37: 'Western',
  };

  static String _generateSlug(String title) {
    return title.trim().toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), '_');
  }

  static Future<void> importAllMalayalamMoviesFromTMDB() async {
    print('[FirestoreSeeder] Starting Malayalam movies import from TMDB...');
    final firestore = FirebaseFirestore.instance;
    final dio = Dio();
    
    const String token = 'eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiI4MjViNzExMDk4YzBmY2E5YjA5ZWMzMWJlNjVlZDU5NiIsIm5iZiI6MTc3OTU5MjExMy4yMzQsInN1YiI6IjZhMTI2YmIxNDM4MjRiY2ViYjZkNzg2OCIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ._7IQjM4SEKBiC7X2Ve3VaGeivJD_PVyfE3hgEn6XXvA';
    
    dio.options.headers['Authorization'] = 'Bearer $token';
    dio.options.headers['Accept'] = 'application/json';

    int currentPage = 1;
    int totalPages = 1;
    int totalMoviesSaved = 0;

    try {
      do {
        print('[FirestoreSeeder] Fetching page $currentPage...');
        final response = await dio.get(
          'https://api.tmdb.org/3/discover/movie',
          queryParameters: {
            'with_original_language': 'ml',
            'sort_by': 'popularity.desc',
            'page': currentPage,
          },
        );

        if (response.statusCode == 200) {
          print('[FirestoreSeeder] Received response for page $currentPage. Parsing data...');
          final data = response.data as Map<String, dynamic>;
          
          if (currentPage == 1) {
            totalPages = data['total_pages'] ?? 1;
            if (totalPages > 500) {
              totalPages = 500; // TMDB limits page search requests to page 500
            }
            print('[FirestoreSeeder] Total pages to fetch: $totalPages (${data['total_results'] ?? 'unknown'} total results)');
          }

          final List<dynamic> results = data['results'] ?? [];
          print('[FirestoreSeeder] Page $currentPage has ${results.length} movies.');
          if (results.isEmpty) {
            print('[FirestoreSeeder] No movies found on page $currentPage. Stopping.');
            break;
          }

          final batch = firestore.batch();
          int batchCount = 0;

          for (final result in results) {
            final movieJson = result as Map<String, dynamic>;
            final int id = movieJson['id'] ?? 0;
            if (id == 0) continue;

            final String originalLanguage = movieJson['original_language'] ?? '';
            if (originalLanguage != 'ml') continue;

            final String title = movieJson['title'] ?? movieJson['original_title'] ?? '';
            if (title.trim().isEmpty) continue;

            final String slug = _generateSlug(title);
            if (slug.isEmpty) continue;

            final String posterPath = movieJson['poster_path'] ?? '';
            final String posterUrl = posterPath.isNotEmpty 
                ? 'https://image.tmdb.org/t/p/w500$posterPath' 
                : '';
                
            final double rating = (movieJson['vote_average'] ?? 0).toDouble();
            final String overview = movieJson['overview'] ?? '';
            
            final String releaseDate = movieJson['release_date'] ?? '';
            int year = 0;
            if (releaseDate.isNotEmpty && releaseDate.length >= 4) {
              year = int.tryParse(releaseDate.substring(0, 4)) ?? 0;
            }

            final List<int> genreIds = List<int>.from(movieJson['genre_ids'] ?? []);
            final List<String> genres = genreIds.map((gid) => _genreMap[gid] ?? 'Other').toList();

            final Map<String, dynamic> movieData = {
              'id': slug, // Use clean slug string as ID
              'title': title,
              'poster': posterUrl,
              'overview': overview,
              'year': year,
              'language': 'Malayalam', // Use full string name "Malayalam"
              'rating': rating,
              'genres': genres,
              'createdAt': FieldValue.serverTimestamp(),
            };

            // Use the slug as the document ID
            final docRef = firestore.collection('malayalam_movies').doc(slug);
            batch.set(docRef, movieData);
            batchCount++;
          }

          print('[FirestoreSeeder] Committing batch for page $currentPage containing $batchCount movies...');
          if (batchCount > 0) {
            await batch.commit();
            totalMoviesSaved += batchCount;
            print('[FirestoreSeeder] Page $currentPage committed successfully. Total saved so far: $totalMoviesSaved.');
          } else {
            print('[FirestoreSeeder] No movies matched filter for page $currentPage.');
          }

          currentPage++;
          // A brief delay to avoid rate-limiting issues or overwhelming the connection
          await Future.delayed(const Duration(milliseconds: 150));
        } else {
          print('[FirestoreSeeder] Failed to fetch page $currentPage. Status code: ${response.statusCode}');
          break;
        }
      } while (currentPage <= totalPages);

      print('[FirestoreSeeder] Import completed successfully! Total movies imported: $totalMoviesSaved');
    } catch (e, stack) {
      print('[FirestoreSeeder] Error during import: $e');
      print(stack);
    }
  }

  static Future<void> clearMovies() async {
    print('[FirestoreSeeder] Starting clearing of movies...');
    final firestore = FirebaseFirestore.instance;
    try {
      final querySnapshot = await firestore.collection('malayalam_movies').get();
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
        print('[FirestoreSeeder] Deleted movie document: ${doc.id}');
      }
      print('[FirestoreSeeder] Movies cleared successfully!');
    } catch (e) {
      print('[FirestoreSeeder] Error clearing movies collection: $e');
    }
  }

  static const List<Map<String, dynamic>> _malayalamCollections = [
    {
      'id': 'top_feel_good_malayalam',
      'title': 'Top 10 Feel-Good Malayalam Movies',
      'description': 'Warm, heartwarming, and comforting Malayalam cinema favorites that will put a smile on your face.',
      'banner': 'https://image.tmdb.org/t/p/w1280/uZr793pQJJZJBjUJYrY9EC32jUL.jpg',
      'type': 'feel_good',
      'language': 'Malayalam',
      'isFeatured': true,
      'order': 1,
      'movieIds': [
        'premalu',
        'bangalore_days',
        'hridayam',
        'kumbalangi_nights',
        'ustad_hotel',
        'super_sharanya',
        'bro_daddy',
        'varane_avashyamund',
        'thattathin_marayathu',
        'godha',
      ],
    },
    {
      'id': 'malayalam_blockbusters_2024',
      'title': 'Top 10 Blockbusters of 2024',
      'description': 'The biggest hits and most acclaimed Malayalam releases of 2024.',
      'banner': 'https://image.tmdb.org/t/p/w1280/gDyLcjvmdAhmYqjCMwZ9PndnAVm.jpg',
      'type': 'hits_2024',
      'language': 'Malayalam',
      'isFeatured': true,
      'order': 2,
      'movieIds': [
        'manjummel_boys',
        'aavesham',
        'premalu',
        'bramayugam',
        'vaazha',
        'marco',
        'guruvayoor_ambalanadayil',
        'the_goat_life',
        'pani',
        'kishkindha_kaandam',
      ],
    },
    {
      'id': 'must_watch_malayalam_thrillers',
      'title': 'Top 20 Malayalam Thrillers',
      'description': 'Edge-of-your-seat suspense, mystery, and crime thrillers from Mollywood.',
      'banner': 'https://image.tmdb.org/t/p/w1280/a6RkQIOZ6wThQOEDv6lHsfH53hD.jpg',
      'type': 'thrillers',
      'language': 'Malayalam',
      'isFeatured': true,
      'order': 3,
      'movieIds': [
        'drishyam',
        'drishyam_2',
        'marco',
        'minnal_murali',
        'kishkindha_kaandam',
        'kannur_squad',
        'pani',
        'rorschach',
        'identity',
        'churuli',
        'bhoothakaalam',
        '12th_man',
        'thalavan',
        'turbo',
        'anweshippin_kandethum',
        'oppam',
        'pada',
        'l2_empuraan',
        'rekhachithram',
        'udal',
      ],
    },
    {
      'id': 'timeless_malayalam_classics',
      'title': 'Top 10 Timeless Classics',
      'description': 'Golden era masterpieces and unforgettable classic films that defined Malayalam cinema.',
      'banner': 'https://image.tmdb.org/t/p/w1280/3yqreNY1f4iOXX0vBAqY64ZvxiV.jpg',
      'type': 'classics',
      'language': 'Malayalam',
      'isFeatured': false,
      'order': 4,
      'movieIds': [
        'manichitrathazhu',
        'sandesham',
        'kireedam',
        'chithram',
        'namukku_parkkan_munthiri_thoppukal',
        'moonnam_pakkam',
        'kilukkam',
        'ravanaprabhu',
        'big_b',
        'pokkiri_raja',
      ],
    },
    {
      'id': 'mind_bending_offbeat_malayalam',
      'title': 'Top 10 Experimental & Offbeat Films',
      'description': 'Unconventional storylines, experimental narratives, and dark psychological dramas.',
      'banner': 'https://image.tmdb.org/t/p/w1280/tkRZ8BpIlvQIFBQWwEHuAlxczyb.jpg',
      'type': 'experimental',
      'language': 'Malayalam',
      'isFeatured': false,
      'order': 5,
      'movieIds': [
        'bramayugam',
        'churuli',
        'jallikattu',
        'double_barrel',
        'trance',
        'rorschach',
        'identity',
        'bhoothakaalam',
        'eko',
        'rekhachithram',
      ],
    },
    {
      'id': 'best_malayalam_comedies',
      'title': 'Top 10 Malayalam Comedies',
      'description': 'Hilarious comedy blockbusters that deliver endless laughs and wholesome entertainment.',
      'banner': 'https://image.tmdb.org/t/p/w1280/bYNO2cFopBEwnVNWPEtFm2FAdjo.jpg',
      'type': 'comedy',
      'language': 'Malayalam',
      'isFeatured': false,
      'order': 6,
      'movieIds': [
        'aavesham',
        'romancham',
        'premalu',
        'in_harihar_nagar',
        'ramji_rao_speaking',
        'cid_moosa',
        'vaazha',
        'guruvayoor_ambalanadayil',
        'super_sharanya',
        'bro_daddy',
      ],
    },
    {
      'id': 'acclaimed_drama_realism',
      'title': 'Top 10 Drama & Realism',
      'description': 'Realistic, slice-of-life stories with profound emotional themes and authentic performances.',
      'banner': 'https://image.tmdb.org/t/p/w1280/ko4cEKcBHcCNbGok2YxnlD4u16N.jpg',
      'type': 'drama',
      'language': 'Malayalam',
      'isFeatured': false,
      'order': 7,
      'movieIds': [
        'kumbalangi_nights',
        'maheshinte_prathikaaram',
        'sudani_from_nigeria',
        'the_great_indian_kitchen',
        'kaathal_the_core',
        'the_goat_life',
        'pada',
        'all_we_imagine_as_light',
        'hridayam',
        'drishyam',
      ],
    },
    {
      'id': 'new_gen_romance_malayalam',
      'title': 'Top 10 New-Gen Romance',
      'description': 'Modern love stories that captured the hearts of youth across generations.',
      'banner': 'https://image.tmdb.org/t/p/w1280/gDyLcjvmdAhmYqjCMwZ9PndnAVm.jpg',
      'type': 'romance',
      'language': 'Malayalam',
      'isFeatured': false,
      'order': 8,
      'movieIds': [
        'premam',
        'thattathin_marayathu',
        'hridayam',
        'premalu',
        'om_shanthi_oshana',
        'super_sharanya',
        'journey_of_love_18_',
        'bangalore_days',
        'romeo_laiju',
        'sureshanteyum_sumalathayudeyum_hrudayahariyaya_pranayakadha',
      ],
    },
  ];

  // New OTT releases collection data
  static const List<Map<String, dynamic>> _ottReleases = [
    {
      'id': 'narivetta',
      'title': 'Narivetta',
      'poster': 'https://example.com/narivetta.jpg',
      'platform': 'SonyLIV',
      'releaseDate': '2026-06-15',
      'language': 'Malayalam',
      'status': 'upcoming',
    },
    {
      'id': 'patriot',
      'title': 'Patriot',
      'poster': 'https://example.com/patriot.jpg',
      'platform': 'AmazonPrime',
      'releaseDate': '2025-12-01',
      'language': 'English',
      'status': 'upcoming',
    },
    {
      'id': 'drishyam_3',
      'title': 'Drishyam 3',
      'poster': 'https://example.com/drishyam3.jpg',
      'platform': 'Netflix',
      'releaseDate': '2025-11-20',
      'language': 'Malayalam',
      'status': 'upcoming',
    },
  ];


  static Future<void> clearAndSeedCollections() async {
    // print('[FirestoreSeeder] Starting clearing of collections...');
    final firestore = FirebaseFirestore.instance;
    // try {
    //   final querySnapshot = await firestore.collection('collections').get();
    //   for (final doc in querySnapshot.docs) {
    //     await doc.reference.delete();
    //     print('[FirestoreSeeder] Deleted collection document: ${doc.id}');
    //   }
    //   print('[FirestoreSeeder] Collections cleared successfully!');
    // } catch (e) {
    //   print('[FirestoreSeeder] Error clearing collections collection: $e');
    //   return;
    // }

    // print('[FirestoreSeeder] Starting collections seeding...');
    // for (final collection in _malayalamCollections) {
    //   // Existing collection seeding

    //   try {
    //     final id = collection['id'] as String;
    //     final docRef = firestore.collection('collections').doc(id);

    //     final dataToSave = Map<String, dynamic>.from(collection);
    //     dataToSave['createdAt'] = FieldValue.serverTimestamp();

    //     await docRef.set(dataToSave);
    //     print('[FirestoreSeeder] Successfully seeded collection: ${collection['title']}');
    //   } catch (e) {
    //     print('[FirestoreSeeder] Error seeding collection ${collection['title']}: $e');
    //   }
    // }

    // Seed OTT releases collection
    for (final ott in _ottReleases) {
      try {
        final id = ott['id'] as String;
        final docRef = firestore.collection('ott_releases').doc(id);
        final dataToSave = Map<String, dynamic>.from(ott);
        dataToSave['createdAt'] = FieldValue.serverTimestamp();
        await docRef.set(dataToSave);
        print('[FirestoreSeeder] Successfully seeded OTT release: ${ott['title']}');
      } catch (e) {
        print('[FirestoreSeeder] Error seeding OTT release ${ott['title']}: $e');
      }
    }
    print('[FirestoreSeeder] Collections seeding completed!');
  }
}
