package mn.flow.flow.glance

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

/**
 * Class name is part of the contract — Dart calls
 * `mn.flow.flow.glance.BudgetRollupReceiver` by its fully qualified name.
 */
class BudgetRollupReceiver : GlanceAppWidgetReceiver() {
  override val glanceAppWidget: GlanceAppWidget = BudgetRollup()

  override fun onDeleted(context: Context, appWidgetIds: IntArray) {
    super.onDeleted(context, appWidgetIds)
    // appWidgetIds get recycled; a new widget must not inherit a deleted one's
    // "amounts visible" state.
    BudgetWidgetConfigStore.clear(context, appWidgetIds)
  }
}
