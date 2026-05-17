package mn.flow.flow.glance

import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.lazy.LazyColumn
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import mn.flow.flow.MainActivity
import mn.flow.flow.R

class YnabBudget : GlanceAppWidget() {
    override val sizeMode = SizeMode.Exact

    override val stateDefinition: GlanceStateDefinition<*>
        get() = HomeWidgetGlanceStateDefinition()

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        provideContent {
            GlanceTheme {
                Content(context, currentState())
            }
        }
    }
}

private data class CategoryRow(
    val name: String,
    val spentRaw: Double,
    val spentDisplay: String,
    val rawDisplay: String
)

/**
 * Parsed theme colors from Flutter's FlowColorScheme, bridged via SharedPreferences.
 * Used by the Flow-style widget to match the app's selected theme.
 */
private data class ThemeColors(
    val surface: Color,
    val onSurface: Color,
    val primary: Color,
    val secondary: Color,
    val onSecondary: Color,
    val income: Color,
    val expense: Color,
    val semi: Color,
    val isDark: Boolean,
)

/** Parse a single color from SharedPreferences, with a hex fallback. */
private fun parseColor(prefs: HomeWidgetGlanceState, key: String, fallback: Long): Color {
    val raw = prefs.preferences.getString(key, null)?.toLongOrNull() ?: fallback
    // Dart Color.value is a 32-bit ARGB int; Compose Color() expects the same
    return Color(raw.toInt())
}

/** Read all theme colors from SharedPreferences bridged by Flutter. */
private fun readThemeColors(prefs: HomeWidgetGlanceState): ThemeColors {
    val isDarkStr = prefs.preferences.getString("theme_isDark", null) ?: "true"
    return ThemeColors(
        surface     = parseColor(prefs, "theme_surface",     0xFFF5F6FA),
        onSurface   = parseColor(prefs, "theme_onSurface",   0xFF111111),
        primary     = parseColor(prefs, "theme_primary",     0xFF8600A5),
        secondary   = parseColor(prefs, "theme_secondary",   0xFFF5CCFF),
        onSecondary = parseColor(prefs, "theme_onSecondary", 0xFF33004F),
        income      = parseColor(prefs, "theme_income",      0xFF32CC70),
        expense     = parseColor(prefs, "theme_expense",     0xFFFF4040),
        semi        = parseColor(prefs, "theme_semi",        0xFF6A666D),
        isDark      = isDarkStr == "true",
    )
}

@Composable
private fun Content(context: Context, currentState: HomeWidgetGlanceState) {
    val countStr = currentState.preferences.getString("ynab_count", null) ?: "0"
    val count = countStr.toIntOrNull() ?: 0
    val style = currentState.preferences.getString("ynab_style", null) ?: "flow"

    val categories = (0 until count).mapNotNull { i ->
        val name = currentState.preferences.getString("ynab_${i}_name", null) ?: return@mapNotNull null
        val spentStr = currentState.preferences.getString("ynab_${i}_spent", null) ?: "0.00"
        val display = currentState.preferences.getString("ynab_${i}_display", null) ?: spentStr
        val rawDisplay = currentState.preferences.getString("ynab_${i}_raw_display", null) ?: spentStr
        CategoryRow(name, spentStr.toDoubleOrNull() ?: 0.0, display, rawDisplay)
    }

    // Tap action: open app to add a new expense transaction
    val launchIntent = Intent(context, MainActivity::class.java).apply {
        action = Intent.ACTION_VIEW
        data = Uri.parse("flow-mn:///transaction/new?type=expense")
        addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
    }

    when (style) {
        "amoled" -> AmoledContent(context, categories, launchIntent)
        else -> FlowContent(context, categories, launchIntent, currentState)
    }
}

// =============================================================================
// Shared: Amount Pill Badge — colored rounded rectangle with contrast text
// =============================================================================

