import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_1/pages/map_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<String> imageList =
      List.generate(5, (index) => 'https://picsum.photos/400?random=$index');

  // Variables for floating button position
  double xPos = 20.0;
  double yPos = 600.0;
  bool isDragging = false;

  // For storing comments and posts
  List<String> comments = ['This is awesome!', 'Great post!', 'Amazing!'];
  List<String> posts = List.generate(30, (index) => 'Post $index');
  ScrollController _scrollController = ScrollController();
  TextEditingController _commentController = TextEditingController();
  FocusNode _focusNode = FocusNode(); // Define the FocusNode

  bool isLoadingMore = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _commentController.dispose();
    _focusNode.dispose(); // Dispose of the FocusNode
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      _loadMorePosts();
    }
  }

  void _loadMorePosts() async {
    if (!isLoadingMore) {
      setState(() {
        isLoadingMore = true;
      });

      // Simulate a network request or data fetch
      await Future.delayed(Duration(seconds: 2));

      setState(() {
        posts.addAll(
            List.generate(10, (index) => 'Post ${posts.length + index}'));
        isLoadingMore = false;
      });
    }
  }

  // Add this state variable to handle replies
  String? _replyingToComment;

  void _showCommentModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height *
            0.95, // Leave some space from the top
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Comments',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),

            // Comment List
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.grey[300],
                          child: const Icon(Icons.person, color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(comments[index]),
                              ),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _replyingToComment = comments[
                                        index]; // Set which comment you're replying to
                                    FocusScope.of(context).requestFocus(
                                        _focusNode); // Focus the input field
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: const Text(
                                    'Reply',
                                    style: TextStyle(
                                        color: Colors.blue, fontSize: 12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Comment Input Field
            Padding(
              padding: MediaQuery.of(context).viewInsets,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                child: Row(
                  children: [
                    if (_replyingToComment !=
                        null) // If replying, show the reply text
                      Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Text(
                          'Replying to: $_replyingToComment',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    Expanded(
                      child: TextField(
                        controller: _commentController,
                        focusNode: _focusNode, // Use the FocusNode here
                        decoration: InputDecoration(
                          hintText: _replyingToComment != null
                              ? 'Write a reply...'
                              : 'Write a comment...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10.0,
                            horizontal: 20.0,
                          ),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: () {
                        setState(() {
                          if (_commentController.text.isNotEmpty) {
                            if (_replyingToComment != null) {
                              // Add reply logic (you could add replies to the comment)
                              comments.add(
                                  '@$_replyingToComment ${_commentController.text}');
                              _replyingToComment = null; // Clear reply state
                            } else {
                              // Add a regular comment
                              comments.add(_commentController.text);
                            }
                            _commentController.clear();
                            Navigator.pop(
                                context); // Close the modal after submitting the comment
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/nari.png',
          height: 30,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40), // The carousel height
          child: CarouselSlider(
            options: CarouselOptions(
              height: 60.0,
              autoPlay: true,
              enlargeCenterPage: true,
              viewportFraction: 0.9,
            ),
            items: imageList.map((imageUrl) {
              return ClipRRect(
                child: Image.network(
                  'https://p16-capcut-va.ibyteimg.com/tos-maliva-i-6rr7idwo9f-us/1703551578867.283~tplv-6rr7idwo9f-image.image',
                  fit: BoxFit.fitWidth,
                  width: double.infinity,
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.maps_home_work),
            onPressed: () {
              // Handle notification action
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MapScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              // Handle profile action
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView.builder(
            controller: _scrollController,
            itemCount: posts.length + (isLoadingMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == posts.length) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              return Column(
                children: [
                  Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(15)),
                          child: Image.network(
                            'https://picsum.photos/400?random=$index',
                            height: 400,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            "Beautiful view from the mountains. #nature #travel",
                            style:
                                TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  _showCommentModal(context);
                                },
                                child: const Text(
                                  'View all comments',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.share_outlined),
                                onPressed: () {
                                  // Handle share action
                                },
                              ),
                            ],
                          ),
                        ),
                        // Display only one comment here
                        if (comments.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.grey[300],
                                  child: const Icon(Icons.person,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[100],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      comments[0],
                                      style: const TextStyle(
                                          fontSize: 16, color: Colors.black87),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Draggable Floating SOS Button
          Positioned(
            left: xPos,
            top: yPos,
            child: GestureDetector(
              onPanStart: (_) {
                setState(() {
                  isDragging = true;
                });
              },
              onPanUpdate: (details) {
                setState(() {
                  xPos += details.delta.dx;
                  yPos += details.delta.dy;
                });
              },
              onPanEnd: (_) {
                setState(() {
                  isDragging = false;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: FloatingActionButton(
                  onPressed: () {
                    // Handle SOS action
                  },
                  child: const Icon(Icons.warning_rounded),
                  backgroundColor: Colors.red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
