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
  private const val KEY_BUDGET_UUID = "budgetUuid_"

  data class Config(
    val hideAmounts: Boolean,
    /**
     * `Budget.uuid`, or null for auto — resolve to `summary.worstId` at render
     * time.
     *
     * A uuid rather than an ObjectBox id because this outlives the payload it
     * came from. The app's export omits ids, so restoring a backup renumbers
     * every budget; a stored id would then resolve to a *different* budget and
     * the widget would confidently render the wrong one.
     */
    val budgetUuid: String?,
  )

  val default = Config(hideAmounts = false, budgetUuid = null)

  fun read(context: Context, appWidgetId: Int): Config {
    if (appWidgetId <= 0) return default

    val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

    return Config(
      hideAmounts = prefs.getBoolean(KEY_HIDE_AMOUNTS + appWidgetId, false),
      // Absent means auto, so no sentinel value is needed.
      budgetUuid = prefs.getString(KEY_BUDGET_UUID + appWidgetId, null),
    )
  }

  fun write(context: Context, appWidgetId: Int, config: Config) {
    if (appWidgetId <= 0) return

    val editor = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
      .putBoolean(KEY_HIDE_AMOUNTS + appWidgetId, config.hideAmounts)

    if (config.budgetUuid == null) {
      editor.remove(KEY_BUDGET_UUID + appWidgetId)
    } else {
      editor.putString(KEY_BUDGET_UUID + appWidgetId, config.budgetUuid)
    }

    editor.commit()
  }

  /**
   * Called from the receivers' `onDeleted`, so a recycled appWidgetId can't
   * inherit a deleted widget's budget or, worse, its "amounts visible" state.
   */
  fun clear(context: Context, appWidgetIds: IntArray) {
    val editor = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE).edit()
    for (id in appWidgetIds) {
      editor.remove(KEY_HIDE_AMOUNTS + id).remove(KEY_BUDGET_UUID + id)
    }
    editor.apply()
  }
}