@Composable
private fun AmountPill(
    amount: String,
    spentRaw: Double,
    isAmoled: Boolean,
    themeColors: ThemeColors? = null,
) {
    // Pill background color
    val pillBg: ColorProvider
    val textColor: ColorProvider

    if (isAmoled) {
        // AMOLED: hardcoded YNAB colors (unchanged)
        pillBg = when {
            spentRaw < -0.001 -> ColorProvider(R.color.expense_red)
            spentRaw > 0.001 -> ColorProvider(R.color.income_green)
            else -> ColorProvider(R.color.ynab_pill_zero)
        }
        textColor = when {
            spentRaw < -0.001 -> ColorProvider(Color.White)
            spentRaw > 0.001 -> ColorProvider(Color(0xFF1A1A1A))
            else -> ColorProvider(Color.White)
        }
    } else if (themeColors != null) {
        // Flow: theme-aware colors from the app
        pillBg = when {
            spentRaw < -0.001 -> ColorProvider(themeColors.expense)
            spentRaw > 0.001 -> ColorProvider(themeColors.income)
            else -> ColorProvider(themeColors.semi)
        }
        // Contrast: dark text on light pills, light text on dark pills
        textColor = when {
            spentRaw < -0.001 -> ColorProvider(if (themeColors.isDark) Color.White else Color(0xFF1A1A1A))
            spentRaw > 0.001 -> ColorProvider(Color(0xFF1A1A1A)) // income green is always light
            else -> ColorProvider(if (themeColors.isDark) Color.White else Color(0xFF1A1A1A))
        }
    } else {
        // Fallback: GlanceTheme (Material You)
        pillBg = when {
            spentRaw < -0.001 -> ColorProvider(R.color.expense_red)
            spentRaw > 0.001 -> ColorProvider(R.color.income_green)
            else -> GlanceTheme.colors.surfaceVariant
        }
        textColor = when {
            spentRaw < -0.001 -> ColorProvider(Color.White)
            spentRaw > 0.001 -> ColorProvider(Color.White)
            else -> GlanceTheme.colors.onSurfaceVariant
        }
    }

    Box(
        modifier = GlanceModifier
            .background(pillBg)
            .cornerRadius(if (isAmoled) 16.dp else 12.dp)
            .padding(horizontal = 6.dp, vertical = 2.dp),
        contentAlignment = Alignment.Center,
    ) {
        Text(
            text = amount,
            style = TextStyle(
                color = textColor,
                fontSize = if (isAmoled) 15.sp else 14.sp,
                fontWeight = FontWeight.Bold,
            ),
            maxLines = 1,
        )
    }
}

// =============================================================================
// YNAB AMOLED Style — Pure black, flat rows, thin dividers, pill badges
// =============================================================================

