import "package:flow/theme/flow_custom_colors.dart";
import "package:flow/widgets/analytics/bullet_chart.dart";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";

/// Geometry guards for the budget progress bar.
///
/// Every number a budget shows the user is a label *except* this bar, so a
/// scale bug here is invisible to every other test in the suite — it reads as a
/// bar that simply looks a bit off, which is exactly how the old `* 1.1`
/// headroom survived: it drew 9% spend at 8.2% of the track and pinned the
/// limit tick at a constant 90.9% for every under-budget budget.
void main() {
  const double trackWidth = 200.0;
  const double barHeight = 16.0;

  Widget wrap(Widget child) => MaterialApp(
    theme: ThemeData(
      extensions: const [
        FlowCustomColors(
          income: Color(0xFF32CC70),
          expense: Color(0xFFC42525),
          semi: Color(0xFF888888),
        ),
      ],
    ),
    home: Scaffold(
      body: Center(
        child: SizedBox(width: trackWidth, height: barHeight, child: child),
      ),
    ),
  );

  /// Track first, then ghost, fill and pace tick in Stack order. `Container`
  /// renders its decoration through a `DecoratedBox`, so every layer shows up
  /// here — and only the layers actually drawn do.
  List<Rect> layers(WidgetTester tester) => tester
      .widgetList<DecoratedBox>(find.byType(DecoratedBox))
      .map((box) => tester.getRect(find.byWidget(box)))
      .toList();

  testWidgets("the fill is as tall as the track it sits in", (tester) async {
    await tester.pumpWidget(
      wrap(const BulletChart(value: 50.0, target: 100.0)),
    );

    final List<Rect> rects = layers(tester);
    expect(rects, hasLength(2));

    final Rect track = rects[0];
    final Rect fill = rects[1];

    // The old inset was `height * 0.28` top and bottom with no left inset, so
    // the fill read as a short bar shoved against the track's rounded cap.
    expect(fill.height, track.height);
    expect(fill.top, track.top);
    expect(fill.left, track.left);
  });

  testWidgets("the fill width is the percentage, with no headroom", (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const BulletChart(value: 50.0, target: 100.0)),
    );

    final List<Rect> rects = layers(tester);
    expect(rects[1].width, moreOrLessEquals(trackWidth / 2));
  });

  testWidgets("an overrun fills the track rather than rescaling it", (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const BulletChart(value: 150.0, target: 100.0)),
    );

    final List<Rect> rects = layers(tester);
    expect(rects[1].width, moreOrLessEquals(trackWidth));
  });

  testWidgets("a tiny non-zero spend still draws at least a dot", (
    tester,
  ) async {
    await tester.pumpWidget(wrap(const BulletChart(value: 0.4, target: 100.0)));

    // 0.4% of 200px is under a pixel — a bar that thin reads as "nothing
    // spent", which is a different thing entirely.
    expect(layers(tester)[1].width, barHeight);
  });

  testWidgets("nothing spent draws no fill at all", (tester) async {
    await tester.pumpWidget(wrap(const BulletChart(value: 0.0, target: 100.0)));

    expect(layers(tester), hasLength(1));
  });

  testWidgets("pending draws a ghost tail past the confirmed fill", (
    tester,
  ) async {
    await tester.pumpWidget(
      wrap(const BulletChart(value: 60.0, target: 100.0, pending: 25.0)),
    );

    final List<Rect> rects = layers(tester);
    expect(rects, hasLength(3));

    final Rect ghost = rects[1];
    final Rect fill = rects[2];

    // The ghost runs the whole committed length with the solid fill layered
    // over it, so the seam is a rounded cap nested inside a rounded cap.
    expect(ghost.width, moreOrLessEquals(trackWidth * 0.6));
    expect(fill.width, moreOrLessEquals(trackWidth * 0.35));
    expect(ghost.left, fill.left);
  });

  testWidgets("no pending means no ghost layer is drawn", (tester) async {
    await tester.pumpWidget(
      wrap(const BulletChart(value: 60.0, target: 100.0)),
    );

    expect(layers(tester), hasLength(2));
  });

  testWidgets("the pace tick sits at the elapsed fraction", (tester) async {
    await tester.pumpWidget(
      wrap(const BulletChart(value: 9.0, target: 100.0, paceRatio: 0.25)),
    );

    final List<Rect> rects = layers(tester);
    expect(rects, hasLength(3));

    final Rect track = rects[0];
    final Rect tick = rects[2];

    // A quarter of the way along — not the constant ~91% the old target tick
    // parked at for every budget that wasn't over.
    expect(tick.center.dx - track.left, moreOrLessEquals(trackWidth * 0.25));
    expect(tick.height, track.height);
  });

  testWidgets("the pace tick is hidden at either extreme", (tester) async {
    await tester.pumpWidget(
      wrap(const BulletChart(value: 9.0, target: 100.0, paceRatio: 0.0)),
    );
    expect(layers(tester), hasLength(2));

    // A finished period would pin it to the right edge, where it says nothing.
    await tester.pumpWidget(
      wrap(const BulletChart(value: 9.0, target: 100.0, paceRatio: 1.0)),
    );
    expect(layers(tester), hasLength(2));
  });

  testWidgets("a non-positive target draws an empty track", (tester) async {
    await tester.pumpWidget(wrap(const BulletChart(value: 50.0, target: 0.0)));

    expect(layers(tester), hasLength(1));
  });
}
