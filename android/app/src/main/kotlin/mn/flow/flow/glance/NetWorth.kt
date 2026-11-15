package mn.flow.flow.glance

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.Shader
import android.os.Build
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.ColorFilter
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.ContentScale
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import mn.flow.flow.MainActivity
import mn.flow.flow.R

/**
 * Net worth today, the change over the last 30 days, and a sparkline of those
 * 30 days. Data comes from lib/services/net_worth_widget_sync.dart.
 *
 * Glance has no chart primitive, so the line is drawn into a bitmap sized to
 * the widget. SizeMode.Exact re-renders on resize, keeping it crisp.
 */
class NetWorth : GlanceAppWidget() {
  override val sizeMode = SizeMode.Exact

  // Picker preview (Android 15+): the real content on sample data.
  override val previewSizeMode = SizeMode.Responsive(WidgetPreviews.sizesNetWorth)

  override suspend fun providePreview(context: Context, widgetCategory: Int) {
    provideContent {
      GlanceTheme {
        NetWorthContent(context, WidgetPreviews.netWorthState(context))
      }
    }
  }

  override val stateDefinition: GlanceStateDefinition<*>
    get() = HomeWidgetGlanceStateDefinition()

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    provideContent {
      GlanceTheme {
        NetWorthContent(context, currentState())
      }
    }
  }
}

@Composable
private fun NetWorthContent(context: Context, state: HomeWidgetGlanceState) {
  val prefs = state.preferences
  val label = prefs.getString("netWorthLabel", null) ?: "Net worth"
  val amount = prefs.getString("netWorthAmount", null) ?: "---"
  val delta = prefs.getString("netWorthDelta", null)
  val positive = prefs.getBoolean("netWorthDeltaPositive", true)
  val rangeLabel = prefs.getString("netWorthRangeLabel", null) ?: ""
  val samples = prefs.getString("netWorthSamples", null)
    ?.split(",")
    ?.mapNotNull { it.toDoubleOrNull() }
    ?: emptyList()

  // Same in light and dark, so a plain colour will do; the resource-id
  // ColorProvider overload is restricted to the Glance library itself.
  val trendColor = ColorProvider(
    Color(context.getColor(if (positive) R.color.income_green else R.color.expense_red))
  )

  val size = LocalSize.current
  val showChart = size.height >= 100.dp && samples.size >= 2

  Box(
    modifier = GlanceModifier
      .background(GlanceTheme.colors.widgetBackground)
      .fillMaxSize()
      .clickable(
        onClick = actionStartActivity(
          Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
          }
        )
      ),
  ) {
    Column(modifier = GlanceModifier.fillMaxSize()) {
      Column(
        modifier = GlanceModifier
          .fillMaxWidth()
          .padding(start = 16.dp, end = 16.dp, top = 16.dp, bottom = 4.dp),
      ) {
        Text(
          text = label,
          style = TextStyle(color = GlanceTheme.colors.onSurfaceVariant, fontSize = 13.sp),
          maxLines = 1,
        )
        Text(
          text = amount,
          style = TextStyle(
            color = GlanceTheme.colors.onSurface,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
          ),
          maxLines = 1,
        )
        if (delta != null) {
          Row(verticalAlignment = Alignment.CenterVertically) {
            Image(
              provider = ImageProvider(
                if (positive) R.drawable.ic_trending_up else R.drawable.ic_trending_down
              ),
              contentDescription = null,
              modifier = GlanceModifier.width(16.dp).height(16.dp),
              colorFilter = ColorFilter.tint(
                trendColor
              ),
            )
            Spacer(modifier = GlanceModifier.width(4.dp))
            Text(
              text = if (rangeLabel.isEmpty()) delta else "$delta · $rangeLabel",
              style = TextStyle(
                color = trendColor,
                fontSize = 12.sp,
              ),
              maxLines = 1,
            )
          }
        }
      }
      if (showChart) {
        // Edge to edge along the bottom: the launcher's rounded corners clip
        // the fill, so the chart reads as part of the card instead of a
        // separate box that stops short of the right edge.
        val chartSize = DpSize(size.width, size.height - 90.dp)
        if (chartSize.height > 24.dp) {
          val chart = sparkline(context, samples, chartSize)
          // Leftover space goes above the chart, which stays on the bottom edge.
          Spacer(modifier = GlanceModifier.defaultWeight())
          // The height is exactly what the bitmap was drawn at, but the width
          // is whatever the launcher gives us, which is rarely the reported
          // one (and never in the picker). The line can take that stretch;
          // the end dot can't, so it is a separate, fixed-size image on top.
          Box(
            modifier = GlanceModifier.fillMaxWidth().height(chartSize.height),
            contentAlignment = Alignment.TopEnd,
          ) {
            Image(
              provider = ImageProvider(chart.line),
              contentDescription = null,
              contentScale = ContentScale.FillBounds,
              modifier = GlanceModifier.fillMaxSize(),
            )
            Box(modifier = GlanceModifier.padding(top = chart.dotTop, end = DOT_END)) {
              Image(
                provider = ImageProvider(chart.dot),
                contentDescription = null,
                modifier = GlanceModifier.size(DOT_RADIUS * 2),
              )
            }
          }
        }
      }
    }
  }
}

