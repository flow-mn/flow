package mn.flow.flow.glance

import es.antonborri.home_widget.HomeWidgetGlanceState
import es.antonborri.home_widget.HomeWidgetGlanceStateDefinition
import android.content.Context
import android.content.Intent
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.LocalSize
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.preview.ExperimentalGlancePreviewApi
import androidx.glance.preview.Preview
import androidx.glance.state.GlanceStateDefinition
import androidx.glance.ColorFilter
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import androidx.glance.unit.ColorProvider
import mn.flow.flow.MainActivity
import mn.flow.flow.R

class Summary : GlanceAppWidget() {
  override val sizeMode = SizeMode.Exact

  // Picker preview (Android 15+): the real content on sample data.
  override val previewSizeMode = SizeMode.Responsive(WidgetPreviews.sizes3x1)

  override suspend fun providePreview(context: Context, widgetCategory: Int) {
    provideContent {
      GlanceTheme {
        Content(context, WidgetPreviews.summaryState(context), preview = true)
      }
    }
  }

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

@OptIn(ExperimentalGlancePreviewApi::class)
@Composable
@Preview(widthDp = 200, heightDp = 100)
private fun Content(context: Context, currentState: HomeWidgetGlanceState, preview: Boolean = false) {
  val income = currentState.preferences.getString("summaryIncome", null) ?: "---"
  val expense = currentState.preferences.getString("summaryExpense", null) ?: "---"
  val incomeLabel = currentState.preferences.getString("summaryIncomeLabel", null) ?: "Income"
  val expenseLabel = currentState.preferences.getString("summaryExpenseLabel", null) ?: "Expense"

  // Launchers pick the picker's box size (One UI's is shorter than the ~92dp
  // this layout needs), so the preview draws a scaled copy.
  val scale = if (preview) minOf(1f, LocalSize.current.height.value / 92f) else 1f
  val panel = if (preview) {
    GlanceModifier
      .fillMaxWidth()
      .background(GlanceTheme.colors.widgetBackground)
      .cornerRadius(((16 + 8) * scale).dp)
      .padding((8 * scale).dp)
  } else {
    GlanceModifier.padding(8.dp).fillMaxSize()
  }
  // Cards fill the cell so the 8dp margin is even on every side.
  val fill = !preview
  // Judged at real scale: the scaled-down preview isn't a 2-column widget.
  val width = LocalSize.current.width.value / scale
  // 2-column cells drop the icon to leave room for the label.
  val narrow = width < 250f
  // A default 3x1 on Pixel (~300dp) cut "6,86 tys. zł" with 16dp insets.
  val sidePad = if (width < 330f) 10 else 16
  // Glance can't measure text, so the amount's size is estimated: bold digits
  // average ~0.44em on device, 0.5 leaves margin. Divided by the font scale
  // because sp grows with it while the card doesn't. Below the 11sp floor
  // (2 columns at large font sizes) the amount still ellipsizes.
  val cardInner = (width - 8 * 3) / 2f - sidePad * 2
  val longest = maxOf(income.length, expense.length, 1)
  val fontScale = context.resources.configuration.fontScale.coerceAtLeast(0.5f)
  val amountSp = (cardInner / (0.5f * longest * fontScale)).coerceIn(11f, 20f)

  Box(
    modifier = (if (preview) GlanceModifier else GlanceModifier.background(GlanceTheme.colors.widgetBackground))
      .fillMaxSize()
      .clickable(
        onClick = actionStartActivity(
          Intent(context, MainActivity::class.java).apply {
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
          }
        )
      ),
    contentAlignment = Alignment.Center
  ) {
    Row(
      modifier = panel,
      verticalAlignment = Alignment.CenterVertically,
    ) {
      Box(modifier = if (fill) GlanceModifier.defaultWeight().fillMaxHeight() else GlanceModifier.defaultWeight()) {
        SummaryCard(
          label = incomeLabel,
          iconRes = R.drawable.ic_arrow_down_forward,
          amount = income,
          accentColor = ColorProvider(R.color.income_green),
          scale = scale,
          narrow = narrow,
          fill = fill,
          sidePad = sidePad,
          amountSp = amountSp,
        )
      }
      Spacer(modifier = GlanceModifier.width((8 * scale).dp))
      Box(modifier = if (fill) GlanceModifier.defaultWeight().fillMaxHeight() else GlanceModifier.defaultWeight()) {
        SummaryCard(
          label = expenseLabel,
          iconRes = R.drawable.ic_arrow_up_forward,
          amount = expense,
          accentColor = ColorProvider(R.color.expense_red),
          scale = scale,
          narrow = narrow,
          fill = fill,
          sidePad = sidePad,
          amountSp = amountSp,
        )
      }
    }
  }
}

@Composable
private fun SummaryCard(
  label: String,
  iconRes: Int,
  amount: String,
  accentColor: ColorProvider,
  scale: Float,
  narrow: Boolean,
  fill: Boolean,
  sidePad: Int,
  amountSp: Float,
) {
  Box(
    modifier = GlanceModifier
      .then(if (fill) GlanceModifier.fillMaxSize() else GlanceModifier.fillMaxWidth())
      .background(GlanceTheme.colors.surfaceVariant)
      .cornerRadius((16 * scale).dp)
      .padding(horizontal = (sidePad * scale).dp, vertical = (12 * scale).dp),
    contentAlignment = Alignment.CenterStart,
  ) {
    Column {
      Row(verticalAlignment = Alignment.CenterVertically) {
        Text(
          text = label,
          style = TextStyle(
            color = GlanceTheme.colors.onSurfaceVariant,
            fontSize = (13 * scale).sp,
          ),
          // A wrapped label made the two cards different heights.
          maxLines = 1,
        )
        if (!narrow) {
          Spacer(modifier = GlanceModifier.width((4 * scale).dp))
          Image(
            provider = ImageProvider(iconRes),
            contentDescription = null,
            modifier = GlanceModifier.width((20 * scale).dp).height((20 * scale).dp),
            colorFilter = ColorFilter.tint(accentColor),
          )
        }
      }
      Spacer(modifier = GlanceModifier.height((4 * scale).dp))
      Text(
        text = amount,
        style = TextStyle(
          color = GlanceTheme.colors.onSurface,
          fontSize = (amountSp * scale).sp,
          fontWeight = FontWeight.Bold,
        ),
        maxLines = 1,
      )
    }
  }
}
