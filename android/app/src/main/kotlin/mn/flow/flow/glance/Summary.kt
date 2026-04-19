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
      modifier = GlanceModifier.padding(8.dp).fillMaxSize(),
      verticalAlignment = Alignment.CenterVertically,
    ) {
      Box(modifier = GlanceModifier.defaultWeight()) {
        SummaryCard(
          label = incomeLabel,
          iconRes = R.drawable.ic_arrow_down_forward,
          amount = income,
          accentColor = ColorProvider(R.color.income_green),
        )
      }
      Spacer(modifier = GlanceModifier.width(8.dp))
      Box(modifier = GlanceModifier.defaultWeight()) {
        SummaryCard(
          label = expenseLabel,
          iconRes = R.drawable.ic_arrow_up_forward,
          amount = expense,
          accentColor = ColorProvider(R.color.expense_red),
        )
      }
    }
  }
}

@Composable
private fun SummaryCard(label: String, iconRes: Int, amount: String, accentColor: ColorProvider) {
  Box(
    modifier = GlanceModifier
      .fillMaxWidth()
      .background(GlanceTheme.colors.surfaceVariant)
      .cornerRadius(16.dp)
      .padding(horizontal = 16.dp, vertical = 12.dp),
  ) {
    Column {
      Row(verticalAlignment = Alignment.CenterVertically) {
        Text(
          text = label,
          style = TextStyle(
            color = GlanceTheme.colors.onSurfaceVariant,
            fontSize = 13.sp,
          ),
        )
        Spacer(modifier = GlanceModifier.width(4.dp))
        Image(
          provider = ImageProvider(iconRes),
          contentDescription = null,
          modifier = GlanceModifier.width(20.dp).height(20.dp),
          colorFilter = ColorFilter.tint(accentColor),
        )
      }
      Spacer(modifier = GlanceModifier.height(4.dp))
      Text(
        text = amount,
        style = TextStyle(
          color = GlanceTheme.colors.onSurface,
          fontSize = 20.sp,
          fontWeight = FontWeight.Bold,
        ),
        maxLines = 1,
      )
    }
  }
}