private val STROKE = 2.5.dp
private val DOT_RADIUS = 3.5.dp

/** Gap between the dot and the widget's right edge. */
private val DOT_END = STROKE

private class Sparkline(val line: Bitmap, val dot: Bitmap, val dotTop: Dp)

/**
 * Draws [samples] as a line with a fading fill, in the system accent colour.
 * The "today" dot comes back as its own bitmap, with the offset to place it
 * at the end of the line.
 */
private fun sparkline(context: Context, samples: List<Double>, size: DpSize): Sparkline {
  val density = context.resources.displayMetrics.density
  val w = (size.width.value * density).toInt().coerceIn(32, 1600)
  val h = (size.height.value * density).toInt().coerceIn(16, 1000)

  val bitmap = Bitmap.createBitmap(w, h, Bitmap.Config.ARGB_8888)
  val canvas = Canvas(bitmap)

  val accent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
    context.getColor(android.R.color.system_accent1_300)
  } else {
    0xFFE7B6F7.toInt()
  }

  val stroke = STROKE.value * density
  val dot = DOT_RADIUS.value * density
  // Headroom above the peak and room for the end dot; the fill still runs to
  // the very bottom edge.
  val top = maxOf(h * 0.12f, dot + stroke)
  val bottom = h - h * 0.12f
  val left = 0f
  val right = w - dot - stroke
  // The axis never zooms in further than 2% of the balance: without a floor,
  // a month of +-20 on a balance of 10 000 fills the whole height and reads
  // like a dramatic swing. Smaller movements stay small, centred vertically.
  val rawMin = samples.min()
  val rawMax = samples.max()
  val floor = 0.02 * maxOf(kotlin.math.abs(rawMin), kotlin.math.abs(rawMax))
  val pad = maxOf(0.0, floor - (rawMax - rawMin)) / 2
  val min = rawMin - pad
  val max = rawMax + pad
  val span = if (max - min < 1e-9) 1.0 else max - min

  fun x(i: Int) = left + (right - left) * i / (samples.size - 1).toFloat()
  fun y(v: Double) =
    if (max - min < 1e-9) (top + bottom) / 2f
    else (bottom - (bottom - top) * ((v - min) / span)).toFloat()

  val line = Path()
  samples.forEachIndexed { i, v ->
    if (i == 0) line.moveTo(x(i), y(v)) else line.lineTo(x(i), y(v))
  }

  // Fill to the bitmap's right and bottom edges so nothing looks cut off.
  val fill = Path(line).apply {
    lineTo(w.toFloat(), y(samples.last()))
    lineTo(w.toFloat(), h.toFloat())
    lineTo(x(0), h.toFloat())
    close()
  }

  canvas.drawPath(fill, Paint(Paint.ANTI_ALIAS_FLAG).apply {
    style = Paint.Style.FILL
    shader = LinearGradient(
      0f, top, 0f, h.toFloat(),
      (accent and 0x00FFFFFF) or 0x55000000, accent and 0x00FFFFFF,
      Shader.TileMode.CLAMP,
    )
  })

  canvas.drawPath(line, Paint(Paint.ANTI_ALIAS_FLAG).apply {
    style = Paint.Style.STROKE
    strokeWidth = stroke
    strokeJoin = Paint.Join.ROUND
    strokeCap = Paint.Cap.ROUND
    color = accent
  })

  // Marks "today" at the end of the line.
  val d = (dot * 2).toInt().coerceAtLeast(2)
  val dotBitmap = Bitmap.createBitmap(d, d, Bitmap.Config.ARGB_8888)
  Canvas(dotBitmap).drawCircle(d / 2f, d / 2f, d / 2f, Paint(Paint.ANTI_ALIAS_FLAG).apply {
    style = Paint.Style.FILL
    color = accent
  })

  val dotTop = (y(samples.last()) / density).dp - DOT_RADIUS
  return Sparkline(bitmap, dotBitmap, if (dotTop.value < 0f) 0.dp else dotTop)
}
