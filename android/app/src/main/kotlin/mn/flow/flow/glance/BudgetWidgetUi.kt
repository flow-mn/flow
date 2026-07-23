package mn.flow.flow.glance

import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.clickable
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextAlign
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import mn.flow.flow.MainActivity
import mn.flow.flow.R

/**
 * Pieces shared by the roll-up and pinned budget widgets.
 *
 * Glance renders to RemoteViews, so there is no arc primitive and no fractional
 * width: progress is a horizontal bar whose filled width is computed in dp from
 * `LocalSize`. That is why every caller has to hand [BudgetBar] the width it
 * actually has.
 */
object BudgetWidgetUi {
  /**
   * Flow has no warning hue. The app softens the expense colour to ~69% alpha
   * for "nearing"; `budget_warning` is that same red pre-multiplied, so the
   * widgets don't introduce a fourth colour into the product.
   */
  fun statusColor(status: BudgetStatus): ColorProvider = when (status) {
    BudgetStatus.OVER -> ColorProvider(R.color.expense_red)
    BudgetStatus.WARNING -> ColorProvider(R.color.budget_warning)
    BudgetStatus.HEALTHY -> ColorProvider(R.color.income_green)
  }

  /** Every budget widget opens the app; matches the Summary widget. */
  fun launchAppIntent(context: Context): Intent =
    Intent(context, MainActivity::class.java).apply {
      addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    }

  /**
   * The widget's outer chrome: launcher background, tap-to-open, and the 16dp
   * surface card the rest of Flow's widgets sit on.
   */
  @Composable
  fun Frame(context: Context, padding: Dp, content: @Composable () -> Unit) {
    Box(
      modifier = GlanceModifier
        .background(GlanceTheme.colors.widgetBackground)
        .fillMaxSize()
        .clickable(onClick = actionStartActivity(launchAppIntent(context))),
    ) {
      Box(
        modifier = GlanceModifier
          .fillMaxSize()
          .padding(8.dp),
      ) {
        Box(
          modifier = GlanceModifier
            .fillMaxSize()
            .background(GlanceTheme.colors.surfaceVariant)
            .cornerRadius(16.dp)
            .padding(padding),
        ) {
          content()
        }
      }
    }
  }

  /**
   * `ratio` is not clamped by the contract — an over-budget entry exceeds 1.0.
   * A full bar can't express *how far* over, which is why the status colour and
   * the percent text carry that information instead.
   */
  @Composable
  fun BudgetBar(width: Dp, ratio: Double, status: BudgetStatus, height: Dp = 6.dp) {
    val clamped = ratio.coerceIn(0.0, 1.0).toFloat()
    val track = width.coerceAtLeast(0.dp)
    val filled = track * clamped

    Box(
      modifier = GlanceModifier
        .width(track)
        .height(height)
        .background(ColorProvider(R.color.budget_bar_track))
        .cornerRadius(height / 2),
    ) {
      if (clamped > 0f) {
        Box(
          modifier = GlanceModifier
            // A sliver of colour reads as "barely started"; zero width reads as
            // a rendering bug, so never draw less than a dot.
            .width(maxOf(filled, height))
            .height(height)
            .background(statusColor(status))
            .cornerRadius(height / 2),
        ) {}
      }
    }
  }

  /**
   * Shown when there is no payload, no budgets, or a payload from a newer app.
   * All three are the same thing to the user: nothing to look at yet.
   */
  @Composable
  fun EmptyState(context: Context, title: String, message: String) {
    Column(
      modifier = GlanceModifier.fillMaxSize(),
      verticalAlignment = Alignment.CenterVertically,
      horizontalAlignment = Alignment.CenterHorizontally,
    ) {
      Text(
        text = title,
        style = TextStyle(
          color = GlanceTheme.colors.onSurfaceVariant,
          fontSize = 12.sp,
          textAlign = TextAlign.Center,
        ),
        maxLines = 1,
      )
      Spacer(modifier = GlanceModifier.height(4.dp))
      Text(
        text = message,
        style = TextStyle(
          color = GlanceTheme.colors.onSurface,
          fontSize = 14.sp,
          fontWeight = FontWeight.Medium,
          textAlign = TextAlign.Center,
        ),
        maxLines = 2,
        modifier = GlanceModifier.fillMaxWidth(),
      )
    }
  }

  /** "spent / limit" — the separator is layout, not money formatting. */
  fun amountsText(context: Context, spent: String?, limit: String?): String? {
    if (spent == null && limit == null) return null
    if (spent == null || limit == null) return spent ?: limit
    return context.getString(R.string.budget_widget_amounts, spent, limit)
  }
}
