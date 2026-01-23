package mn.flow.flow.glance

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.min
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.LocalSize
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.currentState
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Row
import androidx.glance.layout.Column
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.padding
import androidx.glance.preview.ExperimentalGlancePreviewApi
import androidx.glance.preview.Preview
import androidx.glance.state.GlanceStateDefinition
import mn.flow.flow.FlowWidgetUtils

class FourEntry : GlanceAppWidget() {
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
@Preview(widthDp = 100, heightDp = 50)
private fun Content(context: Context, currentState: HomeWidgetGlanceState) {
  val buttonOrder = FlowWidgetUtils.getButtonOrder(currentState.preferences)

  val size = LocalSize.current
  val buttonSize = min((size.width / 2 - 24.dp), (size.height - 16.dp))

  val firstRowItemCount = if(buttonOrder.size > 3) 2 else 1

  val firstRow = buttonOrder.subList(0, firstRowItemCount)
  val secondRow = buttonOrder.subList(firstRowItemCount, buttonOrder.size)

  Box(
    modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground).fillMaxSize(),
    contentAlignment = Alignment.Center
  ) {
    Column() {
      Row(
        modifier = GlanceModifier.padding(8.dp, bottom = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
      ) {
        firstRow.forEachIndexed { index, operation ->
          FlowWidgetUtils.EntryButton(context, operation = operation, size = size, buttonSize = buttonSize, padEnd = index == 0 && firstRow.size > 1, pill = firstRow.size == 1)
        }
      }
      Row(
        modifier = GlanceModifier.padding(8.dp, top = 4.dp),
        verticalAlignment = Alignment.CenterVertically,
      ) {
        secondRow.forEachIndexed { index, operation ->
          FlowWidgetUtils.EntryButton(context, operation = operation, size = size, buttonSize = buttonSize, padEnd = index == 0)
        }
      }
    }
  }
}
