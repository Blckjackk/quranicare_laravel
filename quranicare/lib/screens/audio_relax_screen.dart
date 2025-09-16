import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/audio_relax.dart';
import '../services/audio_relax_service.dart';

class AudioRelaxScreen extends StatefulWidget {
  const AudioRelaxScreen({super.key});

  @override
  State<AudioRelaxScreen> createState() => _AudioRelaxScreenState();
}

class _AudioRelaxScreenState extends State<AudioRelaxScreen> {
  final AudioRelaxService _audioService = AudioRelaxService();
  
  int _currentScreen = 0; // 0: categories, 1: audio list, 2: player
  List<AudioCategory> _categories = [];
  List<AudioRelax> _audioList = [];
  AudioCategory? _selectedCategory;
  AudioRelax? _selectedAudio;
  
  bool _isLoadingCategories = true;
  bool _isLoadingAudio = false;
  String _errorMessage = '';

  // YouTube player controller
  YoutubePlayerController? _youtubeController;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      setState(() {
        _isLoadingCategories = true;
        _errorMessage = '';
      });

      final categories = await _audioService.getAllCategories();
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _loadAudioByCategory(AudioCategory category) async {
    try {
      setState(() {
        _isLoadingAudio = true;
        _errorMessage = '';
        _selectedCategory = category;
        _currentScreen = 1;
      });

      final result = await _audioService.getAudioByCategory(category.id);
      setState(() {
        _audioList = result['audio_list'] as List<AudioRelax>;
        _isLoadingAudio = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoadingAudio = false;
      });
    }
  }

  void _playAudio(AudioRelax audio) {
    setState(() {
      _selectedAudio = audio;
      _currentScreen = 2;
    });

    // Debug: Print audio information
    print('🎵 Playing audio: ${audio.title}');
    print('🔗 Audio path: ${audio.audioPath}');
    print('🎬 Is YouTube: ${audio.isYouTubeAudio}');
    
    // Test regex extraction step by step
    print('🧪 Testing regex extraction:');
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final match = regExp.firstMatch(audio.audioPath);
    print('🔍 Regex match found: ${match != null}');
    if (match != null) {
      print('🆔 Extracted video ID: ${match.group(1)}');
    }
    
    print('🆔 YouTube ID from getter: ${audio.youTubeVideoId}');

    // Initialize YouTube player if it's a YouTube audio
    if (audio.isYouTubeAudio && audio.youTubeVideoId != null) {
      print('🚀 Initializing YouTube controller...');
      print('🆔 Video ID: ${audio.youTubeVideoId}');
      
      // Test dengan video ID yang sederhana untuk debug
      String testVideoId = audio.youTubeVideoId!;
      print('🧪 Using video ID: $testVideoId');
      
      _youtubeController?.dispose();
      _youtubeController = YoutubePlayerController(
        initialVideoId: testVideoId,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          disableDragSeek: false,
          loop: false,
          isLive: false,
          forceHD: false,
          enableCaption: false,
          hideControls: false,
          hideThumbnail: false,
        ),
      );
      
      // Add listener to track player state
      _youtubeController!.addListener(() {
        print('🔄 Controller state changed - Ready: ${_youtubeController!.value.isReady}');
        print('🔄 Player state: ${_youtubeController!.value.playerState}');
        print('🔄 Has error: ${_youtubeController!.value.hasError}');
        if (_youtubeController!.value.hasError) {
          print('❌ YouTube Error: ${_youtubeController!.value.errorCode}');
        }
        
        if (_youtubeController!.value.isReady) {
          setState(() {
            _isPlaying = _youtubeController!.value.isPlaying;
          });
          print('🎮 Player state: ${_isPlaying ? "Playing" : "Paused"}');
          print('✅ YouTube controller is now ready!');
        }
      });
      
      // Wait for controller to be ready
      _waitForControllerReady();
      
      print('✅ YouTube controller initialized successfully!');
    } else {
      print('❌ Not a YouTube audio or no video ID found');
    }

