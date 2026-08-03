package mn.flow.flow.glance

import android.appwidget.AppWidgetManager
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.LocalSize
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.width
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

/**
 * 4x2 roll-up: how many budgets need attention, plus the single worst one.
 *
 * There is deliberately no combined "spent / limit" here. Flow's budgets
 * overlap and span different periods, so any total across them double-counts;
 * the roll-up is counts plus one representative budget by design.
 */
class BudgetRollup : GlanceAppWidget() {
  override val sizeMode = SizeMode.Exact

  override val stateDefinition: GlanceStateDefinition<*>
    get() = HomeWidgetGlanceStateDefinition()

  override suspend fun provideGlance(context: Context, id: GlanceId) {
    // Configuration is per widget instance, so it can't live in the Glance
    // state Dart owns — see BudgetWidgetConfigStore.
    val appWidgetId = try {
      GlanceAppWidgetManager(context).getAppWidgetId(id)
    } catch (e: Exception) {
      AppWidgetManager.INVALID_APPWIDGET_ID
    }
    val config = BudgetWidgetConfigStore.read(context, appWidgetId)

    provideContent {
      GlanceTheme {
        Content(context, currentState(), config)
      }
    }
  }
}

@Composable
private fun Content(
  context: Context,
  state: HomeWidgetGlanceState,
  config: BudgetWidgetConfigStore.Config,
) {
  val payload = BudgetPayload.parse(
    state.preferences.getString(BudgetPayload.PAYLOAD_KEY, null)
  )
  val worst = payload?.worst

  // The overview, not the plain list: this widget *is* that page in
  // miniature, so a tap should expand what it shows.
  BudgetWidgetUi.Frame(padding = 16.dp, destination = "/stats/budgets") {
    if (payload == null || payload.budgets.isEmpty()) {
      BudgetWidgetUi.EmptyState(
        context = context,
        title = BudgetWidgetLabels.title(context, payload),
        message = BudgetWidgetLabels.empty(context, payload),
      )
      return@Frame
    }

    // The frame's single 16dp inset, plus 4dp of slack so the bar stays off
    // the rounded corner on launchers that round more aggressively.
    val barWidth = LocalSize.current.width - 16.dp * 2 - 4.dp

    val overCount = payload.summary.overCount
    val warningCount = payload.summary.warningCount

    val headline = when {
      overCount > 0 -> BudgetWidgetLabels.over(context, payload)
      warningCount > 0 -> BudgetWidgetLabels.nearing(context, payload)
      else -> BudgetWidgetLabels.onTrack(context, payload)
    }
    val headlineStatus = when {
      overCount > 0 -> BudgetStatus.OVER
      warningCount > 0 -> BudgetStatus.WARNING
      else -> BudgetStatus.HEALTHY
    }
    // When both counts are non-zero the headline can only carry one of them,
    // so the "nearing" count rides along on the subtitle rather than vanishing.
    val subtitle = if (overCount > 0 && warningCount > 0) {
      "${BudgetWidgetLabels.nearing(context, payload)} · " +
        BudgetWidgetLabels.tracked(context, payload)
    } else {
      BudgetWidgetLabels.tracked(context, payload)
    }

    Column(modifier = GlanceModifier.fillMaxSize()) {
      Text(
        text = BudgetWidgetLabels.title(context, payload),
        style = TextStyle(
          color = GlanceTheme.colors.onSurfaceVariant,
          fontSize = 12.sp,
        ),
        maxLines = 1,
      )
      Spacer(modifier = GlanceModifier.height(3.dp))
      Text(
        text = headline,
        style = TextStyle(
          // Colour alone never carries status: the headline is the count in
          // words, so a tinted or monochrome render loses nothing.
          color = BudgetWidgetUi.statusColor(headlineStatus),
          fontSize = 19.sp,
          fontWeight = FontWeight.Bold,
        ),
        maxLines = 1,
      )
      Spacer(modifier = GlanceModifier.height(2.dp))
      Text(
        text = subtitle,
        style = TextStyle(
          color = GlanceTheme.colors.onSurfaceVariant,
          fontSize = 12.sp,
        ),
        maxLines = 1,
      )

      Spacer(modifier = GlanceModifier.defaultWeight())

      if (worst != null) {
        WorstBudget(context, worst, config.hideAmounts, barWidth)
      }
    }
  }
}

@Composable
private fun WorstBudget(
  context: Context,
  entry: BudgetEntry,
  hideAmounts: Boolean,
  barWidth: androidx.compose.ui.unit.Dp,
) {
  Column(modifier = GlanceModifier.fillMaxWidth()) {
    Row(
      modifier = GlanceModifier.fillMaxWidth(),
      verticalAlignment = Alignment.CenterVertically,
    ) {
      Text(
        text = entry.name,
        style = TextStyle(
          color = GlanceTheme.colors.onSurface,
          fontSize = 12.sp,
          fontWeight = FontWeight.Medium,
        ),
        maxLines = 1,
        modifier = GlanceModifier.defaultWeight(),
      )
      Spacer(modifier = GlanceModifier.width(8.dp))
      // The word, not just the colour: Material You can recolour the surface
      // out from under a red bar, and a themed home screen flattens hue.
      Text(
        text = BudgetWidgetLabels.status(context, entry),
        style = TextStyle(
          color = BudgetWidgetUi.statusColor(entry.status),
          fontSize = 11.sp,
        ),
        maxLines = 1,
      )
      Spacer(modifier = GlanceModifier.width(6.dp))
      Text(
        text = entry.percentLabel,
        style = TextStyle(
          color = BudgetWidgetUi.statusColor(entry.status),
          fontSize = 12.sp,
          fontWeight = FontWeight.Bold,
        ),
        maxLines = 1,
      )
    }

    Spacer(modifier = GlanceModifier.height(5.dp))
    BudgetWidgetUi.BudgetBar(
      barWidth,
      entry.ratio,
      entry.status,
      confirmedRatio = entry.confirmedRatio,
    )
    Spacer(modifier = GlanceModifier.height(5.dp))

    Row(
      modifier = GlanceModifier.fillMaxWidth(),
      verticalAlignment = Alignment.CenterVertically,
    ) {
      Text(
        text = BudgetWidgetLabels.daysLeft(context, entry),
        style = TextStyle(
          color = GlanceTheme.colors.onSurfaceVariant,
          fontSize = 11.sp,
        ),
        maxLines = 1,
        modifier = GlanceModifier.defaultWeight(),
      )

      // The single branch that decides whether money reaches the home screen.
      // Nothing below this widget reads `spent`/`limit`/`remaining`/`overBy`.
      if (!hideAmounts) {
        val amounts = BudgetWidgetUi.amountsText(context, entry.spent, entry.limit)
        if (amounts != null) {
          Spacer(modifier = GlanceModifier.width(8.dp))
          Text(
            text = amounts,
            style = TextStyle(
              color = GlanceTheme.colors.onSurfaceVariant,
              fontSize = 11.sp,
            ),
            maxLines = 1,
          )
        }
      }
    }
  }
}
