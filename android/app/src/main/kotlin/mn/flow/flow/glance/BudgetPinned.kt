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
import androidx.glance.layout.Column
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition

/**
 * 2x2 pinned budget: one budget, one bar, one number.
 *
 * The budget is chosen in the configuration activity — either a specific
 * budget, stored by uuid, or "any budget that needs attention", which resolves
 * to `summary.worstId` at render time. The distinction matters: a widget that silently changes subject
 * on someone who pinned "Groceries" trains distrust of every red bar on the
 * home screen.
 */
class BudgetPinned : GlanceAppWidget() {
  override val sizeMode = SizeMode.Exact

  override val stateDefinition: GlanceStateDefinition<*>
    get() = HomeWidgetGlanceStateDefinition()

  override suspend fun provideGlance(context: Context, id: GlanceId) {
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

  BudgetWidgetUi.Frame(context, padding = 12.dp) {
    if (payload == null || payload.budgets.isEmpty()) {
      BudgetWidgetUi.EmptyState(
        context = context,
        title = BudgetWidgetLabels.title(context, payload),
        message = BudgetWidgetLabels.empty(context, payload),
      )
      return@Frame
    }

    // A null budgetUuid means "auto"; a non-null one that no longer resolves
    // means the user deleted the budget this widget was pinned to.
    val entry = if (config.budgetUuid == null) {
      payload.worst
    } else {
      payload.budgetByUuid(config.budgetUuid)
    }

    if (entry == null) {
      BudgetWidgetUi.EmptyState(
        context = context,
        title = BudgetWidgetLabels.title(context, payload),
        message = if (config.budgetUuid == null) {
          BudgetWidgetLabels.empty(context, payload)
        } else {
          BudgetWidgetLabels.missingBudget(context, payload)
        },
      )
      return@Frame
    }

    val barWidth = LocalSize.current.width - 8.dp * 2 - 12.dp * 2 - 4.dp

    Column(modifier = GlanceModifier.fillMaxSize()) {
      Text(
        text = entry.name,
        style = TextStyle(
          color = GlanceTheme.colors.onSurface,
          fontSize = 12.5.sp,
          fontWeight = FontWeight.Medium,
        ),
        maxLines = 1,
      )

      Spacer(modifier = GlanceModifier.defaultWeight())

      // Pre-formatted in the app's locale — deriving "84%" from the int here
      // would format in the device's locale and clash with every other string.
      Text(
        text = entry.percentLabel,
        style = TextStyle(
          color = BudgetWidgetUi.statusColor(entry.status),
          fontSize = 26.sp,
          fontWeight = FontWeight.Bold,
        ),
        maxLines = 1,
      )
      // Says what the colour says. A themed or recoloured home screen can wash
      // the status hue out entirely, and 2x2 has no room for a legend.
      Text(
        text = BudgetWidgetLabels.status(context, entry),
        style = TextStyle(
          color = BudgetWidgetUi.statusColor(entry.status),
          fontSize = 11.sp,
          fontWeight = FontWeight.Medium,
        ),
        maxLines = 1,
        modifier = GlanceModifier.fillMaxWidth(),
      )

      Spacer(modifier = GlanceModifier.height(6.dp))
      BudgetWidgetUi.BudgetBar(barWidth, entry.ratio, entry.status, height = 8.dp)
      Spacer(modifier = GlanceModifier.height(6.dp))

      Text(
        text = BudgetWidgetLabels.daysLeft(context, entry),
        style = TextStyle(
          color = GlanceTheme.colors.onSurfaceVariant,
          fontSize = 11.sp,
        ),
        maxLines = 1,
        modifier = GlanceModifier.fillMaxWidth(),
      )

      // Amounts, or the period they belong to. `periodLabel` is a date, never a
      // figure, so it is safe to keep showing when amounts are hidden.
      val secondary = if (config.hideAmounts) {
        entry.periodLabel
      } else {
        BudgetWidgetUi.amountsText(context, entry.spent, entry.limit)
      }

      if (secondary != null) {
        Text(
          text = secondary,
          style = TextStyle(
            color = GlanceTheme.colors.onSurfaceVariant,
            fontSize = 11.sp,
          ),
          maxLines = 1,
          modifier = GlanceModifier.fillMaxWidth(),
        )
      }
    }
  }
}
