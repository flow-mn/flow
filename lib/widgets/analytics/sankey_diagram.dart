import "package:flow/theme/theme.dart";
import "package:flutter/material.dart";

/// One node on either side of a [SankeyDiagram].
class SankeyDatum {
  final String label;

  /// Positive magnitude in the diagram's currency.
  final double value;

  final Color color;

  const SankeyDatum({
    required this.label,
    required this.value,
    required this.color,
  });
}

/// A two-sided cash-flow Sankey: income [sources] on the left flow through a
/// single total hub into spending [targets] on the right.
///
/// The caller is expected to balance the two sides (e.g. add a "Saved" target
/// or a "From reserves" source) so both sum to the same total; the painter
/// scales each side independently and tolerates a small mismatch.
class SankeyDiagram extends StatelessWidget {
  final List<SankeyDatum> sources;
  final List<SankeyDatum> targets;
  final double height;

  const SankeyDiagram({
    super.key,
    required this.sources,
    required this.targets,
    this.height = 280.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(
        painter: _SankeyPainter(
          sources: sources,
          targets: targets,
          hubColor: context.colorScheme.onSurface.withAlpha(0x33),
        ),
      ),
    );
  }
}

class _SankeyPainter extends CustomPainter {
  final List<SankeyDatum> sources;
  final List<SankeyDatum> targets;
  final Color hubColor;

  static const double _nodeWidth = 12.0;
  static const double _gap = 6.0;
  static const int _ribbonAlpha = 0x4d;

  _SankeyPainter({
    required this.sources,
    required this.targets,
    required this.hubColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double sourceSum = _sum(sources);
    final double targetSum = _sum(targets);
    final double total = sourceSum > targetSum ? sourceSum : targetSum;

    if (total <= 0 || sources.isEmpty || targets.isEmpty) return;

    final double height = size.height;
    final double hubScale = height / total;

    final double leftScale =
        (height - (sources.length - 1) * _gap).clamp(0.0, height) / total;
    final double rightScale =
        (height - (targets.length - 1) * _gap).clamp(0.0, height) / total;

    final double leftRight = _nodeWidth;
    final double hubLeft = size.width / 2 - _nodeWidth / 2;
    final double hubRight = hubLeft + _nodeWidth;
    final double rightLeft = size.width - _nodeWidth;

    // Left ribbons: each source node -> its contiguous slice of the hub.
    double leftCursor = 0.0;
    double hubLeftCursor = 0.0;
    for (final SankeyDatum source in sources) {
      final double nodeTop = leftCursor;
      final double nodeBottom = nodeTop + source.value * leftScale;
      final double hubTop = hubLeftCursor;
      final double hubBottom = hubTop + source.value * hubScale;

      _drawRibbon(
        canvas,
        leftRight,
        hubLeft,
        nodeTop,
        nodeBottom,
        hubTop,
        hubBottom,
        source.color,
      );

      leftCursor = nodeBottom + _gap;
      hubLeftCursor = hubBottom;
    }

    // Right ribbons: each contiguous slice of the hub -> its target node.
    double rightCursor = 0.0;
    double hubRightCursor = 0.0;
    for (final SankeyDatum target in targets) {
      final double hubTop = hubRightCursor;
      final double hubBottom = hubTop + target.value * hubScale;
      final double nodeTop = rightCursor;
      final double nodeBottom = nodeTop + target.value * rightScale;

      _drawRibbon(
        canvas,
        hubRight,
        rightLeft,
        hubTop,
        hubBottom,
        nodeTop,
        nodeBottom,
        target.color,
      );

      rightCursor = nodeBottom + _gap;
      hubRightCursor = hubBottom;
    }

    // Nodes drawn on top of the ribbons.
    _drawNodes(canvas, 0.0, sources, leftScale);
    _drawNodes(canvas, rightLeft, targets, rightScale);
    _drawHub(canvas, hubLeft, height);
  }

  void _drawRibbon(
    Canvas canvas,
    double xLeft,
    double xRight,
    double topLeft,
    double bottomLeft,
    double topRight,
    double bottomRight,
    Color color,
  ) {
    final double midX = (xLeft + xRight) / 2;
    final Path path = Path()
      ..moveTo(xLeft, topLeft)
      ..cubicTo(midX, topLeft, midX, topRight, xRight, topRight)
      ..lineTo(xRight, bottomRight)
      ..cubicTo(midX, bottomRight, midX, bottomLeft, xLeft, bottomLeft)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = color.withAlpha(_ribbonAlpha),
    );
  }

  void _drawNodes(
    Canvas canvas,
    double x,
    List<SankeyDatum> nodes,
    double scale,
  ) {
    double cursor = 0.0;
    for (final SankeyDatum node in nodes) {
      final double nodeHeight = node.value * scale;
      final RRect rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, cursor, _nodeWidth, nodeHeight),
        const Radius.circular(3.0),
      );
      canvas.drawRRect(rect, Paint()..color = node.color);
      cursor += nodeHeight + _gap;
    }
  }

  void _drawHub(Canvas canvas, double x, double height) {
    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, 0.0, _nodeWidth, height),
      const Radius.circular(3.0),
    );
    canvas.drawRRect(rect, Paint()..color = hubColor);
  }

  double _sum(List<SankeyDatum> data) =>
      data.fold(0.0, (sum, datum) => sum + datum.value);

  @override
  bool shouldRepaint(covariant _SankeyPainter oldDelegate) {
    return oldDelegate.sources != sources ||
        oldDelegate.targets != targets ||
        oldDelegate.hubColor != hubColor;
  }
}
