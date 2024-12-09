import 'package:flutter/material.dart';

class AnimatedBalloonWidget2 extends StatefulWidget {
  @override
  _AnimatedBalloonWidgetState createState() => _AnimatedBalloonWidgetState();
}

class _AnimatedBalloonWidgetState extends State<AnimatedBalloonWidget2> with TickerProviderStateMixin {
  late AnimationController _controllerFloatUp;
  late AnimationController _controllerGrowSize;
  late AnimationController _controllerRotation;
  late AnimationController _controllerPulse;
  late Animation<double> _animationFloatUp;
  late Animation<double> _animationGrowSize;
  late Animation<double> _animationRotation;
  late Animation<double> _animationPulse;
  late AnimationController _cloudController1;
  Offset _dragOffset = Offset.zero;

  @override
  void initState() {
    super.initState();
    _controllerFloatUp = AnimationController(duration: Duration(seconds: 10), vsync: this);
    _controllerGrowSize = AnimationController(duration: Duration(seconds: 6), vsync: this);
    _controllerRotation = AnimationController(duration: Duration(seconds: 3), vsync: this);
    _controllerPulse = AnimationController(duration: Duration(seconds: 1), vsync: this);
    _cloudController1 = AnimationController(duration: Duration(seconds: 12), vsync: this);

    _controllerFloatUp.forward();
    _controllerGrowSize.forward();
    _controllerRotation.forward();
    _controllerPulse.forward();
    _cloudController1.repeat(reverse: false);
  }

  @override
  void dispose() {
    _controllerFloatUp.dispose();
    _controllerGrowSize.dispose();
    _controllerRotation.dispose();
    _controllerPulse.dispose();
    _cloudController1.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double _balloonHeight = MediaQuery.of(context).size.height / 2;
    double _balloonWidth = MediaQuery.of(context).size.height / 3;
    double _balloonBottomLocation = MediaQuery.of(context).size.height - _balloonHeight;

    _animationFloatUp = Tween(begin: _balloonBottomLocation, end: 0.0).animate(
      CurvedAnimation(parent: _controllerFloatUp, curve: Curves.easeInOutQuad)
    );

    _animationGrowSize = Tween(begin: 60.0, end: _balloonWidth).animate(
      CurvedAnimation(parent: _controllerGrowSize, curve: Curves.easeInOut)
    );

    _animationRotation = Tween(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _controllerRotation, curve: Curves.easeInOutSine)
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controllerRotation.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controllerRotation.forward();
      }
    });

    _animationPulse = Tween(begin: 0.95, end: 1.1).animate(
      CurvedAnimation(parent: _controllerPulse, curve: Curves.easeInOut)
    )..addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _controllerPulse.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _controllerPulse.forward();
      }
    });

    return Stack(
      children: [
        Positioned(
          top: 100,
          left: -100,
          child: AnimatedCloud(controller: _cloudController1, imagePath: 'lib/assets/images/cloud.png'),
        ),
        AnimatedBuilder(
          animation: _animationFloatUp,
          builder: (context, child) {
            return Container(
              child: child,
              margin: EdgeInsets.only(
                top: _animationFloatUp.value,
              ),
              width: _animationGrowSize.value * _animationPulse.value,
              height: _balloonHeight * _animationPulse.value,
            );
          },
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                _dragOffset += details.delta;
              });
            },
            onTap: () {
              if (_controllerFloatUp.isCompleted) {
                _controllerFloatUp.reverse();
                _controllerGrowSize.reverse();
                _controllerRotation.reverse();
                _controllerPulse.reverse();
              } else {
                _controllerFloatUp.forward();
                _controllerGrowSize.forward();
                _controllerRotation.forward();
                _controllerPulse.forward();
              }
            },
            child: Transform.translate(
              offset: _dragOffset,
              child: RotationTransition(
                turns: _animationRotation,
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return LinearGradient(
                      colors: [Colors.yellow, Colors.pink],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ).createShader(bounds);
                  },
                  blendMode: BlendMode.srcATop,
                  child: Image.asset(
                    'lib/assets/images/Balloon.png',
                    height: _balloonHeight,
                    width: _balloonWidth,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class AnimatedCloud extends StatelessWidget {
  final AnimationController controller;
  final String imagePath;

  AnimatedCloud({required this.controller, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    final animation = Tween<Offset>(begin: Offset(-1.5, 0), end: Offset(1.5, 0)).animate(controller);

    return SlideTransition(
      position: animation,
      child: Image.asset(
        imagePath,
        width: 200,
        fit: BoxFit.cover,
      ),
    );
  }
}
