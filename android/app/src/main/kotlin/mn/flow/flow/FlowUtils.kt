package mn.flow.flow.glance

abstract class FlowUtils {
  companion object {
    val defaultButtonOrder = listOf(
      "eny",
      "transfer",
      "income",
      "expense",
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
  }
}
