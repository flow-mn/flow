package mn.flow.flow.glance

import android.content.Context
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver

/**
 * Class name is part of the contract — Dart calls
 * `mn.flow.flow.glance.BudgetPinnedReceiver` by its fully qualified name.
 */
class BudgetPinnedReceiver : GlanceAppWidgetReceiver() {
  override val glanceAppWidget: GlanceAppWidget = BudgetPinned()

  override fun onDeleted(context: Context, appWidgetIds: IntArray) {
    super.onDeleted(context, appWidgetIds)
    BudgetWidgetConfigStore.clear(context, appWidgetIds)
  }
}
