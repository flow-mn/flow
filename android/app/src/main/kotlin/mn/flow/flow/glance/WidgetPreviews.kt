package mn.flow.flow.glance

import android.content.Context
import android.content.SharedPreferences
import android.os.Build
import android.util.Log
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.glance.appwidget.GlanceAppWidgetManager
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetPlugin
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import java.util.concurrent.atomic.AtomicBoolean
import org.json.JSONArray
import org.json.JSONObject
import kotlin.reflect.KClass
import mn.flow.flow.R

/**
 * Generated widget-picker previews (Android 15+).
 *
 * Each widget's `providePreview` renders its real Glance content against the
 * sample state below, so the picker shows exactly what the widget draws —
 * same layout, same Material You colours — instead of a hand-drawn XML copy
 * that drifts. Older Android keeps the static `android:previewLayout`.
 */
object WidgetPreviews {
  private const val TAG = "FlowWidgetPreviews"
  private const val PREFS = "flow_widget_previews"
  private const val KEY_PUBLISHED_VERSION = "publishedVersion"
  private const val KEY_PUBLISHED_RECEIVERS = "publishedReceivers"

  /** One publish at a time: an activity recreated mid-publish must not start a second. */
  private val inFlight = AtomicBoolean(false)

  /**
   * Sizes the picker may render at. Launchers draw the preview in a box of
   * their own choosing (One UI's is noticeably smaller than Pixel's) and
   * use the size here that fits it most closely, so the ladder has to be
   * dense — with gaps, a launcher falls back to a much smaller size and the
   * content looks shrunk inside an oversized card.
   */
  private fun ladder(vararg wh: Pair<Int, Int>) = wh.map { DpSize(it.first.dp, it.second.dp) }.toSet()

  // The button widgets size their buttons from the box (min(w/2 - 24, h - 16)),
  // so a rung well below the picker's box draws visibly smaller buttons than
  // the placed widget. Besides the plain 2:1 / 1:1 steps these carry the
  // cell shapes launchers actually use (Pixel ~195x108 and ~195x227, One UI
  // ~157x80 and ~157x182), a little under so they still fit.
  val sizes2x1 = ladder(
    100 to 50, 120 to 60, 140 to 70, 150 to 75, 160 to 80, 170 to 85,
    180 to 90, 200 to 100, 220 to 110,
    155 to 79, 175 to 96, 185 to 102, 193 to 106, 210 to 116, 230 to 126,
  )
  val sizes2x2 = ladder(
    110 to 110, 130 to 130, 150 to 150, 160 to 160, 170 to 170,
    180 to 180, 200 to 200, 220 to 220,
    140 to 165, 155 to 180, 175 to 205, 193 to 225,
  )
  val sizes3x1 = ladder(
    180 to 60, 200 to 70, 220 to 75, 250 to 80, 280 to 90, 320 to 100, 360 to 110,
  )
  /**
   * The net worth chart is a bitmap drawn for one of these sizes, so the
   * ladder covers both box shapes pickers use for a 3x2 widget: wide (Pixel)
   * and close to square (One UI). Without the squarer rungs One UI picks a
   * short size and the chart ends up as a thin strip under a large gap.
   */
  val sizesNetWorth = ladder(
    180 to 110, 215 to 130, 250 to 150, 280 to 170, 320 to 190, 360 to 215,
    150 to 110, 175 to 130, 200 to 150, 230 to 170, 260 to 190, 290 to 215,
    320 to 240,
  )
  val sizes4x2 = ladder(
    250 to 110, 280 to 130, 300 to 140, 320 to 160, 360 to 180, 400 to 200,
  )

  private val receivers: List<KClass<out GlanceAppWidgetReceiver>> = listOf(
    TwoEntryReceiver::class,
    TwoEntryLastReceiver::class,
    FourEntryReceiver::class,
    SummaryReceiver::class,
    NetWorthReceiver::class,
    BudgetPinnedReceiver::class,
    BudgetRollupReceiver::class,
  )

  /**
   * Publishes the previews once per install/update. The platform rate-limits
   * `setWidgetPreview` (a couple of calls per hour), so success is tracked per
   * receiver: a rate-limited run retries only the missing ones on a later
   * launch instead of spending the budget on previews that are already set.
   */
  fun publishIfNeeded(context: Context) {
    if (Build.VERSION.SDK_INT < 35) return
    if (!inFlight.compareAndSet(false, true)) return

    val app = context.applicationContext
    // Runs on every launch, so the package lookup and the prefs/JSON reads stay
    // off the main thread. Any failure only means no generated previews.
    CoroutineScope(Dispatchers.IO).launch {
      try {
        publish(app)
      } catch (e: Exception) {
        Log.w(TAG, "publishing widget previews failed", e)
      } finally {
        inFlight.set(false)
      }
    }
  }

