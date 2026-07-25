package mn.flow.flow.glance

import org.json.JSONArray
import org.json.JSONObject

/**
 * Parsed form of the `budgetsPayload` JSON string Dart publishes through
 * `home_widget`. See `scratchpad/budget-widget-contract.md` — this file is the
 * single Kotlin transcription of that contract; both budget widgets read it and
 * neither re-parses anything itself.
 *
 * Parsing uses `org.json` (Android framework) on purpose: the widget process
 * has to stay cheap to start, and adding kotlinx.serialization would pull a
 * plugin plus runtime into an app that currently needs neither.
 */
enum class BudgetStatus {
  HEALTHY,
  WARNING,
  OVER,
  ;

  companion object {
    fun parse(raw: String?): BudgetStatus = when (raw?.lowercase()) {
      "over" -> OVER
      "warning" -> WARNING
      else -> HEALTHY
    }
  }
}

data class BudgetEntry(
  /**
   * `Budget.uuid` — the only handle that survives backup/restore, and so the
   * only one [BudgetWidgetConfigStore] may persist.
   *
   * The app's export omits ObjectBox ids, so a restore reinserts every budget
   * and renumbers it: a widget pinned by [id] would come back pointing at
   * whichever budget inherited that number.
   */
  val uuid: String,
  /** Current as of this payload only. Never store it — see [uuid]. */
  val id: Long,
  val name: String,
  val spent: String?,
  val limit: String?,
  val remaining: String?,
  val overBy: String?,
  /** Geometry and colour only — never displayed. Use [percentLabel] for that. */
  val percent: Int,
  /**
   * Pre-formatted in the *app's* locale. The widget process formats in the
   * *device* locale, so a phone set to a different language than Flow would
   * otherwise mix digit styles between this and every other string here.
   */
  val percentLabel: String,
  /** Not clamped — an over-budget entry exceeds 1.0. Clamp at the call site. */
  val ratio: Double,
  /** Colour and branching only — [statusLabel] is what the user reads. */
  val status: BudgetStatus,
  /**
   * The status as a word, so status never depends on colour alone. Absent when
   * the sync beat the app's translations; see [BudgetWidgetLabels.status].
   */
  val statusLabel: String?,
  val daysLeft: Int,
  /** Absent when the app synced before its translations finished loading. */
  val daysLeftLabel: String?,
  val periodLabel: String?,
  val hasMissingData: Boolean,
)

data class BudgetSummary(
  val budgetCount: Int,
  val overCount: Int,
  val warningCount: Int,
  val hasMissingData: Boolean,
  val worstId: Long?,
)

/**
 * Every field is nullable because the contract allows any `labels` key to be
 * absent. Callers must supply their own fallback; rendering a blank where a
 * label belongs is explicitly forbidden.
 */
data class BudgetLabels(
  val title: String?,
  val empty: String?,
  val onTrack: String?,
  val over: String?,
  val nearing: String?,
  val tracked: String?,
  val missingBudget: String?,
)

