package mn.flow.flow.glance

import HomeWidgetGlanceState
import HomeWidgetGlanceStateDefinition
import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.min
import androidx.core.net.toUri
import androidx.glance.ColorFilter
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
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
import androidx.glance.layout.ContentScale
import androidx.glance.layout.Row
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width
import androidx.glance.preview.ExperimentalGlancePreviewApi
import androidx.glance.preview.Preview
import androidx.glance.state.GlanceStateDefinition
import mn.flow.flow.R
import java.util.Locale.getDefault

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
  val buttonOrder = FlowUtils.getButtonOrder(currentState?.preferences)

  val size = LocalSize.current
  val buttonSize = min((size.width / 2 - 24.dp), (size.height - 16.dp))
  val iconSize = buttonSize * 2 / 3

  Box(
    modifier = GlanceModifier.background(GlanceTheme.colors.widgetBackground).fillMaxSize(),
    contentAlignment = Alignment.Center
  ) {
    Row(
      modifier = GlanceModifier.padding(8.dp),
      verticalAlignment = Alignment.CenterVertically,
    ) {
      buttonOrder.forEachIndexed { index, operation ->
        Box(modifier = GlanceModifier.padding(end = if (index == 0) 8.dp else 0.dp)) {
          Box(
            modifier = GlanceModifier
              .background(GlanceTheme.colors.primary)
              .width(buttonSize)
              .height(buttonSize)
              .cornerRadius(999.dp)
              .clickable(
                onClick = actionStartActivity(
                  Intent(Intent.ACTION_VIEW, "flow-mn:///transaction/new?type=${operation}".toUri()).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                  }
                )
              ),
            contentAlignment = Alignment.Center
          ) {
            Image(
              ImageProvider(if (operation.lowercase(getDefault()) == "expense") R.drawable.expense else R.drawable.income),
              modifier = GlanceModifier.height(iconSize).width(iconSize),
              contentDescription = "New $operation",
              colorFilter = ColorFilter.tint(GlanceTheme.colors.primaryContainer),
              contentScale = ContentScale.Fit
            )
          }
//          CircleIconButton(
//            ImageProvider(if (operation.lowercase(getDefault()) == "expense") R.drawable.expense else R.drawable.income),
//            backgroundColor = GlanceTheme.colors.primary,
//            contentColor = GlanceTheme.colors.widgetBackground,
//            contentDescription = "New $operation",
//            onClick =
//              actionStartActivity(
//                Intent(
//                  Intent.ACTION_VIEW,
//                  "flow-mn:///transaction/new?type=${operation}".toUri()
//                )
//              )
//          )
        }
      }
    }
  }
}
