package mn.flow.flow.glance

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.BroadcastReceiver
import android.content.ComponentName
import android.content.Intent
import android.os.Bundle
import android.util.TypedValue
import android.view.Gravity
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.LinearLayout
import android.widget.RadioButton
import android.widget.RadioGroup
import android.widget.ScrollView
import android.widget.Switch
import android.widget.TextView
import es.antonborri.home_widget.HomeWidgetPlugin
import mn.flow.flow.R

/**
 * Widget configuration screen, shown by the launcher when a budget widget is
 * placed (and again on API 31+, where both providers are `reconfigurable`).
 *
 * Built with plain framework views on purpose. This runs before the Flutter
 * engine exists and has to start fast on a cold process; pulling in Compose or
 * AppCompat for two controls would trade a measurable delay for nothing the
 * user can see. Day/night comes from the theme, matching how `NormalTheme`
 * already switches in `styles.xml`.
 */
abstract class BudgetWidgetConfigActivity : Activity() {
  /** The pinned widget targets one budget; the roll-up covers all of them. */
  protected abstract val showsBudgetPicker: Boolean

  protected abstract val titleRes: Int

  /** Receiver to poke once the configuration is saved. */
  protected abstract val receiverClass: Class<out BroadcastReceiver>

  private var appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID

  private var hideAmountsSwitch: Switch? = null
  private var budgetGroup: RadioGroup? = null

