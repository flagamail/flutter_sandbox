import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'dart:math' as math;

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Gap based on Flex Axis',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: LayoutBuilder(builder: (context, constraints) {
            debugPrint('LayoutBuilder $constraints');
            return ListView(
              //  crossAxisAlignment: CrossAxisAlignment.start,
              //  mainAxisAlignment: MainAxisAlignment.center,
              //  mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                //    const Text('This is testing the Gap widget'),
                Column(
                  children: const [
                     Gap(3000),
                  ],
                ),
                //    const Text('Notice the gap between me and the text above me, its vertical'),
                //  const Gap(30),
                //     const Text('Now lets look at it working horizontally'),
                LayoutBuilder(builder: (context, constraints) {
                  debugPrint('Inner LayoutBuilder $constraints');
                  return const SizedBox(height: 10);
                }),
              //  const Gap(16),
                Column(
                  children: [
                    Flexible(
                      child: Row(
                        children: const [
                          Text('First Text inside the Row'),
                          Gap(12),
                          Text(
                            'Second Text inside Row',
                            maxLines: 3,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

class Gap extends LeafRenderObjectWidget {
  const Gap(
    this.mainAxisExtent, {
    Key? key,
  })  : assert(mainAxisExtent >= 0 && mainAxisExtent < double.infinity),
        super(key: key);

  final double mainAxisExtent;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderGap(mainAxisExtent: mainAxisExtent);
  }

  @override
  void updateRenderObject(BuildContext context, RenderBox renderObject) {
    (renderObject as _RenderGap).mainAxisExtent = mainAxisExtent;
  }
}

class _RenderGap extends RenderBox {
  _RenderGap({
    double? mainAxisExtent,
  }) : _mainAxisExtent = mainAxisExtent!;

  double get mainAxisExtent => _mainAxisExtent;
  double _mainAxisExtent;

  set mainAxisExtent(double value) {
    if (_mainAxisExtent != value) {
      _mainAxisExtent = value;
      markNeedsLayout();
    }
  }

  @override
  void performLayout() {
    final AbstractNode flex = parent!;
    if (flex is RenderFlex) {
      debugPrint('Gap $constraints mainaxisExtent $mainAxisExtent');
      if (flex.direction == Axis.horizontal) {
        size = constraints.constrain(Size(mainAxisExtent, 0));
      } else {
        size = constraints.constrain(Size(0, mainAxisExtent));
      }
    } else {
      throw FlutterError(
        'A Gap widget must be placed directly inside a Flex widget',
      );
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // TODO: implement paint
    super.paint(context, offset);
    debugPrint('Paint context $context PaintOffset $offset');
    debugPrint('Paint hasSize $hasSize  ${hasSize ? size : 'No Size'}');
  }
}