data class BudgetPayload(
  val summary: BudgetSummary,
  val budgets: List<BudgetEntry>,
  val labels: BudgetLabels,
) {
  /**
   * The lookup for anything that was *stored* — i.e. the pinned widget's
   * choice, which has to survive a restore renumbering every budget.
   */
  fun budgetByUuid(uuid: String?): BudgetEntry? =
    if (uuid.isNullOrEmpty()) null else budgets.firstOrNull { it.uuid == uuid }

  /**
   * Only valid within one payload: [BudgetSummary.worstId] is an id from this
   * same snapshot, so it can't have drifted out from under the list beside it.
   */
  private fun budgetById(id: Long?): BudgetEntry? =
    if (id == null) null else budgets.firstOrNull { it.id == id }

  /** The single most urgent budget, or null when there are none. */
  val worst: BudgetEntry?
    get() = budgetById(summary.worstId)

  companion object {
    const val PAYLOAD_KEY = "budgetsPayload"
    const val SUPPORTED_VERSION = 2

    /**
     * Returns null for every unusable input — key absent, blank, malformed, or
     * written by a newer app than this widget understands. Callers render their
     * empty state on null rather than distinguishing the causes, because the
     * user-visible outcome is identical.
     */
    fun parse(raw: String?): BudgetPayload? {
      if (raw.isNullOrBlank()) return null

      return try {
        val json = JSONObject(raw)
        if (json.optInt("version", -1) != SUPPORTED_VERSION) return null

        BudgetPayload(
          summary = parseSummary(json.optJSONObject("summary")),
          budgets = parseBudgets(json.optJSONArray("budgets")),
          labels = parseLabels(json.optJSONObject("labels")),
        )
      } catch (e: Exception) {
        null
      }
    }

    private fun parseSummary(json: JSONObject?): BudgetSummary {
      if (json == null) return BudgetSummary(0, 0, 0, false, null)

      return BudgetSummary(
        budgetCount = json.optInt("budgetCount", 0),
        overCount = json.optInt("overCount", 0),
        warningCount = json.optInt("warningCount", 0),
        hasMissingData = json.optBoolean("hasMissingData", false),
        worstId = json.optLongOrNull("worstId"),
      )
    }

    private fun parseBudgets(json: JSONArray?): List<BudgetEntry> {
      if (json == null) return emptyList()

      val budgets = ArrayList<BudgetEntry>(json.length())
      for (i in 0 until json.length()) {
        val entry = json.optJSONObject(i) ?: continue
        // Both are required: an entry with no uuid can't be pinned, and one
        // with no id can't be linked to.
        val uuid = entry.optStringOrNull("uuid") ?: continue
        val id = entry.optLongOrNull("id") ?: continue
        val percent = entry.optInt("percent", 0)

        budgets.add(
          BudgetEntry(
            uuid = uuid,
            id = id,
            // The one string with no sensible fallback: a nameless budget is
            // better shown blank than shown somebody else's word for "budget".
            name = entry.optStringOrNull("name") ?: "",
            spent = entry.optStringOrNull("spent"),
            limit = entry.optStringOrNull("limit"),
            remaining = entry.optStringOrNull("remaining"),
            overBy = entry.optStringOrNull("overBy"),
            percent = percent,
            // Rule 0 guarantees this key, so the fallback is a can't-render-a-
            // blank-hero-number guard rather than a supported code path.
            percentLabel = entry.optStringOrNull("percentLabel") ?: "$percent%",
            ratio = entry.optDouble("ratio", 0.0).let { if (it.isNaN()) 0.0 else it },
            status = BudgetStatus.parse(entry.optStringOrNull("status")),
            statusLabel = entry.optStringOrNull("statusLabel"),
            daysLeft = entry.optInt("daysLeft", 0),
            daysLeftLabel = entry.optStringOrNull("daysLeftLabel"),
            periodLabel = entry.optStringOrNull("periodLabel"),
            hasMissingData = entry.optBoolean("hasMissingData", false),
          )
        )
      }
      return budgets
    }

    private fun parseLabels(json: JSONObject?): BudgetLabels = BudgetLabels(
      title = json?.optStringOrNull("title"),
      empty = json?.optStringOrNull("empty"),
      onTrack = json?.optStringOrNull("onTrack"),
      over = json?.optStringOrNull("over"),
      nearing = json?.optStringOrNull("nearing"),
      tracked = json?.optStringOrNull("tracked"),
      missingBudget = json?.optStringOrNull("missingBudget"),
    )
  }
}

/**
 * `optString` returns "" for an absent key, which would paint a blank line
 * where a label belongs. Absent and blank both mean "use your fallback".
 */
private fun JSONObject.optStringOrNull(key: String): String? {
  if (!has(key) || isNull(key)) return null
  return optString(key, "").takeIf { it.isNotBlank() }
}

private fun JSONObject.optLongOrNull(key: String): Long? {
  if (!has(key) || isNull(key)) return null
  return optLong(key, Long.MIN_VALUE).takeIf { it != Long.MIN_VALUE }
}