  /**
   * Parallel to the radio group: index -> `Budget.uuid`, null for "auto".
   *
   * Uuids, not ObjectBox ids — see [BudgetWidgetConfigStore.Config.budgetUuid].
   */
  private val optionUuids = ArrayList<String?>()

  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)

    // Backing out of configuration must leave no widget behind, so the
    // cancelled result is set before anything can go wrong.
    setResult(RESULT_CANCELED)

    appWidgetId = intent?.extras?.getInt(
      AppWidgetManager.EXTRA_APPWIDGET_ID,
      AppWidgetManager.INVALID_APPWIDGET_ID,
    ) ?: AppWidgetManager.INVALID_APPWIDGET_ID

    if (appWidgetId == AppWidgetManager.INVALID_APPWIDGET_ID) {
      finish()
      return
    }

    // A configuration activity has to be exported for the launcher to start
    // it, which means any app on the device can start it too, with an id it
    // picked. Without this check that caller gets the budget picker — the
    // user's budget names, on screen, on demand — and a Save would rewrite a
    // real widget's privacy setting. Only ids belonging to one of our own
    // providers are ours to configure.
    if (!ownsAppWidget(appWidgetId)) {
      finish()
      return
    }

    setTitle(titleRes)
    setContentView(buildView())
  }

  /** Whether [id] is bound to one of this app's budget widget providers. */
  private fun ownsAppWidget(id: Int): Boolean {
    val manager = AppWidgetManager.getInstance(this) ?: return false

    return BUDGET_RECEIVERS.any { receiver ->
      manager
        .getAppWidgetIds(ComponentName(this, receiver))
        ?.contains(id) == true
    }
  }

  private fun buildView(): View {
    val existing = BudgetWidgetConfigStore.read(this, appWidgetId)
    val payload = BudgetPayload.parse(
      HomeWidgetPlugin.getData(this).getString(BudgetPayload.PAYLOAD_KEY, null)
    )

    val root = LinearLayout(this).apply {
      orientation = LinearLayout.VERTICAL
      setPadding(dp(24), dp(24), dp(24), dp(24))
    }

    root.addView(
      TextView(this).apply {
        setText(titleRes)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 22f)
      }
    )

    if (showsBudgetPicker) {
      root.addView(sectionHeader(R.string.budget_widget_config_budget))
      root.addView(buildBudgetPicker(payload, existing.budgetUuid))
    }

    root.addView(sectionHeader(R.string.budget_widget_config_privacy))
    root.addView(
      Switch(this).apply {
        setText(R.string.budget_widget_config_hide_amounts)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
        isChecked = existing.hideAmounts
        hideAmountsSwitch = this
      }
    )
    root.addView(
      TextView(this).apply {
        setText(R.string.budget_widget_config_hide_amounts_summary)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
        alpha = 0.7f
        setPadding(0, dp(4), 0, 0)
      }
    )

    root.addView(buildButtons())

    return ScrollView(this).apply {
      // targetSdk 36 lays this out edge-to-edge, starting at y=0 — without
      // this the title would sit under the status bar and the buttons under
      // the gesture bar.
      fitsSystemWindows = true

      addView(
        root,
        ViewGroup.LayoutParams(
          ViewGroup.LayoutParams.MATCH_PARENT,
          ViewGroup.LayoutParams.WRAP_CONTENT,
        ),
      )
    }
  }

  private fun sectionHeader(textRes: Int): View = TextView(this).apply {
    setText(textRes)
    setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
    alpha = 0.7f
    setPadding(0, dp(24), 0, dp(8))
  }

  private fun buildBudgetPicker(payload: BudgetPayload?, selectedUuid: String?): View {
    val group = RadioGroup(this).apply { orientation = LinearLayout.VERTICAL }
    budgetGroup = group
    optionUuids.clear()

    // Always first, and always available: resolves to `summary.worstId` at
    // render time rather than being baked in here.
    optionUuids.add(null)
    group.addView(
      RadioButton(this).apply {
        id = View.generateViewId()
        setText(R.string.budget_widget_config_auto)
        setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
      }
    )

    val budgets = payload?.budgets.orEmpty()
    for (budget in budgets) {
      optionUuids.add(budget.uuid)
      group.addView(
        RadioButton(this).apply {
          id = View.generateViewId()
          text = budget.name
          setTextSize(TypedValue.COMPLEX_UNIT_SP, 16f)
        }
      )
    }

    if (budgets.isEmpty()) {
      group.addView(
        TextView(this).apply {
          setText(R.string.budget_widget_config_no_budgets)
          setTextSize(TypedValue.COMPLEX_UNIT_SP, 13f)
          alpha = 0.7f
          setPadding(0, dp(4), 0, 0)
        }
      )
    }

    // A previously pinned budget that has since been deleted falls back to
    // auto rather than leaving nothing selected.
    val selectedIndex = optionUuids.indexOf(selectedUuid).takeIf { it >= 0 } ?: 0
    (group.getChildAt(selectedIndex) as? RadioButton)?.isChecked = true

    return group
  }

  private fun buildButtons(): View = LinearLayout(this).apply {
    orientation = LinearLayout.HORIZONTAL
    gravity = Gravity.END
    setPadding(0, dp(24), 0, 0)

    addView(
      Button(this@BudgetWidgetConfigActivity).apply {
        setText(R.string.budget_widget_config_cancel)
        setOnClickListener { finish() }
      }
    )
    addView(
      Button(this@BudgetWidgetConfigActivity).apply {
        setText(R.string.budget_widget_config_save)
        setOnClickListener { save() }
      }
    )
  }

  private fun save() {
    val budgetUuid = if (showsBudgetPicker) selectedBudgetUuid() else null

    BudgetWidgetConfigStore.write(
      this,
      appWidgetId,
      BudgetWidgetConfigStore.Config(
        hideAmounts = hideAmountsSwitch?.isChecked == true,
        budgetUuid = budgetUuid,
      ),
    )

    // The launcher only guarantees an update for a newly placed widget, so a
    // reconfigure would otherwise keep showing the old budget until the next
    // Dart sync. Broadcasting to the receiver re-runs provideGlance either way.
    sendBroadcast(
      Intent(this, receiverClass).apply {
        action = AppWidgetManager.ACTION_APPWIDGET_UPDATE
        putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, intArrayOf(appWidgetId))
      }
    )

    setResult(
      RESULT_OK,
      Intent().putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId),
    )
    finish()
  }

  private fun selectedBudgetUuid(): String? {
    val group = budgetGroup ?: return null
    val checkedId = group.checkedRadioButtonId
    if (checkedId == View.NO_ID) return null

    val index = (0 until group.childCount)
      .firstOrNull { group.getChildAt(it).id == checkedId }
      ?: return null

    return optionUuids.getOrNull(index)
  }

  private fun dp(value: Int): Int =
    (value * resources.displayMetrics.density).toInt()
}

/** 4x2 roll-up: hide-amounts only, per the contract. */
class BudgetRollupConfigActivity : BudgetWidgetConfigActivity() {
  override val showsBudgetPicker = false
  override val titleRes = R.string.budget_rollup_widget_label
  override val receiverClass = BudgetRollupReceiver::class.java
}

/** 2x2 pinned: budget picker plus hide-amounts. */
class BudgetPinnedConfigActivity : BudgetWidgetConfigActivity() {
  override val showsBudgetPicker = true
  override val titleRes = R.string.budget_pinned_widget_label
  override val receiverClass = BudgetPinnedReceiver::class.java
}

/**
 * Every provider whose widget ids these configuration activities may edit.
 *
 * Listed together rather than per-subclass on purpose: a launcher is free to
 * send either config activity either provider's id, and both are ours.
 */
private val BUDGET_RECEIVERS = listOf(
  BudgetRollupReceiver::class.java,
  BudgetPinnedReceiver::class.java,
)