  private suspend fun publish(app: Context) {
    // lastUpdateTime, not versionCode: a reinstall of the same version
    // (debug builds, sideloads) also wipes the published previews.
    val installed = app.packageManager.getPackageInfo(app.packageName, 0).lastUpdateTime
    // Previews bake in the app's language and button order, so a change to
    // either (synced by Dart after launch) republishes on the next launch.
    val version = installed * 31 + contentSignature(app)
    val store = app.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
    val done = if (store.getLong(KEY_PUBLISHED_VERSION, -1L) == version) {
      store.getStringSet(KEY_PUBLISHED_RECEIVERS, emptySet()).orEmpty()
    } else {
      emptySet()
    }
    val pending = receivers.filter { it.qualifiedName !in done }
    if (pending.isEmpty()) return

    val manager = GlanceAppWidgetManager(app)
    val published = done.toMutableSet()
    for (receiver in pending) {
      val result = try {
        manager.setWidgetPreviews(receiver)
      } catch (e: Exception) {
        Log.w(TAG, "setWidgetPreviews(${receiver.simpleName}) failed", e)
        continue
      }
      if (result == GlanceAppWidgetManager.SET_WIDGET_PREVIEWS_RESULT_SUCCESS) {
        receiver.qualifiedName?.let { published += it }
      } else {
        // Rate limited: the rest would fail too; try again next launch.
        Log.w(TAG, "setWidgetPreviews(${receiver.simpleName}) -> $result")
        break
      }
    }
    store.edit()
      .putLong(KEY_PUBLISHED_VERSION, version)
      .putStringSet(KEY_PUBLISHED_RECEIVERS, published)
      .apply()
  }

  private fun contentSignature(context: Context): Long {
    val r = real(context)
    val keys = listOf(
      "summaryIncomeLabel", "summaryExpenseLabel", "netWorthLabel",
      "netWorthRangeLabel", "buttonOrder",
    )
    val parts = keys.map { r?.getString(it, null) ?: "" }.toMutableList()
    // Only words that don't change with the data: the budget "over"/"nearing"
    // labels carry counts, and amounts change all the time — keying on them
    // would republish (and hit the rate limit) on every transaction.
    parts += try {
      r?.getString(BudgetPayload.PAYLOAD_KEY, null)?.let { raw ->
        JSONObject(raw).optJSONObject("labels")?.let {
          it.optString("title") + "|" + it.optString("onTrack")
        }
      } ?: ""
    } catch (e: Exception) {
      ""
    }
    parts += context.resources.configuration.locales.toLanguageTags()
    return parts.joinToString("\u0000").hashCode().toLong()
  }

  // ---- sample state -------------------------------------------------------
  //
  // Amounts are always samples: the picker is visible to anyone holding the
  // phone. Everything else — labels in the app's language, the currency format,
  // the user's button order — comes from what the app last synced, so the
  // preview reads like the widget the user will actually get.

  private fun real(context: Context): SharedPreferences? = try {
    HomeWidgetPlugin.getData(context)
  } catch (e: Exception) {
    null
  }

  private fun separators(r: SharedPreferences?): Pair<String, Char>? {
    val decimal = r?.getString("numberDecimalSeparator", null) ?: return null
    val group = r.getString("numberGroupSeparator", null)?.firstOrNull() ?: return null
    return decimal to group
  }

  fun buttonsState(context: Context): HomeWidgetGlanceState =
    state(mapOf("buttonOrder" to real(context)?.getString("buttonOrder", null)))

  fun summaryState(context: Context): HomeWidgetGlanceState {
    val r = real(context)
    return state(
      mapOf(
        "summaryIncome" to SampleMoney.like(
          r?.getString("summaryIncome", null), 4250.00, separators = separators(r),
        ),
        "summaryExpense" to SampleMoney.like(
          r?.getString("summaryExpense", null), 2870.40, separators = separators(r),
        ),
        "summaryIncomeLabel" to (r?.getString("summaryIncomeLabel", null)
          ?: context.getString(R.string.widget_preview_income)),
        "summaryExpenseLabel" to (r?.getString("summaryExpenseLabel", null)
          ?: context.getString(R.string.widget_preview_expense)),
      )
    )
  }

