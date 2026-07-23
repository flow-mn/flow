package mn.flow.flow.glance

import android.content.Context

/**
 * Per-`appWidgetId` widget configuration.
 *
 * Deliberately NOT stored in the Glance/`home_widget` state: that store is one
 * shared bag of keys owned by Dart, which rewrites it on every sync and knows
 * nothing about these settings. Two pinned widgets on the same home screen must
 * be able to track different budgets, so the key has to be the widget instance.
 */
object BudgetWidgetConfigStore {
  private const val PREFS = "mn.flow.flow.budget_widgets"
  private const val KEY_HIDE_AMOUNTS = "hideAmounts_"
  private const val KEY_BUDGET_ID = "budgetId_"

  /** Sentinel for "follow whichever budget needs attention". */
  private const val AUTO_WORST = -1L

  data class Config(
    val hideAmounts: Boolean,
    /** null means auto — resolve to `summary.worstId` at render time. */
    val budgetId: Long?,
  )

  val default = Config(hideAmounts = false, budgetId = null)

  fun read(context: Context, appWidgetId: Int): Config {
    if (appWidgetId <= 0) return default

    val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    val budgetId = prefs.getLong(KEY_BUDGET_ID + appWidgetId, AUTO_WORST)

    return Config(
      hideAmounts = prefs.getBoolean(KEY_HIDE_AMOUNTS + appWidgetId, false),
      budgetId = if (budgetId == AUTO_WORST) null else budgetId,
    )
  }

  fun write(context: Context, appWidgetId: Int, config: Config) {
    if (appWidgetId <= 0) return

    context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
      .edit()
      .putBoolean(KEY_HIDE_AMOUNTS + appWidgetId, config.hideAmounts)
      .putLong(KEY_BUDGET_ID + appWidgetId, config.budgetId ?: AUTO_WORST)
      .commit()
  }

  /**
   * Called from the receivers' `onDeleted`, so a recycled appWidgetId can't
   * inherit a deleted widget's budget or, worse, its "amounts visible" state.
   */
  fun clear(context: Context, appWidgetIds: IntArray) {
    val editor = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
    for (id in appWidgetIds) {
      editor.remove(KEY_HIDE_AMOUNTS + id).remove(KEY_BUDGET_ID + id)
    }
    editor.apply()
  }
}
