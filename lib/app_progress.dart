import 'package:flutter/material.dart';

class AppIndefiniteProgressDialog extends StatefulWidget {
  const AppIndefiniteProgressDialog({Key? key}) : super(key: key);
  static final OverlayEntry overlayEntry = OverlayEntry(builder: (BuildContext context) {
    return const AppIndefiniteProgressDialog();
  });

  @override
  _AppIndefiniteProgressDialogState createState() => _AppIndefiniteProgressDialogState();
}

class _AppIndefiniteProgressDialogState extends State<AppIndefiniteProgressDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    animationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AnimatedBuilder(
        animation: animationController,
        child: const Center(
          child: FlutterLogo(),
        ),
        builder: (BuildContext context, Widget? _widget) {
          return Positioned.fill(
            child: GestureDetector(
              onTap: () {
                //  _removeOverlay(); // Remove the overlay when tapped
                AppIndefiniteProgressDialog.overlayEntry.remove();
              },
              child: Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: Transform.rotate(
                    angle: animationController.value * 6.3,
                    child: _widget,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }
}