  fun netWorthState(context: Context): HomeWidgetGlanceState {
    val r = real(context)
    val template = r?.getString("netWorthAmount", null)
    // A plausible month: small dips, overall +6 120.
    val samples = listOf(
      37467.0, 37520.0, 37610.0, 37580.0, 37720.0, 37890.0, 38020.0, 37950.0,
      38310.0, 38640.0, 38590.0, 38900.0, 39250.0, 39180.0, 39420.0, 39860.0,
      40110.0, 39980.0, 40400.0, 40920.0, 41150.0, 41060.0, 41520.0, 41880.0,
      42210.0, 42530.0, 42460.0, 42950.0, 43300.0, 43587.01,
    )
    return state(
      mapOf(
        "netWorthLabel" to (r?.getString("netWorthLabel", null)
          ?: context.getString(R.string.widget_preview_net_worth)),
        "netWorthAmount" to SampleMoney.like(template, 43587.01, separators = separators(r)),
        "netWorthDelta" to "+" + SampleMoney.like(template, 6120.00, separators = separators(r)),
        "netWorthDeltaPositive" to true,
        "netWorthRangeLabel" to (r?.getString("netWorthRangeLabel", null)
          ?: context.getString(R.string.widget_preview_last_30_days)),
        "netWorthSamples" to samples.joinToString(","),
      )
    )
  }

  fun budgetsState(context: Context): HomeWidgetGlanceState {
    // Reuse the synced labels (title, "on track", …) and the amount format of
    // a real budget when there is one.
    val realPayload = try {
      real(context)?.getString(BudgetPayload.PAYLOAD_KEY, null)?.let { JSONObject(it) }
    } catch (e: Exception) {
      null
    }
    val realLabels = realPayload?.optJSONObject("labels")
    // No budgets yet → borrow the currency format from the summary amounts.
    val template = realPayload?.optJSONArray("budgets")?.optJSONObject(0)?.optString("limit", null)
      ?: real(context)?.getString("summaryIncome", null)

    val separators = separators(real(context))
    fun amount(v: Double) = SampleMoney.like(template, v, decimals = 0, separators = separators)

    fun budget(
      id: Long, name: String, spent: Double, limit: Double, status: String, daysLeft: Int,
    ): JSONObject {
      val ratio = spent / limit
      return JSONObject()
        .put("uuid", "preview-$id")
        .put("id", id)
        .put("name", name)
        .put("spent", amount(spent))
        .put("limit", amount(limit))
        .apply { if (spent <= limit) put("remaining", amount(limit - spent)) }
        .apply { if (spent > limit) put("overBy", amount(spent - limit)) }
        .put("percent", (ratio * 100).toInt())
        .put("percentLabel", "${(ratio * 100).toInt()}%")
        .put("ratio", ratio)
        .put("confirmedRatio", ratio)
        .put("status", status)
        .put("daysLeft", daysLeft)
        .put("hasMissingData", false)
    }

    val payload = JSONObject()
      .put("version", BudgetPayload.SUPPORTED_VERSION)
      .put(
        "summary",
        JSONObject()
          .put("budgetCount", 3)
          .put("overCount", 1)
          .put("warningCount", 1)
          .put("hasMissingData", false)
          .put("worstId", 1L),
      )
      .put(
        "budgets",
        JSONArray()
          .put(budget(1, context.getString(R.string.widget_preview_budget_eating_out), 410.0, 400.0, "over", 12))
          .put(budget(2, context.getString(R.string.widget_preview_budget_groceries), 620.0, 800.0, "warning", 12))
          .put(budget(3, context.getString(R.string.widget_preview_budget_transport), 95.0, 300.0, "healthy", 12)),
      )
      // Only the words; counts in "over"/"nearing" belong to the real data,
      // so those fall back to the plurals that match the sample counts.
      .put(
        "labels",
        JSONObject().apply {
          // isNull first: optString turns a JSON null into the text "null".
          for (key in listOf("title", "onTrack")) {
            if (realLabels != null && !realLabels.isNull(key)) put(key, realLabels.getString(key))
          }
        },
      )
    return state(mapOf(BudgetPayload.PAYLOAD_KEY to payload.toString()))
  }

  private fun state(values: Map<String, Any?>) =
    HomeWidgetGlanceState(PreviewPrefs(values.filterValues { it != null }))
}

/**
 * Formats a sample amount the way a real synced amount looks: same currency
 * symbol and position, same grouping and decimal separators. "0,00 zł" turns
 * 4250 into "4 250,00 zł"; "$1,234.50" turns it into "$4,250.00".
 */
internal object SampleMoney {
  private val number = Regex("""\d[\d\s\u00A0\u202F.,']*\d|\d""")

  /** The words the app uses for compact amounts, per language: 1e3, 1e6, 1e9. */
  private val scaleWords = listOf(
    listOf("tys.", "mln", "mld"),
    listOf("мян", "сая", "тэрбум"),
    listOf("K", "M", "B"),
  )
  private val scaleWordFamily = mapOf(
    "tys." to 0, "mln" to 0, "mld" to 0,
    "мянга" to 1, "мян" to 1, "мян." to 1, "сая" to 1, "тэрбум" to 1,
    "k" to 2, "K" to 2, "M" to 2, "B" to 2, "bn" to 2,
  )
  private val scaleWord =
    Regex("""^[\s\u00A0\u202F]*(tys\.|mln|mld|мянга|мян\.?|сая|тэрбум|k|K|M|B|bn)(?!\p{L})""")

