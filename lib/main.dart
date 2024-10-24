import 'package:flutter/material.dart';
import 'dart:math';
import 'package:flutter/animation.dart';
import 'database_helper.dart';

void main() => runApp(AquariumApp());

class AquariumApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Virtual Aquarium',
      home: AquariumScreen(),
    );
  }
}

class AquariumScreen extends StatefulWidget {
  @override
  _AquariumScreenState createState() => _AquariumScreenState();
}

class _AquariumScreenState extends State<AquariumScreen> with SingleTickerProviderStateMixin {
  List<Fish> fishList = [];
  Color selectedColor = Colors.blue;
  double selectedSpeed = 2.0;
  DBHelper dbHelper = DBHelper.instance;

  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(); // Repeat the animation
    loadSettings();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _addFish() {
    if (fishList.length < 10) {
      setState(() {
        fishList.add(Fish(color: selectedColor, speed: selectedSpeed));
      });
    }
  }

  void _saveSettings() async {
    await dbHelper.saveSettings(fishList.length, selectedSpeed, selectedColor.value.toString());
  }

  void loadSettings() async {
    final settings = await dbHelper.loadSettings();
    if (settings != null) {
      setState(() {
        int fishCount = settings['fish_count'];
        selectedSpeed = settings['fish_speed'];
        selectedColor = Color(int.parse(settings['fish_color']));
        fishList = List.generate(fishCount, (index) => Fish(color: selectedColor, speed: selectedSpeed));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Virtual Aquarium'),
      ),
      body: Column(
        children: [
          // Aquarium Container
          Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.blueAccent, width: 5),
            ),
            child: Stack(
              children: fishList.map((fish) => AnimatedFish(fish: fish, controller: _controller!)).toList(),
            ),
          ),

          // Sliders for speed adjustment and color selection
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Speed'),
              Slider(
                value: selectedSpeed,
                min: 1.0,
                max: 5.0,
                onChanged: (value) {
                  setState(() {
                    selectedSpeed = value;
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Color'),
              DropdownButton<Color>(
                value: selectedColor,
                onChanged: (Color? newColor) {
                  if (newColor != null) {
                    setState(() {
                      selectedColor = newColor;
                    });
                  }
                },
                items: <Color>[Colors.blue, Colors.red, Colors.green, Colors.yellow].map<DropdownMenuItem<Color>>(
                  (Color value) {
                    return DropdownMenuItem<Color>(
                      value: value,
                      child: Container(width: 24, height: 24, color: value),
                    );
                  },
                ).toList(),
              ),
            ],
          ),

          // Add Fish and Save Settings Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: _addFish, child: Text('Add Fish')),
              SizedBox(width: 10),
              ElevatedButton(onPressed: _saveSettings, child: Text('Save Settings')),
            ],
          ),
        ],
      ),
    );
  }
}

class Fish {
  final Color color;
  final double speed;

  Fish({required this.color, required this.speed});
}

class AnimatedFish extends StatelessWidget {
  final Fish fish;
  final AnimationController controller;

  AnimatedFish({required this.fish, required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final random = Random();
        double randomX = random.nextDouble() * 300;
        double randomY = random.nextDouble() * 300;

        return Positioned(
          left: randomX,
          top: randomY,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: fish.color,
            ),
          ),
        );
      },
    );
  }
}
