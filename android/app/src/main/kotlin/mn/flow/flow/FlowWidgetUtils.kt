package mn.flow.flow

import android.content.Context
import android.content.Intent
import android.content.SharedPreferences
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.core.net.toUri
import androidx.glance.ColorFilter
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.action.clickable
import androidx.glance.appwidget.action.actionStartActivity
import androidx.glance.appwidget.cornerRadius
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.ContentScale
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.width

abstract class FlowWidgetUtils {
  companion object {
    val defaultButtonOrder = listOf(
      "eny",
      "transfer",
      "income",
      "expense",
    )

    val imageMapping = mapOf(
      "eny" to R.drawable.camera,
      "transfer" to  R.drawable.transfer,
      "income" to R.drawable.income,
      "expense" to R.drawable.expense,
    )

    fun getButtonOrder(prefs: SharedPreferences?): List<String> {
      var buttonOrder =
        prefs?.getString("buttonOrder", null)?.split(",")
          ?: defaultButtonOrder

      if (buttonOrder.size < 2) {
        buttonOrder = defaultButtonOrder
      }

      return buttonOrder
    }


    @Composable
    fun EntryButton(context: Context, operation: String, size: DpSize, buttonSize: Dp, padEnd: Boolean, pill: Boolean = false) {
      val iconSize = buttonSize * 2 / 3
      val buttonWidth = if (pill) (buttonSize * 2 + 8.dp) else buttonSize

      Box(modifier = GlanceModifier.padding(end = if(padEnd) 8.dp else 0.dp)) {
        Box(
          modifier = GlanceModifier
            .background(GlanceTheme.colors.primary)
            .width(buttonWidth)
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
            ImageProvider(FlowWidgetUtils.imageMapping[operation.lowercase()] ?: R.drawable.flow),
            modifier = GlanceModifier.height(iconSize).width(iconSize),
            contentDescription = if (operation.lowercase() == "eny") "Scan receipt with Eny" else "New $operation",
            colorFilter = ColorFilter.tint(GlanceTheme.colors.primaryContainer),
            contentScale = ContentScale.Fit
          )
        }
      }
    }
  }
}