  // Samples are sized for euro/dollar-like currencies; a ₮400 eating-out
  // budget reads as a bug, so low-value currencies get scaled-up samples.
  private val denominations = mapOf('₮' to 1000.0, '₩' to 1000.0, '₫' to 10000.0)

  /**
   * [separators] are the app locale's decimal and grouping separators, used
   * when [template] has none to copy ("$12", "685 tys. zł").
   */
  fun like(
    template: String?,
    value: Double,
    decimals: Int? = null,
    separators: Pair<String, Char>? = null,
  ): String {
    val m = template?.let { number.find(it) }
    // Keep the currency, drop any sign: samples are positive (the caller adds
    // "+" itself), and a negative template must not turn into "+-6 120".
    val prefix = (m?.let { template.substring(0, it.range.first) } ?: "")
      .replace("-", "").replace("\u2212", "").replace("+", "")
    var suffix = m?.let { template.substring(it.range.last + 1) } ?: ""
    val digits = m?.value ?: "0,00"

    val decMatch = Regex("""([.,])(\d{1,2})$""").find(digits)
    val bare = digits.all { it.isDigit() }
    val decSep = decMatch?.groupValues?.get(1)
      ?: separators?.first?.takeIf { bare }
      ?: ","
    var decCount = decimals ?: decMatch?.groupValues?.get(2)?.length ?: 0
    val group = digits.firstOrNull { !it.isDigit() && (decMatch == null || it.toString() != decSep) }
      ?: when {
        bare && separators != null -> separators.second
        decSep == "," -> ' '
        else -> ','
      }
    val denomination = (prefix + suffix).firstNotNullOfOrNull { denominations[it] } ?: 1.0

    // "25,2 tys. zł": abbreviate the sample the same way, or it is longer than
    // anything the real widget shows and gets ellipsized. The scale follows the
    // sample, not the template ("₮ 685 мян" with a 4.25M sample is "₮ 4,3 сая").
    // Below 1e3 the app writes the plain amount, so drop the word and decimals.
    var shown = value * denomination
    scaleWord.find(suffix)?.let { match ->
      val word = match.groups[1] ?: return@let
      val family = scaleWordFamily[word.value] ?: return@let
      val level = when {
        shown >= 1e9 -> 2
        shown >= 1e6 -> 1
        shown >= 1e3 -> 0
        else -> -1
      }
      if (level >= 0) {
        shown /= Math.pow(1e3, level + 1.0)
        decCount = 1
        suffix = suffix.replaceRange(word.range, scaleWords[family][level])
      } else {
        suffix = suffix.substring(match.range.last + 1)
        decCount = 0
      }
    }

    val fixed = String.format(java.util.Locale.ROOT, "%.${decCount}f", shown)
    val intPart = fixed.substringBefore('.')
    val fracPart = fixed.substringAfter('.', "")
    val grouped = intPart.reversed().chunked(3).joinToString(group.toString()).reversed()
    val body = if (decCount > 0) grouped + decSep + fracPart else grouped
    return prefix + body + suffix
  }
}

/** Read-only, in-memory SharedPreferences holding preview sample data. */
private class PreviewPrefs(private val values: Map<String, Any?>) : SharedPreferences {
  override fun getAll(): Map<String, *> = values
  override fun getString(key: String?, defValue: String?): String? = values[key] as? String ?: defValue
  @Suppress("UNCHECKED_CAST")
  override fun getStringSet(key: String?, defValues: Set<String>?): Set<String>? =
    values[key] as? Set<String> ?: defValues
  override fun getInt(key: String?, defValue: Int): Int = values[key] as? Int ?: defValue
  override fun getLong(key: String?, defValue: Long): Long = values[key] as? Long ?: defValue
  override fun getFloat(key: String?, defValue: Float): Float = values[key] as? Float ?: defValue
  override fun getBoolean(key: String?, defValue: Boolean): Boolean = values[key] as? Boolean ?: defValue
  override fun contains(key: String?): Boolean = values.containsKey(key)
  override fun edit(): SharedPreferences.Editor =
    throw UnsupportedOperationException("preview state is read-only")
  override fun registerOnSharedPreferenceChangeListener(l: SharedPreferences.OnSharedPreferenceChangeListener?) {}
  override fun unregisterOnSharedPreferenceChangeListener(l: SharedPreferences.OnSharedPreferenceChangeListener?) {}
}
