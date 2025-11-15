import 'package:flutter/material.dart';
import '../models/audiobook_model.dart';

class PlayerScreen extends StatefulWidget {
  final AudioBookModel book;

  const PlayerScreen({super.key, required this.book});

  @override
  State<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends State<PlayerScreen> {
  bool _isPlaying = false;
  final double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(int.parse('0xFF${widget.book.color}')),
              Color(int.parse('0xFF${widget.book.color}')).withAlpha(179),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(child: _buildContent()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Spacer(),
            _buildBookCover(),
            const SizedBox(height: 32),
            Text(
              widget.book.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              widget.book.author,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const Spacer(),
            _buildProgressBar(),
            const SizedBox(height: 32),
            _buildControls(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildBookCover() {
    return Container(
      width: 200,
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(int.parse('0xFF${widget.book.color}')),
            Color(int.parse('0xFF${widget.book.color}')).withAlpha(179),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Color(int.parse('0xFF${widget.book.color}')).withAlpha(102),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: const Icon(
        Icons.menu_book,
        size: 80,
        color: Colors.white,
      ),
    );
  }

  Widget _buildProgressBar() {
    return Column(
      children: [
        LinearProgressIndicator(
          value: _progress,
          backgroundColor: Colors.grey[200],
          valueColor: AlwaysStoppedAnimation(
            Color(int.parse('0xFF${widget.book.color}')),
          ),
          minHeight: 6,
          borderRadius: BorderRadius.circular(3),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '0:00',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Text(
              '45:30',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10),
          iconSize: 36,
          onPressed: () {},
        ),
        Container(
          decoration: BoxDecoration(
            color: Color(int.parse('0xFF${widget.book.color}')),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Color(int.parse('0xFF${widget.book.color}')).withAlpha(102),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
            ),
            iconSize: 48,
            onPressed: () {
              setState(() => _isPlaying = !_isPlaying);
            },
          ),
        ),
        IconButton(
          icon: const Icon(Icons.forward_10),
          iconSize: 36,
          onPressed: () {},
        ),
      ],
    );
  }
}
