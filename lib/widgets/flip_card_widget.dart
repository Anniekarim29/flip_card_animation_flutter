import 'package:flutter/material.dart';
import 'dart:math';
import 'package:vector_math/vector_math_64.dart' show Vector3;

class FlipCardScreen extends StatefulWidget {
  const FlipCardScreen({super.key});

  @override
  State<FlipCardScreen> createState() => _FlipCardScreenState();
}

class _FlipCardScreenState extends State<FlipCardScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFront = true;
  Axis flipAxis = Axis.horizontal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _flipCard() {
    if (_controller.isAnimating) return;
    _controller.forward(from: 0);
  }

  Widget _buildCard(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        final angle = _animation.value * pi;
        final isUnder = angle > pi / 2;

        // ✅ Delay the state change until halfway for smooth transition
        if (_animation.value >= 0.5 && isFront == isUnder) {
          Future.microtask(() {
            setState(() {
              isFront = !isFront;
            });
          });
        }

        final transform = Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotate(
            flipAxis == Axis.horizontal
                ? Vector3(0, 1, 0)
                : Vector3(1, 0, 0),
            angle,
          );

        final child = isUnder ? _buildCardBack() : _buildCardFront();

        return Transform(
          transform: transform,
          alignment: Alignment.center,
          child: child,
        );
      },
    );
  }

  Widget _buildCardFront() {
    return _cardTemplate("assets/front.png", Colors.redAccent);
  }

  Widget _buildCardBack() {
    return _cardTemplate("assets/back.png", Colors.blueAccent);
  }

  Widget _cardTemplate(String imagePath, Color color) {
    return Container(
      width: 300,
      height: 430,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: color,
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 20,
            color: Colors.white10,
            offset: Offset(0, 8),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Column(
        children: [
          // Top Bar
          Container(
            height: 110,
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.orangeAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(28),
                bottomRight: Radius.circular(28),
              ),
              boxShadow: [
                BoxShadow(blurRadius: 10, color: Colors.deepPurple),
              ],
            ),
            child: const Center(
              child: Text(
                "Flip Card Animation",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),

          // Card + Swipe
          Expanded(
            child: GestureDetector(
              onHorizontalDragEnd: (_) {
                setState(() => flipAxis = Axis.horizontal);
                _flipCard();
              },
              onVerticalDragEnd: (_) {
                setState(() => flipAxis = Axis.vertical);
                _flipCard();
              },
              child: Center(child: _buildCard(context)),
            ),
          ),

          // Button
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: GestureDetector(
              onTap: _flipCard,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Colors.pinkAccent, Colors.orangeAccent],
                  ),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.deepPurple,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: const Text(
                  "Start Flipping",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