@Composable
private fun AmoledContent(
    context: Context,
    categories: List<CategoryRow>,
    launchIntent: Intent
) {
    if (categories.isEmpty()) {
        // Empty state: full background with centered message
        Box(
            modifier = GlanceModifier
                .background(ColorProvider(R.color.ynab_background))
                .fillMaxSize()
                .clickable(onClick = actionStartActivity(launchIntent)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "No categories yet",
                style = TextStyle(
                    color = ColorProvider(R.color.ynab_zero_gray),
                    fontSize = 14.sp,
                ),
            )
        }
    } else {
        // Any non-empty list → LazyColumn as ROOT for proper scrolling
        // Each items{} block emits a SINGLE root Column to avoid Glance auto-Box wrapping
        LazyColumn(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(ColorProvider(R.color.ynab_background))
        ) {
            items(categories.size) { index ->
                val category = categories[index]
                Column(modifier = GlanceModifier.fillMaxWidth()) {
                    AmoledCategoryRow(category, launchIntent)
                    if (index < categories.lastIndex) {
                        Row(
                            modifier = GlanceModifier
                                .fillMaxWidth()
                                .padding(start = 14.dp, end = 8.dp)
                        ) {
                            Spacer(
                                modifier = GlanceModifier
                                    .fillMaxWidth()
                                    .height(1.dp)
                                    .background(ColorProvider(R.color.ynab_divider))
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun AmoledCategoryRow(category: CategoryRow, launchIntent: Intent) {
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .clickable(onClick = actionStartActivity(launchIntent))
            .padding(start = 14.dp, end = 8.dp, top = 10.dp, bottom = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // Category name (left) — light gray, truncates with ellipsis
        Text(
            text = category.name,
            style = TextStyle(
                color = ColorProvider(R.color.ynab_text_primary),
                fontSize = 16.sp,
                fontWeight = FontWeight.Medium,
            ),
            maxLines = 1,
            modifier = GlanceModifier.defaultWeight(),
        )

        Spacer(modifier = GlanceModifier.width(8.dp))

        // Amount pill — colored rounded rectangle
        AmountPill(
            amount = category.rawDisplay,
            spentRaw = category.spentRaw,
            isAmoled = true,
        )
    }
}

// =============================================================================
// Flow Style — Theme-aware colors from the app, flat rows, dividers, pill badges
// =============================================================================

@Composable
private fun FlowContent(
    context: Context,
    categories: List<CategoryRow>,
    launchIntent: Intent,
    currentState: HomeWidgetGlanceState
) {
    // Read theme colors bridged from Flutter
    val theme = readThemeColors(currentState)
    val surfaceBg = ColorProvider(theme.surface)
    // Divider: semi color at reduced opacity (blend with surface)
    val dividerColor = Color(
        red = theme.semi.red * 0.3f + theme.surface.red * 0.7f,
        green = theme.semi.green * 0.3f + theme.surface.green * 0.7f,
        blue = theme.semi.blue * 0.3f + theme.surface.blue * 0.7f,
        alpha = 1f,
    )

    if (categories.isEmpty()) {
        // Empty state
        Box(
            modifier = GlanceModifier
                .background(surfaceBg)
                .fillMaxSize()
                .clickable(onClick = actionStartActivity(launchIntent)),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = "No categories yet",
                style = TextStyle(
                    color = ColorProvider(theme.semi),
                    fontSize = 14.sp,
                ),
            )
        }
    } else {
        // Any non-empty list → LazyColumn as ROOT for proper scrolling
        // Each items{} block emits a SINGLE root Column to avoid Glance auto-Box wrapping
        LazyColumn(
            modifier = GlanceModifier
                .fillMaxSize()
                .background(surfaceBg)
        ) {
            items(categories.size) { index ->
                val category = categories[index]
                Column(modifier = GlanceModifier.fillMaxWidth()) {
                    FlowCategoryRow(category, launchIntent, theme)
                    if (index < categories.lastIndex) {
                        Row(
                            modifier = GlanceModifier
                                .fillMaxWidth()
                                .padding(start = 12.dp, end = 8.dp)
                        ) {
                            Spacer(
                                modifier = GlanceModifier
                                    .fillMaxWidth()
                                    .height(1.dp)
                                    .background(ColorProvider(dividerColor))
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun FlowCategoryRow(
    category: CategoryRow,
    launchIntent: Intent,
    theme: ThemeColors
) {
    Row(
        modifier = GlanceModifier
            .fillMaxWidth()
            .clickable(onClick = actionStartActivity(launchIntent))
            .padding(start = 12.dp, end = 8.dp, top = 10.dp, bottom = 10.dp),
        verticalAlignment = Alignment.CenterVertically,
    ) {
        // Category name (left) — uses theme onSurface color
        Text(
            text = category.name,
            style = TextStyle(
                color = ColorProvider(theme.onSurface),
                fontSize = 15.sp,
                fontWeight = FontWeight.Medium,
            ),
            maxLines = 1,
            modifier = GlanceModifier.defaultWeight(),
        )

        Spacer(modifier = GlanceModifier.width(8.dp))

        // Amount pill — theme-aware colors, no currency (rawDisplay)
        AmountPill(
            amount = category.rawDisplay,
            spentRaw = category.spentRaw,
            isAmoled = false,
            themeColors = theme,
        )
    }
}
