package mn.flow.flow.glance

import android.content.Context
import mn.flow.flow.R

/**
 * Fallbacks for every label the payload is allowed to omit.
 *
 * A sync can fire before Flow's translations have loaded, in which case Dart
 * drops the key rather than publishing an empty string — so every label read
 * here goes through a function that guarantees a real word. Blank text on a
 * home screen looks like a broken widget, which is worse than the wrong
 * language.
 *
 * These live in `strings.xml`/`plurals.xml` rather than as Kotlin literals so
 * the widget picker and the widget itself pull from one place, and so the
 * count-bearing ones get Android's plural rules instead of a naive "s".
 */
object BudgetWidgetLabels {
  fun title(context: Context, payload: BudgetPayload?): String =
    payload?.labels?.title ?: context.getString(R.string.budget_widget_title)

  fun empty(context: Context, payload: BudgetPayload?): String =
    payload?.labels?.empty ?: context.getString(R.string.budget_widget_empty)

  fun missingBudget(context: Context, payload: BudgetPayload?): String =
    payload?.labels?.missingBudget
      ?: context.getString(R.string.budget_widget_missing_budget)

  fun onTrack(context: Context, payload: BudgetPayload?): String =
    payload?.labels?.onTrack ?: context.getString(R.string.budget_widget_on_track)

  fun over(context: Context, payload: BudgetPayload): String =
    payload.labels.over ?: context.resources.getQuantityString(
      R.plurals.budget_widget_over_count,
      payload.summary.overCount,
      payload.summary.overCount,
    )

  fun nearing(context: Context, payload: BudgetPayload): String =
    payload.labels.nearing ?: context.resources.getQuantityString(
      R.plurals.budget_widget_nearing_count,
      payload.summary.warningCount,
      payload.summary.warningCount,
    )

  fun tracked(context: Context, payload: BudgetPayload): String =
    payload.labels.tracked ?: context.resources.getQuantityString(
      R.plurals.budget_widget_tracked_count,
      payload.summary.budgetCount,
      payload.summary.budgetCount,
    )

  /**
   * The status as a word. Colour can't carry status on its own — Material You
   * recolours the surface under the bar and themed icons flatten hue away — so
   * this is never optional on screen, only optional in the payload.
   */
  fun status(context: Context, entry: BudgetEntry): String {
    entry.statusLabel?.let { return it }

    return context.getString(
      when (entry.status) {
        BudgetStatus.OVER -> R.string.budget_widget_status_over
        BudgetStatus.WARNING -> R.string.budget_widget_status_warning
        BudgetStatus.HEALTHY -> R.string.budget_widget_status_healthy
      }
    )
  }

  /**
   * A finished period has no meaningful day count, so it gets its own string
   * rather than "0 days left".
   */
  fun daysLeft(context: Context, entry: BudgetEntry): String {
    entry.daysLeftLabel?.let { return it }

    if (entry.daysLeft < 0) {
      return context.getString(R.string.budget_widget_period_ended)
    }

    return context.resources.getQuantityString(
      R.plurals.budget_widget_days_left,
      entry.daysLeft,
      entry.daysLeft,
    )
  }
}
