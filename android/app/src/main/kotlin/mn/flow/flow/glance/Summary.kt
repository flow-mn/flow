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
private fun Content(context: Context, currentState: HomeWidgetGlanceState) {
  val income = currentState.preferences.getString("summaryIncome", null) ?: "---"
  val expense = currentState.preferences.getString("summaryExpense", null) ?: "---"
  val incomeLabel = currentState.preferences.getString("summaryIncomeLabel", null) ?: "Income"
  val expenseLabel = currentState.preferences.getString("summaryExpenseLabel", null) ?: "Expense"

  // Narrow (2-column) cells: less side padding so labels and amounts fit.
  val width = LocalSize.current.width.value
  val narrow = width < 250f
  // Tighter side padding below ~4 columns: a default 3x1 on Pixel is ~300dp,
  // where 16dp insets left "6,86 tys. zł" cut to "6,86 tys. …".
  val sidePad = if (width < 330f) 10 else 16
  // Glance can't measure or auto-size text, so the amount's size is estimated.
  // Measured on device: "6,86 tys. zł" bold averages 0.44em per character;
  // 0.5 leaves margin for wider digits. Shrinks from the design's 20sp until
  // the longer of the two amounts fits its card; both cards use the same size.
  val cardInner = (width - 8 * 3) / 2f - sidePad * 2
  val longest = maxOf(income.length, expense.length, 1)
  // sp grows with the system font size while the card stays the same dp, so
  // the estimate is divided by the font scale; at large scales the floor
  // drops to 11sp rather than cutting the amount off.
  val fontScale = context.resources.configuration.fontScale.coerceAtLeast(0.5f)
  val amountSp = (cardInner / (0.5f * longest * fontScale)).coerceIn(11f, 20f)

  Box(
    modifier = GlanceModifier
      .background(GlanceTheme.colors.widgetBackground)
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
      // Cards take the full height, so the panel shows the same 8dp margin on
      // every side whatever cell height the launcher gives (Pixel's 1-row cell
      // is taller than the cards; One UI's is about the same).
      modifier = GlanceModifier.padding(8.dp).fillMaxSize(),
      verticalAlignment = Alignment.CenterVertically,
    ) {
      Box(modifier = GlanceModifier.defaultWeight().fillMaxHeight()) {
        SummaryCard(
          label = incomeLabel,
          iconRes = R.drawable.ic_arrow_down_forward,
          amount = income,
          accentColor = ColorProvider(R.color.income_green),
          narrow = narrow,
          sidePad = sidePad,
          amountSp = amountSp,
        )
      }
      Spacer(modifier = GlanceModifier.width(8.dp))
      Box(modifier = GlanceModifier.defaultWeight().fillMaxHeight()) {
        SummaryCard(
          label = expenseLabel,
          iconRes = R.drawable.ic_arrow_up_forward,
          amount = expense,
          accentColor = ColorProvider(R.color.expense_red),
          narrow = narrow,
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
  narrow: Boolean = false,
  sidePad: Int = 16,
  amountSp: Float = 20f,
) {
  Box(
    modifier = GlanceModifier
      .fillMaxSize()
      .background(GlanceTheme.colors.surfaceVariant)
      .cornerRadius(16.dp)
      .padding(horizontal = sidePad.dp, vertical = 12.dp),
    contentAlignment = Alignment.CenterStart,
  ) {
    Column {
      Row(verticalAlignment = Alignment.CenterVertically) {
        Text(
          text = label,
          style = TextStyle(
            color = GlanceTheme.colors.onSurfaceVariant,
            fontSize = 13.sp,
          ),
          // One line: a wrapped label ("Przychó/d") made the two cards
          // different heights in narrow cells.
          maxLines = 1,
        )
        // In a 2-column cell the icon gets squeezed to a sliver; drop it.
        if (!narrow) {
          Spacer(modifier = GlanceModifier.width(4.dp))
          Image(
            provider = ImageProvider(iconRes),
            contentDescription = null,
            modifier = GlanceModifier.width(20.dp).height(20.dp),
            colorFilter = ColorFilter.tint(accentColor),
          )
        }
      }
      Spacer(modifier = GlanceModifier.height(4.dp))
      Text(
        text = amount,
        style = TextStyle(
          color = GlanceTheme.colors.onSurface,
          fontSize = amountSp.sp,
          fontWeight = FontWeight.Bold,
        ),
        maxLines = 1,
      )
    }
  }
}