    // Update play count
    _audioService.updatePlayCount(audio.id);
  }

  Future<void> _waitForControllerReady() async {
    if (_youtubeController == null) return;
    
    int attempts = 0;
    const maxAttempts = 20; // 10 seconds max wait
    
    while (attempts < maxAttempts && !_youtubeController!.value.isReady) {
      await Future.delayed(Duration(milliseconds: 500));
      attempts++;
      print('⏳ Waiting for controller ready... Attempt $attempts/$maxAttempts');
    }
    
    if (_youtubeController!.value.isReady) {
      print('✅ Controller is ready after ${attempts * 500}ms');
    } else {
      print('❌ Controller failed to become ready after ${maxAttempts * 500}ms');
    }
  }

  void _togglePlayPause() async {
    print('🎮 Toggle play/pause called');
    print('🎮 Controller exists: ${_youtubeController != null}');
    
    if (_youtubeController != null) {
      print('🎮 Controller ready: ${_youtubeController!.value.isReady}');
      print('🎮 Current playing state: ${_youtubeController!.value.isPlaying}');
      
      // If not ready, wait a bit more
      if (!_youtubeController!.value.isReady) {
        print('⏳ Controller not ready, waiting...');
        await _waitForControllerReady();
      }
      
      if (_youtubeController!.value.isReady) {
        if (_isPlaying) {
          print('⏸️ Pausing...');
          _youtubeController!.pause();
        } else {
          print('▶️ Playing...');
          _youtubeController!.play();
        }
        setState(() {
          _isPlaying = !_isPlaying;
        });
        print('🎵 New playing state: $_isPlaying');
      } else {
        print('❌ Controller still not ready after waiting');
      }
    } else {
      print('❌ No YouTube controller available');
    }
  }

  void _stopAudio() {
    if (_youtubeController != null) {
      _youtubeController!.pause();
      _youtubeController!.seekTo(Duration.zero);
      setState(() {
        _isPlaying = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8F8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF0F8F8),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF2D5A5A)),
          onPressed: () {
            if (_currentScreen == 2) {
              _youtubeController?.dispose();
              _youtubeController = null;
              setState(() {
                _currentScreen = 1;
                _selectedAudio = null;
              });
            } else if (_currentScreen == 1) {
              setState(() {
                _currentScreen = 0;
                _selectedCategory = null;
                _audioList.clear();
              });
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _currentScreen == 0 
            ? 'Audio Relax Islami'
            : _currentScreen == 1
              ? _selectedCategory?.name ?? 'Audio'
              : _selectedAudio?.title ?? 'Player',
          style: const TextStyle(
            color: Color(0xFF2D5A5A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildCurrentScreen(),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentScreen) {
      case 1:
        return _buildAudioListScreen();
      case 2:
        return _buildPlayerScreen();
      default:
        return _buildCategoriesScreen();
    }
  }

  Widget _buildCategoriesScreen() {
    if (_isLoadingCategories) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8FA68E),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.red.withOpacity(0.8),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadCategories,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8FA68E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadCategories,
      color: const Color(0xFF8FA68E),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: GestureDetector(
              onTap: () => _loadAudioByCategory(category),
              child: Container(
                height: 120,
                decoration: BoxDecoration(
                  color: _getCategoryColor(category.name),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2D5A5A).withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Background pattern
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 20,
                      bottom: -30,
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.05),
                        ),
                      ),
                    ),
                    // Content
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            category.name.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                          if (category.description != null) ...[
                            const SizedBox(height: 8),
                            Text(
                              category.description!,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 14,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudioListScreen() {
    if (_isLoadingAudio) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF8FA68E),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal memuat audio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_selectedCategory != null) {
                  _loadAudioByCategory(_selectedCategory!);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8FA68E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Coba Lagi',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_audioList.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_note_outlined,
              size: 64,
              color: const Color(0xFF8FA68E).withOpacity(0.6),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada audio',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2D5A5A),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Audio akan segera tersedia',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF8FA68E).withOpacity(0.8),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _audioList.length,
      itemBuilder: (context, index) {
        final audio = _audioList[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () => _playAudio(audio),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2D5A5A).withOpacity(0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Thumbnail
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(0xFF8FA68E).withOpacity(0.1),
                    ),
                    child: audio.isYouTubeAudio
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              audio.youTubeThumbnail ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(
                                  Icons.music_note,
                                  color: Color(0xFF8FA68E),
                                  size: 24,
                                );
                              },
                            ),
                          )
                        : const Icon(
                            Icons.music_note,
                            color: Color(0xFF8FA68E),
                            size: 24,
                          ),
                  ),
                  const SizedBox(width: 12),
                  // Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          audio.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2D5A5A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (audio.artist != null) ...[
                              Text(
                                audio.artist!,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: const Color(0xFF8FA68E).withOpacity(0.8),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '•',
                                style: TextStyle(
                                  color: const Color(0xFF8FA68E).withOpacity(0.5),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              audio.formattedDuration,
                              style: TextStyle(
                                fontSize: 14,
                                color: const Color(0xFF8FA68E).withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Play icon
                  Icon(
                    Icons.play_arrow,
                    color: const Color(0xFF8FA68E),
                    size: 24,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlayerScreen() {
    if (_selectedAudio == null) {
      return const Center(
        child: Text('No audio selected'),
      );
    }

    return Column(
      children: [
        // YouTube Player or Audio Info
        if (_selectedAudio!.isYouTubeAudio && _youtubeController != null) ...[
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.black,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: YoutubePlayer(
                  controller: _youtubeController!,
                  showVideoProgressIndicator: true,
                  progressIndicatorColor: const Color(0xFF8FA68E),
                  onReady: () {
                    print('🎬 YouTube player ready!');
                    setState(() {
                      _isPlaying = false;
                    });
                  },
                  onEnded: (metaData) {
                    print('🏁 YouTube playback ended');
                    setState(() {
                      _isPlaying = false;
                    });
                  },
                ),
              ),
            ),
          ),
          // Debug info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                Text(
                  'YouTube Video ID: ${_selectedAudio!.youTubeVideoId}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  'Controller Ready: ${_youtubeController?.value.isReady ?? false}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ] else ...[
          Container(
            margin: const EdgeInsets.all(16),
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: const Color(0xFF8FA68E).withOpacity(0.1),
            ),
            child: const Center(
              child: Icon(
                Icons.music_note,
                size: 64,
                color: Color(0xFF8FA68E),
              ),
            ),
          ),
        ],

        // Audio Info
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              Text(
                _selectedAudio!.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D5A5A),
                ),
                textAlign: TextAlign.center,
              ),
              if (_selectedAudio!.artist != null) ...[
                const SizedBox(height: 8),
                Text(
                  _selectedAudio!.artist!,
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF8FA68E).withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 40),

        // Player Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Shuffle (disabled)
              IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.shuffle,
                  size: 24,
                  color: const Color(0xFF8FA68E).withOpacity(0.3),
                ),
              ),
              // Previous (disabled)
              IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.skip_previous,
                  size: 32,
                  color: const Color(0xFF8FA68E).withOpacity(0.3),
                ),
              ),
              // Play/Pause
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8FA68E),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8FA68E).withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _togglePlayPause,
                  icon: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
              // Next (disabled)
              IconButton(
                onPressed: null,
                icon: Icon(
                  Icons.skip_next,
                  size: 32,
                  color: const Color(0xFF8FA68E).withOpacity(0.3),
                ),
              ),
              // Stop
              IconButton(
                onPressed: _stopAudio,
                icon: const Icon(
                  Icons.stop,
                  size: 24,
                  color: Color(0xFF8FA68E),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 32),

        // Duration
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '00:00',
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF8FA68E).withOpacity(0.8),
                ),
              ),
              Text(
                _selectedAudio!.formattedDuration,
                style: TextStyle(
                  fontSize: 14,
                  color: const Color(0xFF8FA68E).withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),

        const Spacer(),
      ],
    );
  }

  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'nasheed':
        return const Color(0xFF2D5A5A);
      case 'dzikir dan doa':
        return const Color(0xFF8FA68E);
      case 'murottal':
        return const Color(0xFF2D5A5A);
      default:
        return const Color(0xFF8FA68E);
    }
  }
}